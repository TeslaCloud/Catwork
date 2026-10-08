--- Registers the superadmin command `/CharCheckFlags` (alias `/CheckFlags`), which shows the caller the target
-- character's flags.

local COMMAND = cw.command:New('CharCheckFlags')
COMMAND.tip = '#Command_Charcheckflags_Description'
COMMAND.text = '#Command_Charcheckflags_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.alias = { 'CheckFlags' }

--- Shows the caller the target character's flags; the argument is the character name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    cw.player:Notify(player, L('Command_Charcheckflags_Result', target:GetFlags()))
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
