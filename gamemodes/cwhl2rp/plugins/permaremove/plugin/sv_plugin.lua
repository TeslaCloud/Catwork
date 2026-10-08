--- Server side of the Perma Remove plugin: `PLUGIN:LoadRemoves` and `PLUGIN:SaveRemoves`, which keep the class and
-- position of every permanently removed entity in the schema data `plugins/removeData/<map>`.
--
-- Loading removes every map entity whose class and exact position match a saved entry and keeps the entries in
-- `PLUGIN.removeData`, to which `/EntPermaRemove` adds.

local PLUGIN = PLUGIN

--- Removes every map entity whose class and exact position match an entry saved for the current map.
--
-- The loaded entries are kept in `self.removeData`, so later saves include them; entries without a class
-- or a position are dropped.
-- @see PLUGIN:SaveRemoves
function PLUGIN:LoadRemoves()
  self.removeData = {}

  local positions = {}
  local removeData = cw.core:RestoreSchemaData('plugins/removeData/'..game.GetMap())

  for k, v in pairs(removeData) do
    if istable(v) and isstring(v.class) and isvector(v.position) then
      self.removeData[#self.removeData + 1] = v

      positions[v.class] = positions[v.class] or {}
      table.insert(positions[v.class], v.position)
    end
  end

  for k, v in ipairs(ents.GetAll()) do
    local classPositions = positions[v:GetClass()]

    if classPositions then
      local position = v:GetPos()

      for k2, v2 in ipairs(classPositions) do
        if position == v2 then
          v:Remove()

          break
        end
      end
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
