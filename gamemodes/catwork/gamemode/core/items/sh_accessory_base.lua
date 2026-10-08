--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = 'Accessory Base'
ITEM.model = 'models/gibs/hgibs.mdl'
ITEM.weight = 1
ITEM.useText = 'Wear'
ITEM.category = 'Accessories'
ITEM.description = '#Item_AccessoryBase_Description'
ITEM.isAttachment = true
ITEM.attachmentBone = 'ValveBiped.Bip01_Head1'
ITEM.attachmentOffsetAngles = Angle(270, 270, 0)
ITEM.attachmentOffsetVector = Vector(0, 3, 3)

--- Called when a player puts the accessory on or takes it off; does nothing in the base.
-- @param player [Player The player wearing the accessory]
-- @param bIsWearing [Boolean `true` when the accessory was put on, `false` when it was taken off]
function ITEM:OnWearAccessory(player, bIsWearing)
  if bIsWearing then
  else
  end
end

--- Returns whether the player is wearing this accessory; on the client it checks the local player.
-- @return [Boolean Whether the accessory is worn]
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
  if CLIENT then
    return cw.player:IsWearingAccessory(self)
  else
    return player:IsWearingAccessory(self)
  end
end

--- Takes the accessory off the player.
function ITEM:OnPlayerUnequipped(player, extraData)
  player:RemoveAccessory(self)
end

--- Called when a player drops the accessory; blocks the drop while it is worn.
-- @return [Boolean `false` while the player wears the accessory, otherwise `nil`]
function ITEM:OnDrop(player, position)
  if player:IsWearingAccessory(self) then
    cw.player:Notify(player, '#CantDropWhenWearing')
    return false
  end
end

--- Puts the accessory on a living, standing player if the item's optional `CanPlayerWear` allows it.
-- @return [Boolean `true` when worn (the item stays in the inventory), `false` otherwise]
function ITEM:OnUse(player, itemEntity)
  if player:Alive() and !player:IsRagdolled() then
    if !self.CanPlayerWear or self:CanPlayerWear(player, itemEntity) != false then
      player:WearAccessory(self)
      return true
    end
  else
    cw.player:Notify(player, '#CantDoThisNow')
  end

  return false
end

if CLIENT then
  --- Returns the tooltip line saying whether the local player is wearing the accessory.
  -- @return [String Language key for the wearing state, or `nil` for a non-instance item]
  function ITEM:GetClientSideInfo()
    if !self:IsInstance() then return end

    if cw.player:IsWearingAccessory(self) then
      return '#IsWearing_Yes'
    else
      return '#IsWearing_No'
    end
  end
end
