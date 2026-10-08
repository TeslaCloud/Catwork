--- Main file of the Factories plugin, which adds start, stop and eject options to the entity menu of factory entities
-- and saves the garbage recyclers with the map; exposes the plugin as `cwFactories`.
--
-- On the server, `cwFactories:SaveFactories` and `cwFactories:LoadFactories` keep the `cw_factory_garbage_metal`,
-- `cw_factory_garbage_plastic` and `cw_factory_garbage_paper` entities and their contents in the schema data under
-- `plugins/factories/`, and `EntityHandleMenuOption` runs the chosen option on any entity with `IsFactory` set. On the
-- client, `GetEntityMenuOptions` adds the options.

PLUGIN:SetGlobalAlias('cwFactories')

if SERVER then
  --- Called when a player picks an entity menu option; starts, stops or ejects a factory.
  --
  -- Only acts on entities with `IsFactory` set. Starting is ignored while the factory works and
  -- stopping while it is idle.
  -- @param player [Player The player who picked the option]
  -- @param entity [Entity The entity the menu was opened on]
  -- @param option [String The option's display name]
  -- @param arguments [String `cwFactoriesStart`, `cwFactoriesStop` or `cwFactoriesEject`]
  function cwFactories:EntityHandleMenuOption(player, entity, option, arguments)
    local factory = entity.IsFactory

    if factory then
      if arguments == 'cwFactoriesStart' then
        if !entity:GetIsWorking() then
          entity:StartWork()
        end
      elseif arguments == 'cwFactoriesStop' then
        if entity:GetIsWorking() then
          entity:StopWork()
        end
      elseif arguments == 'cwFactoriesEject' then
        entity:Eject()
      end
    end
  end

  -- The garbage recycler classes, by the name of the folder their data is saved in.
  local recyclerClasses = {
    metal = 'cw_factory_garbage_metal',
    plastic = 'cw_factory_garbage_plastic',
    paper = 'cw_factory_garbage_paper'
  }

  --- Saves every metal, plastic and paper garbage recycler on the map to the schema data.
  --
  -- Each factory's angles, position, product position, garbage count, eject storage and stored
  -- garbage are written to `plugins/factories/<type>/<map>`.
  -- @see cwFactories:LoadFactories
  function cwFactories:SaveFactories()
    for name, class in pairs(recyclerClasses) do
      local recyclers = {}

      for k, v in ipairs(ents.FindByClass(class)) do
        recyclers[#recyclers + 1] = {
          angles = v:GetAngles(),
          position = v:GetPos(),
          productpos = v:GetProductPos(),
          garbagecount = v:GetGarbageCount(),
          ejectstorage = v:GetEjectStorage(),
          garbage = v.Garbages
        }
      end

      cw.core:SaveSchemaData('plugins/factories/'..name..'/'..game.GetMap(), recyclers)
    end
  end

  --- Spawns the garbage recyclers saved for the current map, frozen in place, and restores their contents.
  -- @see cwFactories:SaveFactories
  function cwFactories:LoadFactories()
    for name, class in pairs(recyclerClasses) do
      local recyclers = cw.core:RestoreSchemaData('plugins/factories/'..name..'/'..game.GetMap())

      for k, v in pairs(recyclers) do
        local device = ents.Create(class)

        if IsValid(device) then
          device:SetPos(v.position)
          device:SetAngles(v.angles)
          device:Spawn()

          local physicsObject = device:GetPhysicsObject()

          if IsValid(physicsObject) then
            physicsObject:EnableMotion(false)
          end

          device:SetProductPos(v.productpos)
          device:SetGarbageCount(v.garbagecount)
          device:SetEjectStorage(v.ejectstorage)
          device.Garbages = {}

          for z, x in pairs(v.garbage or {}) do
            device.Garbages[z] = x
          end
        end
      end
    end
  end

  --- Called after Catwork has loaded all map entities; spawns the saved factories.
  function cwFactories:ClockworkInitPostEntity()
    self:LoadFactories()
  end

  --- Called after data has been saved; saves the factories.
  function cwFactories:PostSaveData()
    self:SaveFactories()
  end
else
  --- Called when the client builds an entity's menu; adds start, stop and eject options to factories.
  -- @param entity [Entity The entity the menu is for]
  -- @param options [Map Menu options, mapping display names to the arguments sent to the server]
  function cwFactories:GetEntityMenuOptions(entity, options)
    if entity.IsFactory then
      options['#Factories_Start'] = 'cwFactoriesStart'
      options['#Factories_Stop'] = 'cwFactoriesStop'
      options['#Factories_Eject'] = 'cwFactoriesEject'
    end
  end
end
