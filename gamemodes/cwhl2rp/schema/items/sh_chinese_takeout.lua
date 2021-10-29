--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Chinese Takeout"
ITEM.PrintName = "#ITEM_Chinese_Takeout"
ITEM.cost = 8
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl"
ITEM.weight = 0.6
ITEM.access = "v"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.uniqueID = "chinese_takeout"
ITEM.description = "#ITEM_Chinese_Takeout_Desc"
ITEM.hunger = 40

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()))

	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
	player:BoostAttribute(self.name, ATB_ACCURACY, 1, 120)

	player:GiveItem("empty_takeout_carton", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
