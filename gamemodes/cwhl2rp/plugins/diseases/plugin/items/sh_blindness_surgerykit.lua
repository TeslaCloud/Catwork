ITEM.name = 'Eye Surgery Kit'
ITEM.PrintName = '#Item_BlindnessSurgerykit_PrintName'
ITEM.cost = 150
ITEM.model = 'models/Items/BoxMRounds.mdl'
ITEM.weight = 0.2
ITEM.access = 'Q'
ITEM.useText = 'Apply'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_BlindnessSurgerykit_Description'

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
  local lookingPly = player:GetEyeTrace().Entity

  if lookingPly:IsPlayer() then
    if lookingPly:GetCharacterData('diseases') == 'blindness' then
      cw.player:Notify(player, L('Diseases_Surgery_Blindness'))
      lookingPly:SetCharacterData('diseases', 'none')
    elseif lookingPly:GetCharacterData('diseases') == 'colorblindness' then
      cw.player:Notify(player, L('Diseases_Surgery_Colorblindness'))
      lookingPly:SetCharacterData('diseases', 'none')
    else
      cw.player:Notify(player, L('Diseases_Surgery_Wasted'))
    end
  else
    cw.player:Notify(player, L('Diseases_MustLookAtPatient'))

    return false
  end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
