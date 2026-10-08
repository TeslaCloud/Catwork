--- Shared definition of the `cw_gear` entity: its networked item `Index` and the accessors for its item, owner,
-- attachment bone and offsets.
--
-- `ENT:GetRealPosition` works out where the gear is drawn from the owner's bone (or their ragdoll's) and the item's
-- `attachmentOffsetVector` and `attachmentOffsetAngles`, which the item's `AdjustAttachmentOffsetInfo` can change.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Gear'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true

--- Sets up the networked `Index` integer holding the item's instance index.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'Index')
end

--- Returns where the gear should be drawn: the owner's attachment bone plus the item's offsets.
--
-- Uses the ragdoll's bone when the owner is ragdolled. The item's `AdjustAttachmentOffsetInfo(player, entity,
-- info)` can change `info.offsetVector` and `info.offsetAngle` before they are applied.
-- @return [Vector The world position, or `nil` when the owner or bone is missing, Angle The world angles]
function ENT:GetRealPosition()
  local offsetVector = self:GetOffsetVector()
  local offsetAngle = self:GetOffsetAngle()
  local itemTable = self:GetItemTable()
  local player = self:GetPlayer()
  local bone = player and player:LookupBone(self:GetBone())

  if offsetVector and offsetAngle and bone then
    local position, angles = player:GetBonePosition(bone)
    local ragdollEntity = player:GetRagdollEntity()

    if itemTable.AdjustAttachmentOffsetInfo then
      local info = {
        offsetVector = offsetVector,
        offsetAngle = offsetAngle
      }

      itemTable:AdjustAttachmentOffsetInfo(player, self, info)
      offsetVector = info.offsetVector
      offsetAngle = info.offsetAngle
    end

    if ragdollEntity then
      position, angles = ragdollEntity:GetBonePosition(bone)
    end

    if !position or !angles then return end

    local x = angles:Up() * offsetVector.x
    local y = angles:Right() * offsetVector.y
    local z = angles:Forward() * offsetVector.z

    angles:RotateAroundAxis(angles:Forward(), offsetAngle.p)
    angles:RotateAroundAxis(angles:Right(), offsetAngle.y)
    angles:RotateAroundAxis(angles:Up(), offsetAngle.r)

    return position + x + y + z, angles
  end
end

--- Returns the name of the bone the gear is attached to.
-- @return [String The item's `attachmentBone`, or an empty string]
function ENT:GetBone()
  local itemTable = self:GetItemTable()
  return itemTable.attachmentBone or ''
end

--- Returns the item instance shown as this gear.
--
-- On the client it uses the fetched item data, falling back to `item.FindByID` with the networked index.
-- @return [Item The item instance, or `nil` if it is not known]
function ENT:GetItemTable()
  if CLIENT then
    local itemTable = cw.entity:FetchItemTable(self)

    if !itemTable then
      return item.FindByID(self:GetDTInt(0))
    else
      return itemTable
    end
  end

  return self.cwItemTable
end

--- Returns the player who owns the gear.
-- @return [Player The owner, or `nil` when the owner is not a valid player]
function ENT:GetPlayer()
  local player = self:GetOwner()

  if IsValid(player) and player:IsPlayer() then
    return player
  end
end

--- Returns the gear's position offset from its bone.
-- @return [Vector The item's `attachmentOffsetVector`, or a zero vector]
function ENT:GetOffsetVector()
  local itemTable = self:GetItemTable()
  return itemTable.attachmentOffsetVector or Vector(0, 0, 0)
end

--- Returns the gear's angle offset from its bone.
-- @return [Angle The item's `attachmentOffsetAngles`, or a zero angle]
function ENT:GetOffsetAngle()
  local itemTable = self:GetItemTable()
  return itemTable.attachmentOffsetAngles or Angle(0, 0, 0)
end
