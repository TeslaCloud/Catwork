--[[
  Flux © 2016-2017 TeslaCloud Studios
  Do not share or re-distribute before
  the framework is publicly released.
--]]

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

  if (bIsStatic and !player:IsAdmin()) or (!bIsStatic and !player:IsAdmin()) then
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

  cw.player:Notify(player, (bIsStatic and '#Static_Added') or '#Static_Removed')
end

--- Called when the server shuts down; runs the `PersistenceSave` hook to save static entities.
function cwStaticEnts:ShutDown()
  hook.Run('PersistenceSave')
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
end

--- Called to load persistent entities; pastes the saved static entities back and marks them persistent.
--
-- Custom fields saved with each entity are merged back into its table.
function cwStaticEnts:PersistenceLoad()
  local loaded = cw.core:RestoreSchemaData('static', {}, true)

  if !istable(loaded) then return end
  if !loaded.Entities then return end
  if !loaded.Constraints then return end

  local entities, constraints = duplicator.Paste(nil, loaded.Entities, loaded.Constraints)

  -- Restore any custom data the static entities might have had.
  for k, v in pairs(entities) do
    local entData = loaded.Entities[k]

    if entData then
      table.Merge(v:GetTable(), entData)
    end
  end

  for k, v in pairs(entities) do
    v:SetPersistent(true)
  end
end

--- Called after the map has loaded all of its entities; runs the `PersistenceLoad` hook.
function cwStaticEnts:InitPostEntity()
  hook.Run('PersistenceLoad')
end
