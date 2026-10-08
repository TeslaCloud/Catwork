--- Registers the `/ContainmentRemove` superadmin command of the Radiation plugin, which removes the containment zones
-- whose centre or corner lies within a radius, 64 units by default, of where the player is looking.

local COMMAND = cw.command:New('ContainmentRemove')
COMMAND.tip = ''
COMMAND.text = '#Command_Containmentremove_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Removes the containment zones whose centre or corner is near the position the player is looking at.
--
-- The optional first argument is the search radius, 64 by default.
function COMMAND:OnRun(player, arguments)
  local position = player:GetEyeTraceNoCursor().HitPos
  local radius = tonumber(arguments[1]) or 64
  local removed = 0

  for k, v in pairs(cwRadSystem.stored) do
    local bNear = (v.pos and v.pos:Distance(position) <= radius)
      or (v.pos1 and v.pos1:Distance(position) <= radius)
      or (v.pos2 and v.pos2:Distance(position) <= radius)

    if bNear then
      cwRadSystem.stored[k] = nil
      removed = removed + 1
    end
  end

  if removed > 0 then
    cw.player:Notify(player, L('Containment_Removed', removed))
  else
    cw.player:Notify(player, L('Containment_NoneFound'))
  end
end

COMMAND:Register()
