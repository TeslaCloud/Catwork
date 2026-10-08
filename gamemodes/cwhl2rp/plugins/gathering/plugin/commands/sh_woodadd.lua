--- Registers the `/WoodAdd` command, which adds a wood node spawn point where the admin is looking and spawns a
-- breakable wooden prop there.

local COMMAND = cw.command:New('WoodAdd')
COMMAND.tip = '#Command_Woodadd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Adds a wood node spawn point where the player is looking, spawns a node there and saves the points.
function COMMAND:OnRun(player, arguments)
  local class = 'prop_physics'
  local entity = ents.Create(class)

  entity:SetModel(table.Random(cwGather.woodNodes))
  entity:SetMoveType(MOVETYPE_VPHYSICS)
  entity:PhysicsInit(SOLID_VPHYSICS)
  entity:SetSolid(SOLID_VPHYSICS)

  local mins, maxs = entity:GetPhysicsObject():GetAABB()

  local Position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, maxs.z)
  entity:SetPos(Position)
  entity:Spawn()

  if IsValid(entity) then
    local Angles = Angle(0, player:EyeAngles().yaw + 180, 0)
    entity:SetAngles(Angles)

    table.insert(cwGather.nodePoints, {
      position = Position - Vector(0, 0, maxs.z),
      angles = Angles,
      nextSpawn = 0,
      class = class,
      data = 'wood'
    })

    cw.player:Notify(player, L('Gathering_AddedWoodPoint'))

    cwGather:SaveNodesSpawnPoints()
  end
end

COMMAND:Register()
