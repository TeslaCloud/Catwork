--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Citizen Supplements"
ITEM.PrintName = "#ITEM_Citizen_Supplements"
ITEM.model = "models/props_lab/jar01b.mdl"
ITEM.weight = 0.6
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.description = "#ITEM_Citizen_Supplements_Desc"
ITEM.hunger = 35

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()))

	player:GiveItem("empty_tin_can", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
