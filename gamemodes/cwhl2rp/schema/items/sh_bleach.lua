--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Bleach"
ITEM.PrintName = "#ITEM_Bleach"
ITEM.cost = 6
ITEM.model = "models/props_junk/garbage_plasticbottle001a.mdl"
ITEM.plural = "Bleaches"
ITEM.weight = 0.8
ITEM.access = "v"
ITEM.useText = "Drink"
ITEM.business = true
ITEM.category = "Consumables"
ITEM.uniqueID = "bleach"
ITEM.description = "#ITEM_Bleach_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:TakeDamage(75, player, player)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
