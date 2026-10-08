--- Registers the superadmin command `/CharSetAttribute` of the Extra Commands plugin, which sets an attribute of the
-- target character to the given amount.

local COMMAND = cw.command:New('CharSetAttribute')
COMMAND.tip = '#Command_Charsetattribute_Description'
COMMAND.text = '#Command_Charsetattribute_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 3
COMMAND.alias = { 'SetAttribute' }

--- Sets an attribute of the target character to the given amount.
--
-- The amount is clamped between 0 and the attribute's maximum by `cw.attributes:Update`, and the player is told
-- the resulting value.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local attribute = cw.attribute:FindByID(string.utf8lower(arguments[2]))
  local amount = tonumber(arguments[3])

  if !IsValid(target) then
    return cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end

  if !attribute then
    return cw.player:Notify(player, L('ExtraCommands_NotValidAttribute', arguments[2]))
  end

  -- NaN and infinity would be saved with the character.
  if !amount or amount != amount or math.abs(amount) == math.huge then
    return cw.player:Notify(player, L('NotValidAmount'))
  end

  local uniqueID = attribute.uniqueID
  local attributes = target:GetAttributes()
  local current = attributes[uniqueID] and attributes[uniqueID].amount or 0

  -- Update adds points, so pass the difference to the wanted value.
  cw.attributes:Update(target, uniqueID, amount - current)

  -- Update drops the entry of an attribute that is back at zero.
  local result = attributes[uniqueID] and attributes[uniqueID].amount or 0

  cw.player:Notify(
    player,
    L('ExtraCommands_AttributeSet', target:Name(), (attribute.name or 'Unknown'), uniqueID, tostring(result))
  )
end

COMMAND:Register()
