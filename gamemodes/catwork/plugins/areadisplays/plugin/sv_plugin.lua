--- Server-side functions of the Area Displays plugin that load and save the map's areas.
--
-- The areas are kept in the `plugins/areas/<map>` schema data file. The `EnteredArea` netstream sent by clients runs
-- the `PlayerEnteredArea` hook on the server.

netstream.Hook('EnteredArea', function(player, data)
  if data[1] and data[2] and data[3] then
    hook.Run('PlayerEnteredArea', player, data[1], data[2], data[3])
  end
end)

--- Loads the current map's areas from the schema data file `plugins/areas/<map>` into
-- `cwAreaDisplays.storedList`.
function cwAreaDisplays:LoadAreaDisplays()
  self.storedList = cw.core:RestoreSchemaData('plugins/areas/'..game.GetMap())
end

--- Saves `cwAreaDisplays.storedList` to the schema data file `plugins/areas/<map>`.
function cwAreaDisplays:SaveAreaDisplays()
  cw.core:SaveSchemaData('plugins/areas/'..game.GetMap(), self.storedList)
end
