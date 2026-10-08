--- Server-side functions of the Door Commands plugin that save and restore door parents, door data and door states for
-- the current map.
--
-- The data is kept in the `plugins/parents/<map>`, `plugins/doors/<map>` and `plugins/doorstates/<map>` schema data
-- files and matched to the map's doors by position. Defines the `default_doors_hidden` and `doors_save_state` config
-- keys; with the first one on, every door without saved data is hidden.

local IsDoorLocked = cw.entity.IsDoorLocked
local GetDoorState = cw.entity.GetDoorState

config.Add('default_doors_hidden', true, nil, nil, nil, nil, true)
config.Add('doors_save_state', true, nil, nil, nil, nil, true)

--- Restores the door parents saved for the current map.
--
-- Reads `plugins/parents/<map>` from the schema data, matches the saved positions to the map's doors,
-- parents each child with `cw.entity:SetDoorParent` and records it in `cwDoorCmds.parentData`
-- (child door mapped to parent door). Doors already in `parentData` are skipped.
-- @see cwDoorCmds:SaveParentData
function cwDoorCmds:LoadParentData()
  self.parentData = self.parentData or {}

  local parentData = cw.core:RestoreSchemaData('plugins/parents/'..game.GetMap())
  local positions = {}

  for k, v in pairs(cw.entity:GetDoorEntities()) do
    if IsValid(v) then
      local position = v:GetPos()

      if position then
        positions[tostring(position)] = v
      end
    end
  end

  for k, v in pairs(parentData) do
    local parent = positions[tostring(v.parentPosition)]
    local entity = positions[tostring(v.position)]

    if IsValid(entity) and IsValid(parent) and !self.parentData[entity] then
      if cw.entity:IsDoor(entity) and cw.entity:IsDoor(parent) then
        cw.entity:SetDoorParent(entity, parent)

        self.parentData[entity] = parent
      end
    end
  end
end

--- Restores the door names, texts and ownability saved for the current map.
--
-- Reads `plugins/doors/<map>` from the schema data and matches the saved positions to the map's doors.
-- Entries saved with `customName` (ownable doors) only get their name back; the others are made
-- unownable with their name and text. The entries are kept in `cwDoorCmds.doorData`, keyed by door.
-- When the `default_doors_hidden` config is on, every door without saved data is hidden.
-- @see cwDoorCmds:SaveDoorData
function cwDoorCmds:LoadDoorData()
  self.doorData = self.doorData or {}

  local positions = {}
  local doorData = cw.core:RestoreSchemaData('plugins/doors/'..game.GetMap())

  for k, v in pairs(cw.entity:GetDoorEntities()) do
    if IsValid(v) then
      local position = v:GetPos()

      if position then
        positions[tostring(position)] = v
      end
    end
  end

  for k, v in pairs(doorData) do
    local entity = positions[tostring(v.position)]

    if IsValid(entity) and !self.doorData[entity] then
      if cw.entity:IsDoor(entity) then
        local data = {
          customName = v.customName,
          position = v.position,
          entity = entity,
          name = v.name,
          text = v.text
        }

        if !data.customName then
          cw.entity:SetDoorUnownable(data.entity, true)
          cw.entity:SetDoorName(data.entity, data.name)
          cw.entity:SetDoorText(data.entity, data.text)
        else
          cw.entity:SetDoorName(data.entity, data.name)
        end

        self.doorData[data.entity] = data
      end
    end
  end

  if config.Get('default_doors_hidden'):Get() then
    for k, v in pairs(positions) do
      if !self.doorData[v] then
        cw.entity:SetDoorHidden(v, true)
      end
    end
  end
end

--- Sends a player the doors to outline while they set up door parents.
--
-- The `doorParentESP` message holds the player's active parent door under the `Parent` key, followed by the
-- doors parented to it. It is empty when the player has no active parent door.
-- @param player [Player The player setting up door parents]
function cwDoorCmds:SendParentESP(player)
  local parent = player.cwParentDoor
  local doors = {}

  if IsValid(parent) then
    doors.Parent = parent

    for child, childParent in pairs(self.parentData) do
      if childParent == parent and IsValid(child) then
        doors[#doors + 1] = child
      end
    end
  end

  cable.send(player, 'doorParentESP', doors)
end

--- Saves `cwDoorCmds.parentData` to the schema data file `plugins/parents/<map>` as door positions.
function cwDoorCmds:SaveParentData()
  local parentData = {}

  for k, v in pairs(self.parentData) do
    if IsValid(k) and IsValid(v) then
      parentData[#parentData + 1] = {
        parentPosition = v:GetPos(),
        position = k:GetPos()
      }
    end
  end

  cw.core:SaveSchemaData('plugins/parents/'..game.GetMap(), parentData)
end

--- Saves `cwDoorCmds.doorData` to the schema data file `plugins/doors/<map>`.
--
-- Each entry keeps the door's `position`, `name`, `text` and `customName` flag.
function cwDoorCmds:SaveDoorData()
  local doorData = {}

  for k, v in pairs(self.doorData) do
    local data = {
      customName = v.customName,
      position = v.position,
      name = v.name,
      text = v.text
    }

    doorData[#doorData + 1] = data
  end

  cw.core:SaveSchemaData('plugins/doors/'..game.GetMap(), doorData)
end

--- Saves the position, locked state and open state of every door to the schema data file
-- `plugins/doorstates/<map>`.
-- @see cwDoorCmds:LoadDoorStates
function cwDoorCmds:SaveDoorStates()
  local doorTable = {}

  for k, v in pairs(cw.entity:GetDoorEntities()) do
    if v:IsValid() then
      doorTable[#doorTable + 1] = {
        position = v:GetPos(),
        bLocked = IsDoorLocked(cw.entity, v),
        state = GetDoorState(cw.entity, v)
      }
    end
  end

  cw.core:SaveSchemaData('plugins/doorstates/'..game.GetMap(), doorTable)
end

--- Restores the door states saved by `cwDoorCmds:SaveDoorStates`.
--
-- Doors saved while opening or open are opened, and doors saved locked are locked.
function cwDoorCmds:LoadDoorStates()
  local doorTable = cw.core:RestoreSchemaData('plugins/doorstates/'..game.GetMap())
  local positions = {}

  for k, v in pairs(cw.entity:GetDoorEntities()) do
    if IsValid(v) then
      local position = v:GetPos()

      if position then
        positions[tostring(position)] = v
      end
    end
  end

  for k, v in pairs(doorTable) do
    local entity = positions[tostring(v.position)]

    if IsValid(entity) and cw.entity:IsDoor(entity) then
      if v.state == 1 or v.state == 2 then
        cw.entity:OpenDoor(entity, 0)
      end

      if v.bLocked then
        entity:Fire('lock', '', 0)
      end
    end
  end
end
