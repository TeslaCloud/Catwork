--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Baked Potato"
ITEM.PrintName = "#Item_BakedPotato_PrintName"
ITEM.cost = 5
ITEM.model = "models/bioshockinfinite/hext_potato.mdl"
ITEM.weight = 0.1
ITEM.access = "v"
ITEM.uniqueID = "baked_potato"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "#Item_BakedPotato_Description"
ITEM.hunger = 25

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
