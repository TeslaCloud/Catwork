--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when the command has been run.
local COMMAND = cw.command:New("AdvertAdd")
COMMAND.tip = "Add a dynamic advert."
COMMAND.text = "<string URL> <number Width> < number Height> [number Scale]"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 3
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	local scale = tonumber(arguments[4])
	local width = tonumber(arguments[2]) or 256
	local height = tonumber(arguments[3]) or 256

	if (scale) then
		scale = scale * 0.25
	end

	local data = {
		url = arguments[1],
		scale = scale,
		width = width,
		height = height,
		angles = trace.HitNormal:Angle(),
		position = trace.HitPos + (trace.HitNormal * 1.25)
	}

	data.angles:RotateAroundAxis(data.angles:Forward(), 90)
	data.angles:RotateAroundAxis(data.angles:Right(), 270)

	netstream.Start(nil, "DynamicAdvertAdd", data)

	cwDynamicAdverts.storedList[#cwDynamicAdverts.storedList + 1] = data
	cwDynamicAdverts:SaveDynamicAdverts()

	cw.player:Notify(player, "You have added a dynamic advert.")
end

COMMAND:Register();
