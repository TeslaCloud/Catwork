ITEM.baseItem = "clothes_base"
ITEM.name = "Biohazard Suit Mk.2"
ITEM.PrintName = "#ITEM_Biohazard_Suit_Mk2_Name"
ITEM.replacement = "models/industrial_uniforms/industrial_uniform2.mdl"
ITEM.weight = 4
ITEM.access = "m"
ITEM.business = false
ITEM.protection = 0.7
ITEM.description = "#ITEM_Biohazard_Suit_Mk2_Desc"
ITEM.radProtection = true

-- Called when a replacement is needed for a player.
function ITEM:GetReplacement(player)
	if (string.lower(player:GetModel()) == "models/humans/group01/jasona.mdl") then
		return "models/industrial_uniforms/industrial_uniform2.mdl"
	end
end
