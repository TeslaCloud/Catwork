--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Corn'
ITEM.PrintName = '#Item_Corn_PrintName'
ITEM.cost = 5
ITEM.model = 'models/bioshockinfinite/porn_on_cob.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'corn'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_Corn_Description'
ITEM.hunger = 5

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
