--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.baseItem = "clothes_base"
ITEM.name = "Resistance Uniform"
ITEM.PrintName = "#ITEM_Resistance_Uniform"
ITEM.group = "group03"
ITEM.weight = 3
ITEM.access = "m"
ITEM.business = true
ITEM.protection = 0.1
ITEM.description = "#ITEM_Resistance_Uniform_Desc"

-- Called when a replacement is needed for a player.
function ITEM:GetReplacement(player)
	if (string.lower(player:GetModel()) == "models/humans/group01/jasona.mdl") then
		return "models/humans/group03/male_02.mdl"
	end
end
