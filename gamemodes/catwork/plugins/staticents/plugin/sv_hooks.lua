--- Server-side hooks of the Static Entities plugin that make entities static and save and restore them across restarts.
--
-- The file removes Sandbox's own persistence hooks and takes their place: `PlayerMakeStatic` marks a whitelisted
-- entity (props, ragdolls, `edit_` and `gmod_` entities) persistent for an admin, `PersistenceSave` copies every
-- persistent entity into the `static` schema data with the duplicator on shutdown and after a change, and
-- `PersistenceLoad` pastes them back once the map has loaded.
--
-- Backported from the [Flux](https://github.com/TeslaCloud/flux-ce) project.

-- Disable default Sandbox persistence.
hook.Remove('ShutDown', 'SavePersistenceOnShutdown')
hook.Remove('PersistenceSave', 'PersistenceSave')
hook.Remove('PersistenceLoad', 'PersistenceLoad')
hook.Remove('InitPostEntity', 'PersistenceInit')

local whitelistedEntities = {
  'prop_physics',
  'prop_physics_multiplayer',
  'prop_ragdoll',
  'edit_',
  'gmod_'
}

--- Called to make the entity a player is looking at static (persistent) or not.
--
-- Run by the `Static` and `UnStatic` commands and the static tool. Only admins may use it, and only on
-- props, ragdolls and `edit_`/`gmod_` entities; the player is notified of the result or of why it
-- failed.
--
-- @param player [Player The player making the change]
-- @param bIsStatic [Boolean True to make the entity static, false to make it normal again]
function cwStaticEnts:PlayerMakeStatic(player, bIsStatic)
  if !IsValid(player) then return end

  if !player:IsAdmin() then
    cw.player:Notify(player, L('Commands_cwLua_accessDenied', player:Name()))

    return
  end

  local trace = player:GetEyeTraceNoCursor()
  local entity = trace.Entity

  if !IsValid(entity) then
    cw.player:Notify(player, '#Err_NotValidEntity')

    return
  end

  local entClass = entity:GetClass()

  for k, v in ipairs(whitelistedEntities) do
    if entClass:find(v) then
      entClass = true

      break
    end
  end

  if entClass != true then
    cw.player:Notify(player, '#Err_CannotStaticThis')

    return
  end

  local isStatic = entity:GetPersistent()

  if bIsStatic and isStatic then
    cw.player:Notify(player, '#Err_AlreadyStatic')

    return
  elseif !bIsStatic and !isStatic then
    cw.player:Notify(player, '#Err_NotStatic')

    return
  end

  entity:SetPersistent(bIsStatic)

  self.bUnsavedChanges = true

  cw.player:Notify(player, (bIsStatic and '#Static_Added') or '#Static_Removed')
end

--- Called when the server shuts down; runs the `PersistenceSave` hook to save static entities.
function cwStaticEnts:ShutDown()
  hook.Run('PersistenceSave')
end

--- Called when Catwork saves its data; saves the static entities if any were added or removed since the last save.
--
-- Keeps a crash from losing which entities are static. Nothing is saved before the saved entities have been
-- loaded, so that a failed load is not saved over.
function cwStaticEnts:SaveData()
  if self.bLoaded and self.bUnsavedChanges then
    hook.Run('PersistenceSave')
  end
end

--- Called to save persistent entities; copies every static entity with the duplicator into the schema data.
function cwStaticEnts:PersistenceSave()
  local entities = {}

  for k, v in ipairs(ents.GetAll()) do
    if v:GetPersistent() then
      table.insert(entities, v)
    end
  end

  local toSave = duplicator.CopyEnts(entities)

  if !istable(toSave) then return end

  cw.core:SaveSchemaData('static', toSave, true)

  self.bUnsavedChanges = nil
end

-- Item instances do not survive being saved as JSON, which keeps neither their functions nor their place in the
-- item registry, so the items of a saved inventory are created anew from their item IDs and data.
local function RestoreInventory(inventory)
  local stored = item.GetStored()
  local restored = {}

  for uniqueID, items in pairs(inventory) do
    if stored[uniqueID] and istable(items) then
      for itemID, itemData in pairs(items) do
        local itemTable = istable(itemData)
          and item.CreateInstance(uniqueID, tonumber(itemID), istable(itemData.data) and itemData.data or nil)

        if itemTable then
          cw.inventory:AddInstance(restored, itemTable)
        end
      end
    end
  end

  return restored
end

--- Called to load persistent entities; pastes the saved static entities back and marks them persistent.
--
-- Custom fields saved with each entity are merged back into its table, and the items of a saved `cwInventory`
-- are created again as item instances.
function cwStaticEnts:PersistenceLoad()
  local loaded = cw.core:RestoreSchemaData('static', {}, true)

  if istable(loaded) and loaded.Entities and loaded.Constraints then
    local entities, constraints = duplicator.Paste(nil, loaded.Entities, loaded.Constraints)

    -- Restore any custom data the static entities might have had.
    for k, v in pairs(entities) do
      local entData = loaded.Entities[k]

      if entData then
        table.Merge(v:GetTable(), entData)

        if istable(v.cwInventory) then
          v.cwInventory = RestoreInventory(v.cwInventory)
        end
      end
    end

    for k, v in pairs(entities) do
      v:SetPersistent(true)
    end
  end

  self.bLoaded = true
end

--- Called after the map has loaded all of its entities; runs the `PersistenceLoad` hook.
function cwStaticEnts:InitPostEntity()
  hook.Run('PersistenceLoad')
end
