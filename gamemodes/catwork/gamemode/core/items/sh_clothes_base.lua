--- Defines the `clothes_base` base item for clothing, which changes the player's model while worn and restores the
-- default model when taken off.
--
-- The model comes from the item's `GetReplacement`, its `replacement`, or its `group`, a citizen model folder matched
-- to the player's own model. A `whitelist` of factions and an optional `CanPlayerWear` restrict who can wear the
-- clothes, and they cannot be dropped while worn.

ITEM.isBaseItem = true
ITEM.name = 'Clothes Base'
ITEM.model = 'models/props_c17/suitcase_passenger_physics.mdl'
ITEM.weight = 2
ITEM.useText = 'Wear'
ITEM.category = 'Clothing'
ITEM.description = '#Item_ClothesBase_Description'

--- Returns the citizen model file name matching the player's default model, for building a clothes model path.
--
-- Strips the folders from the player's default model. If that model is not a `male`/`female` citizen model, it
-- falls back to `male_05.mdl` or `female_04.mdl` by gender.
-- @param player=cw.client [Player The player whose default model is used]
-- @param group=nil [Boolean Keep the group folder in the result (fallback becomes `group05/...`)]
-- @return [String The model file name, with its group folder when `group` is set]
function ITEM:GetModelName(player, group)
  local modelName = nil

  if !player then
    player = cw.client
  end

  if group then
    modelName = string.gsub(string.lower(cw.player:GetDefaultModel(player)), '^.-/.-/', '')
  else
    modelName = string.gsub(string.lower(cw.player:GetDefaultModel(player)), '^.-/.-/.-/', '')
  end

  if !string.find(modelName, 'male') and !string.find(modelName, 'female') then
    if group then
      group = 'group05/'
    else
      group = ''
    end

    if player:GetGender() == GENDER_FEMALE then
      return group..'female_04.mdl'
    else
      return group..'male_05.mdl'
    end
  else
    return modelName
  end
end

--- Returns the model to show for the item in menus: `GetReplacement`, `replacement`, or the `group` citizen model.
-- @return [String The model path, or `nil` to use the item's own model]
function ITEM:GetClientSideModel()
  local replacement = nil

  if self.GetReplacement then
    replacement = self:GetReplacement(cw.client)
  end

  if isstring(replacement) then
    return replacement
  elseif self.replacement then
    return self.replacement
  elseif self.group then
    return 'models/humans/'..self.group..'/'..self:GetModelName()
  end
end

--- Sets the player's model to the clothes model when worn and restores the default model and skin when removed.
--
-- Calls the item's optional `OnChangedClothes(player, bIsWearing)` afterwards.
-- @param player [Player The player changing clothes]
-- @param bIsWearing [Boolean `true` when the clothes are put on, `false` when they are taken off]
function ITEM:OnChangeClothes(player, bIsWearing)
  if bIsWearing then
    local replacement = nil

    if self.GetReplacement then
      replacement = self:GetReplacement(player)
    end

    if isstring(replacement) then
      player:SetModel(replacement)
    elseif self.replacement then
      player:SetModel(self.replacement)
    elseif self.group then
      player:SetModel('models/humans/'..self.group..'/'..self:GetModelName(player))
    end
  else
    cw.player:SetDefaultModel(player)
    cw.player:SetDefaultSkin(player)
  end

  if self.OnChangedClothes then
    self:OnChangedClothes(player, bIsWearing)
  end
end

--- Returns whether the player is wearing these clothes; on the client it checks the local player.
-- @return [Boolean Whether the clothes are worn]
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
  if CLIENT then
    return cw.player:IsWearingItem(self)
  else
    return player:IsWearingItem(self)
  end
end

--- Takes the clothes off the player.
function ITEM:OnPlayerUnequipped(player, extraData)
  player:RemoveClothes()
end

--- Called when a player drops the clothes; blocks the drop while they are worn.
-- @return [Boolean `false` while the player wears the clothes, otherwise `nil`]
function ITEM:OnDrop(player, position)
  if player:IsWearingItem(self) then
    cw.player:Notify(player, '#CantDropWhenWearing')
    return false
  end
end

--- Dresses the player in the clothes if their faction is on the `whitelist` and `CanPlayerWear` allows it.
-- @return [Boolean `true` when worn (the item stays in the inventory), `false` otherwise]
function ITEM:OnUse(player, itemEntity)
  if self.whitelist and !table.HasValue(self.whitelist, player:GetFaction()) then
    cw.player:Notify(player, '#FactionCantWear')
    return false
  end

  if player:Alive() and !player:IsRagdolled() then
    if !self.CanPlayerWear or self:CanPlayerWear(player, itemEntity) != false then
      player:SetClothesData(self)
      return true
    end
  else
    cw.player:Notify(player, '#CantDoThisNow')
  end

  return false
end

if CLIENT then
  --- Returns the tooltip line saying whether the local player is wearing the clothes.
  -- @return [String Translated wearing state, or `nil` for a non-instance item]
  function ITEM:GetClientSideInfo()
    if !self:IsInstance() then return end

    if cw.player:IsWearingItem(self) then
      return L'#IsWearing_Yes'
    else
      return L'#IsWearing_No'
    end
  end
end
