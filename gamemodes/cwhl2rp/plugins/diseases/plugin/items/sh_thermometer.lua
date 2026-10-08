--- Defines the `Thermometer` item of the Diseases plugin, a reusable diagnostic tool that tells its user the
-- temperature of the player being looked at, which is high when they have a fever.

ITEM.name = 'Thermometer'
ITEM.PrintName = '#Item_Thermometer_PrintName'
ITEM.cost = 50
ITEM.model = 'models/props_c17/TrapPropeller_Lever.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Apply'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Thermometer_Description'

--- Measures the temperature of the player being looked at, which is high when they have a fever.
--
-- Always returns `false`, so the thermometer is never used up.
function ITEM:OnUse(player, itemEntity)
  local lookingPly = cwDiseases:FindPatient(player)

  if !lookingPly then return false end

  if lookingPly:GetCharacterData('diseases') == 'fever' then
    cw.player:Notify(player, L('Diseases_Temperature', math.Round(math.Rand(40.1, 43.6), 1)))
  else
    cw.player:Notify(player, L('Diseases_Temperature', math.Round(math.Rand(36.5, 37.0), 1)))
  end

  return false
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
