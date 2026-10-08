--- Defines the `Pack of Sorbents` medical item (`sorbent`) of the Diseases plugin, which cures diarrhea and restores
-- health when it is swallowed or given to the player being looked at with its `Give` action.

ITEM.name = 'Pack of Sorbents'
ITEM.PrintName = '#Item_Sorbent_PrintName'
ITEM.uniqueID = 'sorbent'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_bag001a.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Sorbent_Description'
ITEM.customFunctions = { 'Give' }

--- Cures the player's diarrhea, heals them and fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'diarrhea' then
    player:SetCharacterData('diseases', 'none')
  end

  player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Gives the sorbents to the player being looked at with "Give", curing their diarrhea and healing them.
  --
  -- Fires `PlayerHealed` with the giver as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = cwDiseases:FindPatient(player, self)

      if !lookingPly then return false end

      if lookingPly:GetCharacterData('diseases') == 'diarrhea' then
        lookingPly:SetCharacterData('diseases', 'none')
      end

      cw.player:Notify(player, L('Diseases_Gave_Sorbent'))
      player:TakeItem(self)
      lookingPly:SetHealth(
        math.Clamp(lookingPly:Health() + Schema:GetHealAmount(player, 1.5), 0, lookingPly:GetMaxHealth())
      )

      hook.Run('PlayerHealed', lookingPly, player, self)
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
