--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

include("shared.lua")

-- Called each frame.
function ENT:Think()
	if (!cw.entity:HasFetchedItemData(self)) then
		cw.entity:FetchItemData(self)
		return
	end

	local playerEyePos = cw.client:EyePos()
	local player = self:GetPlayer()
	local eyePos = EyePos()

	if (IsValid(player)) then
		local isPlayer = player:IsPlayer()

		if ((eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != cw.client
		or cw.client != player or !isPlayer) and (!isPlayer or player:Alive())) then
			self:SetNoDraw(false)
		else
			self:SetNoDraw(true)
		end
	end
end

-- Called when the entity should draw.
function ENT:Draw()
	if (!hook.Run("PreGearEntityDraw", self)) then
		if (!cw.entity:HasFetchedItemData(self)) then
			return
		end

		local playerEyePos = cw.client:EyePos()
		local colorTable = self:GetColor()
		local itemTable = cw.entity:FetchItemTable(self)
		local modelScale = itemTable.attachmentModelScale or Vector(1, 1, 1)
		local bDrawModel = false
		local eyePos = EyePos()
		local player = self:GetPlayer()

		if (IsValid(player) and (player:GetMoveType() == MOVETYPE_WALK
		or player:IsRagdolled() or player:InVehicle())) then
			local position, angles = self:GetRealPosition()
			local isPlayer = player:IsPlayer()

			if (position and angles) then
				self:SetPos(position); self:SetAngles(angles)
			end

			if (itemTable.GetAttachmentModelScale) then
				modelScale = itemTable:GetAttachmentModelScale(player, self) or modelScale
			end

			if ((eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != cw.client
			or cw.client != player or !isPlayer) and (!isPlayer or player:Alive()) and colorTable.a > 0) then
				bDrawModel = true
			end
		end

		if (modelScale) then
			local entityMatrix = Matrix()
				entityMatrix:Scale(modelScale)
			self:EnableMatrix("RenderMultiply", entityMatrix)
		end

		if (bDrawModel and hook.Run("GearEntityDraw", self) != false) then
			self:DrawModel()
		end
	end
end
