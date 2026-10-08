--[[
  © 2016 TeslaCloud Studios.
  Feel free to use, edit or share the plugin, but
  do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New('CharSetAttribute')
COMMAND.tip = '#Command_Charsetattribute_Description'
COMMAND.text = '#Command_Charsetattribute_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 3
COMMAND.alias = { 'SetAttribute' }

--- Adds the given amount to an attribute of the target character.
--
-- Uses `cw.attributes:Update`, which adds the points (clamped to the attribute maximum) rather than
-- setting the value.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local rawAttribute = string.utf8lower(arguments[2])
  local attribute = cw.attribute:FindByID(rawAttribute)
  local amt = tonumber(arguments[3]) or 0

  if IsValid(target) then
    if attribute then
      cw.attributes:Update(target, attribute.uniqueID, amt)

      cw.player:Notify(
        player,
        L('ExtraCommands_AttributeSet', target:Name(), (attribute.name or 'Unknown'), attribute.uniqueID, tostring(amt))
      )
    else
      cw.player:Notify(player, L('ExtraCommands_NotValidAttribute', arguments[2]))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
