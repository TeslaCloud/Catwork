local PLUGIN = PLUGIN

-- A function to load the union light.
function PLUGIN:LoadUnionLights()
	local unionLights = cw.core:RestoreSchemaData("plugins/unionlights/"..game.GetMap())

	for k, v in pairs(unionLights) do
		local entity = ents.Create("cw_unionlight")

		cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

		entity:SetAngles(v.angles)
		entity:SetPos(v.position)
		entity:Spawn()

		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject()

			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false)
			end
		end
	end
end

-- A function to save the union light.
function PLUGIN:SaveUnionLights()
	local unionLights = {}

	for k, v in pairs(ents.FindByClass("cw_unionlight")) do
		local physicsObject = v:GetPhysicsObject()
		local moveable

		if (IsValid(physicsObject)) then
			moveable = physicsObject:IsMoveable()
		end

		unionLights[#unionLights + 1] = {
			key = cw.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
		}
	end

	cw.core:SaveSchemaData("plugins/unionlights/"..game.GetMap(), unionLights)
end