--- Defines the `Special Diet Ration` medical item (`special_ration`) of the Diseases plugin, a food item with a
-- `hunger` value of 40 that cures gastritis and restores health when it is eaten or given to the player being looked
-- at with its `Give` action.

ITEM.name = 'Special Diet Ration'
ITEM.PrintName = '#Item_SpecialRation_PrintName'
ITEM.uniqueID = 'special_ration'
ITEM.cost = 0
ITEM.model = 'models/gibs/shield_scanner_gib2.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_SpecialRation_Description'
ITEM.hunger = 40
ITEM.customFunctions = { 'Give' }

--- Cures the player's gastritis, heals them and fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'gastrits' then
    player:SetCharacterData('diseases', 'none')
  end

  player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Feeds the ration to the player being looked at with "Give", curing their gastritis and healing them.
  --
  -- Fires `PlayerHealed` with the giver as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        if lookingPly:GetCharacterData('diseases') == 'gastrits' then
          lookingPly:SetCharacterData('diseases', 'none')
        end

        cw.player:Notify(player, L('Diseases_Fed'))
        player:TakeItem(player:FindItemByID('special_ration'))
        lookingPly:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

        hook.Run('PlayerHealed', lookingPly, player, self)
      else
        cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

        return false
      end
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
