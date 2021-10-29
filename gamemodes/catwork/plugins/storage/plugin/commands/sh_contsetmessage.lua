--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("ContSetMessage")
COMMAND.tip = "Set a container's message."
COMMAND.text = "<string Message>"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()

	if (IsValid(trace.Entity)) then
		if (cw.entity:IsPhysicsEntity(trace.Entity)) then
			trace.Entity.cwMessage = arguments[1]
			cwStorage:SaveStorage()

			cw.player:Notify(player, "You have set this container's message.")
		else
			cw.player:Notify(player, "This is not a valid container!")
		end
	else
		cw.player:Notify(player, "This is not a valid container!")
	end
end

COMMAND:Register();
