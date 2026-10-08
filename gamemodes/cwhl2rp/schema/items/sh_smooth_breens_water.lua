--- Defines the Smooth Breen's Water drink item (`smooth_breens_water`), which restores 80 stamina and 6 health, boosts
-- agility by 2 for two minutes, leaves an empty soda can and hides its Drink option from Combine players.

ITEM.name = "Smooth Breen's Water"
ITEM.PrintName = '#ITEM_Smooth_Breens_Water'
ITEM.uniqueID = 'smooth_breens_water'
ITEM.cost = 12
ITEM.skin = 1
ITEM.model = 'models/props_junk/popcan01a.mdl'
ITEM.weight = 0.35
ITEM.access = '1'
ITEM.useText = 'Drink'
ITEM.business = true
ITEM.factions = { FACTION_MPF }
ITEM.category = 'Consumables'
ITEM.description = '#ITEM_Smooth_Breens_Water_Desc'
ITEM.thirst = 25

--- Restores 80 stamina and 6 health, boosts agility by 2 for two minutes and gives back an empty soda can.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('Stamina', math.Clamp(player:GetCharacterData('Stamina', 100) + 80, 0, 100))
  player:SetHealth(math.Clamp(player:Health() + 6, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_AGILITY, 2, 120)

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
