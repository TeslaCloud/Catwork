--- Registers the `/UnStatic` admin command (aliases `/StaticRemove` and `/StaticPropRemove`), which makes the entity
-- the player is looking at non-static again.

local COMMAND = cw.command:New('UnStatic')
COMMAND.tip = '#Command_Unstatic_Description'
COMMAND.access = 'a'
COMMAND.alias = { 'StaticRemove', 'StaticPropRemove' }

--- Makes the entity the player is looking at non-static through the `PlayerMakeStatic` hook.
function COMMAND:OnRun(player, arguments)
  plugin.Call('PlayerMakeStatic', player, false)
end

COMMAND:Register()
