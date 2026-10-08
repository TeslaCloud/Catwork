--- Defines `bodygroup_base`, the base item for clothing that is worn by setting a bodygroup on the player's model.
--
-- Derived items set `bodyGroup` and `bodyGroupVal`, and optionally `protection` (percent of damage absorbed),
-- `isCombine` (Combine players can only wear items marked with it) and `requiredBG` (a bodygroup that must already be
-- worn). Wearing goes through `Player:SetBodygroupClothes`, the item stays in the inventory, and it is taken off when
-- dropped, sold, stored, unequipped or taken from the inventory in any other way.
--
-- Originally written for the Global Cooldown community.

ITEM.isBaseItem = true
ITEM.name = 'Bodygroup Base'
ITEM.model = 'models/tnb/items/shirt_citizen1.mdl'
ITEM.skin = 1
ITEM.weight = 1
ITEM.useText = '#ITEM_Wear'
ITEM.category = '#ITEM_Cat_Clothing'
ITEM.description = 'Default Bodygroup Clothing Item.'
ITEM.bodyGroup = -1
ITEM.bodyGroupVal = -1
ITEM.requiredBG = { -1, -1 }
ITEM.isCombine = false
ITEM.protection = 0

--- Sets a bodygroup on the player, or tells them they cannot wear the item if the model lacks it.
--
-- @param player [Player The wearer]
-- @param bg [Number The bodygroup index]
-- @param val [Number The bodygroup value]
-- @return [Boolean Whether the bodygroup was set]
function ITEM:SetBodygroup(player, bg, val)
  if bg <= player:GetNumBodyGroups() then
    player:SetBodygroup(bg, val)

    return true
  else
    cw.player:Notify(player, '#ITEM_ErrCantWear')

    return false
  end
end

--- Resets a bodygroup on the player to 0.
--
-- @param player [Player The wearer]
-- @param bg [Number The bodygroup index]
-- @return [Boolean Always `true`]
function ITEM:ResetBodygroup(player, bg)
  player:SetBodygroup(bg, 0)

  return true
end

--- Wears the item with `Player:SetBodygroupClothes` and keeps it in the inventory.
--
-- Fails when the item's `requiredBG` bodygroup is not worn or the player is dead or
-- ragdolled, and Combine players can only wear items marked `isCombine`.
--
-- @return [Boolean `true` when worn, `false` otherwise; either way the item is kept]
function ITEM:OnUse(player, itemEntity)
  local clothesData = player.bgClothesData or {}

  if self.requiredBG[1] != -1 then
    local bgData = clothesData[self.requiredBG[1]]

    if !bgData then
      cw.player:Notify(player, '#ITEM_ErrCantWear')

      return false
    end
  end

  if (player:IsCombine() and !self.isCombine) or self.bodyGroup == -1 then
    cw.player:Notify(player, '#ITEM_ErrCantWear')

    return false
  end

  if !player:Alive() or player:IsRagdolled() then
    cw.player:Notify(player, '#CantDoThisNow')

    return false
  end

  player:SetBodygroupClothes(self)

  return true
end

--- Takes the item off when it is dropped while worn.
function ITEM:OnDrop(player, position)
  if self:HasPlayerEquipped(player) and self.bodyGroup != -1 then
    player:SetBodygroupClothes(self, true)
  end

  return true
end

--- Takes the item off when it is sold while worn.
function ITEM:CanSell(player)
  if self:HasPlayerEquipped(player) and self.bodyGroup != -1 then
    player:SetBodygroupClothes(self, true)
  end

  return true
end

--- Takes the item off when it is put into storage while worn.
function ITEM:CanGiveStorage(player, storageTable)
  if self:HasPlayerEquipped(player) and self.bodyGroup != -1 then
    player:SetBodygroupClothes(self, true)
  end

  return true
end

--- Sets or resets the item's bodygroup and calls the item's `OnChangedClothes` if it has one.
--
-- @param player [Player The wearer]
-- @param bIsWearing [Boolean Whether the item is being put on]
function ITEM:OnChangeClothes(player, bIsWearing)
  if bIsWearing then
    self:SetBodygroup(player, self.bodyGroup, self.bodyGroupVal)
  else
    self:ResetBodygroup(player, self.bodyGroup)
  end

  if self.OnChangedClothes then
    self:OnChangedClothes(player, bIsWearing)
  end
end

--- Returns whether the player wears this item instance in its bodygroup.
--
-- Uses the networked `bgClothesData` on the client.
--
-- @param player [Player The player to check]
-- @param bIsValidWeapon [Boolean Unused]
-- @return [Boolean Whether the item is worn]
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
  local clothesData = player.bgClothesData or {}

  if CLIENT then
    clothesData = cw.client.bgClothesData or {}
  end

  local bg = self.bodyGroup

  if clothesData[bg] and clothesData[bg].val != nil and clothesData[bg].itemID == self.uniqueID..' '..self.itemID then
    return true
  end

  return false
end

--- Takes the item off when the player unequips it.
function ITEM:OnPlayerUnequipped(player, extraData)
  player:SetBodygroupClothes(self, true)
end

--- Takes the item off when it is taken from the player's inventory while worn.
function ITEM:OnTakeFromPlayer(player)
  if self:HasPlayerEquipped(player) then
    player:SetBodygroupClothes(self, true)
  end
end
