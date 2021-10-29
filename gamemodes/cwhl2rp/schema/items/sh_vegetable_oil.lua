--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Vegetable Oil"
ITEM.PrintName = "#ITEM_Vegetable_Oil"
ITEM.cost = 6
ITEM.model = "models/props_junk/garbage_plasticbottle002a.mdl"
ITEM.weight = 0.6
ITEM.access = "v"
ITEM.uniqueID = "vegetable_oil"
ITEM.useText = "Drink"
ITEM.business = false
ITEM.category = "Consumables"
ITEM.description = "#ITEM_Vegetable_Oil_Desc"
ITEM.thirst = 10
ITEM.hunger = 35

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:TakeDamage(5, player, player)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
