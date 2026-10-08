--- Registers `/CharPermaKill`, an operator command that permanently kills a character with `Schema:PermaKillPlayer`.

local COMMAND = cw.command:New('CharPermaKill')
COMMAND.tip = '#Command_Charpermakill_Description'
COMMAND.text = '#Command_Charpermakill_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 1

--- Permanently kills the character named in the first argument with `Schema:PermaKillPlayer`.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    if !target:GetCharacterData('permakilled') then
      Schema:PermaKillPlayer(target, target:GetRagdollEntity())
    else
      cw.player:Notify(player, L('PermaKill_Already'))

      return
    end

    cw.player:NotifyAll(L('PermaKill_Killed', player:Name(), target:Name()))
  else
    cw.player:Notify(player, L('NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
