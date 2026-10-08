--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Antidepressants'
ITEM.PrintName = '#ITEM_Antidepressants'
ITEM.cost = 10
ITEM.model = 'models/props_junk/garbage_metalcan001a.mdl'
ITEM.weight = 0.2
ITEM.access = 'w'
ITEM.uniqueID = 'antidepressants'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#ITEM_Antidepressants_Desc'

--- Sets the `antidepressants` net var to ten minutes from now, raises endurance by 2 and lowers strength
-- by 2 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:SetNetVar('antidepressants', CurTime() + 600)

  player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
  player:BoostAttribute(self.name, ATB_STRENGTH, -2, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
