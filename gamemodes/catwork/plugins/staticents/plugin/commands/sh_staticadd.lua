--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('Static')
COMMAND.tip = '#Command_Static_Description'
COMMAND.access = 'o'
COMMAND.alias = { 'StaticAdd', 'StaticPropAdd' }

--- Makes the entity the player is looking at static through the `PlayerMakeStatic` hook.
function COMMAND:OnRun(player, arguments)
  plugin.Call('PlayerMakeStatic', player, true)
end

COMMAND:Register()
