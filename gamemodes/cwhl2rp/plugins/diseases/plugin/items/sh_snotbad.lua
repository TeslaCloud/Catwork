--- Defines the `Sleeping Pills (Non-prescription)` medical item (`snotbad`) of the Diseases plugin, which sets the
-- `Fatigue` character data to 100 and cures insomnia with a one in two chance of a relapse six minutes later, when it
-- is swallowed or given to the player being looked at with its `Give` action.

ITEM.name = 'Sleeping Pills (Non-prescription)'
ITEM.PrintName = '#Item_Snotbad_PrintName'
ITEM.uniqueID = 'snotbad'
ITEM.cost = 0
ITEM.model = 'models/props_lab/jar01a.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Snotbad_Description'
ITEM.customFunctions = { 'Give' }

--- Cures insomnia with a one in two chance of relapse after six minutes, and sets `Fatigue` to 100.
--
-- Fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'insomnia' then
    player:SetCharacterData('diseases', 'none')

    if math.random(1, 2) == 1 then
      cwDiseases:SetDiseaseDelayed(player, 360, 'none', 'insomnia')
    end
  end

  player:SetCharacterData('Fatigue', 100)

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Gives the pills to the player being looked at with "Give"; same effect as using them.
  --
  -- Fires `PlayerHealed` with the giver as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = cwDiseases:FindPatient(player, self)

      if !lookingPly then return false end

      if lookingPly:GetCharacterData('diseases') == 'insomnia' then
        lookingPly:SetCharacterData('diseases', 'none')

        if math.random(1, 2) == 1 then
          cwDiseases:SetDiseaseDelayed(lookingPly, 360, 'none', 'insomnia')
        end
      end

      lookingPly:SetCharacterData('Fatigue', 100)
      cw.player:Notify(player, L('Diseases_Gave_SleepingPills'))
      player:TakeItem(self)

      hook.Run('PlayerHealed', lookingPly, player, self)
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
