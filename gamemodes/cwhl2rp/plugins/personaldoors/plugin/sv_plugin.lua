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

--- Restores the personal doors saved for the current map.
--
-- Saved doors are matched to map entities by position. Each door's owner names are stored
-- lowercased in `entity._OwningPersons`, the record goes into `self.personalDoors`, and the
-- door is locked or unlocked according to its `startLocked` setting.
-- @see PLUGIN:SaveDoorData
function PLUGIN:LoadDoorData()
  self.personalDoors = {}

  local positions = {}
  local personalDoors = cw.core:RestoreSchemaData('plugins/personaldoors/'..game.GetMap())

  for k, v in pairs(ents.GetAll()) do
    if IsValid(v) then
      local position = v:GetPos()

      if position then
        positions[tostring(position)] = v
      end
    end
  end

  for k, v in pairs(personalDoors) do
    local entity = positions[tostring(v.position)]

    if IsValid(entity) and !self.personalDoors[entity] then
      if cw.entity:IsDoor(entity) then
        local owners = {}

        for k2, v2 in pairs(v.owners)do
          local owningPerson = v2

          table.insert(owners, owningPerson)

          if !entity._OwningPersons then
            entity._OwningPersons = {}
          end

          entity._OwningPersons[string.lower(tostring(owningPerson))] = true
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

    for k2, v2 in pairs(v.owners)do
      table.insert(data.owners, v2)
    end

    personalDoors[#personalDoors + 1] = data
  end

  cw.core:SaveSchemaData('plugins/personaldoors/'..game.GetMap(), personalDoors)
end
