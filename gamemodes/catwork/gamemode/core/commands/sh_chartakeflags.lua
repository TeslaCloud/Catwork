--- Registers the superadmin command `/CharTakeFlags`, which takes flags other than the admin flags from the target
-- character.

local COMMAND = cw.command:New('CharTakeFlags')
COMMAND.tip = '#Command_Chartakeflags_Description'
COMMAND.text = '#Command_Chartakeflags_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2

--- Takes flags from the target character; arguments are the character name and the flags.
--
-- Admin flags (`a`, `s` and `o`) cannot be taken this way.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    if string.find(arguments[2], 'a') or string.find(arguments[2], 's')
    or string.find(arguments[2], 'o') then
      cw.player:Notify(player, L('Command_CannotTakeAdminFlags'))

      return
    end

    cw.player:TakeFlags(target, arguments[2])

    cw.player:NotifyAll(L('Command_Chartakeflags_Took', player:Name(), target:Name(), arguments[2]))
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
