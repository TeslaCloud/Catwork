--[[
	? 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Tea"
ITEM.PrintName = "#Item_Tea_PrintName"
ITEM.cost = 6
ITEM.model = "models/props_junk/garbage_coffeemug001a.mdl"
ITEM.weight = 0.1
ITEM.useText = "Выпить"
ITEM.category = "Consumables"
ITEM.business = false
ITEM.description = "#Item_Tea_Description"
ITEM.fatigue = 35
ITEM.thirst = 25

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, 100))

	player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)
	player:BoostAttribute(self.name, ATB_STRENGTH, 1, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end