--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
