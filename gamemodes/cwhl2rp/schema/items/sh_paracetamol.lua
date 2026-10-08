--- Defines the Paracetamol medical item, which refills stamina and boosts endurance by 30 for two minutes.

ITEM.name = 'Paracetamol'
ITEM.PrintName = '#ITEM_Paracetamol'
ITEM.cost = 10
ITEM.model = 'models/props_junk/garbage_metalcan002a.mdl'
ITEM.weight = 0.2
ITEM.access = '1v'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#ITEM_Paracetamol_Desc'

--- Sets stamina to 100 and boosts endurance by 30 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('Stamina', 100)
  player:BoostAttribute(self.name, ATB_ENDURANCE, 30, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
