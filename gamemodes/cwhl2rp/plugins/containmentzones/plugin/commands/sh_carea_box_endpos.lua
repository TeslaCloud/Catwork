local COMMAND = cw.command:New("ContainmentBoxEndPos")
COMMAND.tip = ""
COMMAND.text = ""
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 0

function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()

	if !player.cwRadSystemBoxInfo then player.cwRadSystemBoxInfo = {} end
	if !player.cwRadSystemBoxInfo.startpos then
		cw.player:Notify(player, L("Containment_NoStartPoint"))
		return
	end
	if player.cwRadSystemBoxInfo then
		player.cwRadSystemBoxInfo.endpos = trace.HitPos
	end

	cw.player:Notify(player, L("Containment_EndPointSet"))
end

COMMAND:Register()