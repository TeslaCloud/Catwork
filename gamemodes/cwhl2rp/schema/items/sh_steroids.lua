--- Defines the Steroids medical item, which refills stamina and boosts strength by 30 for seven minutes.

ITEM.name = 'Steroids'
ITEM.PrintName = '#ITEM_Steroids'
ITEM.cost = 12
ITEM.model = 'models/props_junk/garbage_metalcan002a.mdl'
ITEM.weight = 0.2
ITEM.access = 'w'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#ITEM_Steroids_Desc'

--- Sets stamina to 100 and boosts strength by 30 for seven minutes.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('stamina', 100)
  player:BoostAttribute(self.name, ATB_STRENGTH, 30, 420)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
