--- Defines the Vegetable Oil consumable item (`vegetable_oil`), which deals 5 damage to the player who drinks it and is
-- not sold in the business menu.

ITEM.name = 'Vegetable Oil'
ITEM.PrintName = '#ITEM_Vegetable_Oil'
ITEM.cost = 6
ITEM.model = 'models/props_junk/garbage_plasticbottle002a.mdl'
ITEM.weight = 0.6
ITEM.access = 'v'
ITEM.uniqueID = 'vegetable_oil'
ITEM.useText = 'Drink'
ITEM.business = false
ITEM.category = 'Consumables'
ITEM.description = '#ITEM_Vegetable_Oil_Desc'
ITEM.thirst = 10
ITEM.hunger = 35

--- Deals 5 damage to the player who drinks it.
function ITEM:OnUse(player, itemEntity)
  player:TakeDamage(5, player, player)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
