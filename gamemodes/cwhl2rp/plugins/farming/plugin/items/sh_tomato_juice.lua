--- Defines the `Tomato Juice` item (`tomato_juice`) of the Farming plugin, a drink that restores 50 thirst and leaves
-- an `empty_soda_can`.

ITEM.name = 'Tomato Juice'
ITEM.PrintName = '#Item_TomatoJuice_PrintName'
ITEM.cost = 25
ITEM.model = 'models/props_nunk/popcan01a.mdl'
ITEM.weight = 0.1
ITEM.uniqueID = 'tomato_juice'
ITEM.access = 'v'
ITEM.useText = 'Drink'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_TomatoJuice_Description'
ITEM.thirst = 50

--- Gives the player back an `empty_soda_can`.
function ITEM:OnUse(player, itemEntity)
  player:GiveItem('empty_soda_can', true)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
