--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Milk Jug"
ITEM.PrintName = "#ITEM_Milk_Jug"
ITEM.cost = 8
ITEM.model = "models/props_junk/garbage_milkcarton001a.mdl"
ITEM.weight = 1
ITEM.access = "v"
ITEM.useText = "Drink"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "#ITEM_Milk_Jug_Desc"
ITEM.thirst = 35

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 10, 0, 100))

	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
	player:BoostAttribute(self.name, ATB_STRENGTH, 2, 120)

	player:GiveItem("empty_jug", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
