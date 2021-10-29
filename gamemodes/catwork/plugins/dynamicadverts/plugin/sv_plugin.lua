--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- A function to load the dynamic adverts.
function cwDynamicAdverts:LoadDynamicAdverts()
	self.storedList = cw.core:RestoreSchemaData("plugins/adverts/"..game.GetMap())
end

-- A function to save the dynamic adverts.
function cwDynamicAdverts:SaveDynamicAdverts()
	cw.core:SaveSchemaData("plugins/adverts/"..game.GetMap(), self.storedList)
end
