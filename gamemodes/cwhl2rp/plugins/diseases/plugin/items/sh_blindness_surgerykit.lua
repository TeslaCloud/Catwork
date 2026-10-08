--- Defines the `Eye Surgery Kit` medical item of the Diseases plugin, sold to holders of the `Q` heavy medicaments
-- flag, which is applied to the player being looked at and cures their blindness or colour blindness.

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

--- Operates on the player being looked at, curing blindness or colour blindness.
--
-- The kit is used up even when the patient has neither. Returns `false`, keeping the kit, when no
-- player is looked at.
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

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
