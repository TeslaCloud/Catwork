--- Defines the Milk Carton drink item, which heals 5 health, boosts endurance and strength by 1 for two minutes and
-- leaves an empty carton.

ITEM.name = 'Milk Carton'
ITEM.PrintName = '#ITEM_Milk_Carton'
ITEM.cost = 6
ITEM.model = 'models/props_junk/garbage_milkcarton002a.mdl'
ITEM.weight = 0.7
ITEM.access = 'v'
ITEM.useText = 'Drink'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#ITEM_Milk_Carton_Desc'
ITEM.thirst = 25

--- Heals 5 health (up to 100), boosts endurance and strength by 1 for two minutes and gives back an empty
-- carton.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 5, 0, 100))

  player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)
  player:BoostAttribute(self.name, ATB_STRENGTH, 1, 120)

  player:GiveItem('empty_carton', true)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
