--- Defines the Large Soda drink item, which refills stamina, heals 10 health, boosts agility and stamina by 5 for two
-- minutes, leaves an empty plastic bottle and hides its Drink option from Combine players.

ITEM.name = 'Large Soda'
ITEM.PrintName = '#ITEM_Large_Soda'
ITEM.cost = 12
ITEM.model = 'models/props_junk/garbage_plasticbottle003a.mdl'
ITEM.weight = 1.5
ITEM.access = 'w'
ITEM.useText = 'Drink'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#ITEM_Large_Soda_Desc'
ITEM.thirst = 35

--- Sets stamina to 100, heals 10 health, boosts agility and stamina by 5 for two minutes and gives back an
-- empty plastic bottle.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('stamina', 100)
  player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_AGILITY, 5, 120)
  player:BoostAttribute(self.name, ATB_STAMINA, 5, 120)

  player:GiveItem('empty_plastic_bottle', true)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end

--- Removes the Drink option from the item's menu when the local player is Combine.
function ITEM:OnEditFunctions(functions)
  if Schema:PlayerIsCombine(cw.client, false) then
    for k, v in pairs(functions) do
      if v == 'Drink' then functions[k] = nil end
    end
  end
end
