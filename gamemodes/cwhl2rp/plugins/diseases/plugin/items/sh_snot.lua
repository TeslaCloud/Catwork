ITEM.name = 'Sleeping Pills (Prescription)'
ITEM.PrintName = '#Item_Snot_PrintName'
ITEM.uniqueID = 'snot'
ITEM.cost = 0
ITEM.model = 'models/props_lab/jar01a.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Snot_Description'
ITEM.customFunctions = { 'Give' }

--- Cures the player's insomnia, sets their `Fatigue` to 100 and fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'insomnia' then
    player:SetCharacterData('diseases', 'none')
  end

  player:SetCharacterData('Fatigue', 100)

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Gives the pills to the player being looked at with "Give", curing insomnia and resetting `Fatigue` to 0.
  --
  -- Fires `PlayerHealed` with the giver as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        if lookingPly:GetCharacterData('diseases') == 'insomnia' then
          lookingPly:SetCharacterData('diseases', 'none')
        end

        lookingPly:SetCharacterData('Fatigue', 0)
        cw.player:Notify(player, L('Diseases_Gave_SleepingPills'))
        player:TakeItem(player:FindItemByID('snot'))

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
