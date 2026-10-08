--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

cwAreaDisplays.activeDisplays = cwAreaDisplays.activeDisplays or {}
cwAreaDisplays.expiredList = cw.core:RestoreSchemaData('plugins/displays/'..game.GetMap())

cw.setting:AddCheckBox('#Framework', '#ShowAreas', 'cwShowAreas', '#ShowAreasDesc')

netstream.Hook('AreaDisplays', function(data)
  for k, v in pairs(data) do
    if cwAreaDisplays:HasExpired(v) then
      data[k] = nil
    end
  end

  cwAreaDisplays.storedList = data
end)

netstream.Hook('AreaAdd', function(data)
  if !cwAreaDisplays:HasExpired(data) then
    cwAreaDisplays.storedList[#cwAreaDisplays.storedList + 1] = data
    cwAreaDisplays:AddAreaDisplayDisplay(data)
  end
end)

netstream.Hook('AreaRemove', function(data)
  for k, v in pairs(cwAreaDisplays.storedList) do
    if v.name == data.name and v.minimum == data.minimum
    and v.maximum == data.maximum then
      cwAreaDisplays.storedList[k] = nil
    end
  end
end)

--- Starts showing an area's name.
--
-- `%t` in the name is replaced with the current in-game time. `Cinematic` areas are shown as cinematic
-- text; `Scrolling` (the default) and `3D` areas are added to `cwAreaDisplays.activeDisplays`, keyed by
-- position, unless that position is already showing.
-- @param areaTable [Map The area, with `name`, `class`, `position` and, for 3D displays, `angles` and `scale`]
function cwAreaDisplays:AddAreaDisplayDisplay(areaTable)
  areaTable.name = string.Replace(
    areaTable.name, '%t', cw.time:GetString()
  )

  if !areaTable.class then
    areaTable.class = 'Scrolling'
  end

  if areaTable.class == 'Cinematic' then
    cw.core:AddCinematicText(areaTable.name)
    return
  end

  local uniqueID = tostring(areaTable.position)
  local curTime = UnPredictedCurTime()

  if !self.activeDisplays[uniqueID] then
    self.activeDisplays[uniqueID] = {
      targetAlpha = 255,
      areaTable = areaTable,
      fadeTime = curTime + 4,
      class = areaTable.class,
      alpha = 0
    }
  end
end

--- Fades an active display in over 4 seconds, holds it for 6 and fades it out over 2, then removes it
-- from `cwAreaDisplays.activeDisplays`.
-- @param displayInfo [Map The active display; `alpha`, `targetAlpha`, `fadeTime` and `goBackTime` are updated]
-- @param index [String The display's key in `cwAreaDisplays.activeDisplays`]
function cwAreaDisplays:CalculateDisplayAlpha(displayInfo, index)
  if displayInfo.targetAlpha == 255 then
    displayInfo.alpha = math.Clamp(1 - ((displayInfo.fadeTime - CurTime()) / 4), 0, 1) * 255

    if displayInfo.alpha == 255 then
      displayInfo.targetAlpha = 0
      displayInfo.goBackTime = CurTime() + 6
      displayInfo.fadeTime = nil
    end
  elseif CurTime() >= displayInfo.goBackTime then
    if !displayInfo.fadeTime then
      displayInfo.fadeTime = CurTime() + 2
    end

    displayInfo.alpha = 255 - (math.Clamp(1 - ((displayInfo.fadeTime - CurTime()) / 2), 0, 1) * 255)

    if displayInfo.alpha == 0 then
      self.activeDisplays[index] = nil
    end
  end
end

--- Handles the local player entering an area.
--
-- For areas that do not expire, records the area as current and runs the `PlayerEnteredArea` hook. The
-- name is shown when the `cwShowAreas` setting is on or the area expires, and an expiring area is then
-- marked as seen with `cwAreaDisplays:SetExpired`.
-- @param areaTable [Map The area that was entered]
-- @param index [Number The area's index in `cwAreaDisplays.storedList`]
-- @return [Boolean `true` when the hook was run, otherwise `nil`]
function cwAreaDisplays:HandleAreaTable(areaTable, index)
  local bCalledHooks = false

  if !areaTable.doesExpire then
    self.currentAreaDisplay = areaTable.name

    hook.Run(
      'PlayerEnteredArea', areaTable.name, areaTable.minimum, areaTable.maximum
    )

    bCalledHooks = true
  end

  if CW_CONVAR_SHOWAREAS:GetInt() == 1 or areaTable.doesExpire then
    self:AddAreaDisplayDisplay(areaTable)
  end

  self:SetExpired(index)

  if bCalledHooks then
    return true
  end
end

--- Draws a 3D display's name in the world at its position and angles, using the large 3D2D font.
-- @param displayInfo [Map The active display, with `areaTable` and `alpha`]
function cwAreaDisplays:DrawDisplay3D(displayInfo)
  local large3D2DFont = cw.option:GetFont('large_3d_2d')
  local colorWhite = cw.option:GetColor('white')
  local eyeAngles = EyeAngles()
  local eyePos = EyePos()

  --[[ We want the font to be the 3D one... --]]
  cw.core:OverrideMainFont(large3D2DFont)

  cam.Start3D(eyePos, eyeAngles)
    local areaTable = displayInfo.areaTable

    cam.Start3D2D(areaTable.position, areaTable.angles, (areaTable.scale or 1) * 0.2)
    cw.core:DrawInfo(areaTable.name, 0, 0, colorWhite, displayInfo.alpha, nil,
      function(x, y, width, height)
        return x, y - (height / 2)
      end, 3
      )
    cam.End3D2D()
  cam.End3D()

  cw.core:OverrideMainFont(false)
end

--- Draws a scrolling display's name, typing it out one character every 0.1 seconds with a sound and
-- erasing it the same way once it starts fading out.
-- @param displayInfo [Map The active display, with `areaTable` and `alpha`; its scroll state is stored in it]
-- @param info [Map Drawing position with `x` and `y`; `y` is moved below the drawn text]
function cwAreaDisplays:DrawDisplayScrolling(displayInfo, info)
  local introTinyTextFont = cw.option:GetFont('intro_text_tiny')
  cw.core:OverrideMainFont(introTinyTextFont)

  local informationColor = cw.option:GetColor('information')
  local bIsGoingBack = (displayInfo.goBackTime and CurTime() >= displayInfo.goBackTime)
  local colorWhite = cw.option:GetColor('white')
  local areaTable = displayInfo.areaTable

  if !displayInfo.scrollInfo then
    displayInfo.scrollInfo = {
      index = 0,
      text = ''
    }
  end

  if bIsGoingBack and !displayInfo.scrollInfo.isGoingBack then
    displayInfo.scrollInfo.isGoingBack = true
    displayInfo.scrollInfo.index = 0
  end

  if !displayInfo.scrollInfo.nextType or CurTime() >= displayInfo.scrollInfo.nextType then
    displayInfo.scrollInfo.nextType = CurTime() + 0.1
    displayInfo.scrollInfo.index = displayInfo.scrollInfo.index + 1

    if displayInfo.scrollInfo.isGoingBack then
      displayInfo.scrollInfo.text = string.utf8sub(
        areaTable.name, displayInfo.scrollInfo.index + 1
      )
    else
      displayInfo.scrollInfo.text = string.utf8sub(
        areaTable.name, 0, displayInfo.scrollInfo.index
      )
    end

    if displayInfo.scrollInfo.index < string.utf8len(areaTable.name) then
      surface.PlaySound('common/talk.wav')
    end
  end

  local defaultWidth, defaultHeight = cw.core:GetCachedTextSize(
    introTinyTextFont, string.upper(areaTable.name)
  )
  local scrollWidth, scrollHeight = cw.core:GetCachedTextSize(
    introTinyTextFont, string.upper(displayInfo.scrollInfo.text)
  )
  local sNextCharacter = ''
  local newX = info.x

  if displayInfo.scrollInfo.isGoingBack then
    sNextCharacter = string.utf8sub(
      areaTable.name, displayInfo.scrollInfo.index, displayInfo.scrollInfo.index
    )

    local _, textWidth = cw.core:DrawInfo(
      string.upper(sNextCharacter), info.x, info.y, informationColor,
      math.max(displayInfo.alpha - 25, 0), true, function(x, y, width, height)
        return x + (defaultWidth - scrollWidth) - width, y
      end
    )

    newX = newX + (defaultWidth - scrollWidth)
  else
    sNextCharacter = string.utf8sub(
      areaTable.name, displayInfo.scrollInfo.index + 1, displayInfo.scrollInfo.index + 1
    )
  end

  local newY, textWidth = cw.core:DrawInfo(
    string.upper(displayInfo.scrollInfo.text), newX, info.y, colorWhite, displayInfo.alpha, true
  )

  if !displayInfo.scrollInfo.isGoingBack and sNextCharacter != '' then
    cw.core:DrawInfo(
      string.upper(sNextCharacter), newX + textWidth, info.y, informationColor, math.max(displayInfo.alpha - 25, 0),
      true
    )
  end

  cw.core:OverrideMainFont(false)
  info.y = newY
end

--- Returns whether an expiring area has already been shown to this client.
-- @param areaDisplay [Map The area]
-- @return [Boolean `true` when the area expires and its name is recorded at its position as seen]
function cwAreaDisplays:HasExpired(areaDisplay)
  if areaDisplay and areaDisplay.doesExpire then
    local position = tostring(areaDisplay.position)

    if self.expiredList[position] == areaDisplay.name then
      return true
    end
  end

  return false
end

--- Marks an expiring area as seen and removes it from `cwAreaDisplays.storedList`.
--
-- The seen areas are saved to the schema data file `plugins/displays/<map>` on the client, so they are
-- not shown again. Areas that do not expire are left alone.
-- @param index [Number The area's index in `cwAreaDisplays.storedList`]
function cwAreaDisplays:SetExpired(index)
  local areaDisplay = self.storedList[index]

  if areaDisplay and areaDisplay.doesExpire then
    local position = tostring(areaDisplay.position)
    local name = areaDisplay.name

    self.storedList[index] = nil
    self.expiredList[position] = name

    cw.core:SaveSchemaData('plugins/displays/'..game.GetMap(), self.expiredList)
  end
end
