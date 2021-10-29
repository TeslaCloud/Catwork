--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PLUGIN = PLUGIN

-- Called when an entity's menu options are needed.
function PLUGIN:GetEntityMenuOptions(entity, options)
	local class = entity:GetClass()

	if (class == "cw_book") then
		options["View"] = "cw_bookView"
		options["Take"] = "cw_bookTake"
	end
end
