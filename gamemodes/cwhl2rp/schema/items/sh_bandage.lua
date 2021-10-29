--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Bandage"
ITEM.PrintName = "#ITEM_Bandage"
ITEM.cost = 8
ITEM.model = "models/props_wasteland/prison_toiletchunk01f.mdl"
ITEM.weight = 0.5
ITEM.access = "1v"
ITEM.useText = "Apply"
ITEM.category = "Medical"
ITEM.business = true
ITEM.description = "#ITEM_Bandage_Desc"
ITEM.customFunctions = {"Give"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player), 0, player:GetMaxHealth()))

	hook.Run("PlayerHealed", player, player, self)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

if (SERVER) then
function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			cw.player:RunClockworkCommand(player, "CharHeal", "bandage")
		end
	end
end
