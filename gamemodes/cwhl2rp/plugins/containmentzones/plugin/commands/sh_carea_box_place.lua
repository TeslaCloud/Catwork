--- Registers the `/ContainmentBoxPlace` superadmin command of the Radiation plugin, which adds a box containment zone
-- with the given radiation level between the corners set with `/ContainmentBoxStartPos` and `/ContainmentBoxEndPos`.

local COMMAND = cw.command:New('ContainmentBoxPlace')
COMMAND.tip = ''
COMMAND.text = '#Command_Containmentboxplace_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1

--- Adds a box containment zone between the player's start and end corners.
--
-- The first argument is the zone's radiation level, which cannot be negative. Clears the player's corners afterwards.
function COMMAND:OnRun(player, arguments)
  local boxInfo = player.cwRadSystemBoxInfo
  local rad = tonumber(arguments[1])

  if !boxInfo then
    cw.player:Notify(player, L('Containment_NoPos'))

    return
  end

  if !boxInfo.startpos then
    cw.player:Notify(player, L('Containment_NoStartPos'))

    return
  end

  if !boxInfo.endpos then
    cw.player:Notify(player, L('Containment_NoEndPos'))

    return
  end

  -- A NaN fails every comparison, so it is refused here as well.
  if !rad or !(rad >= 0 and rad < math.huge) then
    cw.player:Notify(player, L('Containment_InvalidNumber'))

    return
  end

  cwRadSystem.stored[#cwRadSystem.stored + 1] = {
    pos1 = boxInfo.startpos,
    pos2 = boxInfo.endpos,
    rad = rad
  }

  player.cwRadSystemBoxInfo = nil

  cw.player:Notify(player, L('Containment_BoxAdded', rad))
end

COMMAND:Register()
