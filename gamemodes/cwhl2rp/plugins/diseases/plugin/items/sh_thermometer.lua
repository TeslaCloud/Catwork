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
  local lookingPly = player:GetEyeTrace().Entity

  if lookingPly:IsPlayer() then
    if lookingPly:GetCharacterData('diseases') == 'fever' then
      cw.player:Notify(player, L('Diseases_Temperature', math.random(40.1, 43.6)))
    else
      cw.player:Notify(player, L('Diseases_Temperature', math.random(36.5, 37.0)))
    end

    return false
  else
    cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

    return false
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
