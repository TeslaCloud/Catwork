--- Defines the Request Device item, which lets its carrier send requests to the Combine with the `/Request` command and
-- has no behaviour of its own.

ITEM.name = 'Request Device'
ITEM.PrintName = '#ITEM_Request_Device'
ITEM.cost = 15
ITEM.model = 'models/gibs/shield_scanner_gib1.mdl'
ITEM.weight = 0.5
ITEM.access = '1'
ITEM.category = 'Communication'
ITEM.factions = { FACTION_MPF }
ITEM.business = true
ITEM.description = '#ITEM_Request_Device_Desc'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
