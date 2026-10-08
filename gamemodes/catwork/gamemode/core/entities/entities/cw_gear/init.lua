--- Server side of the `cw_gear` entity, an item's model attached to a player's body, such as a holstered weapon.
--
-- It is created by `cw.player:CreateGear`. Its think, ten times a second, removes the gear when the owner is gone or
-- the item's `GetAttachmentExists` says so, hides it when `GetAttachmentVisible` says so (by default a weapon's gear is
-- hidden while that weapon is held), and recreates it when the item's model changes.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the gear as a non-solid, shadowless physics entity.
function ENT:Initialize()
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetNotSolid(true)
  self:DrawShadow(false)
end

--- Always transmits the gear to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Returns whether the gear should still exist on the player.
--
-- Uses the item's `GetAttachmentExists(player, entity)` when defined. Weapon items exist while the player (or
-- their ragdoll) has the weapon; other items always exist.
-- @param player [Player The player wearing the gear]
-- @return [Boolean Whether the gear should exist, or `nil` when the entity has no item]
function ENT:GetShouldExist(player)
  local itemTable = self:GetItemTable()

  if itemTable then
    if itemTable.GetAttachmentExists then
      return itemTable:GetAttachmentExists(player, self)
    elseif item.IsWeapon(itemTable) then
      local weaponClass = itemTable:GetWeaponClass()

      if player:IsRagdolled() then
        return player:RagdollHasWeapon(weaponClass)
      else
        return player:HasWeapon(weaponClass)
      end
    else
      return true
    end
  end
end

--- Returns whether the gear should be visible on the player.
--
-- Uses the item's `GetAttachmentVisible(player, entity)` when defined. Weapon gear is hidden while that
-- weapon is the active one; other gear is always visible.
-- @param player [Player The player wearing the gear]
-- @return [Boolean Whether the gear is visible, or `nil` when the entity has no item]
function ENT:GetIsVisible(player)
  local itemTable = self:GetItemTable()

  if itemTable then
    if itemTable.GetAttachmentVisible then
      return itemTable:GetAttachmentVisible(player, self)
    elseif item.IsWeapon(itemTable) then
      return cw.player:GetWeaponClass(player) != itemTable:GetWeaponClass()
    else
      return true
    end
  end
end

--- Sets whether the gear is removed when the player no longer has the item in their inventory.
-- @param bMustHave [Boolean Remove the gear once the player loses the item]
function ENT:SetMustHave(bMustHave)
  self.cwMustHave = bMustHave
end

--- Sets the gear slot and item the entity represents and networks the item's index.
-- @param gearClass [String The gear slot name, used as the key in the player's gear table]
-- @param itemTable [Item The item instance shown as gear]
function ENT:SetItemTable(gearClass, itemTable)
  self.cwGearClass = gearClass
  self.cwItemTable = itemTable
  self.cwGearModel = itemTable.attachmentModel or itemTable.model
  self:SetDTInt(0, itemTable.index)
end

--- Removes or hides the gear as `ENT:GetShouldExist` and `ENT:GetIsVisible` decide, and copies the owner's material.
--
-- Recreates the gear with `cw.player:CreateGear` when the item's model changed since the gear was made or the
-- item's `ShouldGearRespawn` says so, and removes it when it must be carried (`ENT:SetMustHave`) but the player
-- lost the item.
function ENT:Think()
  local player = self:GetPlayer()

  if !IsValid(player) or !self:GetShouldExist(player) then
    self:Remove()

    return
  end

  self:NextThink(CurTime() + 0.1)

  local entityColor = self:GetColor()
  local bVisible = self:GetIsVisible(player) and true or false
  local alpha = bVisible and 255 or 0

  if entityColor.a != alpha then
    self:SetColor(Color(entityColor.r, entityColor.g, entityColor.b, alpha))
  end

  self:SetNoDraw(!bVisible)

  local material = player:GetMaterial()

  if self:GetMaterial() != material then
    self:SetMaterial(material)
  end

  if self.cwMustHave and !player:HasItemInstance(self.cwItemTable) then
    cw.player:RemoveGear(
      player, self.cwGearClass
    )

    return true
  end

  -- The model is compared with the one the gear was made for: `GetModel` reports the error model for a missing
  -- one, which would never match and respawn the gear on every think.
  local model = self.cwItemTable.attachmentModel or self.cwItemTable.model

  if self.cwGearModel != model or (self.cwItemTable.ShouldGearRespawn
  and self.cwItemTable:ShouldGearRespawn(self)) then
    cw.player:CreateGear(
      player, self.cwGearClass, self.cwItemTable, self.cwMustHave
    )
  end

  return true
end
