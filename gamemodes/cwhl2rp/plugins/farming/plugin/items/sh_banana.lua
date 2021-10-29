--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Banana"
ITEM.PrintName = "Банан"
ITEM.cost = 5
ITEM.model = "models/props/cs_italy/bananna.mdl"
ITEM.weight = 0.1
ITEM.access = "v"
ITEM.uniqueID = "banana"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "Длинный сладкий желтый банан."
ITEM.hunger = 10

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
