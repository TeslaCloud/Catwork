--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwGather:ClockworkInitPostEntity()
	self:LoadNodesSpawnPoints()
end

function cwGather:OneSecond()
	local curTime = CurTime()

	for k, v in ipairs(self.nodePoints) do
		if (curTime > v.nextSpawn) then
			if (hook.Run("CanSpawnNode", v.position, v.class)) then
				self:SpawnNode(v)
				v.nextSpawn = curTime + math.Round(config.GetVal("nodes_respawn_delay"))
			end
		end
	end
end

function cwGather:CanSpawnNode(position, class)
	local entities = ents.FindInSphere(position, 50)

	if (entities) then
		for k, v in ipairs(entities) do
			if (IsValid(v) and v:GetClass() == class) then
				return false
			end
		end
	end

	return true
end

hook.Add("PropBreak", "cwGather_wood", function(ply, ent)
	if (ent:GetMaterialType() == MAT_WOOD) then
		cwGather:PlayerBreaksWood(ply, ent)
	end
end)
