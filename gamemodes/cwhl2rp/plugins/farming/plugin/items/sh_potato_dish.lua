--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Potato Dish'
ITEM.PrintName = '#Item_PotatoDish_PrintName'
ITEM.cost = 5
ITEM.model = 'models/props_junk/garbage_takeoutcarton001a.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'potato_dish'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_PotatoDish_Description'
ITEM.hunger = 65

--- Gives the player back an `empty_takeout_carton`.
function ITEM:OnUse(player, itemEntity)
  player:GiveItem('empty_takeout_carton', true)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
