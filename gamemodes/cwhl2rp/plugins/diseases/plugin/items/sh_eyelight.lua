--- Defines the `Medical Penlight` item of the Diseases plugin, a reusable diagnostic tool that tells its user whether
-- the player being looked at is blind or colour blind.

ITEM.name = 'Medical Penlight'
ITEM.PrintName = '#Item_Eyelight_PrintName'
ITEM.cost = 50
ITEM.model = 'models/lagmite/lagmite.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Apply'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Eyelight_Description'

--- Examines the eyes of the player being looked at and reports any blindness.
--
-- Always returns `false`, so the penlight is never used up.
function ITEM:OnUse(player, itemEntity)
  local lookingPly = cwDiseases:FindPatient(player)

  if !lookingPly then return false end

  local disease = lookingPly:GetCharacterData('diseases')

  if disease == 'blindness' then
    cw.player:Notify(player, L('Diseases_Eyelight_Blind'))
  elseif disease == 'colorblindness' then
    cw.player:Notify(player, L('Diseases_Eyelight_Colorblind'))
  else
    cw.player:Notify(player, L('Diseases_Eyelight_Normal'))
  end

  return false
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
