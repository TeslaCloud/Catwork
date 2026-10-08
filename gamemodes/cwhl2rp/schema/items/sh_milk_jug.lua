--- Defines the Milk Jug drink item, which heals 10 health, boosts endurance and strength by 2 for two minutes and
-- leaves an empty jug.

ITEM.name = 'Milk Jug'
ITEM.PrintName = '#ITEM_Milk_Jug'
ITEM.cost = 8
ITEM.model = 'models/props_junk/garbage_milkcarton001a.mdl'
ITEM.weight = 1
ITEM.access = 'v'
ITEM.useText = 'Drink'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#ITEM_Milk_Jug_Desc'
ITEM.thirst = 35

--- Heals 10 health (up to 100), boosts endurance and strength by 2 for two minutes and gives back an empty
-- jug.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 10, 0, 100))

  player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
  player:BoostAttribute(self.name, ATB_STRENGTH, 2, 120)

  player:GiveItem('empty_jug', true)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
