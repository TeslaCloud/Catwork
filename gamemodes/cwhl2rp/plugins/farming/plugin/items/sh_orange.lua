--- Defines the `Orange` item (`orange`) of the Farming plugin, which is peeled on use to give an `orange_cleaned` item.

ITEM.name = 'Orange'
ITEM.PrintName = '#Item_Orange_PrintName'
ITEM.cost = 5
ITEM.model = 'models/props/cs_italy/orange.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'orange'
ITEM.useText = '#Farming_UseText_Peel'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_Orange_Description'

--- Peels the orange, giving the player an `orange_cleaned`.
function ITEM:OnUse(player, itemEntity)
  player:FastGiveItem('orange_cleaned')
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
