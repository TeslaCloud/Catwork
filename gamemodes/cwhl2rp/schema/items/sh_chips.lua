--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Chips"
ITEM.PrintName = "#Item_Chips_PrintName"
ITEM.cost = 35
ITEM.model = "models/bioshockinfinite/bag_of_hhips.mdl"
ITEM.weight = 0.1
ITEM.access = "v"
ITEM.useText = "Съесть"
ITEM.business = false
ITEM.category = "Consumables"
ITEM.description = "#Item_Chips_Description"
ITEM.hunger = 15
ITEM.thirst = -10

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:BoostAttribute(self.name, ATB_AGILITY, 3, 120)
	player:BoostAttribute(self.name, ATB_STAMINA, 3, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

