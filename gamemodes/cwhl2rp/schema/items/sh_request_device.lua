--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Request Device"
ITEM.PrintName = "#ITEM_Request_Device"
ITEM.cost = 15
ITEM.model = "models/gibs/shield_scanner_gib1.mdl"
ITEM.weight = 0.5
ITEM.access = "1"
ITEM.category = "Communication"
ITEM.factions = {FACTION_MPF}
ITEM.business = true
ITEM.description = "#ITEM_Request_Device_Desc"

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
