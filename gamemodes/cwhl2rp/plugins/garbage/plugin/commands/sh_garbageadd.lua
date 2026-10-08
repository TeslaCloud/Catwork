--- Registers the `/GarbageAdd` command, which adds a garbage spawn point where the admin is looking and spawns a
-- `cw_garbage` pile there.

local COMMAND = cw.command:New('GarbageAdd')
COMMAND.tip = '#Command_Garbageadd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.alias = { 'AddGarbage', 'GarbageSpawnAdd' }

--- Adds a garbage spawn point where the player is looking, spawns a pile there and saves the points.
function COMMAND:OnRun(player, arguments)
  local entity = ents.Create('cw_garbage')

  local Position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 5)
  entity:SetPos(Position)
  entity:Spawn()

  if IsValid(entity) then
    Angles = Angle(0, player:EyeAngles().yaw + 180, 0)
    entity:SetAngles(Angles)

    table.insert(cwGarbage.garbagePoints, {
      position = Position,
      angles = Angles,
      nextSpawn = 0
    })

    cw.player:Notify(player, L('Garbage_AddedPoint'))

    cwGarbage:SaveGarbageSpawnPoints()
  end
end

COMMAND:Register()
