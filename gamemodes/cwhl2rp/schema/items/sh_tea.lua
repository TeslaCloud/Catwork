--- Defines the Tea drink item, which heals 5 health and boosts endurance and strength by 1 for two minutes.

ITEM.name = 'Tea'
ITEM.PrintName = '#Item_Tea_PrintName'
ITEM.cost = 6
ITEM.model = 'models/props_junk/garbage_coffeemug001a.mdl'
ITEM.weight = 0.1
ITEM.useText = 'Drink'
ITEM.category = 'Consumables'
ITEM.business = false
ITEM.description = '#Item_Tea_Description'
ITEM.fatigue = 35
ITEM.thirst = 25

--- Heals 5 health and boosts endurance and strength by 1 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)
  player:BoostAttribute(self.name, ATB_STRENGTH, 1, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
