--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

config.Add("nodes_respawn_delay", 30)

function cwGather:SaveNodesSpawnPoints()
	cw.core:SaveSchemaData("plugins/gather/"..game.GetMap(), self.nodePoints)
end

function cwGather:LoadNodesSpawnPoints()
	self.nodePoints = cw.core:RestoreSchemaData("plugins/gather/"..game.GetMap())

	if (!self.nodePoints) then
		self.nodePoints = {}
	end

	for k, v in pairs(self.nodePoints) do
		v.nextSpawn = 0
	end
end

function cwGather:CanSpawnNodeAtPos(position, class)
	local props = ents.FindInSphere(position, 50)

	if (props) then
		for k, v in ipairs(props) do
			if (IsValid(v) and v:GetClass() == class) then
				return false
			end
		end
	end

	return true
end

function cwGather:SpawnNode(pointTable)
	local entity = ents.Create(pointTable.class)

	if (pointTable.data == "wood") then
		entity:SetModel(table.Random(cwGather.woodNodes))
		entity:SetMoveType(MOVETYPE_VPHYSICS)
		entity:PhysicsInit(SOLID_VPHYSICS)
		entity:SetSolid(SOLID_VPHYSICS)
	end

	local mins, maxs = entity:GetPhysicsObject():GetAABB()

	entity:SetPos(pointTable.position + Vector(0, 0, maxs.z))
	entity:Spawn()

	if (IsValid(entity)) then
		entity:SetAngles(pointTable.angles)
	end
end

function cwGather:PlayerBreaksWood(player, ent)
	if (!IsValid(player) or !player:HasInitialized()) then return end

	local mass = ent:GetPhysicsObject():GetMass()

	for i = 1, math.Clamp(mass / 25, 1, 5) do
		local chance = math.random(1, 100) + cw.attributes:Fraction(player, ATB_SCAVENGER, 50)

		if (chance >= 90) then
			cw.entity:CreateItem(player, "wooden_board", ent:GetPos())
		elseif (chance >= 70) then
			cw.entity:CreateItem(player, "wooden_parts", ent:GetPos())
		end
	end

	--cw.player:Notify(player, "Масса объекта: "..ent:GetPhysicsObject():GetMass())
	player:ProgressAttribute(ATB_SCAVENGER, math.Round(math.Clamp(mass / 10, 5, 25)), true)
end
