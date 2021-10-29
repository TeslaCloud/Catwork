--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("TargetPlayerText", cw)

cw.TargetPlayerText.stored = cw.TargetPlayerText.stored or {}

-- A function to add some target player text.
function cw.TargetPlayerText:Add(uniqueID, text, color, scale)
	self.stored[#self.stored + 1] = {
		uniqueID = uniqueID,
		color = color,
		scale = scale,
		text = text
	}
end

-- A function to get some target player text.
function cw.TargetPlayerText:Get(uniqueID)
	for k, v in pairs(self.stored) do
		if (v.uniqueID == uniqueID) then
			return v
		end
	end
end

-- A function to destroy some target player text.
function cw.TargetPlayerText:Destroy(uniqueID)
	for k, v in pairs(self.stored) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.stored, k)
		end
	end
end
