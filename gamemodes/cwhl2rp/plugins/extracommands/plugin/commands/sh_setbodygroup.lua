--- Registers the admin command `/CharSetBodyGroup` of the Extra Commands plugin, which sets a bodygroup on the target
-- character and saves it in the `CustomBodyGroup` character data.

local COMMAND = cw.command:New('CharSetBodyGroup')
COMMAND.tip = '#Command_Charsetbodygroup_Description'
COMMAND.text = '#Command_Charsetbodygroup_Syntax'
COMMAND.access = 'a'
COMMAND.arguments = 2
COMMAND.alias = { 'SetBodyGroup', 'CharBodyGroup' }

--- Sets a bodygroup on the target character and saves it so it is reapplied on spawn.
--
-- The value defaults to 0 when omitted. The bodygroup and its value must be whole numbers that exist on
-- the target's current model.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local bg = tonumber(arguments[2])
  local val = tonumber(arguments[3] or 0)

  if !IsValid(target) then
    return cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end

  -- Both are saved with the character, the bodygroup as a table key; the modulo also rejects NaN and infinity.
  if !bg or !val or bg % 1 != 0 or val % 1 != 0 or bg < 0 or bg >= target:GetNumBodyGroups()
  or val < 0 or val >= target:GetBodygroupCount(bg) then
    return cw.player:Notify(player, L('ExtraCommands_NotValidBodyGroup'))
  end

  target:SetBodygroup(bg, val)

  local bodyGroups = target:GetCharacterData('CustomBodyGroup')

  if !istable(bodyGroups) then
    bodyGroups = {}
  end

  bodyGroups[bg] = val

  target:SetCharacterData('CustomBodyGroup', bodyGroups)
end

COMMAND:Register()
