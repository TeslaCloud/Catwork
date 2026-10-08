--- Defines the `Syringe of Alomorphine` item of the Diseases plugin, an antidote sold to `FACTION_MPF` that cures the
-- slow lethal injection (`slow_deathinjection`) of its user, or of the player being looked at through its `Inject`
-- action, but has no effect on the fast one.

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
  local disease = player:GetCharacterData('diseases')

  if disease == 'slow_deathinjection' then
    player:SetCharacterData('diseases', 'none')
    cw.player:Notify(player, L('Diseases_Antidote_Self'))
  elseif disease == 'fast_deathinjection' then
    cw.player:Notify(player, L('Diseases_Antidote_SelfNoEffect'))
  end
end

if SERVER then
  --- Injects the antidote into the player being looked at using "Inject".
  --
  -- Cures `slow_deathinjection` only. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Inject' then
      local lookingPly = cwDiseases:FindPatient(player, self)

      if !lookingPly then return false end

      local disease = lookingPly:GetCharacterData('diseases')

      if disease == 'slow_deathinjection' then
        lookingPly:SetCharacterData('diseases', 'none')
      end

      if disease == 'fast_deathinjection' then
        cw.player:Notify(player, L('Diseases_Antidote_OtherNoEffect'))
      else
        cw.player:Notify(player, L('Diseases_Antidote_Other'))
      end

      player:TakeItem(self)
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
