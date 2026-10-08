--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Boiled Corn'
ITEM.PrintName = '#Item_BoiledCorn_PrintName'
ITEM.cost = 15
ITEM.model = 'models/bioshockinfinite/porn_on_cob.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'boiled_corn'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_BoiledCorn_Description'
ITEM.hunger = 35

--- Lets the item be eaten; its hunger and other effects come from the item fields.
function ITEM:OnUse(player, itemEntity)
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
