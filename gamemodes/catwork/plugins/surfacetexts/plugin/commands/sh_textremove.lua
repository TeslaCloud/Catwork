--- Registers the `/TextRemove` admin command, which removes the surface text the player is looking at.

local COMMAND = cw.command:New('TextRemove')
COMMAND.tip = '#Command_Textremove_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Removes the surface text the player is looking at with `cwSurfaceTexts:Remove`.
function COMMAND:OnRun(player, arguments)
  cwSurfaceTexts:Remove(player)
end

COMMAND:Register()
