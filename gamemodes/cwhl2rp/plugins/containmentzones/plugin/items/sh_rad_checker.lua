--- Defines the PDB-6 item (`rad_checker`) of the Radiation plugin, a device that tells a player with at least half of
-- the Medical attribute the radiation dose (`radlevel`) of the player or NPC they are looking at from close up.

ITEM.name = 'PDB-6'
ITEM.PrintName = '#Item_RadChecker_PrintName'
ITEM.uniqueID = 'rad_checker'
ITEM.cost = 0
ITEM.model = 'models/Items/car_battery01.mdl'
ITEM.useText = '#Containment_UseText_Check'
ITEM.useSound = false
ITEM.weight = 2.5
ITEM.business = true
ITEM.description = '#Item_RadChecker_Description'

--- Tells the player the radiation dose of the player or NPC they are looking at.
--
-- Requires at least half of the Medical attribute and a target closer than 55 units. The
-- device is kept.
function ITEM:OnUse(player, itemEntity)
  local medical = cw.attributes:Fraction(player, ATB_MEDICAL, 100)

  if medical >= 50 then
    local traceent = player:GetEyeTrace().Entity

    if IsValid(traceent) then
      local rad = L('Containment_RadDose_Unknown')

      if traceent:IsPlayer() or traceent:IsNPC() then
        if traceent:GetPos():Distance(player:GetPos()) < 55 then
          if traceent.GetCharacterData then
            rad = L('Containment_RadDose_Value', math.Round(traceent:GetCharacterData('radlevel', 0), 2))
          end

          cw.player:Notify(player, L('Containment_RadDose')..' '..rad)
        end
      end
    end
  else
    cw.player:Notify(player, L('Containment_RadChecker_NoSkill'))
  end

  return false
end

--- Called when the PDB-6 is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
