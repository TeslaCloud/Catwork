--- Defines the `Pack of Allergy Tablets` medical item (`allergy_tablet`) of the Diseases plugin, which cures an allergy
-- 30 to 60 seconds after it is given to the player being looked at with its `Give` action, while swallowing it oneself
-- cures gastritis instead.

ITEM.name = 'Pack of Allergy Tablets'
ITEM.PrintName = '#Item_AllergyTablet_PrintName'
ITEM.uniqueID = 'allergy_tablet'
ITEM.cost = 25
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_AllergyTablet_Description'
ITEM.customFunctions = { 'Give' }

--- Cures the player's allergy after 30 to 60 seconds and fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'allergy' then
    cwDiseases:SetDiseaseDelayed(player, math.random(30, 60), 'allergy', 'none')
  end

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Gives a tablet to the player being looked at with "Give", curing their allergy after a delay.
  --
  -- Fires `PlayerHealed` with the giver as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = cwDiseases:FindPatient(player, self)

      if !lookingPly then return false end

      if lookingPly:GetCharacterData('diseases') == 'allergy' then
        cwDiseases:SetDiseaseDelayed(lookingPly, math.random(30, 60), 'allergy', 'none')
      end

      player:TakeItem(self)
      cw.player:Notify(player, L('Diseases_Gave_AllergyTablet'))

      hook.Run('PlayerHealed', lookingPly, player, self)
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
