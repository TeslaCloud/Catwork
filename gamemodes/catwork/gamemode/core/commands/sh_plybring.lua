--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyBring")

COMMAND.tip = "#Command_Plybring_Description"
COMMAND.text = "#Command_Plybring_Syntax"
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.access = "o"
COMMAND.alias = {"Bring"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local trace = player:GetEyeTraceNoCursor()
	local isSilent = cw.core:ToBool(arguments[2])

	if (target) then
		cw.player:SetSafePosition(target, trace.HitPos)

		if (!isSilent) then
			cw.player:NotifyAll(player:Name().." has brought "..target:Name().." to their target location.")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
