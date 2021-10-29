--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DispenserAdd")
COMMAND.tip = "#Command_Dispenseradd_Description"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	local entity = ents.Create("cw_rationdispenser")

	entity:SetPos(trace.HitPos)
	entity:Spawn()

	if (IsValid(entity)) then
		entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0))

		cw.player:Notify(player, "You have added a ration dispenser.")
	end
end

COMMAND:Register();
