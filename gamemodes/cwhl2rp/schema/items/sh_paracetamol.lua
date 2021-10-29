--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Paracetamol"
ITEM.PrintName = "#ITEM_Paracetamol"
ITEM.cost = 10
ITEM.model = "models/props_junk/garbage_metalcan002a.mdl"
ITEM.weight = 0.2
ITEM.access = "1v"
ITEM.useText = "Swallow"
ITEM.category = "Medical"
ITEM.business = true
ITEM.description = "#ITEM_Paracetamol_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("stamina", 100)
	player:BoostAttribute(self.name, ATB_ENDURANCE, 30, 120)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
