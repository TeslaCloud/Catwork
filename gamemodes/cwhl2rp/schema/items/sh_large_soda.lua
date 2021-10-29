--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Large Soda"
ITEM.PrintName = "#ITEM_Large_Soda"
ITEM.cost = 12
ITEM.model = "models/props_junk/garbage_plasticbottle003a.mdl"
ITEM.weight = 1.5
ITEM.access = "w"
ITEM.useText = "Drink"
ITEM.category = "Consumables"
ITEM.business = true
ITEM.description = "#ITEM_Large_Soda_Desc"
ITEM.thirst = 35

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("stamina", 100)
	player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()))

	player:BoostAttribute(self.name, ATB_AGILITY, 5, 120)
	player:BoostAttribute(self.name, ATB_STAMINA, 5, 120)

	player:GiveItem("empty_plastic_bottle", true)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

-- Called when the item's functions should be edited.
function ITEM:OnEditFunctions(functions)
	if (Schema:PlayerIsCombine(cw.client, false)) then
		for k, v in pairs(functions) do
			if (v == "Drink") then functions[k] = nil; end
		end
	end
end
