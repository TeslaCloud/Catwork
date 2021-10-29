--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Tomato"
ITEM.PrintName = "Помидор"
ITEM.cost = 5
ITEM.model = "models/bioshockinfinite/hext_apple.mdl"
ITEM.weight = 0.1
ITEM.uniqueID = "tomato"
ITEM.access = "v"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "А я томат."
ITEM.hunger = 5
ITEM.thirst = 10

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
