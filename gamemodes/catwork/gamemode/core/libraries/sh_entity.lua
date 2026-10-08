--- Defines the `cw.entity` library, helpers for entities in general and for doors, ragdolls, property and item entities
-- in particular.
--
-- The shared part classifies entities and checks lines of sight. The server part manages doors (names, text, parents,
-- ownability, opening and blasting them), tracks which character owns an entity, and spawns `cw_item`, `cw_cash` and
-- `cw_shipment` entities. The client part fetches the item of an item entity over the `FetchItemData` message and
-- works out where door text is drawn.

library.New('entity', cw)

if CLIENT then
  --- Returns the position and angles of a weapon's muzzle attachment.
  --
  -- When the weapon is carried by the local player and seen in first person, the attachment is read
  -- from the viewmodel instead of the world model.
  -- @param weapon [Weapon The weapon]
  -- @param attachment=1 [Number Index of the attachment]
  -- @return [Vector The muzzle position, Angle The muzzle angles; the weapon's own position and angles when it has
  -- no such attachment, the world origin when the weapon is invalid]
  function cw.entity:GetMuzzlePos(weapon, attachment)
    if !IsValid(weapon) then
      return vector_origin, Angle(0, 0, 0)
    end

    local origin = weapon:GetPos()
    local angle = weapon:GetAngles()

    if weapon:IsWeapon() and weapon:IsCarriedByLocalPlayer() then
      local owner = weapon:GetOwner()

      if IsValid(owner) and GetViewEntity() == owner then
        local viewmodel = owner:GetViewModel()

        if IsValid(viewmodel) then
          weapon = viewmodel
        end
      end
    end

    local attachment = weapon:GetAttachment(attachment or 1)

    if !attachment then
      return origin, angle
    end

    return attachment.Pos, attachment.Ang
  end
else
  --- Returns the doors that existed on the map when the server started.
  -- @return [Map<Entity> The doors indexed by entity index]
  function cw.entity:GetDoorEntities()
    return self.DoorEntities or {}
  end
end

--- Returns whether an entity is a door.
--
-- Doors are `func_door`, `func_door_rotating`, `prop_door_rotating` and `func_movelinear`
-- entities, and `prop_dynamic` entities whose model path contains `door`.
-- @param entity [Entity The entity to check]
-- @return [Boolean `true` when the entity is a door, `nil` otherwise]
function cw.entity:IsDoor(entity)
  if IsValid(entity) then
    local class = entity:GetClass()
    local model = entity:GetModel()

    if class and model then
      class = string.lower(class)
      model = string.lower(model)

      if class == 'func_door'
          or class == 'func_door_rotating'
          or class == 'prop_door_rotating'
          or (class == 'prop_dynamic' and string.find(model, 'door'))
          or class == 'func_movelinear' then
        return true
      end
    end
  end
end

--- Returns whether an entity is fading out to be removed by `cw.entity:Decay`.
-- @param entity [Entity The entity to check]
-- @return [Boolean Whether the entity is decaying; the decay timer's ID string when it is, `nil` otherwise]
function cw.entity:IsDecaying(entity)
  return entity.cwIsDecaying
end

--- Returns a door and the doors next to it that form a double door.
--
-- Partners have the same class, model and skin, sit 90 to 100 units away at the same height and
-- face another direction.
-- @param entity [Entity The door]
-- @return [List<Entity> The door followed by its partners]
function cw.entity:GetDoorPartners(entity)
  local doorPartners = { entity }
  local doorEntities = ents.FindByClass(entity:GetClass())
  local doorAngles = entity:GetAngles()
  local doorModel = entity:GetModel()
  local doorSkin = entity:GetSkin()
  local doorPos = entity:GetPos()

  for k, v in pairs(doorEntities) do
    if entity != v and v:GetModel() == doorModel
    and v:GetSkin() == doorSkin then
      local tempPosition = v:GetPos()
      local distance = tempPosition:Distance(doorPos)

      if distance >= 90 and distance <= 100
      and v:GetAngles() != doorAngles then
        if math.floor(tempPosition.z) == math.floor(doorPos.z) then
          doorPartners[#doorPartners + 1] = v
        end
      end
    end
  end

  return doorPartners
end

--- Returns whether an entity is inside an axis-aligned box.
--
-- The shoot position is used for players and NPCs, the entity position for anything else.
-- @param entity [Entity The entity to check]
-- @param minimum [Vector One corner of the box]
-- @param maximum [Vector The opposite corner of the box]
-- @return [Boolean Whether the entity is inside the box]
function cw.entity:IsInBox(entity, minimum, maximum)
  local position = entity:GetPos()

  if entity:IsPlayer() or entity:IsNPC() then
    position = entity:GetShootPos()
  end

  if (position.x >= math.min(minimum.x, maximum.x) and position.x <= math.max(minimum.x, maximum.x))
  and (position.y >= math.min(minimum.y, maximum.y) and position.y <= math.max(minimum.y, maximum.y))
  and (position.z >= math.min(minimum.z, maximum.z) and position.z <= math.max(minimum.z, maximum.z)) then
    return true
  else
    return false
  end
end

--- Returns the position of an entity's pelvis bone, such as a ragdoll's.
-- @param entity [Entity The entity]
-- @return [Vector The pelvis position, or the entity's position when it has no pelvis bone]
function cw.entity:GetPelvisPosition(entity)
  local position = entity:GetPos()
  local physBone = entity:LookupBone('ValveBiped.Bip01_Pelvis')

  if physBone then
    local bonePosition = entity:GetBonePosition(physBone)

    if bonePosition then
      position = bonePosition
    end
  end

  return position
end

--- Returns whether a position is visible from the centre of an entity.
--
-- Traces against solid, opaque and moveable contents, hitboxes and monsters, and counts the
-- position as visible when the trace gets far enough.
-- @param entity [Entity The entity looking]
-- @param position [Vector The position to look at]
-- @param iAllowance=0.75 [Number Fraction of the trace that must be clear, from `0` to `1`]
-- @param tIgnoreEnts=nil [List<Entity> Extra entities the trace ignores; any other non-`nil` value ignores them all]
-- @return [Boolean `true` when visible, `nil` otherwise]
function cw.entity:CanSeePosition(entity, position, iAllowance, tIgnoreEnts)
  local trace = {}

  trace.mask =
    CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
  trace.start = entity:LocalToWorld(entity:OBBCenter())
  trace.endpos = position
  trace.filter = { entity }

  if tIgnoreEnts then
    if type(tIgnoreEnts) == 'table' then
      table.Add(trace.filter, tIgnoreEnts)
    else
      table.Add(trace.filter, ents.GetAll())
    end
  end

  trace = util.TraceLine(trace)

  if trace.Fraction >= (iAllowance or 0.75) then
    return true
  end
end

--- Returns whether an NPC's shoot position is visible from the centre of an entity.
-- @param entity [Entity The entity looking]
-- @param target [NPC The NPC to look at]
-- @param iAllowance=0.75 [Number Fraction of the trace that must be clear, from `0` to `1`]
-- @param tIgnoreEnts=nil [List<Entity> Extra entities the trace ignores; any other non-`nil` value ignores them all]
-- @return [Boolean `true` when visible, `nil` otherwise]
-- @see cw.entity:CanSeePosition
function cw.entity:CanSeeNPC(entity, target, iAllowance, tIgnoreEnts)
  local trace = {}

  trace.mask =
    CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
  trace.start = entity:LocalToWorld(entity:OBBCenter())
  trace.endpos = target:GetShootPos()
  trace.filter = { entity, target }

  if tIgnoreEnts then
    if type(tIgnoreEnts) == 'table' then
      table.Add(trace.filter, tIgnoreEnts)
    else
      table.Add(trace.filter, ents.GetAll())
    end
  end

  trace = util.TraceLine(trace)

  if trace.Fraction >= (iAllowance or 0.75) then
    return true
  end
end

--- Returns whether a player and an entity can see each other.
--
-- Visible when the player is looking straight at the entity, or when the player's shoot position
-- is visible from the centre of the entity.
-- @param entity [Entity The entity looking]
-- @param target [Player The player to look at]
-- @param iAllowance=0.75 [Number Fraction of the trace that must be clear, from `0` to `1`]
-- @param tIgnoreEnts=nil [List<Entity> Extra entities the trace ignores; any other non-`nil` value ignores them all]
-- @return [Boolean `true` when visible, `nil` otherwise]
-- @see cw.entity:CanSeePosition
function cw.entity:CanSeePlayer(entity, target, iAllowance, tIgnoreEnts)
  if target:GetEyeTraceNoCursor().Entity == entity then
    return true
  else
    local trace = {}

    trace.mask =
      CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
    trace.start = entity:LocalToWorld(entity:OBBCenter())
    trace.endpos = target:GetShootPos()
    trace.filter = { entity, target }

    if tIgnoreEnts then
      if type(tIgnoreEnts) == 'table' then
        table.Add(trace.filter, tIgnoreEnts)
      else
        table.Add(trace.filter, ents.GetAll())
      end
    end

    trace = util.TraceLine(trace)

    if trace.Fraction >= (iAllowance or 0.75) then
      return true
    end
  end
end

--- Returns whether the centre of an entity is visible from the centre of another.
-- @param entity [Entity The entity looking]
-- @param target [Entity The entity to look at]
-- @param iAllowance=0.75 [Number Fraction of the trace that must be clear, from `0` to `1`]
-- @param tIgnoreEnts=nil [List<Entity> Extra entities the trace ignores; any other non-`nil` value ignores them all]
-- @return [Boolean `true` when visible, `nil` otherwise]
-- @see cw.entity:CanSeePosition
function cw.entity:CanSeeEntity(entity, target, iAllowance, tIgnoreEnts)
  local trace = {}
  trace.mask =
    CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
  trace.start = entity:LocalToWorld(entity:OBBCenter())
  trace.endpos = target:LocalToWorld(target:OBBCenter())
  trace.filter = { entity, target }

  if tIgnoreEnts then
    if type(tIgnoreEnts) == 'table' then
      table.Add(trace.filter, tIgnoreEnts)
    else
      table.Add(trace.filter, ents.GetAll())
    end
  end

  trace = util.TraceLine(trace)

  if trace.Fraction >= (iAllowance or 0.75) then
    return true
  end
end

--- Returns whether a door cannot be bought.
-- @param entity [Entity The door]
-- @return [Boolean The door's `Unownable` networked boolean]
function cw.entity:IsDoorUnownable(entity)
  return entity:GetNWBool('Unownable')
end

--- Returns whether a door is a false door: unownable, named `false` and shown with no text.
-- @param entity [Entity The door]
-- @return [Boolean Whether the door is false]
-- @see cw.entity:SetDoorFalse
function cw.entity:IsDoorFalse(entity)
  return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == 'false'
end

--- Returns whether a door is hidden: unownable and named `hidden`.
-- @param entity [Entity The door]
-- @return [Boolean Whether the door is hidden]
-- @see cw.entity:SetDoorHidden
function cw.entity:IsDoorHidden(entity)
  return self:IsDoorUnownable(entity) and self:GetDoorName(entity) == 'hidden'
end

--- Returns a door's name.
-- @param entity [Entity The door]
-- @return [String The name, or `''` when not set]
function cw.entity:GetDoorName(entity)
  return entity:GetNWString('Name')
end

--- Returns the text displayed on a door.
-- @param entity [Entity The door]
-- @return [String The text, or `''` when not set]
function cw.entity:GetDoorText(entity)
  return entity:GetNWString('Text')
end

--- Returns whether an entity is the ragdoll of a ragdolled player.
-- @param entity [Entity The entity to check]
-- @return [Boolean `true` when the entity is its player's current ragdoll, `nil` otherwise]
function cw.entity:IsPlayerRagdoll(entity)
  local player = entity:GetNWEntity('Player')

  if IsValid(player) then
    if player:GetRagdollEntity() == entity then
      return true
    end
  end
end

--- Returns the player an entity belongs to, such as a player's ragdoll.
-- @param entity [Entity The entity]
-- @return [Player The player set with `cw.entity:SetPlayer`, the entity itself when it is a player, or `nil`]
function cw.entity:GetPlayer(entity)
  local player = entity:GetNWEntity('Player')

  if IsValid(player) then
    return player
  elseif entity:IsPlayer() then
    return entity
  end
end

--- Returns whether players can pick up and interact with an entity.
--
-- Frozen or pickup-protected props, NPCs, players, dynamic props, frozen physboxes, other `func_`
-- brush entities and doors are not interactable.
-- @param entity [Entity The entity to check]
-- @return [Boolean Whether the entity is interactable]
function cw.entity:IsInteractable(entity)
  local class = entity:GetClass()

  if string.find(class, 'prop_') then
    if entity:HasSpawnFlags(SF_PHYSPROP_MOTIONDISABLED) or entity:HasSpawnFlags(SF_PHYSPROP_PREVENT_PICKUP) then
      return false
    end
  end

  if entity:IsNPC() or entity:IsPlayer() or string.find(class, 'prop_dynamic') then
    return false
  end

  if class == 'func_physbox' and entity:HasSpawnFlags(SF_PHYSBOX_MOTIONDISABLED) then
    return false
  end

  if class != 'func_physbox' and string.find(class, 'func_') then
    return false
  end

  if self:IsDoor(entity) then
    return false
  end

  return true
end

--- Returns whether an entity is a `prop_physics` or `prop_physics_multiplayer`.
-- @param entity [Entity The entity to check]
-- @return [Boolean `true` when it is a physics prop, `nil` otherwise]
function cw.entity:IsPhysicsEntity(entity)
  local class = string.lower(entity:GetClass())

  if class == 'prop_physics_multiplayer' or class == 'prop_physics' then
    return true
  end
end

--- Returns whether an entity's model path contains `prisoner`, as prisoner pod vehicles do.
-- @param entity [Entity The entity to check]
-- @return [Boolean `true` when it is a pod, `nil` otherwise]
function cw.entity:IsPodEntity(entity)
  local entityModel = string.lower(entity:GetModel())

  if string.find(entityModel, 'prisoner') then
    return true
  end
end

--- Returns whether an entity's model path contains `chair` or `seat`.
-- @param entity [Entity The entity to check]
-- @return [Boolean `true` when it is a chair, `nil` otherwise]
function cw.entity:IsChairEntity(entity)
  if entity:GetModel() then
    local entityModel = string.lower(entity:GetModel())

    if string.find(entityModel, 'chair') or string.find(entityModel, 'seat') then
      return true
    end
  end
end

if CLIENT then
  --- Returns whether the item data of an item entity has been received from the server.
  -- @param entity [Entity The item entity]
  -- @return [Boolean Whether the item data has been fetched]
  -- @see cw.entity:FetchItemData
  function cw.entity:HasFetchedItemData(entity)
    return (entity.cwFetchedItemData == true)
  end

  --- Returns the item instance received for an entity with `cw.entity:FetchItemData`.
  -- @param entity [Entity The item entity]
  -- @return [Item The item instance, or `nil` when not fetched yet]
  function cw.entity:FetchItemTable(entity)
    return entity.cwItemTable
  end

  --- Requests the item instance of an entity from the server over the `FetchItemData` netstream message.
  --
  -- Requests are sent at most every four seconds per entity. The reply creates the instance, after
  -- which `cw.entity:HasFetchedItemData` returns `true` and `cw.entity:FetchItemTable` returns it.
  -- @param entity [Entity The item entity or vehicle]
  function cw.entity:FetchItemData(entity)
    local curTime = CurTime()

    if !entity.m_iNextFetchItemData then
      entity.m_iNextFetchItemData = 0
    end

    if curTime > entity.m_iNextFetchItemData then
      entity.m_iNextFetchItemData = curTime + 4

      if entity:IsVehicle() then
        netstream.Start('FetchItemData', entity:EntIndex())
      else
        netstream.Start('FetchItemData', entity)
      end
    end
  end

  netstream.Hook('FetchItemData', function(data)
    if type(data.entity) == 'number' then
      data.entity = ents.GetByIndex(data.entity)
    end

    if IsValid(data.entity) then
      data.entity.cwFetchedItemData = true
      data.entity.cwItemTable = item.CreateInstance(
        data.definition.index, data.definition.itemID, data.definition.data
      )
    end
  end)
else
  netstream.Hook('FetchItemData', function(player, data)
    local entity = data

    if type(data) == 'number' then
      entity = ents.GetByIndex(data)
    end

    if !IsValid(entity) then return end

    --[[
      Find out what the entity's item table is
      by trying a couple of common methods.
    --]]

    local itemTable = entity.cwItemTable

    if entity.GetItemTable then
      itemTable = entity:GetItemTable()
    end

    if itemTable then
      local definition = item.GetDefinition(itemTable, true)

      if entity:IsVehicle() then
        data = entity:EntIndex()
      end

      netstream.Start(player, 'FetchItemData', {
        definition = definition,
        entity = data
      })
    end
  end)

  --- Dissolves an entity with an `env_entity_dissolver`.
  -- @param entity [Entity The entity to dissolve]
  -- @param dissolveType [Number Dissolve effect, the dissolver's `dissolvetype` key value]
  -- @param iRemoveDelay=nil [Number Seconds after which the entity is removed; it is not removed when `nil`]
  -- @param attacker=nil [Entity Entity set as the dissolver's physics attacker]
  -- @return [Entity The dissolver, already removed]
  function cw.entity:Dissolve(entity, dissolveType, iRemoveDelay, attacker)
    local dissolver = ents.Create('env_entity_dissolver')
    local oldName = entity:GetName()

    if !oldName or oldName == '' then
      entity:SetName('dissolve_'..entity:EntIndex())
    end

    dissolver:SetKeyValue('dissolvetype', dissolveType)
    dissolver:SetKeyValue('magnitude', 0)
    dissolver:SetPos(entity:GetPos())

    if IsValid(attacker) then
      dissolver:SetPhysicsAttacker(attacker)
    end

    dissolver:Spawn()

    --[[ Dissolve the entity now using Fire commands. --]]
    dissolver:Fire('dissolve', entity:GetName(), 0)
    dissolver:Fire('kill', '', 0.1)
    dissolver:Remove()

    --[[ Give the entity its old name back! --]]
    entity:SetName(oldName)

    if iRemoveDelay then
      timer.Simple(iRemoveDelay, function()
        if IsValid(entity) then
          entity:Remove()
        end
      end)
    end

    return dissolver
  end

  --- Makes a door move three times faster for one second.
  --
  -- Does nothing for entities that are not doors or have no speed, or when used on the same door
  -- within two seconds.
  -- @param entity [Entity The door]
  function cw.entity:SetDoorSpeedFast(entity)
    local curTime = CurTime()
    local iSpeed = entity:GetSaveTable().speed

    if cw.entity:IsDoor(entity) and iSpeed
    and (!entity.cwNextDoorSpeed or curTime >= entity.cwNextDoorSpeed) then
      entity:Fire('setspeed', tostring(iSpeed * 3), 0)

      timer.Simple(1, function()
        if IsValid(entity) then
          entity:Fire('setspeed', tostring(iSpeed), 0)
        end
      end)

      entity.cwNextDoorSpeed = curTime + 2
    end
  end

  --- Blasts a door off its hinges, replacing it with a physics prop that decays after five minutes.
  --
  -- The door is unlocked and made invisible and non-solid, its Combine lock explodes and its breach
  -- entity is breached. The prop is pushed away from the attacker, or by `force` when there is no
  -- attacker. The timer meant to restore the door after five minutes checks an undefined `door`
  -- variable, so the door is never restored.
  -- @param entity [Entity The door]
  -- @param force=nil [Vector Force applied to the prop]
  -- @param attacker=nil [Entity The entity that blasted the door]
  function cw.entity:BlastDownDoor(entity, force, attacker)
    entity.cwIsBustedDown = true
    entity:SetNotSolid(true)
    entity:DrawShadow(false)
    entity:SetNoDraw(true)
    entity:EmitSound('physics/wood/wood_box_impact_hard3.wav')
    entity:Fire('unlock', '', 0)

    if IsValid(entity.cwCombineLock) then
      entity.cwCombineLock:Explode()
      entity.cwCombineLock:Remove()
    end

    if IsValid(entity.cwBreachEnt) then
      entity.cwBreachEnt:BreachEntity()
    end

    local fakeDoor = ents.Create('prop_physics')

    fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD)
    fakeDoor:SetAngles(entity:GetAngles())
    fakeDoor:SetModel(entity:GetModel())
    fakeDoor:SetSkin(entity:GetSkin())
    fakeDoor:SetPos(entity:GetPos())
    fakeDoor:Spawn()

    cw.entity:Decay(fakeDoor, 300)

    timer.Create('ResetDoor'..entity:EntIndex(), 300, 1, function()
      if IsValid(door) then
        entity.cwIsBustedDown = nil
        entity:SetNotSolid(false)
        entity:DrawShadow(true)
        entity:SetNoDraw(false)
      end
    end)

    local physicsObject = fakeDoor:GetPhysicsObject()
    if !IsValid(physicsObject) then return end

    if IsValid(attacker) then
      local position = entity:GetPos() - attacker:GetPos()
        position:Normalize()
      force = position * 10000
    end

    if force then
      physicsObject:ApplyForceCenter(force)
    end
  end
end

--- Returns a door's state from its save table.
-- @param entity [Entity The door]
-- @return [Number A `DOOR_STATE_*` enum, `DOOR_STATE_CLOSED` when unknown]
function cw.entity:GetDoorState(entity)
  return entity:GetSaveTable().m_eDoorState or DOOR_STATE_CLOSED
end

--- Returns whether a door is locked.
-- @param entity [Entity The door]
-- @return [Boolean Whether the door's save table says it is locked]
function cw.entity:IsDoorLocked(entity)
  return (entity:GetSaveTable().m_bLocked == true)
end

if SERVER then
  --- Opens a door after a delay.
  --
  -- Dynamic prop doors play their open animation and close again after five seconds. Rotating prop
  -- doors open away from `origin` when it is given.
  -- @param entity [Entity The door]
  -- @param delay [Number Seconds before the door opens]
  -- @param bUnlock=nil [Boolean Unlock the door first]
  -- @param bSound=nil [Boolean Play an impact sound when unlocking]
  -- @param origin=nil [Vector Position the door opens away from]
  -- @param fSpeed=nil [Number Unused]
  function cw.entity:OpenDoor(entity, delay, bUnlock, bSound, origin, fSpeed)
    if self:IsDoor(entity) then
      if bUnlock then
        entity:Fire('unlock', '', delay)
        delay = delay + 0.025

        if bSound then
          entity:EmitSound('physics/wood/wood_box_impact_hard3.wav')
        end
      end

      if entity:GetClass() == 'prop_dynamic' then
        entity:Fire('setanimation', 'open', delay)
        entity:Fire('setanimation', 'close', delay + 5)
      elseif origin and string.lower(entity:GetClass()) == 'prop_door_rotating' then
        local target = ents.Create('info_target')
          target:SetName(tostring(target))
          target:SetPos(origin)
          target:Spawn()
        entity:Fire('openawayfrom', tostring(target), delay)

        timer.Simple(delay + 1, function()
          if IsValid(target) then
            target:Remove()
          end
        end)
      else
        entity:Fire('open', '', delay)
      end
    end
  end

  --- Bashes a closed door open, away from the entity bashing it.
  --
  -- The door opens fast and becomes non-solid to players until it stops overlapping anything.
  -- @param entity [Entity The door]
  -- @param eBasher [Entity The entity bashing the door]
  function cw.entity:BashInDoor(entity, eBasher)
    local curTime = CurTime()

    if self:GetDoorState(entity) != DOOR_STATE_CLOSED then
      return
    end

    local oldCollisionGroup = entity:GetCollisionGroup()

    cw.entity:SetDoorSpeedFast(entity)
    cw.entity:OpenDoor(
      entity, 0, nil, nil, eBasher:GetPos()
    )

    entity:EmitSound('physics/wood/wood_box_impact_hard3.wav')
    entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    entity.cwNextBashDoor = curTime + 3

    cw.entity:ReturnCollisionGroup(
      entity, oldCollisionGroup
    )
  end

  --- Protects an entity from the physics gun and tools and optionally freezes it.
  --
  -- ```
  -- cw.entity:MakeSafe(entity, true, { 'remover', 'weld' }, true)
  -- ```
  --
  -- @param entity [Entity The entity]
  -- @param bPhysgunProtect=nil [Boolean Prevent the physics gun from picking it up]
  -- @param tToolProtect=nil [List<String> Tool modes that cannot be used on it; any other non-`nil` value blocks every
  -- tool]
  -- @param bFreezeEntity=nil [Boolean Disable the entity's motion]
  function cw.entity:MakeSafe(entity, bPhysgunProtect, tToolProtect, bFreezeEntity)
    if bPhysgunProtect then
      entity.PhysgunDisabled = true
    end

    if tToolProtect then
      entity.CanTool = function(entity, player, trace, tool)
        if type(tToolProtect) == 'table' then
          return !table.HasValue(tToolProtect, tool)
        else
          return false
        end
      end
    end

    if bFreezeEntity then
      if IsValid(entity:GetPhysicsObject()) then
        entity:GetPhysicsObject():EnableMotion(false)
      end
    end
  end

  --- Welds every bone of a ragdoll together so it holds its pose like a statue.
  --
  -- The welds are stored in `entity.cwStatueInfo.Welds` and a glass effect plays on each bone.
  -- @param entity [Entity The ragdoll]
  -- @param forceLimit=0 [Number Force a weld takes before breaking; `0` never breaks]
  function cw.entity:StatueRagdoll(entity, forceLimit)
    local bones = entity:GetPhysicsObjectCount()

    if !entity.cwStatueInfo then
      entity.cwStatueInfo = {
        Welds = {}
      }
    end

    if !forceLimit then
      forceLimit = 0
    end

    for bone = 1, bones do
      local boneOne = bone - 1
      local boneTwo = bones - bone

      if !entity.cwStatueInfo.Welds[boneTwo] then
        local constraintOne = constraint.Weld(entity, entity, boneOne, boneTwo, forceLimit)

        if constraintOne then
          entity.cwStatueInfo.Welds[boneOne] = constraintOne
        end
      end

      local constraintTwo = constraint.Weld(entity, entity, boneOne, 0, forceLimit)

      if constraintTwo then
        entity.cwStatueInfo.Welds[boneOne + bones] = constraintTwo
      end

      local effectData = EffectData()
        effectData:SetScale(1)
        effectData:SetOrigin(entity:GetPhysicsObjectNum(boneOne):GetPos())
        effectData:SetMagnitude(1)
      util.Effect('GlassImpact', effectData, true, true)
    end
  end

  --- Spawns every item of an inventory and an amount of cash at a position.
  -- @param inventory [Inventory The items to drop]
  -- @param cash [Number Amount of cash to drop; none when `nil` or not positive]
  -- @param position [Vector Where to drop them]
  -- @param entity=nil [Entity Entity whose ownership the item entities get, copied with `cw.entity:CopyOwner`]
  function cw.entity:DropItemsAndCash(inventory, cash, position, entity)
    if !cw.inventory:IsEmpty(inventory) then
      for k, v in pairs(inventory) do
        for k2, v2 in pairs(v) do
          local itemEntity = self:CreateItem(nil, v2, position)

          if IsValid(itemEntity) and IsValid(entity) then
            self:CopyOwner(entity, itemEntity)
          end
        end
      end
    end

    if cash and cash > 0 then
      self:CreateCash(nil, cash, position)
    end
  end

  --- Creates a ragdoll copying an entity's model, appearance, pose and velocity.
  --
  -- The ragdoll's angles are always set from the entity's angles, so `overrideAngles` has no
  -- effect. The head gets twice the velocity and force. Burning entities give a burning ragdoll.
  -- @param entity [Entity The entity to copy]
  -- @param force=nil [Vector Force applied to each bone]
  -- @param overrideVelocity=nil [Vector Velocity given to the bones instead of 1.5 times the entity's]
  -- @param overrideAngles=nil [Angle Angles to give the ragdoll]
  -- @return [Entity The ragdoll]
  function cw.entity:MakeIntoRagdoll(entity, force, overrideVelocity, overrideAngles)
    local velocity = entity:GetVelocity() * 1.5
    local ragdoll = ents.Create('prop_ragdoll')

    if overrideVelocity then
      velocity = overrideVelocity
    end

    if overrideAngles then
      ragdoll:SetAngles(overrideAngles)
    else
      ragdoll:SetAngles(entity:GetAngles())
    end

    ragdoll:SetMaterial(entity:GetMaterial())
    ragdoll:SetAngles(entity:GetAngles() - Angle(0, -45, 0))
    ragdoll:SetColor(entity:GetColor())
    ragdoll:SetModel(entity:GetModel())
    ragdoll:SetSkin(entity:GetSkin())
    ragdoll:SetPos(entity:GetPos())
    ragdoll:Spawn()

    if IsValid(ragdoll) then
      local headIndex = ragdoll:LookupBone('ValveBiped.Bip01_Head1')

      for i = 1, ragdoll:GetPhysicsObjectCount() do
        local physicsObject = ragdoll:GetPhysicsObjectNum(i)
        local boneIndex = ragdoll:TranslatePhysBoneToBone(i)
        local position, angle = entity:GetBonePosition(boneIndex)

        if IsValid(physicsObject) then
          physicsObject:SetPos(position)
          physicsObject:SetAngles(angle)

          if boneIndex == headIndex then
            physicsObject:SetVelocity(velocity * 2)
          else
            physicsObject:SetVelocity(velocity)
          end

          if force then
            if boneIndex == headIndex then
              physicsObject:ApplyForceCenter(force * 2)
            else
              physicsObject:ApplyForceCenter(force)
            end
          end
        end
      end
    end

    if entity:IsOnFire() then
      ragdoll:Ignite(8, 0)
    end

    return ragdoll
  end

  --- Returns whether a door cannot be sold by its owner.
  -- @param door [Entity The door]
  -- @return [Boolean The door's `unsellable` field]
  function cw.entity:IsDoorUnsellable(door)
    return door.unsellable
  end

  --- Sets the parent of a door, or removes it.
  --
  -- Children of the door are unparented first, and the door's shared access and text are reset.
  -- Parents can share their access and text with their children.
  -- @param door [Entity The door]
  -- @param parent [Entity The parent door; anything that is not a valid door removes the parent]
  -- @see cw.entity:SetDoorSharedAccess
  function cw.entity:SetDoorParent(door, parent)
    if self:IsDoor(door) then
      for k, v in pairs(self:GetDoorChildren(door)) do
        if IsValid(v) then
          self:SetDoorParent(v, false)
        end
      end

      if IsValid(door.doorParent) then
        if door.doorParent.doorChildren then
          door.doorParent.doorChildren[door] = nil
        end
      end

      if IsValid(parent) and self:IsDoor(parent) then
        if parent.doorChildren then
          parent.doorChildren[door] = door
        else
          parent.doorChildren = { [door] = door }
        end

        door.doorParent = parent
      else
        door.doorParent = nil
      end

      door.cwDoorSharedAxs = nil
      door.cwDoorSharedTxt = nil
    end
  end

  --- Returns whether a door has child doors.
  -- @param door [Entity The door]
  -- @return [Boolean Whether the door is a parent]
  function cw.entity:IsDoorParent(door)
    return table.Count(self:GetDoorChildren(door)) > 0
  end

  --- Returns the parent of a door.
  -- @param door [Entity The door]
  -- @return [Entity The parent door, or `nil` when it has none]
  function cw.entity:GetDoorParent(door)
    if IsValid(door.doorParent) then
      return door.doorParent
    end
  end

  --- Returns the child doors of a door.
  -- @param door [Entity The door]
  -- @return [Map<Entity> The children, indexed by themselves]
  function cw.entity:GetDoorChildren(door)
    return door.doorChildren or {}
  end

  --- Sets whether a door can be bought.
  --
  -- Making a door unownable takes it from its owner.
  -- @param entity [Entity The door]
  -- @param unownable [Boolean Whether the door should be unownable]
  function cw.entity:SetDoorUnownable(entity, unownable)
    if self:IsDoor(entity) then
      if unownable then
        entity:SetNWBool('Unownable', true)

        if self:GetOwner(entity) then
          cw.player:TakeDoor(self:GetOwner(entity), entity, true)
        elseif self:HasOwner(entity) then
          self:ClearProperty(entity)
        end
      else
        entity:SetNWBool('Unownable', false)
      end
    end
  end

  --- Sets whether a door is a false door, an unownable door named `false`.
  -- @param entity [Entity The door]
  -- @param isFalse [Boolean Whether the door should be false; `false` makes it ownable and clears its name]
  function cw.entity:SetDoorFalse(entity, isFalse)
    if self:IsDoor(entity) then
      if isFalse then
        self:SetDoorUnownable(entity, true)
        self:SetDoorName(entity, 'false')
      else
        self:SetDoorUnownable(entity, false)
        self:SetDoorName(entity, '')
      end
    end
  end

  --- Sets whether a door is hidden, an unownable door named `hidden`.
  -- @param entity [Entity The door]
  -- @param hidden [Boolean Whether the door should be hidden; `false` makes it ownable and clears its name]
  function cw.entity:SetDoorHidden(entity, hidden)
    if self:IsDoor(entity) then
      if hidden then
        self:SetDoorUnownable(entity, true)
        self:SetDoorName(entity, 'hidden')
      else
        self:SetDoorUnownable(entity, false)
        self:SetDoorName(entity, '')
      end
    end
  end

  --- Sets whether a parent door shares its access with its child doors.
  --
  -- Does nothing for doors without children.
  -- @param entity [Entity The parent door]
  -- @param sharedAccess [Boolean Whether access is shared]
  function cw.entity:SetDoorSharedAccess(entity, sharedAccess)
    if self:IsDoorParent(entity) then
      entity.cwDoorSharedAxs = sharedAccess
    end
  end

  --- Sets whether a parent door shares its text with its child doors.
  --
  -- Enabling it copies the parent's text to every child. Does nothing for doors without children.
  -- @param entity [Entity The parent door]
  -- @param sharedText [Boolean Whether text is shared]
  function cw.entity:SetDoorSharedText(entity, sharedText)
    if self:IsDoorParent(entity) then
      entity.cwDoorSharedTxt = sharedText

      if sharedText then
        for k, v in pairs(self:GetDoorChildren(entity)) do
          if IsValid(v) then
            self:SetDoorText(v, self:GetDoorText(entity))
          end
        end
      end
    end
  end

  --- Returns whether a parent door shares its access with its children.
  -- @param entity [Entity The door]
  -- @return [Boolean Whether access is shared]
  function cw.entity:DoorHasSharedAccess(entity)
    return entity.cwDoorSharedAxs
  end

  --- Returns whether a parent door shares its text with its children.
  -- @param entity [Entity The door]
  -- @return [Boolean Whether text is shared]
  function cw.entity:DoorHasSharedText(entity)
    return entity.cwDoorSharedTxt
  end

  --- Sets the text displayed on a door, and on its children when it shares its text.
  --
  -- Text containing "this door can be purchased" (ignoring case and spaces) is rejected.
  -- @param entity [Entity The door]
  -- @param text [String The text; `nil` clears it]
  function cw.entity:SetDoorText(entity, text)
    if self:IsDoor(entity) then
      if self:IsDoorParent(entity) then
        if self:DoorHasSharedText(entity) then
          for k, v in pairs(self:GetDoorChildren(entity)) do
            if IsValid(v) then
              self:SetDoorText(v, text)
            end
          end
        end
      end

      if text then
        if !string.find(string.gsub(string.lower(text), '%s', ''), 'thisdoorcanbepurchased') then
          entity:SetNWString('Text', text)
        end
      else
        entity:SetNWString('Text', '')
      end
    end
  end

  --- Sets a door's name.
  -- @param entity [Entity The door]
  -- @param name [String The name; `nil` clears it]
  function cw.entity:SetDoorName(entity, name)
    if self:IsDoor(entity) then
      entity:SetNWString('Name', name or '')
    end
  end

  --- Gives a chair vehicle the key values and members of its vehicle list entry, so players sit in it
  -- correctly.
  --
  -- Only acts on `prop_vehicle_prisoner_pod` entities without a vehicle table. Some stock chair
  -- models are first replaced by their `models/nova` equivalents.
  -- @param entity [Entity The chair vehicle]
  -- @return [Boolean `true` when a vehicle entry was applied, `nil` otherwise]
  function cw.entity:SetChairAnimations(entity)
    if !entity.VehicleTable then
      local targetFaction = 'prop_vehicle_prisoner_pod'

      if entity:GetClass() == targetFaction then
        local entityModel = string.lower(entity:GetModel())

        if entityModel == 'models/props_c17/furniturechair001a.mdl'
        or entityModel == 'models/props_furniture/chair1.mdl' then
          entity:SetModel('models/nova/chair_wood01.mdl')
        elseif entityModel == 'models/props_c17/chair_office01a.mdl' then
          entity:SetModel('models/nova/chair_office01.mdl')
        elseif entityModel == 'models/props_combine/breenchair.mdl' then
          entity:SetModel('models/nova/chair_office02.mdl')
        elseif entityModel == 'models/props_interiors/furniture_chair03a.mdl'
        or entityModel == 'models/props_wasteland/controlroom_chair001a.mdl' then
          entity:SetModel('models/nova/chair_plastic01.mdl')
        end

        if self:IsChairEntity(entity) then
          local entityModel = string.lower(entity:GetModel())
          local vehicles = list.Get('Vehicles')
          -- local k2, v2

          for k, v in pairs(vehicles) do
            local keyValues = v.KeyValues
            local members = v.Members
            local model = v.Model
            local class = v.Class

            if string.lower(class) == targetFaction then
              if string.lower(model) == entityModel then
                for k2, v2 in pairs(keyValues) do
                  entity:SetKeyValue(k2, v2)
                end

                entity.VehicleTable = v
                entity.ClassOverride = class

                table.Merge(entity, members)

                return true
              end
            end
          end
        end
      end
    end
  end

  --- Stores the angles an entity started with.
  -- @param entity [Entity The entity]
  -- @param angles [Angle The start angles]
  function cw.entity:SetStartAngles(entity, angles)
    entity.cwStartAng = angles
  end

  --- Returns the angles stored with `cw.entity:SetStartAngles`.
  -- @param entity [Entity The entity]
  -- @return [Angle The start angles, or `nil`]
  function cw.entity:GetStartAngles(entity)
    return entity.cwStartAng
  end

  --- Stores the position an entity started at.
  -- @param entity [Entity The entity]
  -- @param position [Vector The start position]
  function cw.entity:SetStartPosition(entity, position)
    entity.cwStartPos = position
  end

  --- Returns the position stored with `cw.entity:SetStartPosition`.
  -- @param entity [Entity The entity]
  -- @return [Vector The start position, or `nil`]
  function cw.entity:GetStartPosition(entity)
    return entity.cwStartPos
  end

  --- Cancels a pending collision group restore started by `cw.entity:ReturnCollisionGroup`.
  -- @param entity [Entity The entity]
  function cw.entity:StopCollisionGroupRestore(entity)
    timer.Remove('CollisionGroup'..entity:EntIndex())
  end

  --- Restores an entity's collision group once it no longer overlaps anything.
  --
  -- Retries every second while the entity's physics object is penetrating something.
  -- @param entity [Entity The entity]
  -- @param collisionGroup [Number A `COLLISION_GROUP_*` enum]
  function cw.entity:ReturnCollisionGroup(entity, collisionGroup)
    if IsValid(entity) then
      local physicsObject = entity:GetPhysicsObject()
      local index = entity:EntIndex()

      if IsValid(physicsObject) then
        if !physicsObject:IsPenetrating() then
          entity:SetCollisionGroup(collisionGroup)
        else
          timer.Create('CollisionGroup'..index, 1, 1, function()
            self:ReturnCollisionGroup(entity, collisionGroup)
          end)
        end
      end
    end
  end

  --- Sets whether an entity was created by the map.
  -- @param entity [Entity The entity]
  -- @param isMapEntity [Boolean Whether it is a map entity]
  function cw.entity:SetMapEntity(entity, isMapEntity)
    local entIndex = entity:EntIndex()

    if isMapEntity then
      cw.Entities[entity] = true
    else
      cw.Entities[entity] = false
    end
  end

  --- Returns whether an entity was created by the map.
  -- @param entity [Entity The entity]
  -- @return [Boolean Whether it is a map entity]
  function cw.entity:IsMapEntity(entity)
    return cw.Entities[entity] or false
  end

  --- Moves an entity so its nearest point rests on a surface.
  -- @param entity [Entity The entity]
  -- @param position [Vector Point on the surface]
  -- @param normal [Vector Normal of the surface]
  function cw.entity:MakeFlushToGround(entity, position, normal)
    entity:SetPos(position + (entity:GetPos() - entity:NearestPoint(position - (normal * 512))))
  end

  --- Disintegrates an entity: makes it non-solid, freezes it, plays a removal effect and decays it.
  --
  -- When a velocity is given, the entity is pushed first and frozen up to a second later.
  -- @param entity [Entity The entity]
  -- @param delay [Number Seconds the decay takes]
  -- @param velocity=nil [Vector Velocity added to the entity or each ragdoll bone]
  -- @param Callback=nil [Function Called just before the entity is removed]
  -- @see cw.entity:Decay
  function cw.entity:Disintegrate(entity, delay, velocity, Callback)
    if velocity then
      if entity:GetClass() == 'prop_ragdoll' then
        for i = 1, entity:GetPhysicsObjectCount() do
          local physicsObject = entity:GetPhysicsObjectNum(i)

          if IsValid(physicsObject) then
            physicsObject:AddVelocity(velocity)
          end
        end
      elseif IsValid(entity:GetPhysicsObject()) then
        entity:GetPhysicsObject():AddVelocity(velocity)
      end
    end

    self:Decay(entity, delay, Callback)

    if velocity then
      timer.Simple(math.min(1, delay / 2), function()
        if IsValid(entity) then
          entity:SetNotSolid(true)

          if entity:GetClass() == 'prop_ragdoll' then
            for i = 1, entity:GetPhysicsObjectCount() do
              local physicsObject = entity:GetPhysicsObjectNum(i)

              if IsValid(physicsObject) then
                physicsObject:EnableMotion(false)
              end
            end
          elseif IsValid(entity:GetPhysicsObject()) then
            entity:GetPhysicsObject():EnableMotion(false)
          end
        end
      end)
    else
      entity:SetNotSolid(true)

      if entity:GetClass() == 'prop_ragdoll' then
        for i = 1, entity:GetPhysicsObjectCount() do
          local physicsObject = entity:GetPhysicsObjectNum(i)

          if IsValid(physicsObject) then
            physicsObject:EnableMotion(false)
          end
        end
      elseif IsValid(entity:GetPhysicsObject()) then
        entity:GetPhysicsObject():EnableMotion(false)
      end
    end

    local effectData = EffectData()
      effectData:SetEntity(entity)
    util.Effect('entity_remove', effectData, true, true)
  end

  --- Sets the player an entity belongs to, through its `Player` networked entity.
  -- @param entity [Entity The entity]
  -- @param player [Player The player, or `NULL` to clear it]
  -- @see cw.entity:GetPlayer
  function cw.entity:SetPlayer(entity, player)
    entity:SetNWEntity('Player', player)
  end

  --- Fades an entity out over time and removes it.
  --
  -- The entity is also detached from its player. Calling it again on a decaying entity restarts the
  -- fade from the current alpha.
  --
  -- ```
  -- cw.entity:Decay(ragdoll, 300, function()
  --   print('The ragdoll has decayed.')
  -- end)
  -- ```
  --
  -- @param entity [Entity The entity]
  -- @param seconds [Number Roughly how many seconds the fade takes]
  -- @param Callback=nil [Function Called just before the entity is removed]
  function cw.entity:Decay(entity, seconds, Callback)
    local color = entity:GetColor()
    local subtract = math.ceil(color.a / seconds)
    local index = tostring({})
    local alpha = color.a

    if !entity.cwIsDecaying then
      entity.cwIsDecaying = index
    end

    self:SetPlayer(entity, NULL)
    index = entity.cwIsDecaying

    timer.Create('Decay'..index, 1, 0, function()
      alpha = alpha - subtract

      if IsValid(entity) then
        local color = entity:GetColor()
        local decayed = math.Clamp(math.ceil(alpha), 0, 255)

        if color.a <= 0 then
          if Callback then Callback() end

          entity:Remove()
          timer.Remove('Decay'..index)
        else
          entity:SetColor(Color(color.r, color.g, color.b, decayed))
        end
      else
        timer.Remove('Decay'..index)
      end
    end)
  end

  --- Spawns a `cw_cash` entity.
  --
  -- Does nothing when cash is disabled in the config.
  --
  -- The owner is either a player or, for offline owners, a table with a character `key` and the
  -- player's `uniqueID`.
  -- @param ownerObj [Player The owner, or a `Map` with `key` and `uniqueID`; no owner when `nil`]
  -- @param cash [Number Amount of cash, rounded]
  -- @param position [Vector Where to spawn it]
  -- @param angles=nil [Angle Angles of the entity]
  -- @return [Entity The cash entity, or `nil` when cash is disabled or it failed to spawn]
  function cw.entity:CreateCash(ownerObj, cash, position, angles)
    if config.Get('cash_enabled'):Get() then
      local entity = ents.Create('cw_cash')

      if type(ownerObj) == 'table' then
        if ownerObj.key and ownerObj.uniqueID then
          cw.player:GivePropertyOffline(ownerObj.key, ownerObj.uniqueID, entity, true)
        end
      elseif IsValid(ownerObj) and ownerObj:IsPlayer() then
        cw.player:GiveProperty(ownerObj, entity)
      end

      if !angles then
        angles = Angle(0, 0, 0)
      end

      entity:SetPos(position)
      entity:SetAngles(angles)
      entity:Spawn()

      if IsValid(entity) then
        entity:SetAmount(math.Round(cash))

        return entity
      end
    end
  end

  --- Spawns a `cw_shipment` entity holding a batch of items.
  -- @param ownerObj [Player The owner, or a `Map` with `key` and `uniqueID`; no owner when `nil`]
  -- @param uniqueID [String Unique ID of the item]
  -- @param batch [Number How many items the shipment holds]
  -- @param position [Vector Where to spawn it]
  -- @param angles=nil [Angle Angles of the entity]
  -- @return [Entity The shipment entity]
  function cw.entity:CreateShipment(ownerObj, uniqueID, batch, position, angles)
    local entity = ents.Create('cw_shipment')

    if !angles then
      angles = Angle(0, 0, 0)
    end

    if type(ownerObj) == 'table' then
      if ownerObj.key and ownerObj.uniqueID then
        cw.player:GivePropertyOffline(ownerObj.key, ownerObj.uniqueID, entity, true)
      end
    elseif IsValid(ownerObj) and ownerObj:IsPlayer() then
      cw.player:GiveProperty(ownerObj, entity)
    end

    entity:SetItemTable(uniqueID, batch)
    entity:SetAngles(angles)
    entity:SetPos(position)
    entity:Spawn()

    return entity
  end

  --- Spawns an item as a `cw_item` entity.
  --
  -- Item definitions and unique IDs get a new instance. Calls the item's `OnEntitySpawned` and
  -- enables its `bodyGroup` on the entity.
  --
  -- ```
  -- cw.entity:CreateItem(player, 'ration', player:GetEyeTraceNoCursor().HitPos)
  -- ```
  --
  -- @param ownerObj [Player The owner, or a `Map` with `key` and `uniqueID`; no owner when `nil`]
  -- @param itemTable [Item The item instance or definition, or a unique ID string]
  -- @param position [Vector Where to spawn it]
  -- @param angles=nil [Angle Angles of the entity]
  -- @return [Entity The item entity, or `nil` when `itemTable` is `nil`]
  function cw.entity:CreateItem(ownerObj, itemTable, position, angles)
    if itemTable == nil then return end

    item.Validate(itemTable)

    local entity = ents.Create('cw_item')

    if !angles then
      angles = Angle(0, 0, 0)
    end

    if isstring(itemTable) then
      itemTable = item.CreateInstance(itemTable)
    end

    if type(ownerObj) == 'table' then
      if ownerObj.key and ownerObj.uniqueID then
        cw.player:GivePropertyOffline(ownerObj.key, ownerObj.uniqueID, entity, true)
      end
    elseif IsValid(ownerObj) and ownerObj:IsPlayer() then
      cw.player:GiveProperty(ownerObj, entity)
    end

    if !itemTable:IsInstance() then
      itemTable = item.CreateInstance(itemTable.uniqueID)
    end

    entity:SetItemTable(itemTable)
    entity:SetAngles(angles)
    entity:SetPos(position)
    entity:Spawn()

    if itemTable.OnEntitySpawned then
      itemTable:OnEntitySpawned(entity)
    end

    local itemBodyGroup = itemTable.bodyGroup

    if itemBodyGroup then
      entity:SetBodygroup(itemBodyGroup, 1)
    end

    return entity
  end

  --- Gives an entity the same owner as another entity.
  -- @param entity [Entity The entity to copy the owner from]
  -- @param target [Entity The entity to give the owner to]
  function cw.entity:CopyOwner(entity, target)
    local removeDelay = self:QueryProperty(entity, 'removeDelay')
    local networked = self:QueryProperty(entity, 'networked')
    local uniqueID = self:QueryProperty(entity, 'uniqueID')
    local key = self:QueryProperty(entity, 'key')

    cw.player:GivePropertyOffline(key, uniqueID, target, networked, removeDelay)
  end

  --- Returns whether an entity belongs to another character of the same player.
  -- @param player [Player The player]
  -- @param entity [Entity The entity]
  -- @return [Boolean Whether the player owns it with a character other than the current one]
  function cw.entity:BelongsToAnotherCharacter(player, entity)
    local uniqueID = self:QueryProperty(entity, 'uniqueID')
    local key = self:QueryProperty(entity, 'key')

    if uniqueID and key then
      if uniqueID == player:UniqueID() and key != player:GetCharacterKey() then
        return true
      end
    end

    return false
  end

  --- Sets a field of an owned entity's property table.
  --
  -- Does nothing for entities without an owner.
  --
  -- @param entity [Entity The entity]
  -- @param key [String Name of the field]
  -- @param value [Any The new value]
  function cw.entity:SetPropertyVar(entity, key, value)
    if entity.cwPropertyTab then entity.cwPropertyTab[key] = value end
  end

  --- Returns a field of an entity's property table.
  --
  -- The table is set by `cw.player:GiveProperty` and holds `key`, `owner`, `owned`, `uniqueID`,
  -- `networked` and `removeDelay`.
  -- @param entity [Entity The entity]
  -- @param key [String Name of the field]
  -- @param default=nil [Any Value returned when the field or the table is not set]
  -- @return [Any The field's value, or `default`]
  function cw.entity:QueryProperty(entity, key, default)
    if entity.cwPropertyTab then
      return entity.cwPropertyTab[key] or default
    else
      return default
    end
  end

  --- Takes an entity away from its owner, whether the owner is online or not.
  -- @param entity [Entity The entity]
  function cw.entity:ClearProperty(entity)
    local owner = self:GetOwner(entity)

    if owner then
      cw.player:TakeProperty(owner, entity)
    elseif self:HasOwner(entity) then
      local uniqueID = self:QueryProperty(entity, 'uniqueID')
      local key = self:QueryProperty(entity, 'key')

      cw.player:TakePropertyOffline(key, uniqueID, entity)
    end
  end

  --- Returns whether an entity is owned by a character.
  -- @param entity [Entity The entity]
  -- @return [Boolean Whether the entity has an owner]
  function cw.entity:HasOwner(entity)
    return self:QueryProperty(entity, 'owned')
  end

  --- Returns the player that owns an entity.
  -- @param entity [Entity The entity]
  -- @param bAnyCharacter=nil [Boolean Return the owner even when the entity belongs to another of their characters]
  -- @return [Player The owner, or `nil` when it is not online or on the owning character]
  function cw.entity:GetOwner(entity, bAnyCharacter)
    local owner = self:QueryProperty(entity, 'owner')
    local key = self:QueryProperty(entity, 'key')

    if IsValid(owner) and (bAnyCharacter or owner:GetCharacterKey() == key) then
      return owner
    end
  end
else
  --- Fades a clientside entity out over time and removes it.
  --
  -- Calling it again on a decaying entity restarts the fade from the current alpha.
  -- @param entity [Entity The entity]
  -- @param seconds [Number Roughly how many seconds the fade takes]
  -- @param Callback=nil [Function Called just before the entity is removed]
  function cw.entity:Decay(entity, seconds, Callback)
    local color = entity:GetColor()
    local subtract = math.ceil(color.a / seconds)
    local index = tostring({})
    local alpha = color.a

    if !entity.cwIsDecaying then
      entity.cwIsDecaying = index
    end

    index = entity.cwIsDecaying

    timer.Create('Decay'..index, 1, 0, function()
      alpha = alpha - subtract

      if IsValid(entity) then
        local color = entity:GetColor()
        local decayed = math.Clamp(math.ceil(alpha), 0, 255)

        if color.a <= 0 then
          if Callback then Callback() end

          entity:Remove()
          timer.Remove('Decay'..index)
        else
          entity:SetColor(Color(color.r, color.g, color.b, decayed))
        end
      else
        timer.Remove('Decay'..index)
      end
    end)
  end

  --[[
    Description: A function to calculate a door's text position.
    Author: Nori (thanks a lot mate, if you're reading this, check out
    CakeScript G3 - it's epic!).
  ]] --

  --- Calculates where to draw the text on both faces of a door.
  --
  -- Traces onto the door's thinnest side, and retries from the other side when the trace hits the
  -- world. The body checks an undefined `reverse` variable instead of `reversed`, so the retry
  -- traces from the same side.
  -- @param door [Entity The door]
  -- @param reversed=nil [Boolean Whether this is the retry from the other side]
  -- @return [Map The `position`, `angles`, `positionBack`, `anglesBack`, `width` and `hitWorld` of the text]
  function cw.entity:CalculateDoorTextPosition(door, reversed)
    local traceData = {}
    local obbCenter = door:OBBCenter()
    local obbMaxs = door:OBBMaxs()
    local obbMins = door:OBBMins()

    traceData.endpos = door:LocalToWorld(obbCenter)
    traceData.filter = ents.FindInSphere(traceData.endpos, 20)

    for k, v in pairs(traceData.filter) do
      if v == door then
        traceData.filter[k] = nil
      end
    end

    local length = 0
    local width = 0
    local size = obbMins - obbMaxs

    size.x = math.abs(size.x)
    size.y = math.abs(size.y)
    size.z = math.abs(size.z)

    if size.z < size.x and size.z < size.y then
      length = size.z
      width = size.y

      if reverse then
        traceData.start = traceData.endpos - (door:GetUp() * length)
      else
        traceData.start = traceData.endpos + (door:GetUp() * length)
      end
    elseif size.x < size.y then
      length = size.x
      width = size.y

      if reverse then
        traceData.start = traceData.endpos - (door:GetForward() * length)
      else
        traceData.start = traceData.endpos + (door:GetForward() * length)
      end
    elseif size.y < size.x then
      length = size.y
      width = size.x

      if reverse then
        traceData.start = traceData.endpos - (door:GetRight() * length)
      else
        traceData.start = traceData.endpos + (door:GetRight() * length)
      end
    end

    local trace = util.TraceLine(traceData)
    local angles = trace.HitNormal:Angle()

    if trace.HitWorld and !reversed then
      return self:CalculateDoorTextPosition(door, true)
    end

    angles:RotateAroundAxis(angles:Forward(), 90)
    angles:RotateAroundAxis(angles:Right(), 90)

    local position = trace.HitPos - (((traceData.endpos - trace.HitPos):Length() * 2) + 2) * trace.HitNormal
    local anglesBack = trace.HitNormal:Angle()
    local positionBack = trace.HitPos + (trace.HitNormal * 2)

    anglesBack:RotateAroundAxis(anglesBack:Forward(), 90)
    anglesBack:RotateAroundAxis(anglesBack:Right(), -90)

    return {
      positionBack = positionBack,
      anglesBack = anglesBack,
      position = position,
      hitWorld = trace.HitWorld,
      angles = angles,
      width = math.abs(width)
    }
  end

  --- Runs an entity menu option on the server over the `EntityMenuOption` netstream message.
  -- @param entity [Entity The entity]
  -- @param option [String Name of the option]
  -- @param arguments [Any Arguments of the option, such as the action to run]
  function cw.entity:ForceMenuOption(entity, option, arguments)
    netstream.Start('EntityMenuOption', { entity, option, arguments })
  end

  --- Returns whether an entity is owned by a character, through its `Owned` networked boolean.
  -- @param entity [Entity The entity]
  -- @return [Boolean Whether the entity has an owner]
  function cw.entity:HasOwner(entity)
    return entity:GetNWBool('Owned')
  end

  --- Returns the player that owns an entity, if its ownership is networked.
  -- @param entity [Entity The entity]
  -- @param bAnyCharacter=nil [Boolean Return the owner even when the entity belongs to another of their characters]
  -- @return [Player The owner, or `nil` when unknown or not on the owning character]
  function cw.entity:GetOwner(entity, bAnyCharacter)
    local owner = entity:GetNWEntity('Owner')
    local key = entity:GetNWInt('Key')

    if IsValid(owner) and (bAnyCharacter or cw.player:GetCharacterKey(owner) == key) then
      return owner
    end
  end
end
