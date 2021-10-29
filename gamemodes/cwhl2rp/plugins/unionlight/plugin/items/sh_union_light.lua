
ITEM.name = "Union Light"
ITEM.cost = 50
ITEM.model = "models/props_combine/combine_light001a.mdl"
ITEM.weight = 4
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.category = "Lights"
ITEM.useText = "Place"
ITEM.business = true
ITEM.description = "A Union Light capable of illuminating large areas."

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor()
	local entity = ents.Create("cw_unionlight")

	if (trace.HitPos:Distance(player:GetShootPos()) <= 192) then

		cw.player:GiveProperty(player, entity)

		entity:SetModel(self.model)
		entity:SetPos(trace.HitPos)
		entity:Spawn()

		if (IsValid(itemEntity)) then
			local physicsObject = itemEntity:GetPhysicsObject()

			entity:SetPos(itemEntity:GetPos())
			entity:SetAngles(itemEntity:GetAngles())

			if (IsValid(physicsObject)) then
				if (!physicsObject:IsMoveable()) then
					physicsObject = entity:GetPhysicsObject()

					if (IsValid(physicsObject)) then
						physicsObject:EnableMotion(false)
					end
				end
			end
		else
			cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
		end
	else
		cw.player:Notify(player, "You cannot drop a light that far away!")

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

