--- Defines the `Inhaler` medical item (`ingall`) of the Diseases plugin, which cures its user's pneumonia one to two
-- minutes after use; its custom action for treating the player being looked at is listed under another name than the
-- `Give` its handler reacts to, so only self-use has an effect.

ITEM.name = 'Inhaler'
ITEM.PrintName = '#Item_Ingall_PrintName'
ITEM.uniqueID = 'ingall'
ITEM.cost = 0
ITEM.model = 'models/props_combine/breenlight.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Use'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Ingall_Description'
ITEM.customFunctions = { 'Use on...' }

--- Cures the player's pneumonia after one to two minutes and fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'pneumonia' then
    cwDiseases:SetDiseaseDelayed(player, math.random(60, 120), 'pneumonia', 'none')
  end

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Uses the inhaler on the player being looked at with "Use on...", curing their pneumonia after a delay.
  --
  -- Fires `PlayerHealed` with the user as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Use on...' then
      local lookingPly = cwDiseases:FindPatient(player, self)

      if !lookingPly then return false end

      if lookingPly:GetCharacterData('diseases') == 'pneumonia' then
        cwDiseases:SetDiseaseDelayed(lookingPly, math.random(60, 120), 'pneumonia', 'none')
      end

      player:EmitSound('ambient/voices/cough1.wav', 100, 100)
      cw.player:Notify(player, L('Diseases_Used_Inhaler'))
      player:TakeItem(self)

      hook.Run('PlayerHealed', lookingPly, player, self)
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
