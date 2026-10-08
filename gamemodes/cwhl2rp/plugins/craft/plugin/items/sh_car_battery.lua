--- Defines the Car Battery item (`car_battery`) of the Craft plugin, an item in the Materials category that no
-- blueprint uses yet.

ITEM.name = 'Car Battery'
ITEM.PrintName = '#Item_CarBattery_Name'
ITEM.model = 'models/items/car_battery01.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_CarBattery_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
