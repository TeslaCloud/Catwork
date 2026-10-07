
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

function ITEM:OnDrop(player, position) end
