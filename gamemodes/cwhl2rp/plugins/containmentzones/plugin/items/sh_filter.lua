
ITEM.name = 'Filter'
ITEM.PrintName = '#Item_Filter_PrintName'
ITEM.uniqueID = 'filter'
ITEM.cost = 0
ITEM.model = 'models/Items/battery.mdl'
ITEM.useText = '#Containment_UseText_ReplaceFilter'
ITEM.useSound = false
ITEM.weight = 0.1
ITEM.business = true
ITEM.description = '#Item_Filter_Description'
ITEM:AddData('energy', 100, true)

if CLIENT then
  --- Returns the filter's description with its remaining charge appended.
  --
  -- @return [String The description, or `false` when it is empty]
  function ITEM:GetClientSideDescription()
    local desc = L(self.description)
    local filter = self:GetData('energy')

    if filter then
      desc = L('#Item_Filter_Description')..'\n'..L('#Item_Filter_Condition:'..filter..';')
    end

    return (desc != '' and desc)
  end
end

--- Swaps the filter into the player's gas mask, returning the old filter if it had charge left.
--
-- Civil Protection refill their `cp_filter` character data; other players need an equipped
-- gas mask, otherwise the filter is not used up.
--
-- @return [Boolean `false` when the player has no equipped gas mask]
function ITEM:OnUse(player, itemEntity)
  if player:GetFaction() == FACTION_MPF then
    local energy = self:GetData('energy', 0)
    local oldenergy = math.floor(player:GetCharacterData('cp_filter', 0))
    player:SetCharacterData('cp_filter', energy)

    if oldenergy > 0 then
      local oldfilter = player:GiveItem('filter', true)
      oldfilter:SetData('energy', oldenergy)
    end
  else
    local gasmasks = player:GetInventory()['gasmask']

    if gasmasks then
      local gasmask_equipped

      for k, gasmask in pairs(gasmasks) do
        if !gasmask:GetData('equip') then continue end

        gasmask_equipped = gasmask
      end

      if gasmask_equipped then
        local energy = self:GetData('energy', 0)
        local oldenergy = math.floor(gasmask_equipped:GetData('energy', 0))
        gasmask_equipped:SetData('energy', energy)

        if oldenergy > 0 then
          local oldfilter = player:GiveItem('filter', true)
          oldfilter:SetData('energy', oldenergy)
        end
      else
        return false
      end
    else
      return false
    end
  end
end

--- Called when the filter is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
