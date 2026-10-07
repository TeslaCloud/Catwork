ITEM.name = 'Potassium Cyanide'
ITEM.PrintName = '#Item_FastGreenLiquid_PrintName'
ITEM.uniqueID = 'fast_green_liquid'
ITEM.cost = 50
ITEM.model = 'models/healthvial.mdl'
ITEM.weight = 0.2
ITEM.factions = { FACTION_MPF }
ITEM.useText = 'Use'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_FastGreenLiquid_Description'
ITEM.customFunctions = { 'Inject' }

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('diseases', 'fast_deathinjection')
  cw.player:Notify(player, L('Diseases_Injected_Self'))
end

if SERVER then
  function ITEM:OnCustomFunction(player, name)
    if name == 'Inject' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        lookingPly:SetCharacterData('diseases', 'fast_deathinjection')
        cw.player:Notify(player, L('Diseases_Injected_Other'))
        player:TakeItem(player:FindItemByID('fast_green_liqud'))
      else
        cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

        return false
      end
    end
  end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
