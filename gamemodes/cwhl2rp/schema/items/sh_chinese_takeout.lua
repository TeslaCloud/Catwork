--- Defines the Chinese Takeout food item, which heals 10 health, boosts endurance by 2 and accuracy by 1 for two
-- minutes and leaves an empty takeout carton.

ITEM.name = 'Chinese Takeout'
ITEM.PrintName = '#ITEM_Chinese_Takeout'
ITEM.cost = 8
ITEM.model = 'models/props_junk/garbage_takeoutcarton001a.mdl'
ITEM.weight = 0.6
ITEM.access = 'v'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.uniqueID = 'chinese_takeout'
ITEM.description = '#ITEM_Chinese_Takeout_Desc'
ITEM.hunger = 40

--- Heals 10 health, boosts endurance by 2 and accuracy by 1 for two minutes and gives back an empty
-- takeout carton.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
  player:BoostAttribute(self.name, ATB_ACCURACY, 1, 120)

  player:GiveItem('empty_takeout_carton', true)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
