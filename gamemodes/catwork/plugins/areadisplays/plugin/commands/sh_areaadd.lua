--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AreaAdd")
COMMAND.tip = "Add an area. Classes are 3D, Scrolling or Cinematic. Use %t in the name to show time."
COMMAND.text = "<string Name> [number Scale] [bool Expires] [string Class]"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 1
COMMAND.optionalArguments = 3

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local areaPointData = player.cwAreaData
	local trace = player:GetEyeTraceNoCursor()
	local name = arguments[1]

	if (!areaPointData or areaPointData.name != name) then
		player.cwAreaData = {
			name = name,
			class = (arguments[4] != "" and arguments[4] or "Scrolling"),
			scale = tonumber(arguments[2]),
			minimum = trace.HitPos
		}

		if (cw.core:ToBool(arguments[3])) then
			player.cwAreaData.doesExpire = true
		end

		cw.player:Notify(player, "You have added the minimum point. Now add the maximum point.")
		return
	elseif (!areaPointData.maximum) then
		areaPointData.maximum = trace.HitPos

		if (areaPointData.class == "3D") then
			cw.player:Notify(player, "You have added the minimum point. Now point at where the text will show.")
			return
		end
	end

	local data = {
		name = areaPointData.name,
		scale = areaPointData.scale,
		angles = trace.HitNormal:Angle(),
		expires = areaPointData.doesExpire,
		minimum = areaPointData.minimum,
		maximum = areaPointData.maximum,
		position = trace.HitPos + (trace.HitNormal * 1.25)
	}

	data.angles:RotateAroundAxis(data.angles:Forward(), 90)
	data.angles:RotateAroundAxis(data.angles:Right(), 270)

	netstream.Start(nil, "AreaAdd", data)
		cwAreaDisplays.storedList[#cwAreaDisplays.storedList + 1] = data
		cwAreaDisplays:SaveAreaDisplays()
	cw.player:Notify(player, "You have added the '"..data.name.."' area display.")

	player.cwAreaData = nil
end

COMMAND:Register();
