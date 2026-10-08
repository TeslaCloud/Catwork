--- Defines the Geiger Counter item (`geiger_counter`) of the Radiation plugin, which has no use action and lets its
-- carrier hear and see radiation levels through `cwRadSystem:PlayerHasGeigerCounter`.

ITEM.name = 'Geiger Counter'
ITEM.PrintName = '#Item_GeigerCounter_PrintName'
ITEM.uniqueID = 'geiger_counter'
ITEM.cost = 0
ITEM.model = 'models/kali/miscstuff/stalker/sensor_a.mdl'
ITEM.weight = 0.1
ITEM.business = true
ITEM.description = '#Item_GeigerCounter_Description'

--- Called when the Geiger counter is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
