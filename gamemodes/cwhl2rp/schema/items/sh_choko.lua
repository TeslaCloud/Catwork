--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Choko"
ITEM.PrintName = "#Item_Choko_PrintName"
ITEM.cost = 70
ITEM.model = "models/bioshockinfinite/hext_candy_chocolate.mdl"
ITEM.weight = 0.1
ITEM.access = "v"
ITEM.useText = "Съесть"
ITEM.business = false
ITEM.category = "Consumables"
ITEM.description = "#Item_Choko_Description"
ITEM.hunger = 35

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:BoostAttribute(self.name, ATB_STRENGHT, 2, 120)
	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

