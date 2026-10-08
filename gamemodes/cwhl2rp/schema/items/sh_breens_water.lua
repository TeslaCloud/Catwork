--- Defines the Breen's Water drink item (`breens_water`), which restores 70 stamina and 4 health, boosts agility and
-- endurance by 1 for two minutes, leaves an empty soda can and hides its Drink option from Combine players.

ITEM.name = "Breen's Water"
ITEM.PrintName = '#ITEM_Breens_Water'
ITEM.cost = 10
ITEM.model = 'models/props_junk/popcan01a.mdl'
ITEM.weight = 0.35
ITEM.access = '1'
ITEM.useText = 'Drink'
ITEM.business = true
ITEM.category = 'Consumables'
ITEM.uniqueID = 'breens_water'
ITEM.description = '#ITEM_Breens_Water_Desc'
ITEM.thirst = 20

--- Restores 70 stamina and 4 health, boosts agility and endurance by 1 for two minutes and gives back an
-- empty soda can.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('Stamina', math.Clamp(player:GetCharacterData('Stamina', 100) + 70, 0, 100))
  player:SetHealth(math.Clamp(player:Health() + 4, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_AGILITY, 1, 120)
  player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 120)

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
