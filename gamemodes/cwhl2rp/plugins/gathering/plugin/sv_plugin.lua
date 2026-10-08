--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

config.Add('nodes_respawn_delay', 30)

--- Saves the resource node spawn points of the current map to the schema data.
--
-- Writes `plugins/gather/<map>`.
function cwGather:SaveNodesSpawnPoints()
  cw.core:SaveSchemaData('plugins/gather/'..game.GetMap(), self.nodePoints)
end

--- Loads the resource node spawn points of the current map and makes each spawn as soon as possible.
function cwGather:LoadNodesSpawnPoints()
  self.nodePoints = cw.core:RestoreSchemaData('plugins/gather/'..game.GetMap())

  if !self.nodePoints then
    self.nodePoints = {}
  end

  for k, v in pairs(self.nodePoints) do
    v.nextSpawn = 0
  end
end

--- Returns whether no entity of a class is within 50 units of a position.
--
-- Same check as the `CanSpawnNode` hook; not used by the plugin itself.
--
-- @param position [Vector The position to check]
-- @param class [String The entity class to look for]
-- @return [Boolean Whether the position is free]
function cwGather:CanSpawnNodeAtPos(position, class)
  local props = ents.FindInSphere(position, 50)

  if props then
    for k, v in ipairs(props) do
      if IsValid(v) and v:GetClass() == class then
        return false
      end
    end
  end

  return true
end

--- Spawns a resource node at a spawn point.
--
-- Wood points (`data` is `'wood'`) get a random model from `cwGather.woodNodes`. The node is
-- raised so its bottom rests on the point.
--
-- @param pointTable [Map The spawn point, with `class`, `data`, `position` and `angles`]
function cwGather:SpawnNode(pointTable)
  local entity = ents.Create(pointTable.class)

  if pointTable.data == 'wood' then
    entity:SetModel(table.Random(cwGather.woodNodes))
    entity:SetMoveType(MOVETYPE_VPHYSICS)
    entity:PhysicsInit(SOLID_VPHYSICS)
    entity:SetSolid(SOLID_VPHYSICS)
  end

  local mins, maxs = entity:GetPhysicsObject():GetAABB()

  entity:SetPos(pointTable.position + Vector(0, 0, maxs.z))
  entity:Spawn()

  if IsValid(entity) then
    entity:SetAngles(pointTable.angles)
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
  if !IsValid(player) or !player:HasInitialized() then return end

  local mass = ent:GetPhysicsObject():GetMass()

  for i = 1, math.Clamp(mass / 25, 1, 5) do
    local chance = math.random(1, 100) + cw.attributes:Fraction(player, ATB_SCAVENGER, 50)

    if chance >= 90 then
      cw.entity:CreateItem(player, 'wooden_board', ent:GetPos())
    elseif chance >= 70 then
      cw.entity:CreateItem(player, 'wooden_parts', ent:GetPos())
    end
  end

  -- cw.player:Notify(player, "Масса объекта: "..ent:GetPhysicsObject():GetMass())
  player:ProgressAttribute(ATB_SCAVENGER, math.Round(math.Clamp(mass / 10, 5, 25)), true)
end
