--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Potato Dish"
ITEM.PrintName = "Жареный картофель с овощами"
ITEM.cost = 5
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl"
ITEM.weight = 0.1
ITEM.access = "v"
ITEM.uniqueID = "potato_dish"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "Жареная картошечка со свежей кукурузой и помидорами."
ITEM.hunger = 65

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:GiveItem("empty_takeout_carton", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
