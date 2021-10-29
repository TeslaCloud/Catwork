--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Breen's Water"
ITEM.PrintName = "#ITEM_Breens_Water"
ITEM.cost = 10
ITEM.model = "models/props_junk/popcan01a.mdl"
ITEM.weight = 0.35
ITEM.access = "1"
ITEM.useText = "Drink"
ITEM.business = true
ITEM.category = "Consumables"
ITEM.uniqueID = "breens_water"
ITEM.description = "#ITEM_Breens_Water_Desc"
ITEM.thirst = 20

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") + 70, 0, 100))
	player:SetHealth(math.Clamp(player:Health() + 4, 0, player:GetMaxHealth()))

	player:BoostAttribute(self.name, ATB_AGILITY, 1, 120)
	player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)

	player:GiveItem("empty_soda_can", true)
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
