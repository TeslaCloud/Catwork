--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua")

local glowMaterial = Material("sprites/glow04_noz")

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel()
end