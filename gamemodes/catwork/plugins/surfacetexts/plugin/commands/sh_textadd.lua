--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("TextAdd")
COMMAND.tip = "Add some text to a surface."
COMMAND.text = "<string Text> [number Scale] [number Style] [color First Color] [color Second Color]"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.optionalArguments = 4

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = arguments[1]
	local scale = tonumber(arguments[2])
	local style = tonumber((arguments[3] or 1))
	local color = arguments[4] or "#FF0000"
	local extraColor = arguments[5]

	if (!text or text == "") then
		cw.player:Notify(player, "You did not specify enough text.")

		return
	end

	local trace = player:GetEyeTraceNoCursor()
	local angle = trace.HitNormal:Angle()
	angle:RotateAroundAxis(angle:Forward(), 90);
	angle:RotateAroundAxis(angle:Right(), 270);

	local data = {
		text = text,
		style = style or 0,
		color = (color and Color(color)) or Color("#FFFFFF"),
		extraColor = (extraColor and Color(extraColor)) or Color("#FF0000"),
		angle = angle,
		pos = trace.HitPos,
		normal = trace.HitNormal,
		scale = scale or 1
	}

	cwSurfaceTexts:AddText(data)

	cw.player:Notify(player, "You have added a 3D text.")
end

COMMAND:Register();
