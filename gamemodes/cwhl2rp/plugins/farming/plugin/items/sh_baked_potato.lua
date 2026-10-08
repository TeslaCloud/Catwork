--- Defines the `Baked Potato` item (`baked_potato`) of the Farming plugin, a food item that restores 25 hunger.

ITEM.name = 'Baked Potato'
ITEM.PrintName = '#Item_BakedPotato_PrintName'
ITEM.cost = 5
ITEM.model = 'models/bioshockinfinite/hext_potato.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'baked_potato'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_BakedPotato_Description'
ITEM.hunger = 25

--- Lets the item be eaten; its hunger and other effects come from the item fields.
function ITEM:OnUse(player, itemEntity)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
