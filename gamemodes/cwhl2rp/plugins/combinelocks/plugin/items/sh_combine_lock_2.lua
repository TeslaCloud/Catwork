--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Combine Lock"
ITEM.PrintName = "Purple Level Combine Lock"
ITEM.overrideColor = Color(210, 110, 255)
ITEM.uniqueID = "combine_lock_2"
ITEM.cost = 0
ITEM.model = "models/props_combine/combine_lock01.mdl"
ITEM.weight = 4
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.useText = "Place"
ITEM.business = true
ITEM.description = "УРОВЕНЬ ДОСТУПА: ФИОЛЕТОВЫЙ\nУстройство Альянса, использующееся для запирания дверей."
ITEM.accessLevel = 2
ITEM.category = "Карты и замки"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor()
	local entity = trace.Entity

	if (IsValid(entity)) then
		if (entity:GetPos():Distance(player:GetPos()) <= 192) then
			if (!IsValid(entity.combineLock)) then
				if (cw.entity:IsDoorUnownable(entity)) then
					local angles = trace.HitNormal:Angle() + Angle(0, 270, 0)
					local position

					if (string.lower(entity:GetClass()) == "prop_door_rotating") then
						position = trace
					else
						position = trace.HitPos + (trace.HitNormal * 4)
					end

					if (!IsValid(Schema:ApplyCombineLock(entity, position, angles, self.accessLevel, nil, self.overrideColor))) then
						return false
					elseif (IsValid(entity.breach)) then
						entity.breach:CreateDummyBreach()
						entity.breach:Explode()
						entity.breach:Remove()
					end
				else
					cw.player:Notify(player, L"This door cannot have a Combine lock!")

					return false
				end
			else
				cw.player:Notify(player, L"This entity already has a Combine lock!")

				return false
			end
		else
			cw.player:Notify(player, L"You are not close enough to the entity!")

			return false
		end
	else
		cw.player:Notify(player, L"That is not a valid entity!")

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

