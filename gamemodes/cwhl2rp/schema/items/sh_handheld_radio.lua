--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Handheld Radio"
ITEM.PrintName = "#ITEM_Handheld_Radio"
ITEM.cost = 20
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.model = "models/handheld_radio.mdl"
ITEM.weight = 0.4
ITEM.access = "v"
ITEM.category = "Communication"
ITEM.business = true
ITEM.description = "#ITEM_Handheld_Radio_Desc"
ITEM.customFunctions = {"Frequency"}

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

if (SERVER) then
function ITEM:OnCustomFunction(player, name)
		if (name == "Frequency") then
			netstream.Start(player, "Frequency", player:GetCharacterData("frequency", ""))
		end
	end
end
