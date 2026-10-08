--- Client side of the `cw_gear` entity: fetches its item data, moves the gear onto its owner's bone every frame and
-- draws it with the item's model scale.
--
-- The gear is hidden while the local player wears it in first person or is dead. The `PreGearEntityDraw` and
-- `GearEntityDraw` hooks and the item's `GetAttachmentModelScale` can change how it is drawn.

include('shared.lua')

local defaultModelScale = Vector(1, 1, 1)

--- Fetches the item data, then hides the gear while the local player wears it in first person or is dead.
function ENT:Think()
  if !cw.entity:HasFetchedItemData(self) then
    cw.entity:FetchItemData(self)
    return
  end

  local playerEyePos = cw.client:EyePos()
  local player = self:GetPlayer()
  local eyePos = EyePos()

  if IsValid(player) then
    local isPlayer = player:IsPlayer()

    if (eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != cw.client
    or cw.client != player or !isPlayer) and (!isPlayer or player:Alive()) then
      self:SetNoDraw(false)
    else
      self:SetNoDraw(true)
    end
  end
end

--- Positions the gear on its owner's bone, applies the model scale and draws it.
--
-- Does nothing when `PreGearEntityDraw` returns `true`. The item's `GetAttachmentModelScale` can change the
-- scale, and `GearEntityDraw` can return `false` to skip drawing.
function ENT:Draw()
  if !hook.Run('PreGearEntityDraw', self) then
    if !cw.entity:HasFetchedItemData(self) then
      return
    end

    local playerEyePos = cw.client:EyePos()
    local colorTable = self:GetColor()
    local itemTable = cw.entity:FetchItemTable(self)
    local modelScale = itemTable.attachmentModelScale or defaultModelScale
    local bDrawModel = false
    local eyePos = EyePos()
    local player = self:GetPlayer()

    if IsValid(player) and (player:GetMoveType() == MOVETYPE_WALK
    or player:IsRagdolled() or player:InVehicle()) then
      local position, angles = self:GetRealPosition()
      local isPlayer = player:IsPlayer()

      if position and angles then
        self:SetPos(position) self:SetAngles(angles)
      end

      if itemTable.GetAttachmentModelScale then
        modelScale = itemTable:GetAttachmentModelScale(player, self) or modelScale
      end

      if (eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != cw.client
      or cw.client != player or !isPlayer) and (!isPlayer or player:Alive()) and colorTable.a > 0 then
        bDrawModel = true
      end
    end

    -- The scale matrix stays on the entity, so it is only rebuilt when the scale changes.
    if modelScale and modelScale != self.cwModelScale then
      local entityMatrix = Matrix()
        entityMatrix:Scale(modelScale)
      self:EnableMatrix('RenderMultiply', entityMatrix)

      self.cwModelScale = Vector(modelScale)
    end

    if bDrawModel and hook.Run('GearEntityDraw', self) != false then
      self:DrawModel()
    end
  end
end
