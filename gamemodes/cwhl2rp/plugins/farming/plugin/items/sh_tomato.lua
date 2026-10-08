--- Defines the `Tomato` item (`tomato`) of the Farming plugin, a food item that restores 5 hunger and 10 thirst.

ITEM.name = 'Tomato'
ITEM.PrintName = '#Item_Tomato_PrintName'
ITEM.cost = 5
ITEM.model = 'models/bioshockinfinite/hext_apple.mdl'
ITEM.weight = 0.1
ITEM.uniqueID = 'tomato'
ITEM.access = 'v'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_Tomato_Description'
ITEM.hunger = 5
ITEM.thirst = 10

--- Lets the item be eaten; its hunger and other effects come from the item fields.
function ITEM:OnUse(player, itemEntity)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
