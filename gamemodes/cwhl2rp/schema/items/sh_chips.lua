--- Defines the Chips food item, which boosts agility and stamina by 3 for two minutes.

ITEM.name = 'Chips'
ITEM.PrintName = '#Item_Chips_PrintName'
ITEM.cost = 35
ITEM.model = 'models/bioshockinfinite/bag_of_hhips.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.useText = 'Eat'
ITEM.business = false
ITEM.category = 'Consumables'
ITEM.description = '#Item_Chips_Description'
ITEM.hunger = 15
ITEM.thirst = -10

--- Boosts agility and stamina by 3 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:BoostAttribute(self.name, ATB_AGILITY, 3, 120)
  player:BoostAttribute(self.name, ATB_STAMINA, 3, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
