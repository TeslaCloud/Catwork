--- Defines the Sardine food item, which boosts strength and endurance by 5 for two minutes.

ITEM.name = 'Sardine'
ITEM.PrintName = '#Item_Sardine_PrintName'
ITEM.cost = 50
ITEM.model = 'models/bioshockinfinite/cardine_can_open.mdl'
ITEM.weight = 0.7
ITEM.access = 'v'
ITEM.useText = 'Eat'
ITEM.business = false
ITEM.category = 'Consumables'
ITEM.description = '#Item_Sardine_Description'
ITEM.hunger = 40
ITEM.thirst = -5

--- Boosts strength and endurance by 5 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:BoostAttribute(self.name, ATB_STRENGHT, 5, 120)
  player:BoostAttribute(self.name, ATB_ENDURANCE, 5, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
