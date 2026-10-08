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
    timer.Simple(math.random(60, 120), function()
      player:SetCharacterData('diseases', 'none')
    end)
  end

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Uses the inhaler on the player being looked at with "Give", curing their pneumonia after a delay.
  --
  -- Fires `PlayerHealed` with the user as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        if lookingPly:GetCharacterData('diseases') == 'pneumonia' then
          timer.Simple(math.random(60, 120), function()
            lookingPly:SetCharacterData('diseases', 'none')
          end)
        end

        player:EmitSound('ambient/voices/cough1.wav', 100, 100)
        cw.player:Notify(player, L('Diseases_Used_Inhaler'))
        player:TakeItem(player:FindItemByID('ingall'))

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
