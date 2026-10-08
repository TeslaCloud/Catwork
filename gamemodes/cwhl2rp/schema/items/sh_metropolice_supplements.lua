--- Defines the Metropolice Supplements food item for the Metropolice Force faction, which heals 5 health and boosts
-- endurance by 2 for two minutes.

ITEM.name = 'Metropolice Supplements'
ITEM.PrintName = '#ITEM_Metropolice_Supplements'
ITEM.cost = 10
ITEM.model = 'models/props_lab/jar01b.mdl'
ITEM.weight = 0.6
ITEM.useText = 'Eat'
ITEM.factions = { FACTION_MPF }
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#ITEM_Metropolice_Supplements_Desc'
ITEM.hunger = 100
ITEM.thirst = 10

--- Heals 5 health and boosts endurance by 2 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()))
  player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 120)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
