--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Health Vial"
ITEM.PrintName = "#ITEM_Health_Vial"
ITEM.cost = 15
ITEM.model = "models/healthvial.mdl"
ITEM.weight = 0.5
ITEM.access = "v"
ITEM.useText = "Drink"
ITEM.factions = {FACTION_MPF, FACTION_OTA}
ITEM.category = "Medical"
ITEM.business = true
ITEM.useSound = "items/medshot4.wav"
ITEM.description = "#ITEM_Health_Vial_Desc"
ITEM.customFunctions = {"Give"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

	hook.Run("PlayerHealed", player, player, self)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

if (SERVER) then
function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			cw.player:RunClockworkCommand(player, "CharHeal", "health_vial")
		end
	end
end
