--[[
  Catwork � 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('GarbageRemove')
COMMAND.tip = '#Command_Garbageremove_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.alias = { 'GarbagePointRemove', 'GarbageSpawnRemove' }

--- Removes the garbage spawn points within 50 units of where the player is looking and saves the points.
function COMMAND:OnRun(player, arguments)
  local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32)
  local pointsCount = 0

  for k, v in pairs(cwGarbage.garbagePoints) do
    if v.position:Distance(position) <= 50 then
      pointsCount = pointsCount + 1
      cwGarbage.garbagePoints[k] = nil
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
