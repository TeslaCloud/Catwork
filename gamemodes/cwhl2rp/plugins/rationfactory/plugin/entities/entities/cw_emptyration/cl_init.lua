--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

include("shared.lua")

function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = cw.option:GetColor("target_id")
	local colorWhite = cw.option:GetColor("white")

	y = cw.core:DrawInfo("#Factory_Ration", x, y, colorTargetID, alpha)

	local item1 = "#Factory_Empty"
	local item2 = "#Factory_Empty"

	if (self:GetDTBool(1)) then
		item1 = "#Factory_Water"
	end

	if (self:GetDTBool(2)) then
		item2 = "#Factory_Supplements"
	end

	y = cw.core:DrawInfo("#Factory_Contains "..item1.." , "..item2, x, y, colorWhite, alpha)

	if (self:GetDTBool(1) and self:GetDTBool(2)) then
		y = cw.core:DrawInfo("#Factory_Ready", x, y, colorWhite, alpha)
	end
end

function ENT:Draw()
	self:DrawModel()
end

