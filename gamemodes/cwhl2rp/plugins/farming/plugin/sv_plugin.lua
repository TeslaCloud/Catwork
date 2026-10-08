--- Server-side persistence of the Farming plugin: `SavePlants` and `LoadPlants` store and respawn every `cw_plant` on
-- the map with its position, growth and seed item.
--
-- The data is kept per map in the schema data file `plugins/farming/<map>`. Growth is stored as the plant's `age` and
-- the `remaining` seconds until it is ripe, since `CurTime` starts over with every map.

--- Saves the position, angles, growth and seed item of every plant on the map.
--
-- The data goes to `plugins/farming/<map>`.
function PLUGIN:SavePlants()
  local plants = {}
  local curTime = CurTime()

  for k, v in ipairs(ents.FindByClass('cw_plant')) do
    plants[#plants + 1] = {
      angles = v:GetAngles(),
      position = v:GetPos(),
      age = curTime - v:GetSpawnTime(),
      remaining = v:GetGrowTime() - curTime,
      item = v:GetItem()
    }
  end

  cw.core:SaveSchemaData('plugins/farming/'..game.GetMap(), plants)
end

--- Spawns the plants saved for the current map with their seed item, growth and plant model.
--
-- Plants whose seed item no longer exists are skipped. Data saved before growth was stored as
-- `age` and `remaining` holds the `CurTime` values `spawn` and `grow` of an earlier map, which
-- are used as they are.
function PLUGIN:LoadPlants()
  local plants = cw.core:RestoreSchemaData('plugins/farming/'..game.GetMap())
  local curTime = CurTime()

  for k, v in pairs(plants) do
    local itemTable = isstring(v.item) and v.item != '' and item.FindByID(v.item)
    local plant = itemTable and itemTable.PlantModel and ents.Create('cw_plant')

    if IsValid(plant) then
      plant:SetPos(v.position)
      plant:SetAngles(v.angles)
      plant:SetItem(v.item)

      if v.remaining then
        plant:SetGrowTime(curTime + v.remaining)
        plant:SetSpawnTime(curTime - (v.age or 0))
      else
        plant:SetGrowTime(v.grow)
        plant:SetSpawnTime(v.spawn)
      end

      plant:Spawn()
      plant:SetModel(itemTable.PlantModel)
    end
  end
end
