--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Coffee"
ITEM.PrintName = "#Item_Coffee_PrintName"
ITEM.cost = 6
ITEM.model = "models/props_junk/garbage_coffeemug001a.mdl"
ITEM.weight = 0.1
ITEM.useText = "Выпить"
ITEM.category = "Consumables"
ITEM.business = false
ITEM.description = "#Item_Coffee_Description"
ITEM.fatigue = 40
ITEM.thirst = 45

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, 100))

	player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)
	player:BoostAttribute(self.name, ATB_STRENGTH, 1, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end