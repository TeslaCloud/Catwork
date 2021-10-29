--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

netstream.Hook("EnteredArea", function(player, data)
	if (data[1] and data[2] and data[3]) then
		hook.Run("PlayerEnteredArea", player, data[1], data[2], data[3])
	end
end)

-- A function to load the area names.
function cwAreaDisplays:LoadAreaDisplays()
	self.storedList = cw.core:RestoreSchemaData("plugins/areas/"..game.GetMap())
end

-- A function to save the area names.
function cwAreaDisplays:SaveAreaDisplays()
	cw.core:SaveSchemaData("plugins/areas/"..game.GetMap(), self.storedList)
end
