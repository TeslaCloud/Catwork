--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Apple"
ITEM.PrintName = "#Item_Apple_PrintName"
ITEM.cost = 20
ITEM.model = "models/bioshockinfinite/hext_apple.mdl"
ITEM.weight = 0.15
ITEM.access = "v"
ITEM.useText = "Съесть"
ITEM.business = true
ITEM.category = "Consumables"
ITEM.description = "#Item_Apple_Description"
ITEM.hunger = 15
ITEM.thirst = 10

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:BoostAttribute(self.name, ATB_STRENGHT, 1, 120)
	player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

