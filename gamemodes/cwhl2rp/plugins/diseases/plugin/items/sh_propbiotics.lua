--- Defines the `Pack of Probiotics` medical item (`probiotics`) of the Diseases plugin, which cures diarrhea when it is
-- swallowed or given to the player being looked at with its `Give` action.

ITEM.name = 'Pack of Probiotics'
ITEM.PrintName = '#Item_Probiotics_PrintName'
ITEM.uniqueID = 'probiotics'
ITEM.cost = 25
ITEM.model = 'models/props_pipes/pipe01_connector01.mdl'
ITEM.weight = 0.2
ITEM.access = 'q'
ITEM.useText = 'Swallow'
ITEM.category = 'Medical'
ITEM.business = true
ITEM.description = '#Item_Probiotics_Description'
ITEM.customFunctions = { 'Give' }

--- Cures the player's diarrhea and fires `PlayerHealed`.
function ITEM:OnUse(player, itemEntity)
  if player:GetCharacterData('diseases') == 'diarrhea' then
    player:SetCharacterData('diseases', 'none')
  end

  hook.Run('PlayerHealed', player, player, self)
end

if SERVER then
  --- Gives the probiotics to the player being looked at with "Give", curing their diarrhea.
  --
  -- Fires `PlayerHealed` with the giver as the healer. Returns `false` when no player is looked at.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Give' then
      local lookingPly = player:GetEyeTrace().Entity

      if lookingPly:IsPlayer() then
        if lookingPly:GetCharacterData('diseases') == 'diarrhea' then
          lookingPly:SetCharacterData('diseases', 'none')
        end

        cw.player:Notify(player, L('Diseases_Gave_Probiotics'))
        player:TakeItem(player:FindItemByID('probiotics'))

        hook.Run('PlayerHealed', lookingPly, player, self)
      else
        cw.player:Notify(player, L('Diseases_MustLookAtPerson'))

        return false
      end
    end
  end
end

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
