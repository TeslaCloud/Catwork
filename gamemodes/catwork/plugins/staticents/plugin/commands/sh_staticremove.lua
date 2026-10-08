--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('UnStatic')
COMMAND.tip = '#Command_Unstatic_Description'
COMMAND.access = 'a'
COMMAND.alias = { 'StaticRemove', 'StaticPropRemove' }

--- Makes the entity the player is looking at non-static through the `PlayerMakeStatic` hook.
function COMMAND:OnRun(player, arguments)
  plugin.Call('PlayerMakeStatic', player, false)
end

COMMAND:Register()
