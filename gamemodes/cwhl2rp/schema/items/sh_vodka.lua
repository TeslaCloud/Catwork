--- Defines the Vodka item (`vodka`) on `alcohol_base`, which heals 15 health, boosts strength by 15 for two minutes and
-- leaves an empty glass bottle.

ITEM.baseItem = 'alcohol_base'
ITEM.name = 'Vodka'
ITEM.PrintName = '#Item_Vodka_PrintName'
ITEM.cost = 13
ITEM.model = 'models/props_junk/garbage_glassbottle002a.mdl'
ITEM.weight = 0.2
ITEM.access = 'w'
ITEM.uniqueID = 'vodka'
ITEM.business = true
ITEM.attributes = { Strength = 3 }
ITEM.thirst = -15
ITEM.hunger = -20
ITEM.fatigue = -30
ITEM.description = '#Item_Vodka_Description'

--- Heals 15 health (up to 100), boosts strength by 15 for two minutes and gives back an empty glass bottle.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 15, 0, 100))

  player:BoostAttribute(self.name, 'str', 15, 120)

  player:GiveItem('empty_glass_bottle', true)
end
