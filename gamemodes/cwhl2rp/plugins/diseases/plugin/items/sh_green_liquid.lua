--- Defines the `Syringe of Strychnine` item (`green_liquid`) of the Diseases plugin, a slow lethal poison sold to
-- `FACTION_MPF` that gives its user, or the player being looked at through its `Inject` action, the
-- `slow_deathinjection` disease.

ITEM.name = 'Syringe of Strychnine'
ITEM.PrintName = '#Item_GreenLiquid_PrintName'
ITEM.uniqueID = 'green_liquid'
ITEM.cost = 50
ITEM.model = 'models/healthvial.mdl'
ITEM.weight = 0.2
ITEM.factions = { FACTION_MPF }
ITEM.useText = 'Use'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_GreenLiquid_Description'
ITEM.customFunctions = { 'Inject' }

--- Injects the player with the slow lethal poison (`slow_deathinjection`).
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('diseases', 'slow_deathinjection')
  cw.player:Notify(player, L('Diseases_Injected_Self'))
end

if SERVER then
  --- Injects the player being looked at with the slow lethal poison using "Inject".
  --
  -- Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Inject' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        lookingPly:SetCharacterData('diseases', 'slow_deathinjection')
        cw.player:Notify(player, L('Diseases_Injected_Other'))
        player:TakeItem(player:FindItemByID('green_liqud'))
      else
        cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

        return false
      end
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
