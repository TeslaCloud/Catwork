--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Banana'
ITEM.PrintName = '#Item_Banana_PrintName'
ITEM.cost = 5
ITEM.model = 'models/props/cs_italy/bananna.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'banana'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_Banana_Description'
ITEM.hunger = 10

--- Lets the item be eaten; its hunger and other effects come from the item fields.
function ITEM:OnUse(player, itemEntity)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
