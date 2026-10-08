--- Defines the `Corn` item (`corn`) of the Farming plugin, a food item that restores 5 hunger.

ITEM.name = 'Corn'
ITEM.PrintName = '#Item_Corn_PrintName'
ITEM.cost = 5
ITEM.model = 'models/bioshockinfinite/porn_on_cob.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'corn'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_Corn_Description'
ITEM.hunger = 5

--- Lets the item be eaten; its hunger and other effects come from the item fields.
function ITEM:OnUse(player, itemEntity)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
