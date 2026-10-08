ITEM.name = 'Syringe of Alomorphine'
ITEM.PrintName = '#Item_GreenAntidote_PrintName'
ITEM.cost = 50
ITEM.model = 'models/healthvial.mdl'
ITEM.weight = 0.2
ITEM.factions = { FACTION_MPF }
ITEM.useText = 'Use'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_GreenAntidote_Description'
ITEM.customFunctions = { 'Inject' }

--- Cures the slow lethal poison (`slow_deathinjection`); the fast one is not affected.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'slow_deathinjection' then
    player:SetCharacterData('diseases', 'none')
    cw.player:Notify(player, L('Diseases_Antidote_Self'))
  elseif player:GetCharacterData('diseases') == 'fast_deathinjection' then
    cw.player:Notify(player, L('Diseases_Antidote_SelfNoEffect'))
  end
end

if SERVER then
  --- Injects the antidote into the player being looked at using "Inject".
  --
  -- Cures `slow_deathinjection` only. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Inject' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        if lookingPly:GetCharacterData('diseases') == 'slow_deathinjection' then
          lookingPly:SetCharacterData('diseases', 'none')
        elseif lookingPly:GetCharacterData('diseases') == 'fast_deathinjection' then
          cw.player:Notify(player, L('Diseases_Antidote_OtherNoEffect'))
        end

        cw.player:Notify(player, L('Diseases_Antidote_Other'))

        return true
      else
        cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

        return false
      end
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
