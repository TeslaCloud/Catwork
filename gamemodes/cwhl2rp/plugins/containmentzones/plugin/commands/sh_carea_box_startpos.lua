local COMMAND = cw.command:New("ContainmentBoxStartPos")
COMMAND.tip = ""
COMMAND.text = ""
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 0

function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()

	if !player.cwRadSystemBoxInfo then player.cwRadSystemBoxInfo = {} end

	if player.cwRadSystemBoxInfo then
		player.cwRadSystemBoxInfo.startpos = trace.HitPos
	end

	cw.player:Notify(player, "You have set the start point. Now set the end point.")
end

COMMAND:Register()