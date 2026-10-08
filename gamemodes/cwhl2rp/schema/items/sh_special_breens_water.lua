--- Defines the Special Breen's Water drink item, which restores full stamina and 8 health, boosts agility and stamina
-- by 3 for two minutes, leaves an empty soda can and hides its Drink option from Combine players.

ITEM.name = "Special Breen's Water"
ITEM.PrintName = '#ITEM_Special_Breens_Water'
ITEM.cost = 15
ITEM.skin = 2
ITEM.model = 'models/props_junk/popcan01a.mdl'
ITEM.weight = 0.35
ITEM.useText = 'Drink'
ITEM.business = true
ITEM.factions = { FACTION_MPF }
ITEM.category = 'Consumables'
ITEM.description = '#ITEM_Special_Breens_Water_Desc'
ITEM.thirst = 30

--- Restores full stamina and 8 health, boosts agility and stamina by 3 for two minutes and gives back an
-- empty soda can.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('Stamina', math.Clamp(player:GetCharacterData('Stamina') + 100, 0, 100))
  player:SetHealth(math.Clamp(player:Health() + 8, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_AGILITY, 3, 120)
  player:BoostAttribute(self.name, ATB_STAMINA, 3, 120)

  player:GiveItem('empty_soda_can', true)
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
