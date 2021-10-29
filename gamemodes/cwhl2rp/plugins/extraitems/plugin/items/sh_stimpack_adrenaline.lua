--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Adrenaline"
ITEM.PrintName = "#ITEM_Adrenaline"
ITEM.cost = 300
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.weight = 0.2
ITEM.access = "V"
ITEM.useText = "#ITEM_Adrenaline_UseText"
ITEM.business = true
ITEM.category = "#ITEM_Category_Stimpacks"
ITEM.uniqueID = "stimpack_adrenaline"
ITEM.description = "#ITEM_Adrenaline_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("Stamina", 100)
	player:SetCharacterData("Fatigue", 0)
	player:SetHealth(math.Clamp(player:Health() + 25, 0, player:GetMaxHealth()))

	player:BoostAttribute(self.name, ATB_AGILITY, 40, 240)
	player:BoostAttribute(self.name, ATB_ENDURANCE, 90, 240)
	player:BoostAttribute(self.name, ATB_STRENGTH, 40, 240)

	cw.player:Notify(player, "#ITEM_Adrenaline_Effect")
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end


local eng = cw.lang:GetTable("en")
local ru = cw.lang:GetTable("ru")

eng["#ITEM_Adrenaline"] = "Adrenaline"
eng["#ITEM_Adrenaline_Desc"] = "A syringe filled with liquid. It is labeled as 'Adrenaline'."
eng["#ITEM_Adrenaline_Effect"] = "You feel sudden surge of energy. Your heartbeat skyrockets and you want to RUN."
eng["#ITEM_Adrenaline_UseText"] = "Inject"
eng["#ITEM_Category_Stimpacks"] = "Stimpacks"

ru["#ITEM_Adrenaline"] = "Адреналин"
ru["#ITEM_Adrenaline_Desc"] = "Шприц, наполненный жидкостью. На нем наклейка, на которой написано 'Адреналин'."
ru["#ITEM_Adrenaline_Effect"] = "Вы чувствуете сильный прилив сил. Ваше сердцебиение зашкаливает и все, что вы хотите в данную секунду это БЕЖАТЬ."
ru["#ITEM_Adrenaline_UseText"] = "Вколоть"
ru["#ITEM_Category_Stimpacks"] = "Вещества"
