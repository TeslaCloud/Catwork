--- Defines the `Popcorn` item (`popcorn`) of the Farming plugin, a food item that restores 25 hunger and leaves an
-- `empty_carton`.

ITEM.name = 'Popcorn'
ITEM.PrintName = '#Item_Popcorn_PrintName'
ITEM.cost = 15
ITEM.model = 'models/bioshockinfinite/topcorn_bag.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'popcorn'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_Popcorn_Description'
ITEM.hunger = 25

--- Gives the player back an `empty_carton`.
function ITEM:OnUse(player, itemEntity)
  player:GiveItem('empty_carton', true)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
