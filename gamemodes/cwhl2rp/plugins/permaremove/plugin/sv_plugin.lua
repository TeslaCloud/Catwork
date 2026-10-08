--- Server side of the Perma Remove plugin: `PLUGIN:LoadRemoves` and `PLUGIN:SaveRemoves`, which keep the class and
-- position of every permanently removed entity in the schema data `plugins/removeData/<map>`.
--
-- Loading removes every map entity whose class and exact position match a saved entry and keeps the entries in
-- `PLUGIN.removeData`, to which `/EntPermaRemove` adds.

local PLUGIN = PLUGIN

--- Removes every map entity whose class and exact position match an entry saved for the current map.
--
-- The loaded entries are kept in `self.removeData`, so later saves include them.
-- @see PLUGIN:SaveRemoves
function PLUGIN:LoadRemoves()
  self.removeData = {}

  local positions = {}
  local removeData = cw.core:RestoreSchemaData('plugins/removeData/'..game.GetMap())

  for k, v in pairs(removeData) do
    self.removeData[#self.removeData + 1] = v
  end

  --[[
  for k, v in pairs(ents.GetAll()) do
    if (IsValid(v)) then
      local position = v:GetPos()

      if (position) then
        positions[tostring(position)] = v
      end
    end
  end
  --]]

  for k1, v1 in pairs(ents.GetAll()) do
    for k, v in pairs(removeData) do
      if v1:GetPos() == v.position and v1:GetClass() == v.class then
        v1:Remove()
      end

      --[[
      local entity = positions[tostring(v.position)]

      if (IsValid(entity) and !self.removeData[entity]) then
        local data = {
          class = v.class,
          position = v.position,
          entity = entity,
          angle = v.angle,
          name = v.name
        }

        self.removeData[data.entity] = data
      end
      --]]
    end
  end
end

--- Saves the class and position of every entity in `self.removeData` to `plugins/removeData/<map>`.
-- @see PLUGIN:LoadRemoves
function PLUGIN:SaveRemoves()
  local removeData = {}

  for k, v in pairs(self.removeData) do
    local data = {
      class = v.class,
      position = v.position
    }

    removeData[#removeData + 1] = data
  end

  cw.core:SaveSchemaData('plugins/removeData/'..game.GetMap(), removeData)
end
