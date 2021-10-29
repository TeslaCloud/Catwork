--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("ContSetPassword")
COMMAND.tip = "Set a container's password."
COMMAND.text = "<string Pass>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()

	if (IsValid(trace.Entity)) then
		if (cw.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel())

			if (cwStorage.containerList[model]) then
				if (!trace.Entity.inventory) then
					cwStorage.storage[trace.Entity] = trace.Entity
					trace.Entity.inventory = {}
				end

				trace.Entity.cwPassword = table.concat(arguments, " ")
				cwStorage:SaveStorage()

				cw.player:Notify(player, "This container's password has been set to '"..trace.Entity.cwPassword.."'.")
			else
				cw.player:Notify(player, "This is not a valid container!")
			end
		else
			cw.player:Notify(player, "This is not a valid container!")
		end
	else
		cw.player:Notify(player, "This is not a valid container!")
	end
end

COMMAND:Register();
