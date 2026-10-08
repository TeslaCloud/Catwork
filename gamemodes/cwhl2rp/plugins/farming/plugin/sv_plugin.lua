--- Server-side persistence of the Farming plugin: `SavePlants` and `LoadPlants` store and respawn every `cw_plant` on
-- the map with its position, timings and seed item.
--
-- The data is kept per map in the schema data file `plugins/farming/<map>`.

--- Saves the position, angles, timings and seed item of every plant on the map.
--
-- The data goes to `plugins/farming/<map>`.
function PLUGIN:SavePlants()
  local plants = {}

  for k, v in pairs(ents.FindByClass('cw_plant')) do
    plants[#plants + 1] = {
      angles = v:GetAngles(),
      position = v:GetPos(),
      spawn = v:GetSpawnTime(),
      grow = v:GetGrowTime(),
      item = v:GetItem()
    }
  end

  cw.core:SaveSchemaData('plugins/farming/'..game.GetMap(), plants)
end

--- Spawns the plants saved for the current map with their seed item, timings and plant model.
function PLUGIN:LoadPlants()
  local plants = cw.core:RestoreSchemaData('plugins/farming/'..game.GetMap())

  for k, v in pairs(plants) do
    local plant = ents.Create('cw_plant')

    if plant then
      local itemTable = item.FindByID(v.item)

      plant:SetPos(v.position)
      plant:SetAngles(v.angles)
      plant:SetItem(v.item)
      plant:SetGrowTime(v.grow)
      plant:SetSpawnTime(v.spawn)
      plant:Spawn()
      plant:SetModel(itemTable.PlantModel)
    end
  end
end
