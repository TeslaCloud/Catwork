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

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'insomnia' then
    player:SetCharacterData('diseases', 'none')

    timer.Simple(360, function()
      if math.random(1, 2) == 1 then
        player:SetCharacterData('diseases', 'insomnia')
      end
    end)
  end

  player:SetCharacterData('Fatigue', 100)

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        if lookingPly:GetCharacterData('diseases') == 'insomnia' then
          lookingPly:SetCharacterData('diseases', 'none')

          timer.Simple(360, function()
            if math.random(1, 2) == 1 then
              lookingPly:SetCharacterData('diseases', 'insomnia')
            end
          end)
        end

        lookingPly:SetCharacterData('Fatigue', 100)
        cw.player:Notify(player, L('Diseases_Gave_SleepingPills'))
        player:TakeItem(player:FindItemByID('snotbad'))

        hook.Run('PlayerHealed', lookingPly, player, self)
      else
        cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

        return false
      end
    end
  end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
