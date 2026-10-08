--- Client-side hooks of the Combine Technology Overlay plugin, which draw the Combine HUD overlay: the biosignal
-- markers of other units, requests for assistance, Combine cameras with the movement violations they see, and the
-- socio-status and objectives at the top of the screen.
--
-- `cwCTO:UpdateBiosignalLocations` keeps the marker tables current, and `cwCTO:HUDPaintForeground` and
-- `cwCTO:HUDPaintTopScreen` draw them for Combine players. The data arrives from the server through the
-- `CombineRequestSignal`, `UpdateBiosignalCameraData` and `RecalculateHUDObjectives` Cable messages; the camera text is
-- built once per update and kept in `cwCTO.cameraInfo`.

local cwCTO = cwCTO

cwCTO.biosignalLocations = {}
cwCTO.requestLocations = {}

cwCTO.cameraData = cwCTO.cameraData or {}
cwCTO.cameraInfo = cwCTO.cameraInfo or {}
cwCTO.hudObjectives = cwCTO.hudObjectives or {}
cwCTO.socioStatus = cwCTO.socioStatus or 'GREEN'

local colorRed = Color(255, 0, 0, 255)
local colorObject = Color(150, 150, 200, 255)
local colorRequest = Color(175, 125, 100, 255)
-- Reused every frame; only their channels change.
local colorSocio = Color(255, 255, 255, 255)
local colorObjective = Color(255, 255, 255, 255)

local headOffset = Vector(0, 0, 16)
local feetOffset = Vector(0, 0, 80)

local lowDetailText = '<...>'
local violationRunning = '<:: 1 x #CTO_HUD_Violation_Running ::>'
local violationJumping = '<:: 1 x #CTO_HUD_Violation_Jumping ::>'
local violationCrouching = '<:: 1 x #CTO_HUD_Violation_Crouching ::>'
local violationFallenOver = '<:: 1 x #CTO_HUD_Violation_FallenOver ::>'

--- Returns where a player's HUD marker goes: above their head bone, or above their feet without one.
-- @param player [Player The player]
-- @return [Vector The marker position]
local function GetMarkerPosition(player)
  local physBone = player:LookupBone('ValveBiped.Bip01_Head1')
  local bonePosition = physBone and player:GetBonePosition(physBone)

  if bonePosition then
    return bonePosition + headOffset
  end

  return player:GetPos() + feetOffset
end

--- Formats a number of seconds with two decimals.
-- @param seconds [Number The seconds]
-- @return [String The text, such as `'12.50'`]
local function FormatSeconds(seconds)
  return string.format('%.2f', seconds)
end

--- Updates the biosignal markers shown on the local player's HUD.
--
-- Drops expired requests (after 60 seconds) and markers of units that no longer count,
-- marks the remaining markers as lost and then refreshes the marker above every other living
-- Combine unit with a biosignal, unless the local player's own biosignal is gone. Lost
-- markers expire after 120 seconds. Called by `Schema:AddCombineDisplayLine` for every
-- uncoloured display line.
function cwCTO:UpdateBiosignalLocations()
  local curTime = CurTime()

  -- Clear expired requests.
  for i = #self.requestLocations, 1, -1 do
    if curTime - self.requestLocations[i].time >= 60 then
      table.remove(self.requestLocations, i)
    end
  end

  -- Clear active biosignals and expired lost biosignals.
  for unit, data in pairs(self.biosignalLocations) do
    if !IsValid(unit) or !Schema:PlayerIsCombine(unit)
    or (!cw.client:GetSharedVar('IsBiosignalGone') and !unit:GetSharedVar('IsBiosignalGone'))
    or curTime - data.time >= 120 then
      self.biosignalLocations[unit] = nil
    end

    data.isLost = true
  end

  -- Add active biosignals, update camera data.
  if !cw.client:GetSharedVar('IsBiosignalGone') then
    for _, v in ipairs(_player.GetAll()) do
      if Schema:PlayerIsCombine(v) and v != cw.client and !v:GetSharedVar('IsBiosignalGone') and v:Alive() then
        self.biosignalLocations[v] = {
          pos = GetMarkerPosition(v),
          time = curTime,
          isLost = false,
          isKnockedOut = v:GetRagdollState() == RAGDOLL_KNOCKEDOUT,
          digits = string.match(v:Name(), '%d%d%d%d?%d?') or '???'
        }
      end
    end
  end
end

--- Called to paint the HUD foreground; draws the Combine biosignal overlay.
--
-- For Combine players, draws unit biosignal markers, requests for assistance, Combine
-- cameras with the violations they see and, within 2048 units (three times that while
-- zoomed), possible movement violations of other players. Markers near the centre of the
-- screen show more detail.
function cwCTO:HUDPaintForeground()
  local client = cw.client

  if !Schema:PlayerIsCombine(client) then return end

  local colorWhite = cw.option:GetColor('white')
  local fontHeight = draw.GetFontHeight('BudgetLabel')
  local curTime = CurTime()
  local lowDetailBox = math.floor(ScrW() / 10)
  local halfW, halfH = ScrW() / 2, ScrH() / 2

  for unit, data in pairs(self.biosignalLocations) do
    if !IsValid(unit) or curTime - data.time >= 120 then
      self.biosignalLocations[unit] = nil
    elseif !cw.player:IsNoClipping(unit) then
      local toScreen = data.pos:ToScreen()

      if toScreen.visible then
        local text = '<:: '..data.digits..' ::>'
        local color = _team.GetColor(unit:Team()) or colorWhite
        local x, y = toScreen.x, toScreen.y
        local showDetail = (math.Distance(x, y, halfW, halfH) <= lowDetailBox)

        if showDetail then
          text = '<:: '..unit:Name()..' ::>'
        end

        local timeSince = FormatSeconds(curTime - data.time)

        draw.SimpleText(text, 'BudgetLabel', x, y, color, 1, 1)
        y = y + fontHeight

        if data.isLost then
          local timeUntil = FormatSeconds(120 - (curTime - data.time))

          draw.SimpleText('<:: '..L('#CTO_HUD_Lost:'..timeSince..';')..' ::>', 'BudgetLabel', x, y, colorRed, 1, 1)
          y = y + fontHeight
          draw.SimpleText('<:: '..L('#CTO_HUD_Removal:'..timeUntil..';')..' ::>', 'BudgetLabel', x, y, colorRed, 1, 1)
        else
          local text2 = lowDetailText

          if showDetail then
            text2 = '<:: '..L('#CTO_HUD_Received:'..timeSince..';')..' ::>'
          end

          draw.SimpleText(text2, 'BudgetLabel', x, y, colorWhite, 1, 1)

          if data.isKnockedOut then
            y = y + fontHeight
            draw.SimpleText('<:: #CTO_HUD_Unconscious ::>', 'BudgetLabel', x, y, colorRed, 1, 1)
          end
        end
      end
    end
  end

  -- Backwards, so that expired requests can be removed on the way.
  for i = #self.requestLocations, 1, -1 do
    local data = self.requestLocations[i]

    if curTime - data.time >= 60 then
      table.remove(self.requestLocations, i)
    else
      local toScreen = data.pos:ToScreen()

      if toScreen.visible then
        local x, y = toScreen.x, toScreen.y
        local showDetail = (math.Distance(x, y, halfW, halfH) <= lowDetailBox)
        local timeUntil = FormatSeconds(60 - (curTime - data.time))

        draw.SimpleText('<:: #CTO_HUD_Request ::>', 'BudgetLabel', x, y, colorRequest, 1, 1)
        y = y + fontHeight
        draw.SimpleText(showDetail and data.label or lowDetailText, 'BudgetLabel', x, y, colorWhite, 1, 1)
        y = y + fontHeight
        draw.SimpleText('<:: '..L('#CTO_HUD_Removal:'..timeUntil..';')..' ::>', 'BudgetLabel', x, y, colorRed, 1, 1)
      end
    end
  end

  for combineCamera, info in pairs(self.cameraInfo) do
    if IsValid(combineCamera) then
      local toScreen = combineCamera:GetPos():ToScreen()

      if toScreen.visible then
        local x, y = toScreen.x, toScreen.y
        local showDetail = (math.Distance(x, y, halfW, halfH) <= lowDetailBox)

        draw.SimpleText(showDetail and info.label or lowDetailText, 'BudgetLabel', x, y, colorObject, 1, 1)
        y = y + fontHeight

        if info.inView then
          draw.SimpleText(showDetail and info.inView or lowDetailText, 'BudgetLabel', x, y, colorWhite, 1, 1)

          if #info.violations > 0 then
            y = y + fontHeight
            draw.SimpleText('<:: #CTO_HUD_ViolationsInView ::>', 'BudgetLabel', x, y, colorRed, 1, 1)

            for i, violation in ipairs(info.violations) do
              y = y + fontHeight
              draw.SimpleText(showDetail and violation or lowDetailText, 'BudgetLabel', x, y, colorWhite, 1, 1)
            end
          end
        else
          draw.SimpleText('<:: #CTO_HUD_Disabled ::>', 'BudgetLabel', x, y, colorRed, 1, 1)
        end
      end
    end
  end

  local clientEyePos = client:EyePos()
  local maximumDistance = 2048

  -- If we are using suit zoom.
  if client:GetFOV() < 40 then
    maximumDistance = maximumDistance * 3
  end

  local maximumDistanceSqr = maximumDistance * maximumDistance

  for _, v in ipairs(_player.GetAll()) do
    if v != client and !(Schema:PlayerIsCombine(v) and !v:GetSharedVar('IsBiosignalGone'))
    and clientEyePos:DistToSqr(v:GetPos()) <= maximumDistanceSqr and !cw.player:IsNoClipping(v) then
      local ragdollState = v:GetRagdollState()
      local bRunning = v:IsRunning()
      local bJumping = v.m_bJumping
      local bCrouching = v:Crouching()
      local bFallenOver = (ragdollState != RAGDOLL_NONE and ragdollState != RAGDOLL_RESET)

      -- The cheap checks come first: the marker position and the line of sight cost a bone lookup and a trace.
      if bRunning or bJumping or bCrouching or bFallenOver then
        local toScreen = GetMarkerPosition(v):ToScreen()

        if toScreen.visible and client:IsLineOfSightClear(v) then
          local x, y = toScreen.x, toScreen.y
          local showDetail = (math.Distance(x, y, halfW, halfH) <= lowDetailBox)

          draw.SimpleText('<:: #CTO_HUD_PossibleViolation ::>', 'BudgetLabel', x, y, colorRed, 1, 1)

          if bRunning then
            y = y + fontHeight
            draw.SimpleText(showDetail and violationRunning or lowDetailText, 'BudgetLabel', x, y, colorWhite, 1, 1)
          end

          if bJumping then
            y = y + fontHeight
            draw.SimpleText(showDetail and violationJumping or lowDetailText, 'BudgetLabel', x, y, colorWhite, 1, 1)
          end

          if bCrouching then
            y = y + fontHeight
            draw.SimpleText(showDetail and violationCrouching or lowDetailText, 'BudgetLabel', x, y, colorWhite, 1, 1)
          end

          if bFallenOver then
            y = y + fontHeight
            draw.SimpleText(showDetail and violationFallenOver or lowDetailText, 'BudgetLabel', x, y, colorWhite, 1, 1)
          end
        end
      end
    end
  end
end

cable.receive('CombineRequestSignal', function(data)
  local player = data[1]
  local text = data[2]

  if IsValid(player) then
    table.insert(cwCTO.requestLocations, {
      time = CurTime(),
      pos = GetMarkerPosition(player),
      text = text,
      label = '<:: '..tostring(text)..' ::>'
    })
  end
end)

--- Builds the text the HUD shows for a Combine camera, so that it is not put together again every frame.
-- @param combineCamera [Entity The camera]
-- @param players [Map The players the camera sees mapped to their violations, or `0` for an idle camera]
-- @return [Map `label`, and for an alert camera `inView` and the `violations` list]
local function BuildCameraInfo(combineCamera, players)
  local info = { label = '<:: C-i'..combineCamera:EntIndex()..' ::>' }

  if !istable(players) then return info end

  local violations = {}

  for player, vios in pairs(players) do
    for i, vio in ipairs(vios) do
      if vio == cwCTO.VIOLATION_RUNNING then
        violations[#violations + 1] = violationRunning
      elseif vio == cwCTO.VIOLATION_JUMPING then
        violations[#violations + 1] = violationJumping
      elseif vio == cwCTO.VIOLATION_CROUCHING then
        violations[#violations + 1] = violationCrouching
      elseif vio == cwCTO.VIOLATION_FALLEN_OVER then
        violations[#violations + 1] = violationFallenOver
      end
    end
  end

  info.inView = '<:: '..L('#CTO_HUD_InView:'..table.Count(players)..';')..' ::>'
  info.violations = violations

  return info
end

cable.receive('UpdateBiosignalCameraData', function(data)
  local newCameraData = {}
  local newCameraInfo = {}

  for entIndex, players in pairs(data) do
    local combineCamera = Entity(entIndex)

    if IsValid(combineCamera) then
      newCameraData[combineCamera] = players
      newCameraInfo[combineCamera] = BuildCameraInfo(combineCamera, players)
    end
  end

  cwCTO.cameraData = newCameraData
  cwCTO.cameraInfo = newCameraInfo
end)

cable.receive('RecalculateHUDObjectives', function(data)
  local lines = {}

  for k, v in ipairs(string.Split(data[2] or '', '\n')) do
    if string.StartsWith(v, '^') then
      table.insert(lines, '<:: '..string.sub(v, 2)..' ::>')
    end
  end

  cwCTO.socioStatus = data[1]
  cwCTO.hudObjectives = lines
end)

--- Called to paint the top of the screen; shows Combine players the socio-status and HUD objectives.
function cwCTO:HUDPaintTopScreen()
  if !Schema:PlayerIsCombine(cw.client) then return end

  local alpha = 255 - cw.core:GetBlackFadeAlpha()
  local colorWhite = cw.option:GetColor('white')
  local height = draw.GetFontHeight('BudgetLabel')
  local x, y = ScrW() - 8, 8
  local socioColor = self.sociostatusColors[self.socioStatus] or colorWhite

  if self.socioStatus == 'BLACK' then
    local tsin = TimedSin(1, 0, 255, 0)

    colorSocio.r, colorSocio.g, colorSocio.b = tsin, tsin, tsin
  else
    colorSocio.r, colorSocio.g, colorSocio.b = socioColor.r, socioColor.g, socioColor.b
  end

  colorSocio.a = alpha

  draw.SimpleText(
    '<:: '..L('#CTO_HUD_SocioStatus:'..self.socioStatus..';')..' ::>',
    'BudgetLabel',
    x,
    y,
    colorSocio,
    TEXT_ALIGN_RIGHT
  )
  y = y + height

  colorObjective.r, colorObjective.g, colorObjective.b = colorWhite.r, colorWhite.g, colorWhite.b
  colorObjective.a = alpha

  for k, v in ipairs(self.hudObjectives) do
    draw.SimpleText(v, 'BudgetLabel', x, y, colorObjective, TEXT_ALIGN_RIGHT)

    y = y + height
  end
end
