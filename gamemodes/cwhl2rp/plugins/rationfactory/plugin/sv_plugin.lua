--[[
  © 2012 Iron-Wall.org do not share, re-distribute or modify
  without permission of its author (ext@iam1337.ru).
--]]

--- Saves the position, angles and spawn type of every `cw_factorydispenser` on the map.
--
-- The data goes to `plugins/factorydispensers/<map>`.
function PLUGIN:SaveFactoryDispensers()
  local dispensers = {}

  for k, v in pairs(ents.FindByClass('cw_factorydispenser')) do
    dispensers[#dispensers + 1] = {
      type = v:GetSpawnType(),
      angles = v:GetAngles(),
      position = v:GetPos()
    }
  end

  cw.core:SaveSchemaData('plugins/factorydispensers/'..game.GetMap(), dispensers)
end

--- Spawns the `cw_factorydispenser` entities saved for the current map.
function PLUGIN:LoadFactoryDispensers()
  local dispensers = cw.core:RestoreSchemaData('plugins/factorydispensers/'..game.GetMap())

  for k, v in pairs(dispensers) do
    local entity = ents.Create('cw_factorydispenser')

    entity:SetPos(v.position)
    entity:Spawn()

    if IsValid(entity) then
      entity:SetAngles(v.angles)
      entity:SetSpawnType(v.type)
    end
  end
end

--- Saves the position, angles, ration count and lock state of every `cw_factoryrationdispenser`.
--
-- The data goes to `plugins/factoryrationdispensers/<map>`.
function PLUGIN:SaveFactoryRationDispensers()
  local dispensers = {}

  for k, v in pairs(ents.FindByClass('cw_factoryrationdispenser')) do
    dispensers[#dispensers + 1] = {
      count = v:GetRationCount(),
      angles = v:GetAngles(),
      locked = v:IsLocked(),
      position = v:GetPos()
    }
  end

  cw.core:SaveSchemaData('plugins/factoryrationdispensers/'..game.GetMap(), dispensers)
end

--- Spawns the `cw_factoryrationdispenser` entities saved for the current map.
--
-- Each one gets back its saved ration count and lock state.
function PLUGIN:LoadFactoryRationDispensers()
  local dispensers = cw.core:RestoreSchemaData('plugins/factoryrationdispensers/'..game.GetMap())

  for k, v in pairs(dispensers) do
    local entity = ents.Create('cw_factoryrationdispenser')

    entity:SetPos(v.position)
    entity:Spawn()

    if IsValid(entity) then
      entity:SetAngles(v.angles)
      entity:SetRationCount(v.count)

      if !v.locked then
        entity:Unlock()
      else
        entity:Lock()
      end
    end
  end
end

--- Saves the position, angles and spawn type of every `cw_bigfactorydispenser` on the map.
--
-- The data goes to `plugins/bigfactorydispensers/<map>`.
function PLUGIN:SaveBigFactoryDispensers()
  local dispensers = {}

  for k, v in pairs(ents.FindByClass('cw_bigfactorydispenser')) do
    dispensers[#dispensers + 1] = {
      type = v:GetSpawnType(),
      angles = v:GetAngles(),
      position = v:GetPos()
    }
  end

  cw.core:SaveSchemaData('plugins/bigfactorydispensers/'..game.GetMap(), dispensers)
end

--- Spawns the `cw_bigfactorydispenser` entities saved for the current map.
function PLUGIN:LoadBigFactoryDispensers()
  local dispensers = cw.core:RestoreSchemaData('plugins/bigfactorydispensers/'..game.GetMap())

  for k, v in pairs(dispensers) do
    local entity = ents.Create('cw_bigfactorydispenser')

    entity:SetPos(v.position)
    entity:Spawn()

    if IsValid(entity) then
      entity:SetAngles(v.angles)
      entity:SetSpawnType(v.type)
    end
  end
end
