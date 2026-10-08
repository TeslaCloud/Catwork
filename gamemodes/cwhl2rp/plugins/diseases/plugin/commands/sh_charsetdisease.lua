--- Registers the admin command `/CharSetDisease` of the Diseases plugin, which sets the target character's `diseases`
-- character data to one of the diseases in `cwDiseases.stored`, where `none` cures the character.

local COMMAND = cw.command:New('CharSetDisease')
COMMAND.tip = '#Command_Charsetdisease_Description'
COMMAND.text = '#Command_Charsetdisease_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 2

--- Sets the target character's disease to the given name and notifies both players.
--
-- The name has to be one of `cwDiseases.stored`; `none` cures the character.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local disease = string.lower(arguments[2])

  if !cwDiseases.stored[disease] then
    cw.player:Notify(player, L('Diseases_InvalidDisease', disease))

    return
  end

  if target then
    if player != target then
      cw.player:Notify(target, L('Diseases_SetByOther', player:Name(), disease))
      cw.player:Notify(player, L('Diseases_SetOther', target:Name(), disease))
    else
      cw.player:Notify(player, L('Diseases_SetSelf', disease))
    end

    target:SetCharacterData('diseases', disease)
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
