ITEM.name = 'Paracetamol'
ITEM.PrintName = '#Item_Paracetamol_PrintName'
ITEM.uniqueID = 'paracetamol'
ITEM.cost = 25
ITEM.model = 'models/props_junk/garbage_metalcan001a.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Paracetamol_Description'
ITEM.customFunctions = { 'Give' }

--- Cures the player's fever.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'fever' then
    player:SetCharacterData('diseases', 'none')
  end
end

if SERVER then
  --- Gives the paracetamol to the player being looked at with "Give", curing their fever.
  --
  -- Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        if lookingPly:GetCharacterData('diseases') == 'fever' then
          lookingPly:SetCharacterData('diseases', 'none')
        end

        cw.player:Notify(player, L('Diseases_Gave_Paracetamol'))
        player:TakeItem(player:FindItemByID('paracetamol'))
      else
        cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

        return false
      end
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
