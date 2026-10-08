--- Defines the `Orange Juice` item (`orange_juice`) of the Farming plugin, a drink that restores 55 thirst and leaves
-- an `empty_soda_can`.

ITEM.name = 'Orange Juice'
ITEM.PrintName = '#Item_OrangeJuice_PrintName'
ITEM.cost = 25
ITEM.model = 'models/props_nunk/popcan01a.mdl'
ITEM.weight = 0.1
ITEM.uniqueID = 'orange_juice'
ITEM.access = 'v'
ITEM.useText = 'Drink'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_OrangeJuice_Description'
ITEM.thirst = 55

--- Gives the player back an `empty_soda_can`.
function ITEM:OnUse(player, itemEntity)
  player:GiveItem('empty_soda_can', true)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
