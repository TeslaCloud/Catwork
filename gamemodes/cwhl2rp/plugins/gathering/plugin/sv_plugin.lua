--- Server-side core of the Gathering plugin: the `nodes_respawn_delay` config key, the saving, loading and spawning of
-- resource node spawn points, and the wood reward.
--
-- Spawn points live in `cwGather.nodePoints` and are kept per map in `plugins/gather/<map>`; the node each point last
-- spawned is in `cwGather.nodes`. `cwGather:PlayerBreaksWood` drops `wooden_board` or `wooden_parts` items at a broken
-- prop, with the number of rolls set by the prop's mass and the odds by the Scavenger attribute, which it also
-- progresses.

config.Add('nodes_respawn_delay', 30)

-- Kept apart from the spawn points, which are saved as they are. Keyed by the point's table.
cwGather.nodes = cwGather.nodes or setmetatable({}, { __mode = 'k' })

--- Saves the resource node spawn points of the current map to the schema data.
--
-- Writes `plugins/gather/<map>`.
function cwGather:SaveNodesSpawnPoints()
  cw.core:SaveSchemaData('plugins/gather/'..game.GetMap(), self.nodePoints)
end

--- Loads the resource node spawn points of the current map and makes each spawn as soon as possible.
--
-- The list is rebuilt without the gaps that removed points left in older data.
function cwGather:LoadNodesSpawnPoints()
  self.nodePoints = {}

  for k, v in pairs(cw.core:RestoreSchemaData('plugins/gather/'..game.GetMap())) do
    v.nextSpawn = 0

    self.nodePoints[#self.nodePoints + 1] = v
  end
end

--- Spawns a resource node at a spawn point and remembers it as the point's node.
--
-- Wood points (`data` is `'wood'`) get a random model from `cwGather.woodNodes`. The node is
-- raised so its bottom rests on the point.
--
-- @param pointTable [Map The spawn point, with `class`, `data`, `position` and `angles`]
-- @return [Entity The node, or `nil` when it could not be created]
function cwGather:SpawnNode(pointTable)
  local entity = ents.Create(pointTable.class)

  if !IsValid(entity) then return end

  if pointTable.data == 'wood' then
    entity:SetModel(table.Random(cwGather.woodNodes))
    entity:SetMoveType(MOVETYPE_VPHYSICS)
    entity:PhysicsInit(SOLID_VPHYSICS)
    entity:SetSolid(SOLID_VPHYSICS)
  end

  local physicsObject = entity:GetPhysicsObject()

  -- Without a physics object, as with a missing model, there are no bounds to place the node by.
  if !IsValid(physicsObject) then
    entity:Remove()

    return
  end

  local mins, maxs = physicsObject:GetAABB()

  entity:SetPos(pointTable.position + Vector(0, 0, maxs.z))
  entity:Spawn()

  if IsValid(entity) then
    entity:SetAngles(pointTable.angles)

    self.nodes[pointTable] = entity

    return entity
  end
end

--- Gives a player wood for breaking a wooden prop.
--
-- Rolls once per 25 units of the prop's mass (1 to 5 rolls), each roll raised by the
-- player's Scavenger attribute, and drops a `wooden_board` or `wooden_parts` item at the
-- prop for good rolls. Progresses Scavenger by 5 to 25 depending on the mass.
--
-- @param player [Player The player who broke the prop]
-- @param ent [Entity The broken prop]
function cwGather:PlayerBreaksWood(player, ent)
  if !IsValid(player) or !player:IsPlayer() or !player:HasInitialized() then return end

  local physicsObject = ent:GetPhysicsObject()

  if !IsValid(physicsObject) then return end

  local mass = physicsObject:GetMass()

  for i = 1, math.Clamp(mass / 25, 1, 5) do
    local chance = math.random(1, 100) + (cw.attributes:Fraction(player, ATB_SCAVENGER, 50) or 0)

    if chance >= 90 then
      cw.entity:CreateItem(player, 'wooden_board', ent:GetPos())
    elseif chance >= 70 then
      cw.entity:CreateItem(player, 'wooden_parts', ent:GetPos())
    end
  end

  player:ProgressAttribute(ATB_SCAVENGER, math.Round(math.Clamp(mass / 10, 5, 25)), true)
end
