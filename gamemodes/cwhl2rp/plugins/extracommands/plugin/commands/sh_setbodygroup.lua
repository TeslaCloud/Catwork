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
-- The value defaults to 0 when omitted.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local bg = tonumber(arguments[2])
  local val = tonumber(arguments[3] or 0)

  if bg != nil and val != nil then
    if IsValid(target) then
      target:SetBodygroup(bg, val)

      local bodyGroups = target:GetCharacterData('CustomBodyGroup', {})
      bodyGroups[bg] = val

      target:SetCharacterData('CustomBodyGroup', bodyGroups)
    end
  end
end

COMMAND:Register()
