--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[
	@codebase Client
	@details Provides an interface to the Menu Items.
	@field stored A table containing a list of stored menu items.
--]]
library.New("menuitems", cw)
cw.menuitems.stored = cw.menuitems.stored or {}

-- A function to get a menu item.
function cw.menuitems:Get(text)
	for k, v in pairs(self.stored) do
		if (v.text == text) then
			return v
		end
	end
end

-- A function to add a menu item.
function cw.menuitems:Add(text, panel, tip, iconData)
	self.stored[#self.stored + 1] = {text = text, panel = panel, tip = tip, iconData = iconData}
end

-- A function to destroy a menu item.
function cw.menuitems:Destroy(text)
	for k, v in pairs(self.stored) do
		if (v.text == text) then
			table.remove(self.stored, k)
		end
	end
end
