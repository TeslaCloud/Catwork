--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("WoodAdd")
COMMAND.tip = "Установить точку появления деревянной мебели для добычи."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local class = "prop_physics"
	local entity = ents.Create(class)

	entity:SetModel(table.Random(cwGather.woodNodes))
	entity:SetMoveType(MOVETYPE_VPHYSICS)
	entity:PhysicsInit(SOLID_VPHYSICS)
	entity:SetSolid(SOLID_VPHYSICS)

	local mins, maxs = entity:GetPhysicsObject():GetAABB()

	local Position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, maxs.z)
	entity:SetPos(Position)
	entity:Spawn()

	if (IsValid(entity)) then
		local Angles = Angle(0, player:EyeAngles().yaw + 180,0)
		entity:SetAngles(Angles)

		table.insert(cwGather.nodePoints, {
			position = Position - Vector(0, 0, maxs.z),
			angles = Angles,
			nextSpawn = 0,
			class = class,
			data = "wood"
		})

		cw.player:Notify(player, "Вы добавили точку появления деревянной мебели.")

		cwGather:SaveNodesSpawnPoints()
	end
end

COMMAND:Register();
