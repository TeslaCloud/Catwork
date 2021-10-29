--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Melon"
ITEM.PrintName = "#ITEM_Melon"
ITEM.cost = 8
ITEM.model = "models/props_junk/watermelon01.mdl"
ITEM.weight = 1
ITEM.access = "v"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "#ITEM_Melon_Desc"
ITEM.thirst = 30
ITEM.hunger = 45

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 10, 0, 100))

	player:BoostAttribute(self.name, ATB_ACROBATICS, 2, 120)
	player:BoostAttribute(self.name, ATB_AGILITY, 2, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
