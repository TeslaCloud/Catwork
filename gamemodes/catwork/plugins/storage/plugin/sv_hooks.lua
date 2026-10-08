--- Server-side hooks of the Storage plugin that open containers from the entity menu and handle their breaching,
-- removal and prop cost name.
--
-- A container with a password asks for it before opening, unless it was breached in the last two minutes. A removed
-- container drops its items and cash, and containers that have been opened or named are kept from automatic removal.

--- Called when a player attempts to breach an entity; allows breaching password protected containers.
-- @param player [Player The player breaching]
-- @param entity [Entity The entity to breach]
-- @return [Boolean `true` for a container with a password]
function cwStorage:PlayerCanBreachEntity(player, entity)
  if entity.cwInventory and entity.cwPassword then
    return true
  end
end

--- Called when an entity is about to be removed automatically; keeps containers that have been opened
-- or named.
-- @param entity [Entity The entity to remove]
-- @return [Boolean `false` to keep the entity]
function cwStorage:EntityCanAutoRemove(entity)
  if self.storage[entity] or entity:GetNWString('Name') != '' then
    return false
  end
end

--- Called when a player picks an entity menu option; opens a container or lockers for the "Open" option.
--
-- Password protected containers that are not breached ask the player for the password first.
-- @param player [Player The player who picked the option]
-- @param entity [Entity The entity the menu was for]
-- @param option [String The option label]
-- @param arguments [Any The option's arguments; `'cwContainerOpen'` for the "Open" option]
function cwStorage:EntityHandleMenuOption(player, entity, option, arguments)
  local class = entity:GetClass()

  if class == 'cw_locker' and arguments == 'cwContainerOpen' then
    self:OpenContainer(player, entity)
  elseif arguments == 'cwContainerOpen' then
    if cw.entity:IsPhysicsEntity(entity) then
      local model = string.lower(entity:GetModel())

      if self.containerList[model] then
        local containerWeight = self.containerList[model][1]

        if !entity.cwPassword or entity.cwIsBreached then
          self:OpenContainer(player, entity, containerWeight)
        else
          netstream.Start(player, 'ContainerPassword', entity)
        end
      end
    end
  end
end

--- Called when an entity has been breached; lets anyone open a password protected container for two
-- minutes.
-- @param entity [Entity The breached entity]
-- @param activator [Entity The entity that breached it]
function cwStorage:EntityBreached(entity, activator)
  if entity.cwInventory and entity.cwPassword then
    entity.cwIsBreached = true

    timer.Create('ResetBreach'..entity:EntIndex(), 120, 1, function()
      if IsValid(entity) then
        entity.cwIsBreached = nil
      end
    end)
  end
end

--- Called when an entity is removed; drops the container's items and cash on the ground, unless the
-- entity is a belongings bag.
-- @param entity [Entity The removed entity]
function cwStorage:EntityRemoved(entity)
  if IsValid(entity) and !entity.cwIsBelongings then
    cw.entity:DropItemsAndCash(entity.cwInventory, entity.cwCash, entity:GetPos(), entity)
    entity.cwInventory = nil
    entity.cwCash = nil
  end
end

--- Called when a player's prop cost is worked out; names the charge after the container type.
-- @param player [Player The player spawning the prop]
-- @param entity [Entity The spawned prop]
-- @param info [Map Prop cost info with `cost` and `name`; changed in place]
function cwStorage:PlayerAdjustPropCostInfo(player, entity, info)
  local model = string.lower(entity:GetModel())

  if self.containerList[model] then
    info.name = self.containerList[model][2]
  end
end
