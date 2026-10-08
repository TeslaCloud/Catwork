--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Premium Supplements'
ITEM.PrintName = '#ITEM_Premium_Supplements'
ITEM.uniqueID = 'premium_supplements'
ITEM.model = 'models/pg_plops/pg_food/pg_tortellinat.mdl'
ITEM.weight = 1
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.description = '#ITEM_Premium_Supplements_Desc'
ITEM.hunger = 75
ITEM.thirst = 5

--- Heals 5 health, boosts endurance by 2 for two minutes and gives back an empty cardboard box.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()))
  player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)

  player:GiveItem('empty_cardboard', true)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
