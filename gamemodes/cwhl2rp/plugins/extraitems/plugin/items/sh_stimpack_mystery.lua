--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Mysterious Serum"
ITEM.PrintName = "#ITEM_Mystery"
ITEM.cost = 1000
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.weight = 0.2
ITEM.access = "V"
ITEM.useText = "#ITEM_Adrenaline_UseText"
ITEM.business = true
ITEM.category = "#ITEM_Category_Stimpacks"
ITEM.uniqueID = "stimpack_mystery"
ITEM.description = "#ITEM_Mystery_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("Stamina", 100)
	player:SetCharacterData("Fatigue", 0)
	player:SetHealth(200)

	player:BoostAttribute(self.name, ATB_AGILITY, 100, 600)
	player:BoostAttribute(self.name, ATB_ENDURANCE, 100, 600)
	player:BoostAttribute(self.name, ATB_STRENGTH, 100, 600)

	cw.player:Notify(player, "#ITEM_Mystery_Effect")
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end


local eng = cw.lang:GetTable("en")
local ru = cw.lang:GetTable("ru")

eng["#ITEM_Mystery"] = "Mysterious Serum"
eng["#ITEM_Mystery_Desc"] = "A syringe filled with blue glowing liquid. It's not labeled."
eng["#ITEM_Mystery_Effect"] = "You keep standing here, not feeling much, when suddenly you feel strong rush of energy filling your very essence. You feel indestructible!"

ru["#ITEM_Mystery"] = "Загадочная сыворотка"
ru["#ITEM_Mystery_Desc"] = "Шприц, наполненный синей светящейся жидкостью. На нем нет никаких маркировок."
ru["#ITEM_Mystery_Effect"] = "Вы стоите на месте пару секунд, как вдруг вы чувствуете резкий, сильный прилив сил. Вы чувствуете себя непобедимыми."
