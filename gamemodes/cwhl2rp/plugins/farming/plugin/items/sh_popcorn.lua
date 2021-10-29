--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Popcorn"
ITEM.PrintName = "Попкорн"
ITEM.cost = 15
ITEM.model = "models/bioshockinfinite/topcorn_bag.mdl"
ITEM.weight = 0.1
ITEM.access = "v"
ITEM.uniqueID = "popcorn"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "Рекомендуется к употреблению при захватывающем зрелище."
ITEM.hunger = 25

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:GiveItem("empty_carton", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
