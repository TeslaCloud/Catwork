--- Defines the Melon food item, which heals 10 health and boosts agility by 2 for two minutes.

ITEM.name = 'Melon'
ITEM.PrintName = '#ITEM_Melon'
ITEM.cost = 8
ITEM.model = 'models/props_junk/watermelon01.mdl'
ITEM.weight = 1
ITEM.access = 'v'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#ITEM_Melon_Desc'
ITEM.thirst = 30
ITEM.hunger = 45

--- Heals 10 health and boosts agility by 2 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_AGILITY, 2, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
