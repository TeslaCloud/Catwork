--- Defines the `Potassium Cyanide` item (`fast_green_liquid`) of the Diseases plugin, a fast-acting lethal poison sold
-- to `FACTION_MPF` that gives its user, or the player being looked at through its `Inject` action, the
-- `fast_deathinjection` disease.

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

--- Injects the player with the fast-acting lethal poison (`fast_deathinjection`).
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('diseases', 'fast_deathinjection')
  cw.player:Notify(player, L('Diseases_Injected_Self'))
end

if SERVER then
  --- Injects the player being looked at with the fast-acting lethal poison using "Inject".
  --
  -- Returns `false` when no player is looked at.
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

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
