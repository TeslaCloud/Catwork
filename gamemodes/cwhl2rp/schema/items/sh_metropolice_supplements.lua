--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Metropolice Supplements"
ITEM.PrintName = "#ITEM_Metropolice_Supplements"
ITEM.cost = 10
ITEM.model = "models/props_lab/jar01b.mdl"
ITEM.weight = 0.6
ITEM.useText = "Eat"
ITEM.factions = {FACTION_MPF}
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "#ITEM_Metropolice_Supplements_Desc"
ITEM.hunger = 100
ITEM.thirst = 10

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()))
	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
