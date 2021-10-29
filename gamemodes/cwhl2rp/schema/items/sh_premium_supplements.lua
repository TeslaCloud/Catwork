--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Premium Supplements"
ITEM.PrintName = "#ITEM_Premium_Supplements"
ITEM.uniqueID = "premium_supplements"
ITEM.model = "models/pg_plops/pg_food/pg_tortellinap.mdl"
ITEM.weight = 1
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.description = "#ITEM_Premium_Supplements_Desc"
ITEM.hunger = 75
ITEM.thirst = 5

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()))
	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)

	player:GiveItem("empty_cardboard", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
