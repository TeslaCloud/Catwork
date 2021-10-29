--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("bars", cw)

cw.bars.x = 0
cw.bars.y = 0
cw.bars.width = 0
cw.bars.height = 16
cw.bars.padding = 18
cw.bars.stored = cw.bars.stored or {}

-- A function to get a top bar.
function cw.bars:FindByID(uniqueID)
	for k, v in ipairs(self.stored) do
		if (v.uniqueID == uniqueID) then
			return v
		end
	end
end

-- A function to add a top bar.
function cw.bars:Add(uniqueID, color, text, value, maximum, flash, priority, maxValue, limitText)
	table.insert(self.stored, {
		uniqueID = uniqueID,
		priority = priority or 0,
		maximum = maximum,
		color = color,
		class = class,
		value = value,
		maxValue = maxValue,
		limitText = limitText,
		flash = flash,
		text = text,
	})
end

-- A function to destroy a top bar.
function cw.bars:Destroy(uniqueID)
	for k, v in ipairs(self.stored) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.stored, k)
		end
	end
end
