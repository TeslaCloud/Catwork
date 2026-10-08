--- Registers the superadmin command `/CharGiveFlags` (alias `/GiveFlags`), which gives flags other than the admin flags
-- to the target character.

local COMMAND = cw.command:New('CharGiveFlags')
COMMAND.tip = '#Command_Chargiveflags_Description'
COMMAND.text = '#Command_Chargiveflags_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'GiveFlags' }

--- Gives flags to the target character; arguments are the character name and the flags.
--
-- Admin flags (`a`, `s` and `o`) cannot be given this way.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    if string.find(arguments[2], 'a') or string.find(arguments[2], 's')
    or string.find(arguments[2], 'o') then
      cw.player:Notify(player, L('Command_CannotGiveAdminFlags'))

      return
    end

    cw.player:GiveFlags(target, arguments[2])

    cw.player:NotifyAll(L('Command_Chargiveflags_Gave', player:Name(), target:Name(), arguments[2]))
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
