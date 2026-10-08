--- Registers the admin command `/CharSetSkin` of the Extra Commands plugin, which sets the target character's skin and
-- saves it in the `CustomSkin` character data.

local COMMAND = cw.command:New('CharSetSkin')
COMMAND.tip = '#Command_Charsetskin_Description'
COMMAND.text = '#Command_Charsetskin_Syntax'
COMMAND.access = 'a'
COMMAND.arguments = 2
COMMAND.alias = { 'SetSkin', 'CharSkin' }

--- Sets the target character's skin and saves it so it is reapplied on spawn.
--
-- The skin must be a whole number that exists on the target's current model.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local skin = tonumber(arguments[2])

  if !IsValid(target) then
    return cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end

  -- The modulo also rejects NaN and infinity, which would be saved with the character.
  if !skin or skin % 1 != 0 or skin < 0 or skin >= target:SkinCount() then
    return cw.player:Notify(player, L('ExtraCommands_NotValidSkin'))
  end

  target:SetSkin(skin)
  target:SetCharacterData('CustomSkin', skin)
end

COMMAND:Register()
