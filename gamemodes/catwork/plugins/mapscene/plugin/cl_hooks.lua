--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when the character background should be drawn.
function cwMapScene:ShouldDrawCharacterBackground()
	if (self.curStored) then return false end
end

-- Called when the view should be calculated.
function cwMapScene:CalcView(player, origin, angles, fov)
	if (cw.core:IsChoosingCharacter() and self.curStored) then
		local addAngles = Angle(0, 0, 0)

		if (self.curStored.shouldSpin) then
			addAngles = Angle(0, math.sin(CurTime() * 0.2) * 180, 0)
		end

		return {
			vm_origin = self.curStored.position + Vector(0, 0, 2048),
			vm_angles = Angle(0, 0, 0),
			origin = self.curStored.position,
			angles = self.curStored.angles + addAngles,
			fov = fov
		}
	end
end
