--- Registers the `/Static` operator command (aliases `/StaticAdd` and `/StaticPropAdd`), which makes the entity the
-- player is looking at static so that it stays on the map permanently.

local COMMAND = cw.command:New('Static')
COMMAND.tip = '#Command_Static_Description'
COMMAND.access = 'o'
COMMAND.alias = { 'StaticAdd', 'StaticPropAdd' }

--- Makes the entity the player is looking at static through the `PlayerMakeStatic` hook.
function COMMAND:OnRun(player, arguments)
  plugin.Call('PlayerMakeStatic', player, true)
end

COMMAND:Register()
