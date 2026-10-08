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
  local trace = player:GetEyeTraceNoCursor()

  if !player.cwRadSystemBoxInfo then player.cwRadSystemBoxInfo = {} end

  if !player.cwRadSystemBoxInfo.startpos then
    cw.player:Notify(player, L('Containment_NoStartPoint'))
    return
  end

  if player.cwRadSystemBoxInfo then
    player.cwRadSystemBoxInfo.endpos = trace.HitPos
  end

  cw.player:Notify(player, L('Containment_EndPointSet'))
end

COMMAND:Register()
