--- Server-side hooks of the Gathering plugin that respawn resource nodes at their spawn points and reward players for
-- breaking wooden props.
--
-- `OneSecond` spawns a node at every point whose node has been gone for `nodes_respawn_delay` seconds and that
-- `CanSpawnNode` allows. A `PropBreak` hook passes broken wooden props to `cwGather:PlayerBreaksWood`.

--- Called after Catwork has loaded the map entities; loads the resource node spawn points.
function cwGather:ClockworkInitPostEntity()
  self:LoadNodesSpawnPoints()
end

--- Called every second; respawns resource nodes whose respawn delay has passed.
--
-- The `nodes_respawn_delay` config runs from the moment a point's node is found gone. The
-- point then spawns a new node when `CanSpawnNode` allows it, and is looked at again five
-- seconds later when it does not or the node cannot be created.
function cwGather:OneSecond()
  local points = self.nodePoints

  if !points then return end

  local curTime = CurTime()
  local nodes = self.nodes

  for k, v in ipairs(points) do
    local node = nodes[v]

    if node != nil then
      if !IsValid(node) then
        nodes[v] = nil
        v.nextSpawn = curTime + math.Round(config.GetVal('nodes_respawn_delay'))
      end
    elseif curTime > v.nextSpawn
    and (!hook.Run('CanSpawnNode', v.position, v.class) or !self:SpawnNode(v)) then
      v.nextSpawn = curTime + 5
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
  if IsValid(ply) and ply:IsPlayer() and ent:GetMaterialType() == MAT_WOOD then
    cwGather:PlayerBreaksWood(ply, ent)
  end
end)
