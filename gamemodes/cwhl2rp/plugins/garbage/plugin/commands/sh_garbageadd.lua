--- Registers the `/GarbageAdd` command, which adds a garbage spawn point where the admin is looking and spawns a
-- `cw_garbage` pile there.

local COMMAND = cw.command:New('GarbageAdd')
COMMAND.tip = '#Command_Garbageadd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.alias = { 'AddGarbage', 'GarbageSpawnAdd' }

--- Adds a garbage spawn point where the player is looking, spawns a pile there and saves the points.
function COMMAND:OnRun(player, arguments)
  local point = {
    position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 5),
    angles = Angle(0, player:EyeAngles().yaw + 180, 0),
    nextSpawn = 0
  }

  if IsValid(cwGarbage:SpawnGarbage(point)) then
    table.insert(cwGarbage.garbagePoints, point)

    cw.player:Notify(player, L('Garbage_AddedPoint'))

    cwGarbage:SaveGarbageSpawnPoints()
  end
end

COMMAND:Register()
