--- Server-side functions of the Dynamic Adverts plugin that load and save the current map's adverts.
--
-- `cwDynamicAdverts:LoadDynamicAdverts` and `cwDynamicAdverts:SaveDynamicAdverts` keep `cwDynamicAdverts.storedList`
-- in the schema data under `plugins/adverts/<map>`.

--- Loads the current map's adverts from the schema data into `cwDynamicAdverts.storedList`.
function cwDynamicAdverts:LoadDynamicAdverts()
  self.storedList = cw.core:RestoreSchemaData('plugins/adverts/'..game.GetMap())
end

--- Saves `cwDynamicAdverts.storedList` to the schema data for the current map.
function cwDynamicAdverts:SaveDynamicAdverts()
  cw.core:SaveSchemaData('plugins/adverts/'..game.GetMap(), self.storedList)
end
