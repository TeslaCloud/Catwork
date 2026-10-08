--- Defines the Bleach consumable item, which deals 75 damage to the player who drinks it.

ITEM.name = 'Bleach'
ITEM.PrintName = '#ITEM_Bleach'
ITEM.cost = 6
ITEM.model = 'models/props_junk/garbage_plasticbottle001a.mdl'
ITEM.plural = 'Bleaches'
ITEM.weight = 0.8
ITEM.access = 'v'
ITEM.useText = 'Drink'
ITEM.business = true
ITEM.category = 'Consumables'
ITEM.uniqueID = 'bleach'
ITEM.description = '#ITEM_Bleach_Desc'

--- Deals 75 damage to the player who drinks it.
function ITEM:OnUse(player, itemEntity)
  player:TakeDamage(75, player, player)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
