--- Defines the Bandage medical item, which heals the user by `Schema:GetHealAmount` and has a Give option that runs the
-- `CharHeal` command on another character.

ITEM.name = 'Bandage'
ITEM.PrintName = '#ITEM_Bandage'
ITEM.cost = 8
ITEM.model = 'models/props_wasteland/prison_toiletchunk01f.mdl'
ITEM.weight = 0.5
ITEM.access = '1v'
ITEM.useText = 'Apply'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#ITEM_Bandage_Desc'
ITEM.customFunctions = { 'Give' }

--- Heals the player by `Schema:GetHealAmount`, capped at max health, and fires the `PlayerHealed` hook.
function ITEM:OnUse(player, itemEntity)
  player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player), 0, player:GetMaxHealth()))

  hook.Run('PlayerHealed', player, player, self)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end

if SERVER then
  --- Runs the `CharHeal` command with this item when the Give option is chosen.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      cw.player:RunClockworkCommand(player, 'CharHeal', 'bandage')
    end
  end
end
