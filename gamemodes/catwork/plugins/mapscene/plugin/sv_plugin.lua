--- Server-side functions of the Map Scenes plugin that load and save the current map's scenes.
--
-- `cwMapScene:LoadMapScenes` and `cwMapScene:SaveMapScenes` keep `cwMapScene.storedList` in the schema data under
-- `plugins/scenes/<map>`.

--- Loads the current map's scenes from the schema data and appends them to `cwMapScene.storedList`.
function cwMapScene:LoadMapScenes()
  local mapScenes = cw.core:RestoreSchemaData('plugins/scenes/'..game.GetMap())
  self.storedList = self.storedList or {}

  for k, v in pairs(mapScenes) do
    self.storedList[#self.storedList + 1] = v
  end
end

--- Saves `cwMapScene.storedList` to the schema data for the current map.
function cwMapScene:SaveMapScenes()
  local mapScenes = {}

  for k, v in pairs(self.storedList) do
    mapScenes[#mapScenes + 1] = v
  end

  cw.core:SaveSchemaData('plugins/scenes/'..game.GetMap(), mapScenes)
end
