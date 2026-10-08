--- Registers the `/WoodAdd` command, which adds a wood node spawn point where the admin is looking and spawns a
-- breakable wooden prop there.

local COMMAND = cw.command:New('WoodAdd')
COMMAND.tip = '#Command_Woodadd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Adds a wood node spawn point where the player is looking, spawns a node there and saves the points.
function COMMAND:OnRun(player, arguments)
  local point = {
    position = player:GetEyeTraceNoCursor().HitPos,
    angles = Angle(0, player:EyeAngles().yaw + 180, 0),
    nextSpawn = 0,
    class = 'prop_physics',
    data = 'wood'
  }

  if IsValid(cwGather:SpawnNode(point)) then
    table.insert(cwGather.nodePoints, point)

    cw.player:Notify(player, L('Gathering_AddedWoodPoint'))

    cwGather:SaveNodesSpawnPoints()
  end
end

COMMAND:Register()
