--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.baseItem = "alcohol_base"
ITEM.name = "Beer"
ITEM.PrintName = "#ITEM_Beer"
ITEM.cost = 6
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl"
ITEM.weight = 0.6
ITEM.access = "w"
ITEM.business = true
ITEM.attributes = {Strength = 2}
ITEM.description = "#ITEM_Beer_Desc"
ITEM.thirst = 25

function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 10, 0, 100))

	player:BoostAttribute(self.name, ATB_ACROBATICS, 2, 120)
	player:BoostAttribute(self.name, ATB_AGILITY, 2, 120)

	player:GiveItem("empty_glass_bottle", true)
end
