--- Defines the Beer Bad item on `alcohol_base`, shown as Low-Quality Beer, which heals 10 health, boosts agility by 12
-- for two minutes and leaves an empty glass bottle.

ITEM.baseItem = 'alcohol_base'
ITEM.name = 'Beer Bad'
ITEM.PrintName = '#Item_BeerBad_PrintName'
ITEM.cost = 6
ITEM.model = 'models/props_junk/garbage_glassbottle003a.mdl'
ITEM.weight = 0.4
ITEM.access = 'w'
ITEM.business = true
ITEM.attributes = { Strength = 1 }
ITEM.thirst = 15
ITEM.fatigue = -10
ITEM.description = '#Item_BeerBad_Description'

--- Heals 10 health (up to 100), boosts agility by 12 for two minutes and gives back an empty glass bottle.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 10, 0, 100))

  player:BoostAttribute(self.name, ATB_AGILITY, 12, 120)

  player:GiveItem('empty_glass_bottle', true)
end
