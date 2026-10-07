--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Orange Juice"
ITEM.PrintName = "#Item_OrangeJuice_PrintName"
ITEM.cost = 25
ITEM.model = "models/props_nunk/popcan01a.mdl"
ITEM.weight = 0.1
ITEM.uniqueID = "orange_juice"
ITEM.access = "v"
ITEM.useText = "Drink"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "#Item_OrangeJuice_Description"
ITEM.thirst = 55

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:GiveItem("empty_soda_can", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
