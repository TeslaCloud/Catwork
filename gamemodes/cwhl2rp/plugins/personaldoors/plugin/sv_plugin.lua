--[[
  Author: Arbiter
  Clockwork Version: 0.88a.

  Credits:	A small part of this code comes from kurozael's DoorCommands Plugin.
        Heavily based off the works of Cervidae Kosmonaut in Faction Doors.
--]]

--- Server side of the Personal Doors plugin: `PLUGIN:LoadDoorData` and `PLUGIN:SaveDoorData`, which keep the owners,
-- position and `startLocked` setting of every personal door in the schema data `plugins/personaldoors/<map>`.
--
-- Loading matches the saved doors to map entities by position, fills each door's `_OwningPersons` table and
-- `PLUGIN.personalDoors`, and locks or unlocks the door.

--- Collects the owner names out of a saved owners list.
--
-- `/DoorSetAccess` used to nest the earlier owners inside a table whenever another owner was added to a door, so
-- nested tables are searched too and anything that is not a name is dropped.
-- @param source [Map The saved owners list]
-- @param owners [List<String> The list the names are added to]
-- @return [List<String> The `owners` list]
local function CollectOwners(source, owners)
  for k, v in pairs(source) do
    if isstring(v) then
      owners[#owners + 1] = v
    elseif istable(v) then
      CollectOwners(v, owners)
    end
  end

  return owners
end

--- Restores the personal doors saved for the current map.
--
-- Saved doors are matched to the map's doors by position. Each door's owner names are stored
-- lowercased in `entity._OwningPersons`, the record goes into `self.personalDoors`, and the
-- door is locked or unlocked according to its `startLocked` setting.
-- @see PLUGIN:SaveDoorData
function PLUGIN:LoadDoorData()
  self.personalDoors = {}

  local positions = {}
  local personalDoors = cw.core:RestoreSchemaData('plugins/personaldoors/'..game.GetMap())

  -- Only doors are indexed, so another entity at the same origin cannot take a door's place.
  for k, v in pairs(cw.entity:GetDoorEntities()) do
    if IsValid(v) then
      positions[tostring(v:GetPos())] = v
    end
  end

  for k, v in pairs(personalDoors) do
    local entity = istable(v) and positions[tostring(v.position)]

    if IsValid(entity) and !self.personalDoors[entity] then
      local owners = istable(v.owners) and CollectOwners(v.owners, {}) or {}

      entity._OwningPersons = {}

      for k2, v2 in ipairs(owners) do
        entity._OwningPersons[string.lower(v2)] = true
      end

      v.owners = owners

      self.personalDoors[entity] = v

      if v.startLocked then
        entity:Fire('Lock', '', 0)
      else
        entity:Fire('Unlock', '', 0)
      end
    end
  end
end

--- Saves the owners, position and `startLocked` setting of every personal door to `plugins/personaldoors/<map>`.
-- @see PLUGIN:LoadDoorData
function PLUGIN:SaveDoorData()
  local personalDoors = {}

  for k, v in pairs(self.personalDoors) do
    local data = {
      owners = {},
      position = v.position,
      startLocked = v.startLocked
    }

    for k2, v2 in ipairs(v.owners) do
      table.insert(data.owners, v2)
    end

    personalDoors[#personalDoors + 1] = data
  end

  cw.core:SaveSchemaData('plugins/personaldoors/'..game.GetMap(), personalDoors)
end
