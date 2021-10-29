--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Steroids"
ITEM.PrintName = "#ITEM_Steroids"
ITEM.cost = 12
ITEM.model = "models/props_junk/garbage_metalcan002a.mdl"
ITEM.weight = 0.2
ITEM.access = "w"
ITEM.useText = "Swallow"
ITEM.category = "Medical"
ITEM.business = true
ITEM.description = "#ITEM_Steroids_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("stamina", 100)
	player:BoostAttribute(self.name, ATB_STRENGTH, 30, 420)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
