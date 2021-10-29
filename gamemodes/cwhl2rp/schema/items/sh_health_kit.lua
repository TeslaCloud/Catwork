--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Health Kit"
ITEM.PrintName = "#ITEM_Health_Kit"
ITEM.cost = 30
ITEM.model = "models/items/healthkit.mdl"
ITEM.weight = 1
ITEM.access = "v"
ITEM.useText = "Apply"
ITEM.factions = {FACTION_MPF, FACTION_OTA}
ITEM.category = "Medical"
ITEM.business = true
ITEM.useSound = "items/medshot4.wav"
ITEM.blacklist = {CLASS_MPR}
ITEM.description = "#ITEM_Health_Kit_Desc"
ITEM.customFunctions = {"Give"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 2), 0, player:GetMaxHealth()))

	hook.Run("PlayerHealed", player, player, self)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

if (SERVER) then
function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			cw.player:RunClockworkCommand(player, "CharHeal", "health_kit")
		end
	end
end
