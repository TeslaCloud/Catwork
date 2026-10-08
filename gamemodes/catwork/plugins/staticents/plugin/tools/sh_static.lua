--- Defines the `static` toolgun of the Static Entities plugin, which makes the entity under the crosshair static on
-- left click and non-static on right click.

local TOOL = cw.tool:New()

TOOL.Category = 'Clockwork'
TOOL.UniqueID = 'static'
TOOL.Name = '#tool.static.name'
TOOL.Command = nil
TOOL.ConfigName = ''

--- Makes the entity the owner is looking at static through the `PlayerMakeStatic` hook.
function TOOL:LeftClick(trace)
  if CLIENT then return true end

  local player = self:GetOwner()

  plugin.Call('PlayerMakeStatic', player, true)

  return true
end

--- Makes the entity the owner is looking at non-static through the `PlayerMakeStatic` hook.
function TOOL:RightClick(trace)
  if CLIENT then return true end

  local player = self:GetOwner()

  plugin.Call('PlayerMakeStatic', player, false)

  return true
end

TOOL:Register()
