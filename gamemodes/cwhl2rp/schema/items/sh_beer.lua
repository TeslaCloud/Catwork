--- Defines the Beer item on `alcohol_base`, which heals 10 health, boosts agility by 2 for two minutes and leaves an
-- empty glass bottle.

ITEM.baseItem = 'alcohol_base'
ITEM.name = 'Beer'
ITEM.PrintName = '#ITEM_Beer'
ITEM.cost = 6
ITEM.model = 'models/props_junk/garbage_glassbottle003a.mdl'
ITEM.weight = 0.6
ITEM.access = 'w'
ITEM.business = true
ITEM.attributes = { Strength = 2 }
ITEM.description = '#ITEM_Beer_Desc'
ITEM.thirst = 25

--- Heals 10 health, boosts agility by 2 for two minutes and gives back an empty glass bottle.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_AGILITY, 2, 120)

  player:GiveItem('empty_glass_bottle', true)
end
