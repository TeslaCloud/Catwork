--- Registers the `/ContainmentBoxEndPos` superadmin command of the Radiation plugin, which sets the end corner of the
-- box containment zone being placed to where the player is looking.

local COMMAND = cw.command:New('ContainmentBoxEndPos')
COMMAND.tip = ''
COMMAND.text = ''
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 0

--- Sets the end corner of the box zone being placed to the position the player is looking at.
--
-- Requires the start corner to be set first with `/ContainmentBoxStartPos`.
function COMMAND:OnRun(player, arguments)
  local boxInfo = player.cwRadSystemBoxInfo

  if !boxInfo or !boxInfo.startpos then
    cw.player:Notify(player, L('Containment_NoStartPoint'))

    return
  end

  boxInfo.endpos = player:GetEyeTraceNoCursor().HitPos

  cw.player:Notify(player, L('Containment_EndPointSet'))
end

COMMAND:Register()
