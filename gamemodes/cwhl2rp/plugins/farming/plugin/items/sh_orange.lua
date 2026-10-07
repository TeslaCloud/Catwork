--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Orange'
ITEM.PrintName = '#Item_Orange_PrintName'
ITEM.cost = 5
ITEM.model = 'models/props/cs_italy/orange.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'orange'
ITEM.useText = '#Farming_UseText_Peel'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_Orange_Description'

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
  player:FastGiveItem('orange_cleaned')
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
