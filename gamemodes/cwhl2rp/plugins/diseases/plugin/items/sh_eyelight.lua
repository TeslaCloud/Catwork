ITEM.name = "Medical Penlight"
ITEM.PrintName = "#Item_Eyelight_PrintName"
ITEM.cost = 50
ITEM.model = "models/lagmite/lagmite.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Apply"
ITEM.category = "Medical"
ITEM.business = true;
ITEM.description = "#Item_Eyelight_Description"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local lookingPly = player:GetEyeTrace().Entity

	if (lookingPly:IsPlayer()) then
		if (lookingPly:GetCharacterData("diseases") == "blindness") then
			cw.player:Notify(player, L("Diseases_Eyelight_Blind"))
		elseif (lookingPly:GetCharacterData("diseases") == "colorblindness") then
			cw.player:Notify(player, L("Diseases_Eyelight_Colorblind"))
		else
			cw.player:Notify(player, L("Diseases_Eyelight_Normal"))
		end

		return false
	else
		cw.player:Notify(player, L("Diseases_MustLookAtPerson"))

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end