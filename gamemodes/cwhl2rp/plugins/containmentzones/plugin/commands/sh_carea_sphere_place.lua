local COMMAND = cw.command:New("ContainmentSpherePlace")
COMMAND.tip = ""
COMMAND.text = "<number Radius> <number Rad/second>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 2

function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()

	cwRadSystem.stored[#cwRadSystem.stored + 1] = {
		pos = trace.HitPos,
		radius = tonumber(arguments[1]),
		rad = tonumber(arguments[2]),
	}

	cw.player:Notify(player, "You have added the containment area with specified parameters: radius: "..arguments[1].."; rad: "..arguments[2]..".")
end

COMMAND:Register()