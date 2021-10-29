--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("PlayerInfoText", cw)
cw.PlayerInfoText.text = cw.PlayerInfoText.text or {}
cw.PlayerInfoText.width = cw.PlayerInfoText.width or {}
cw.PlayerInfoText.subText = cw.PlayerInfoText.subText or {}

-- A function to get whether any player info text exists.
function cw.PlayerInfoText:DoesAnyExist()
	return (#self.text > 0 or #self.subText > 0)
end

-- A function to add some player info text.
function cw.PlayerInfoText:Add(uniqueID, text)
	if (text) then
		self.text[#self.text + 1] = {
			uniqueID = uniqueID,
			text = text
		}
	end
end

-- A function to get some player info text.
function cw.PlayerInfoText:Get(uniqueID)
	for k, v in pairs(self.text) do
		if (v.uniqueID == uniqueID) then
			return v
		end
	end
end

-- A function to add some sub player info text.
function cw.PlayerInfoText:AddSub(uniqueID, text, priority)
	if (text) then
		self.subText[#self.subText + 1] = {
			priority = priority or 0,
			uniqueID = uniqueID,
			text = text
		}
	end
end

-- A function to get some sub player info text.
function cw.PlayerInfoText:GetSub(uniqueID)
	for k, v in pairs(self.subText) do
		if (v.uniqueID == uniqueID) then
			return v
		end
	end
end

-- A function to destroy some player info text.
function cw.PlayerInfoText:Destroy(uniqueID)
	for k, v in pairs(self.text) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.text, k)
		end
	end
end

-- A function to destroy some sub player info text.
function cw.PlayerInfoText:DestroySub(uniqueID)
	for k, v in pairs(self.subText) do
		if (v.uniqueID == uniqueID) then
			table.remove(self.subText, k)
		end
	end
end
