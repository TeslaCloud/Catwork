--- Server-side functions of the Combine Locks plugin that check access to a Combine lock, fit a lock to a door and save
-- and load the locks of the current map.
--
-- `Schema:PlayerHasCombineLockAccess` lets Combine players through unless their rank is one the lock is closed to, and
-- other players when they carry the matching `combine_lock_access_<level>` card or the `combine_lock_access_x` card.
-- `Schema:ApplyCombineLock` spawns a `cw_combinelock` parented to a door, and `PLUGIN:SaveCombineLocks` and
-- `PLUGIN:LoadCombineLocks` keep the locks in the schema data under `plugins/combinelocks/<map>`.

local PLUGIN = PLUGIN

--- Returns whether a player can open a Combine lock.
--
-- Combine players have access unless their rank is one the lock is restricted for. Other
-- players need the `combine_lock_access_<access>` card or the `combine_lock_access_x` card.
--
-- @param client [Player The player to check]
-- @param access [Number The lock's access level, 1 to 4]
-- @param rank=nil [List<String> Combine ranks the lock is closed to, as set with `/SetCombineLockRank`]
-- @return [Boolean Whether the player has access]
function Schema:PlayerHasCombineLockAccess(client, access, rank)
  if Schema:PlayerIsCombine(client) then
    if rank then
      return !Schema:IsPlayerCombineRank(client, rank)
    else
      return true
    end
  elseif client:HasItemByID('combine_lock_access_'..tostring(access)) then
    return true
  elseif client:HasItemByID('combine_lock_access_x') then
    return true
  end

  return false
end

--- Spawns a frozen `cw_combinelock` parented to a door.
--
-- ```
-- local lock = Schema:ApplyCombineLock(door, trace, trace.HitNormal:Angle(), 2)
-- ```
--
-- @param entity [Entity The door]
-- @param position=nil [Vector The lock's position; a trace `Map` instead places it at the standard
-- offset on a `prop_door_rotating`, pushed 4 units out along `HitNormal`]
-- @param angles=nil [Angle The lock's angles]
-- @param access=nil [Number The lock's access level, 1 to 4]
-- @param rank=nil [List<String> Combine ranks the lock is closed to]
-- @param color=nil [Color The lock's light colour]
-- @return [Entity The new lock, or `nil` when it could not be created]
function Schema:ApplyCombineLock(entity, position, angles, access, rank, color)
  local combineLock = ents.Create('cw_combinelock')
  combineLock:SetVelocity(Vector())

  if IsValid(combineLock:GetPhysicsObject()) then
    combineLock:GetPhysicsObject():EnableMotion(false)
  end

  combineLock:SetParent(entity)
  combineLock:SetDoor(entity)

  if position then
    if type(position) == 'table' then
      combineLock:SetLocalPos(Vector(-1.0313, 43.7188, -1.2258))
      combineLock:SetPos(combineLock:GetPos() + (position.HitNormal * 4))
    else
      combineLock:SetPos(position)
    end
  end

  if angles then
    combineLock:SetAngles(angles)
  end

  if color then
    combineLock:SetOverrideColor(color)
  end

  combineLock:Spawn()
  combineLock:SetAccess(access)
  combineLock:SetCPRank(rank)

  if IsValid(combineLock) then
    return combineLock
  end
end

--- Saves every Combine lock on a door to the schema data.
--
-- Writes `plugins/combinelocks/<map>` with each lock's door, local position and angles,
-- locked state, access level, restricted ranks, colour and owner.
function PLUGIN:SaveCombineLocks()
  local cmbLocks = {}

  for k, v in pairs(ents.FindByClass('cw_combinelock')) do
    if IsValid(v.entity) then
      cmbLocks[#cmbLocks + 1] = {
        doorID = v.entity:MapCreationID(),
        key = cw.entity:QueryProperty(v, 'key'),
        locked = v:IsLocked(),
        angles = v:GetLocalAngles(),
        position = v:GetLocalPos(),
        uniqueID = cw.entity:QueryProperty(v, 'uniqueID'),
        doorPosition = v.entity:GetPos(),
        access = v:GetAccess(),
        rank = v:GetCPRank(),
        color = v.overrideColor
      }
    end
  end

  cw.core:SaveSchemaData('plugins/combinelocks/'..game.GetMap(), cmbLocks)
end

--- Puts the Combine locks saved for the current map back on their doors.
--
-- Restores each lock's position, angles, access level, restricted ranks, colour and locked
-- state, and gives the door back to its saved owner.
function PLUGIN:LoadCombineLocks()
  local cmbLocks = cw.core:RestoreSchemaData('plugins/combinelocks/'..game.GetMap())

  for k, v in pairs(cmbLocks) do
    local entity = ents.GetMapCreatedEntity(v.doorID)

    if IsValid(entity) then
      local combineLock = Schema:ApplyCombineLock(entity)

      if combineLock then
        cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

        combineLock:SetLocalAngles(v.angles)
        combineLock:SetLocalPos(v.position)
        combineLock:SetAccess(v.access)
        combineLock:SetCPRank(v.rank)
        combineLock:SetOverrideColor(v.color)

        if !v.locked then
          combineLock:Unlock()
        else
          combineLock:Lock()
        end
      end
    end
  end
end
