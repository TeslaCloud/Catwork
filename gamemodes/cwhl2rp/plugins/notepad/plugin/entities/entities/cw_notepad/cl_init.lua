--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua");

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = cw.option:GetColor("target_id");
	local colorWhite = cw.option:GetColor("white");

	y = cw.core:DrawInfo("#Notepad_Title", x, y, colorTargetID, alpha);

	if (self:GetDTBool(0)) then
		y = cw.core:DrawInfo("#Notepad_Written", x, y, colorWhite, alpha);
	else
		y = cw.core:DrawInfo("#Notepad_Blank", x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;