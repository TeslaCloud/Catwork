--- Spawns the forcefields saved for the current map with their saved mode and power state.
--
-- Restored fields keep their exact position instead of snapping to the floor.
function cwForceField:LoadForceFields()
  local forcefields = cw.core:RestoreSchemaData('plugins/forcefields/'..game.GetMap())

  for k, v in pairs(forcefields) do
    local entity = ents.Create('cw_forcefield')
      entity:SetPos(v.position)
      entity:SetAngles(v.angles)
      entity.noCorrect = true
      entity:RestoreMode(v.mode or 1, v.on)
    entity:Spawn()
  end
end

--- Saves the position, angles, mode and power state of every `cw_forcefield` to the schema data.
--
-- Writes `plugins/forcefields/<map>`.
function cwForceField:SaveForceFields()
  local forcefields = {}

  for k, v in pairs(ents.FindByClass('cw_forcefield')) do
    table.insert(forcefields, {
      angles = v:GetAngles(),
      position = v:GetPos(),
      mode = v.mode,
      on = v.on
    })
  end

  cw.core:SaveSchemaData('plugins/forcefields/'..game.GetMap(), forcefields)
end
