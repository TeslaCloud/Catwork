local COMMAND = cw.command:New("ContainmentBoxPlace")
COMMAND.tip = ""
COMMAND.text = "<number Rad/second>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 1

function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()

	if player.cwRadSystemBoxInfo then
		if player.cwRadSystemBoxInfo.startpos then
			if player.cwRadSystemBoxInfo.endpos then
				cwRadSystem.stored[#cwRadSystem.stored + 1] = {
					pos1 = player.cwRadSystemBoxInfo.startpos,
					pos2 = player.cwRadSystemBoxInfo.endpos,
					rad = tonumber(arguments[1]),
				}
			else
				cw.player:Notify(player, "No end-pos specified.")
				return
			end
		else
			cw.player:Notify(player, "No start-pos specified.")
			return
		end
	else
		cw.player:Notify(player, "No position specified.")
		return
	end

	player.cwRadSystemBoxInfo = nil

	cw.player:Notify(player, "You have added the containment area to position with specified parameters: rad: "..arguments[1]..".")
end

COMMAND:Register()