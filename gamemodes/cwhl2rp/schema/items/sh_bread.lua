--- Defines the Bread food item, which boosts strength and endurance by 2 for two minutes.

ITEM.name = 'Bread'
ITEM.PrintName = '#Item_Bread_PrintName'
ITEM.cost = 25
ITEM.model = 'models/bioshockinfinite/dread_loaf.mdl'
ITEM.weight = 0.4
ITEM.access = 'v'
ITEM.useText = 'Eat'
ITEM.business = false
ITEM.category = 'Consumables'
ITEM.description = '#Item_Bread_Description'
ITEM.hunger = 35

--- Boosts strength and endurance by 2 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:BoostAttribute(self.name, ATB_STRENGHT, 2, 120)
  player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
