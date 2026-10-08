--- Registers the `/GarbageRemove` command, which removes the garbage spawn points within 50 units of where the admin is
-- looking.

local COMMAND = cw.command:New('GarbageRemove')
COMMAND.tip = '#Command_Garbageremove_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.alias = { 'GarbagePointRemove', 'GarbageSpawnRemove' }

--- Removes the garbage spawn points within 50 units of where the player is looking and saves the points.
function COMMAND:OnRun(player, arguments)
  local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32)
  local pointsCount = 0

  -- Backwards, so that removing a point does not shift the ones still to be checked.
  for k = #cwGarbage.garbagePoints, 1, -1 do
    if cwGarbage.garbagePoints[k].position:Distance(position) <= 50 then
      pointsCount = pointsCount + 1
      table.remove(cwGarbage.garbagePoints, k)
    end
  end

  if pointsCount > 0 then
    if pointsCount == 1 then
      cw.player:Notify(player, L('Garbage_RemovedSpawn', pointsCount))
    else
      cw.player:Notify(player, L('Garbage_RemovedSpawns', pointsCount))
    end
  else
    cw.player:Notify(player, L('Garbage_NoSpawnsNear'))
  end

  cwGarbage:SaveGarbageSpawnPoints()
end

COMMAND:Register()
