--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

include("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	if (cw.entity:HasFetchedItemData(self)) then
		local itemTable = cw.entity:FetchItemTable(self)

		if (hook.Run("PaintItemTargetID", x, y, alpha, itemTable)) then
			local colorTargetID = cw.option:GetColor("target_id")
			local colorWhite = cw.option:GetColor("white")
			local color = itemTable.color or colorTargetID

			y = cw.core:DrawInfo(cw.lang:TranslateText(itemTable.PrintName), x, y, color, alpha)

			if (itemTable.OnHUDPaintTargetID) then
				local newY = itemTable:OnHUDPaintTargetID(self, x, y, alpha)

				if (newY == false) then
					return
				end

				if (isnumber(newY)) then
					y = newY
				end
			end

			y = cw.core:DrawInfo((itemTable.weightText or itemTable.weight.."kg"), x, y, colorWhite, alpha)

			local spaceUsed = itemTable.space
			if (cw.inventory:UseSpaceSystem() and spaceUsed > 0) then
				y = cw.core:DrawInfo((itemTable.spaceText or spaceUsed.."l"), x, y, colorWhite, alpha)
			end
		end
	end
end

-- Called each frame.
function ENT:Think()
	if (!cw.entity:HasFetchedItemData(self)) then
		cw.entity:FetchItemData(self)
		return
	end

	local itemTable = cw.entity:FetchItemTable(self)

	if (itemTable.OnEntityThink) then
		local nextThink = itemTable:OnEntityThink(self)

		if (isnumber(nextThink)) then
			self:NextThink(CurTime() + nextThink)
		end
	end

	hook.Run("ItemEntityThink", itemTable, self)
end

-- Called when the entity should draw.
function ENT:Draw()
	if (!cw.entity:HasFetchedItemData(self)) then
		return
	end

	local drawModel = true
	local itemTable = cw.entity:FetchItemTable(self)
	local shouldDrawItemEntity = hook.Run("ItemEntityDraw", itemTable, self)

	if (shouldDrawItemEntity == false
	or (itemTable.OnDrawModel and itemTable:OnDrawModel(self) == false)) then
		drawModel = false
	end

	if (drawModel) then
		self:DrawModel()
	end
end
