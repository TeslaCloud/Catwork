--- Server-side functions of the Area Displays plugin that load and save the map's areas.
--
-- The areas are kept in the `plugins/areas/<map>` schema data file. The `EnteredArea` netstream sent by clients runs
-- the `PlayerEnteredArea` hook on the server, once the area is known to exist and the player is found near it.

-- How far outside an area a player may be when their client reports entering it, to allow for lag.
local areaTolerance = Vector(64, 64, 64)

netstream.Hook('EnteredArea', function(player, data)
  if !istable(data) or !isstring(data[1]) or !isvector(data[2]) or !isvector(data[3]) then return end
  if !player:HasInitialized() then return end

  local curTime = CurTime()

  if player.cwNextEnteredArea and curTime < player.cwNextEnteredArea then return end

  player.cwNextEnteredArea = curTime + 0.5

  for k, v in pairs(cwAreaDisplays.storedList) do
    if v.name == data[1] and v.minimum == data[2] and v.maximum == data[3] then
      local minimum = Vector(v.minimum)
      local maximum = Vector(v.maximum)

      OrderVectors(minimum, maximum)

      if player:GetShootPos():WithinAABox(minimum - areaTolerance, maximum + areaTolerance) then
        hook.Run('PlayerEnteredArea', player, v.name, v.minimum, v.maximum)
      end

      return
    end
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
