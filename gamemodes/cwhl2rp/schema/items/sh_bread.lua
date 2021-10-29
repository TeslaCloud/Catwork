--[[
	? 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Хлеб"
ITEM.PrintName = "#Item_Bread_PrintName"
ITEM.cost = 25
ITEM.model = "models/bioshockinfinite/dread_loaf.mdl"
ITEM.weight = 0.4
ITEM.access = "v"
ITEM.useText = "Съесть"
ITEM.business = false
ITEM.category = "Consumables"
ITEM.description = "#Item_Bread_Description"
ITEM.hunger = 35

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:BoostAttribute(self.name, ATB_STRENGHT, 2, 120)
	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

