--[[
	Catwork � 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("GarbageAdd")
COMMAND.tip = "Spawns garbage entity at your target location."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.alias = {"AddGarbage", "GarbageSpawnAdd"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local entity = ents.Create("cw_garbage")

	local Position = player:GetEyeTraceNoCursor().HitPos + Vector(0,0,5)
	entity:SetPos(Position)
	entity:Spawn()

	if (IsValid(entity)) then
		Angles = Angle(0, player:EyeAngles().yaw + 180,0)
		entity:SetAngles(Angles)

		table.insert(cwGarbage.garbagePoints, {
			position = Position,
			angles = Angles,
			nextSpawn = 0
		})

		cw.player:Notify(player, "You have added a garbage point.")

		cwGarbage:SaveGarbageSpawnPoints()
	end
end

COMMAND:Register();
