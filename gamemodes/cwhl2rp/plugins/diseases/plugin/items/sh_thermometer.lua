ITEM.name = "Thermometer"
ITEM.PrintName = "#Item_Thermometer_PrintName"
ITEM.cost = 50
ITEM.model = "models/props_c17/TrapPropeller_Lever.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Apply"
ITEM.category = "Medical"
ITEM.business = true
ITEM.description = "#Item_Thermometer_Description"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local lookingPly = player:GetEyeTrace().Entity
	
	if (lookingPly:IsPlayer()) then
		if (lookingPly:GetCharacterData("diseases") == "fever") then
			cw.player:Notify(player, L("Diseases_Temperature", math.random(40.1, 43.6)))
		else
			cw.player:Notify(player, L("Diseases_Temperature", math.random(36.5, 37.0)))
		end

		return false
	else
		cw.player:Notify(player, L("Diseases_MustLookAtPerson"))

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end