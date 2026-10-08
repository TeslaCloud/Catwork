--- Defines `skin_base`, the base item for clothing that is worn by setting the skin of the player's model.
--
-- Derived items set `playerSkin`, and optionally `protection` (percent of damage absorbed) and `isCombine` (Combine
-- players can only wear items marked with it). Wearing goes through `Player:SetSkinClothes`, the item stays in the
-- inventory, and it is taken off, resetting the skin to 0, when dropped, sold, stored or unequipped.
--
-- Originally written for the Global Cooldown community.

ITEM.isBaseItem = true
ITEM.name = 'Skin Base'
ITEM.model = 'models/tnb/items/shirt_citizen1.mdl'
ITEM.skin = 1
ITEM.weight = 1
ITEM.useText = '#ITEM_Wear'
ITEM.category = '#ITEM_Cat_Clothing'
ITEM.description = 'Default Skin Clothing Item.'
ITEM.playerSkin = -1
ITEM.isCombine = false
ITEM.protection = 0

--- Sets the player's skin, or tells them they cannot wear the item if the model lacks it.
--
-- @param player [Player The wearer]
-- @param skin [Number The skin index]
-- @return [Boolean Whether the skin was set]
function ITEM:SetSkin(player, skin)
  if skin <= player:SkinCount() then
    player:SetSkin(skin)

    return true
  else
    cw.player:Notify(player, '#ITEM_ErrCantWear')

    return false
  end
end

--- Resets the player's skin to 0.
--
-- @param player [Player The wearer]
-- @return [Boolean Always `true`]
function ITEM:ResetSkin(player)
  player:SetSkin(0)
  return true
end

--- Wears the item with `Player:SetSkinClothes` and keeps it in the inventory.
--
-- Combine players can only wear items marked `isCombine`.
function ITEM:OnUse(player, itemEntity)
  if (!player:IsCombine() or self.isCombine) and self.playerSkin != -1 then
    if player:Alive() and !player:IsRagdolled() then
      player:SetSkinClothes(self)
      return true
    end
  else
    cw.player:Notify(player, '#ITEM_ErrCantWear')

    return false
  end
end

--- Takes the item off when it is dropped while worn.
function ITEM:OnDrop(player, position)
  if self:HasPlayerEquipped(player) and self.playerSkin != -1 then
    player:SetSkinClothes(self, true)
  end

  return true
end

--- Takes the item off when it is sold while worn.
function ITEM:CanSell(player)
  if self:HasPlayerEquipped(player) and self.playerSkin != -1 then
    player:SetSkinClothes(self, true)
  end

  return true
end

--- Takes the item off when it is put into storage while worn.
function ITEM:CanGiveStorage(player, storageTable)
  if self:HasPlayerEquipped(player) and self.playerSkin != -1 then
    player:SetSkinClothes(self, true)
  end

  return true
end

--- Sets or resets the player's skin and calls the item's `OnChangedClothes` if it has one.
--
-- @param player [Player The wearer]
-- @param bIsWearing [Boolean Whether the item is being put on]
function ITEM:OnChangeClothes(player, bIsWearing)
  if bIsWearing then
    self:SetSkin(player, self.playerSkin)
  else
    self:ResetSkin(player)
  end

  if self.OnChangedClothes then
    self:OnChangedClothes(player, bIsWearing)
  end
end

--- Returns whether the player wears this item instance as their skin.
--
-- Uses the networked `skinClothesData` on the client.
--
-- @param player [Player The player to check]
-- @param bIsValidWeapon [Boolean Unused]
-- @return [Boolean Whether the item is worn]
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
  local clothesData = player.skinClothesData or {}

  if CLIENT then
    clothesData = cw.client.skinClothesData or {}
  end

  local skin = self.playerSkin

  if clothesData[skin] and clothesData[skin].val != nil
  and clothesData[skin].itemID == self.uniqueID..' '..self.itemID then
    return true
  end

  return false
end

--- Takes the item off when the player unequips it.
function ITEM:OnPlayerUnequipped(player, extraData)
  player:SetSkinClothes(self, true)
end
