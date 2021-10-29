--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Milk Carton"
ITEM.PrintName = "#ITEM_Milk_Carton"
ITEM.cost = 6
ITEM.model = "models/props_junk/garbage_milkcarton002a.mdl"
ITEM.weight = 0.7
ITEM.access = "v"
ITEM.useText = "Drink"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "#ITEM_Milk_Carton_Desc"
ITEM.thirst = 25

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, 100))

	player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)
	player:BoostAttribute(self.name, ATB_STRENGTH, 1, 120)

	player:GiveItem("empty_carton", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
