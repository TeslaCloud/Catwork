--- Client-side hooks of the Area Displays plugin that detect which area the local player is in and draw the area names.
--
-- `Tick` checks the stored areas once a second and runs the `PlayerEnteredArea` and `PlayerExitedArea` hooks, while
-- `PostDrawTranslucentRenderables` and `HUDPaintForeground` draw the 3D and scrolling displays. `Initialize` creates
-- the `cwShowAreas` client convar.

--- Called when the client initializes; creates the `cwShowAreas` client convar as `CW_CONVAR_SHOWAREAS`.
function cwAreaDisplays:Initialize()
  CW_CONVAR_SHOWAREAS = cw.core:CreateClientConVar('cwShowAreas', 1, true, true)
end

--- Called when the local player enters an area; tells the server, which runs `PlayerEnteredArea` there
-- with the player as the first argument.
-- @param name [String The area's name]
-- @param minimum [Vector One corner of the area's box]
-- @param maximum [Vector The opposite corner of the area's box]
function cwAreaDisplays:PlayerEnteredArea(name, minimum, maximum)
  netstream.Start('EnteredArea', { name, minimum, maximum })
end

--- Called when the local player leaves an area; forgets the current area.
-- @param name [String The area's name]
-- @param minimum [Vector One corner of the area's box]
-- @param maximum [Vector The opposite corner of the area's box]
function cwAreaDisplays:PlayerExitedArea(name, minimum, maximum)
  self.currentAreaDisplay = nil
end

--- Called after translucent renderables are drawn; draws and fades the active 3D area displays.
-- @param bDrawingDepth [Boolean Whether the depth pass is being drawn]
-- @param bDrawingSkybox [Boolean Whether the skybox is being drawn]
-- @param bDrawing3DSkybox [Boolean Whether the 3D skybox is being drawn]
function cwAreaDisplays:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox, bDrawing3DSkybox)
  if bDrawing3DSkybox or bDrawingDepth then return end

  for k, v in pairs(self.activeDisplays) do
    if v.class == '3D' then
      self:DrawDisplay3D(v)
      self:CalculateDisplayAlpha(v, k)
    end
  end
end

--- Called when the foreground HUD is painted; draws and fades the active scrolling area displays.
function cwAreaDisplays:HUDPaintForeground()
  if next(self.activeDisplays) == nil then return end

  local info = { x = ScrW() * 0.1, y = ScrH() * 0.6 }

  for k, v in pairs(self.activeDisplays) do
    if v.class == 'Scrolling' then
      self:DrawDisplayScrolling(v, info)
      self:CalculateDisplayAlpha(v, k)
    end
  end
end

--- Called every tick; once a second, checks which stored area the local player is in.
--
-- Entering a new area runs `cwAreaDisplays:HandleAreaTable`, and leaving the current area runs the
-- `PlayerExitedArea` hook.
function cwAreaDisplays:Tick()
  local lastAreaDisplay = self.currentAreaDisplay
  local bDidLeave = false
  local curTime = UnPredictedCurTime()

  if !IsValid(cw.client) or !cw.client:HasInitialized() then
    return
  end

  if self.nextCheckAreaDisplays and curTime < self.nextCheckAreaDisplays then
    return
  end

  self.nextCheckAreaDisplays = curTime + 1

  for k, v in pairs(self.storedList) do
    if cw.entity:IsInBox(cw.client, v.minimum, v.maximum) then
      if self.currentAreaDisplay != v.name then
        local bCalledHooks = self:HandleAreaTable(v, k)

        if !bCalledHooks then
          hook.Run(
            'PlayerExitedArea', lastAreaDisplay, v.name
          )
        end

        return
      end
    elseif lastAreaDisplay == v.name then
      bDidLeave = v.name
    end
  end

  if bDidLeave then
    hook.Run('PlayerExitedArea', bDidLeave)
  end
end
