--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.baseItem = "alcohol_base"
ITEM.name = "Vodka"
ITEM.PrintName = "#Item_Vodka_PrintName"
ITEM.cost = 13
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl"
ITEM.weight = 0.2
ITEM.access = "w"
ITEM.uniqueID = "vodka"
ITEM.business = true
ITEM.attributes = {Strength = 3}
ITEM.thirst = -15
ITEM.hunger = -20
ITEM.fatigue = -30
ITEM.description = "#Item_Vodka_Description"

function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 15, 0, 100))

	player:BoostAttribute(self.name, "str", 15, 120)

	player:GiveItem("empty_glass_bottle", true)
end

