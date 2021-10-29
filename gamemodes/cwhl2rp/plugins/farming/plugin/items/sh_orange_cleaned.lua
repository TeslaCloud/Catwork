--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Cleaned Orange"
ITEM.PrintName = "Очищенный апельсин"
ITEM.cost = 5
ITEM.model = "models/props/cs_italy/orange.mdl"
ITEM.weight = 0.1
ITEM.access = "v"
ITEM.uniqueID = "orange_cleaned"
ITEM.useText = "Eat"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "В этом фрукте содержится вся сила. Очищен и готов к употреблению."

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 15, 0, 100))

	player:BoostAttribute(self.name, ATB_ENDURANCE, 10, 120)
	player:BoostAttribute(self.name, ATB_STRENGTH, 10, 120)
	player:EmitSound("vo/npc/male01/finally.wav")
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
