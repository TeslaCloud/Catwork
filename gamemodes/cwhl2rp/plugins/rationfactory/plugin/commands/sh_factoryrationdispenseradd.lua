--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

local COMMAND = cw.command:New("FactoryRationDispenserAdd")
COMMAND.tip = "Add ration dispenser at your target position."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	local entity = ents.Create("cw_factoryrationdispenser")

	entity:SetPos(trace.HitPos + Vector(0,0,10))
	entity:Spawn()

	if (IsValid(entity)) then
		entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180,0))

		cw.player:Notify(player, "You have added a ration dispenser.")
	end
end

COMMAND:Register();