--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Loads the current map's adverts from the schema data into `cwDynamicAdverts.storedList`.
function cwDynamicAdverts:LoadDynamicAdverts()
  self.storedList = cw.core:RestoreSchemaData('plugins/adverts/'..game.GetMap())
end

--- Saves `cwDynamicAdverts.storedList` to the schema data for the current map.
function cwDynamicAdverts:SaveDynamicAdverts()
  cw.core:SaveSchemaData('plugins/adverts/'..game.GetMap(), self.storedList)
end
