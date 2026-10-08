--- Defines the `Pack of Antibiotics` medical item (`antibiotics`) of the Diseases plugin, which cures fever, cough and
-- pneumonia and restores health when it is swallowed or given to the player being looked at with its `Give` action.

ITEM.name = 'Pack of Antibiotics'
ITEM.PrintName = '#Item_Antibiotics_PrintName'
ITEM.uniqueID = 'antibiotics'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_bag001a.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Antibiotics_Description'
ITEM.customFunctions = { 'Give' }

--- Cures fever, cough or pneumonia, heals the player and fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  local disease = player:GetCharacterData('diseases')

  if disease == 'fever' or disease == 'cough' or disease == 'pneumonia' then
    player:SetCharacterData('diseases', 'none')
  end

  player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Gives the antibiotics to the player being looked at with "Give", curing and healing them.
  --
  -- Fires `PlayerHealed` with the giver as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = cwDiseases:FindPatient(player, self)

      if !lookingPly then return false end

      local disease = lookingPly:GetCharacterData('diseases')

      if disease == 'fever' or disease == 'cough' or disease == 'pneumonia' then
        lookingPly:SetCharacterData('diseases', 'none')
      end

      cw.player:Notify(player, L('Diseases_Gave_Antibiotics'))
      player:TakeItem(self)
      lookingPly:SetHealth(
        math.Clamp(lookingPly:Health() + Schema:GetHealAmount(player, 1.5), 0, lookingPly:GetMaxHealth())
      )

      hook.Run('PlayerHealed', lookingPly, player, self)
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
