--- Server-side hooks of the Gathering plugin that respawn resource nodes at their spawn points and reward players for
-- breaking wooden props.
--
-- `OneSecond` spawns a node at every point whose `nodes_respawn_delay` has passed and that `CanSpawnNode` allows. A
-- `PropBreak` hook passes broken wooden props to `cwGather:PlayerBreaksWood`.

--- Called after Catwork has loaded the map entities; loads the resource node spawn points.
function cwGather:ClockworkInitPostEntity()
  self:LoadNodesSpawnPoints()
end

--- Called every second; respawns resource nodes whose respawn delay has passed.
--
-- A point only spawns when `CanSpawnNode` allows it, then waits for the
-- `nodes_respawn_delay` config before the next node.
function cwGather:OneSecond()
  local curTime = CurTime()

  for k, v in ipairs(self.nodePoints) do
    if curTime > v.nextSpawn then
      if hook.Run('CanSpawnNode', v.position, v.class) then
        self:SpawnNode(v)
        v.nextSpawn = curTime + math.Round(config.GetVal('nodes_respawn_delay'))
      end
    end
  end
end

--- Called to check whether a node can spawn at a point; blocks it within 50 units of a node of the same class.
--
-- @param position [Vector The spawn point's position]
-- @param class [String The node's entity class]
-- @return [Boolean Whether the node can spawn]
function cwGather:CanSpawnNode(position, class)
  local entities = ents.FindInSphere(position, 50)

  if entities then
    for k, v in ipairs(entities) do
      if IsValid(v) and v:GetClass() == class then
        return false
      end
    end
  end

  return true
end

hook.Add('PropBreak', 'cwGather_wood', function(ply, ent)
  if ent:GetMaterialType() == MAT_WOOD then
    cwGather:PlayerBreaksWood(ply, ent)
  end
end)
