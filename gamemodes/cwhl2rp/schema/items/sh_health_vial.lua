--- Defines the Health Vial medical item for the Metropolice Force and Overwatch factions, which heals one and a half
-- times `Schema:GetHealAmount` and has a Give option that runs the `CharHeal` command on another character.

ITEM.name = 'Health Vial'
ITEM.PrintName = '#ITEM_Health_Vial'
ITEM.cost = 15
ITEM.model = 'models/healthvial.mdl'
ITEM.weight = 0.5
ITEM.access = 'v'
ITEM.useText = 'Drink'
ITEM.factions = { FACTION_MPF, FACTION_OTA }
ITEM.category = 'Medical'
ITEM.business = true
ITEM.useSound = 'items/medshot4.wav'
ITEM.description = '#ITEM_Health_Vial_Desc'
ITEM.customFunctions = { 'Give' }

--- Heals the player by `Schema:GetHealAmount` times 1.5, capped at max health, and fires the `PlayerHealed` hook.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

  hook.Run('PlayerHealed', player, player, self)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end

if SERVER then
  --- Runs the `CharHeal` command with this item when the Give option is chosen.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      cw.player:RunClockworkCommand(player, 'CharHeal', 'health_vial')
    end
  end
end
