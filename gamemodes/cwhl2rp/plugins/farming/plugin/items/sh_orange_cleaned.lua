--- Defines the `Cleaned Orange` item (`orange_cleaned`) of the Farming plugin, a food item that heals 15 health and
-- boosts endurance and strength by 10 for two minutes.

ITEM.name = 'Cleaned Orange'
ITEM.PrintName = '#Item_OrangeCleaned_PrintName'
ITEM.cost = 5
ITEM.model = 'models/props/cs_italy/orange.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'orange_cleaned'
ITEM.useText = 'Eat'
ITEM.category = 'Consumables'
ITEM.business = true
ITEM.description = '#Item_OrangeCleaned_Description'

--- Heals the player by 15 and boosts endurance and strength by 10 for two minutes.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + 15, 0, player:GetMaxHealth()))

  player:BoostAttribute(self.name, ATB_ENDURANCE, 10, 120)
  player:BoostAttribute(self.name, ATB_STRENGTH, 10, 120)
  player:EmitSound('vo/npc/male01/finally.wav')
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
