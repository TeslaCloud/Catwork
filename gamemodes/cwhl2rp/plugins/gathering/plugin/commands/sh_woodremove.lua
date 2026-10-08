--- Registers the `/WoodRemove` command, which removes wood node spawn points around where the admin is looking.
--
-- The distance limit is 50000000 units, so in practice it removes every point on the map.

local COMMAND = cw.command:New('WoodRemove')
COMMAND.tip = '#Command_Woodremove_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Removes wood node spawn points and saves the points.
--
-- The distance limit is 50000000 units, so every point on the map is removed.
function COMMAND:OnRun(player, arguments)
  local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32)
  local pointsCount = 0

  -- Backwards, so that removing a point does not shift the ones still to be checked.
  for k = #cwGather.nodePoints, 1, -1 do
    if cwGather.nodePoints[k].position:Distance(position) <= 50000000 then
      pointsCount = pointsCount + 1
      table.remove(cwGather.nodePoints, k)
    end
  end

  if pointsCount > 0 then
    if pointsCount == 1 then
      cw.player:Notify(player, L('Gathering_RemovedPoint', pointsCount))
    else
      cw.player:Notify(player, L('Gathering_RemovedPoints', pointsCount))
    end
  else
    cw.player:Notify(player, L('Gathering_NoPointsFound'))
  end

  cwGather:SaveNodesSpawnPoints()
end

COMMAND:Register()
