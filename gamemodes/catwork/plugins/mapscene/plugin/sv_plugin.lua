--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- A function to load the map scenes.
function cwMapScene:LoadMapScenes()
	local mapScenes = cw.core:RestoreSchemaData("plugins/scenes/"..game.GetMap())
	self.storedList = self.storedList or {}

	for k, v in pairs(mapScenes) do
		self.storedList[#self.storedList + 1] = v
	end
end

-- A function to save the map scenes.
function cwMapScene:SaveMapScenes()
	local mapScenes = {}

	for k, v in pairs(self.storedList) do
		mapScenes[#mapScenes + 1] = v
	end

	cw.core:SaveSchemaData("plugins/scenes/"..game.GetMap(), mapScenes)
end
