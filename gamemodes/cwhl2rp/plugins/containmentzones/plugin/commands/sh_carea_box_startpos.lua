local COMMAND = cw.command:New('ContainmentBoxStartPos')
COMMAND.tip = ''
COMMAND.text = ''
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 0

--- Sets the start corner of the box zone being placed to the position the player is looking at.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()

  if !player.cwRadSystemBoxInfo then player.cwRadSystemBoxInfo = {} end

  if player.cwRadSystemBoxInfo then
    player.cwRadSystemBoxInfo.startpos = trace.HitPos
  end

  cw.player:Notify(player, L('Containment_StartPointSet'))
end

COMMAND:Register()
