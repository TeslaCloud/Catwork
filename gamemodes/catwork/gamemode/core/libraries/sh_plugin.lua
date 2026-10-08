--- Defines the global `plugin` library, which loads plugins and the schema and dispatches hooks to them.
--
-- `plugin.Include` loads a plugin from its `plugin` folder or a single file, together with its entities and its extra
-- folders (`items`, `commands`, `language` and so on), and `plugin.Add` registers a library as a hook module. The
-- functions of every plugin and module are cached by name, and `hook.Call` is replaced so they run before the regular
-- hooks and the gamemode. `plugin.SetUnloaded` turns a plugin off.

--[[ The plugin library is already defined! --]]
if plugin then return end

library.New('plugin', _G)

--[[
  We do local variables instead of global ones for performance increase.
  Most CW libraries use functions to return their tables anyways.
--]]
local stored = {}
local modules = {}
local unloaded = {}
local extras = {}
local hooksCache = {}

--- Returns every registered plugin, indexed by name.
-- @return [Map<Plugin> The plugins indexed by name]
function plugin.GetStored()
  return stored
end

--- Returns every module added with `plugin.Add`, indexed by name.
-- @return [Map The module tables indexed by name]
function plugin.GetModules()
  return modules
end

--- Returns the folder names of the plugins that are unloaded.
-- @return [Map `true` for each unloaded plugin's folder name]
function plugin.GetUnloaded()
  return unloaded
end

--- Returns the names of the folders loaded from every plugin, as added with `plugin.AddExtra`.
-- @return [List<String> The folder names]
function plugin.GetExtras()
  return extras
end

--- Returns the hook cache that `hook.Call` runs plugin hooks from.
-- @return [Map Lists of `{ func, owner, id = moduleName }` entries indexed by hook name]
function plugin.GetCache()
  return hooksCache
end

--- Prints the hook cache to the console.
function plugin.DebugPrintCache()
  PrintTable(hooksCache)
end

PLUGIN_META = { __index = PLUGIN_META }
PLUGIN_META.description = 'An undescribed plugin or schema.'
PLUGIN_META.hookOrder = 0
PLUGIN_META.version = 1.0
PLUGIN_META.author = 'Unknown'
PLUGIN_META.name = 'Unknown'

--- Makes the plugin available as a global variable, so its hooks can be defined as `Alias:Hook`.
--
-- ```
-- PLUGIN:SetGlobalAlias('cwStorage')
--
-- function cwStorage:PlayerSpawn(player) end
-- ```
--
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @param aliasName [String Name of the global variable]
PLUGIN_META.SetGlobalAlias = function(PLUGIN_META, aliasName)
  _G[aliasName] = PLUGIN_META
  PLUGIN_META.alias = aliasName
end

--- Returns the plugin's description.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [String The description]
PLUGIN_META.GetDescription = function(PLUGIN_META)
  return PLUGIN_META.description
end

--- Returns the Lua directory the plugin was loaded from.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [String The plugin's `plugin` folder, or the path of a single-file plugin]
PLUGIN_META.GetBaseDir = function(PLUGIN_META)
  return PLUGIN_META.baseDir
end

--- Returns the plugin's hook order.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [Number The hook order; `0` by default]
PLUGIN_META.GetHookOrder = function(PLUGIN_META)
  return PLUGIN_META.hookOrder
end

--- Returns the plugin's version.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [Number The version; `1.0` by default]
PLUGIN_META.GetVersion = function(PLUGIN_META)
  return PLUGIN_META.version
end

--- Returns the plugin's author.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [String The author; `'Unknown'` by default]
PLUGIN_META.GetAuthor = function(PLUGIN_META)
  return PLUGIN_META.author
end

--- Returns the plugin's name.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [String The name, as set in `plugin.ini`]
PLUGIN_META.GetName = function(PLUGIN_META)
  return PLUGIN_META.name
end

--- Returns the CRC of a single-file plugin's path.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [String The path CRC, or `nil` for folder plugins]
PLUGIN_META.GetCRC = function(PLUGIN_META)
  return PLUGIN_META.__crc
end

--- Returns whether the plugin is a single Lua file rather than a folder.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [Boolean `true` for single-file plugins, `nil` otherwise]
PLUGIN_META.IsSingleFile = function(PLUGIN_META)
  return PLUGIN_META.__singlefile
end

--- Registers the plugin.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @see plugin.Register
PLUGIN_META.Register = function(PLUGIN_META)
  plugin.Register(PLUGIN_META)
end

--- Converts the plugin to a string of the form `Plugin [name]`.
-- @param PLUGIN_META [Plugin The plugin; passed implicitly when called as `PLUGIN:Method()`]
-- @return [String The string representation]
PLUGIN_META.__tostring = function(PLUGIN_META)
  return 'Plugin ['..PLUGIN_META.name..']'
end

--- Returns whether a plugin is disabled because a plugin containing it is unloaded.
--
-- Unloaded plugins are looked up with `plugin.FindByID` by folder name, so this only finds parents
-- whose folder name matches their name.
-- @param name [String Name of the plugin, or its folder name when `bFolder` is set]
-- @param bFolder=nil [Boolean Treat `name` as a folder name]
-- @return [Boolean Whether the plugin is disabled]
function plugin.IsDisabled(name, bFolder)
  local folderName = name

  if !bFolder then
    local pluginTable = plugin.FindByID(name)

    if !pluginTable or pluginTable == Schema then
      return false
    end

    folderName = pluginTable.folderName
  end

  for k, v in pairs(unloaded) do
    local parent = plugin.FindByID(k)

    if parent and parent != Schema and folderName != parent.folderName
    and table.HasValue(parent.plugins, folderName) then
      return true
    end
  end

  return false
end

if SERVER then
  --- Sets whether a plugin is unloaded and saves the list of unloaded plugins.
  --
  -- The change takes effect the next time plugins are loaded. The schema cannot be unloaded.
  -- @param name [String Name of the plugin]
  -- @param isUnloaded [Boolean Whether the plugin should be unloaded]
  -- @return [Boolean Whether the plugin was found]
  function plugin.SetUnloaded(name, isUnloaded)
    local pluginTable = plugin.FindByID(name)

    if pluginTable and pluginTable != Schema then
      if isUnloaded then
        unloaded[pluginTable.folderName] = true
      else
        unloaded[pluginTable.folderName] = nil
      end

      cw.core:SaveSchemaData('plugins', unloaded)
      return true
    end

    return false
  end

  --- Returns whether a plugin is unloaded.
  -- @param name [String Name of the plugin, or its folder name when `bFolder` is set]
  -- @param bFolder=nil [Boolean Treat `name` as a folder name]
  -- @return [Boolean Whether the plugin is unloaded; always `false` for the schema]
  function plugin.IsUnloaded(name, bFolder)
    if !bFolder then
      local pluginTable = plugin.FindByID(name)

      if pluginTable and pluginTable != Schema then
        return (unloaded[pluginTable.folderName] == true)
      end
    else
      return (unloaded[name] == true)
    end

    return false
  end
else
  plugin.override = plugin.override or {}

  --- Overrides whether a plugin is shown as unloaded on the client.
  --
  -- Only changes what `plugin.IsUnloaded` returns on the client, e.g. to reflect a pending change.
  -- @param name [String Name of the plugin]
  -- @param isUnloaded [Boolean Whether the plugin should count as unloaded; `nil` removes the override]
  function plugin.SetUnloaded(name, isUnloaded)
    local pluginTable = plugin.FindByID(name)

    if pluginTable then
      plugin.override[pluginTable.folderName] = isUnloaded
    end
  end

  --- Returns whether a plugin is unloaded, taking overrides set with `plugin.SetUnloaded` into account.
  -- @param name [String Name of the plugin, or its folder name when `bFolder` is set]
  -- @param bFolder=nil [Boolean Treat `name` as a folder name]
  -- @return [Boolean Whether the plugin is unloaded; always `false` for the schema]
  function plugin.IsUnloaded(name, bFolder)
    if !bFolder then
      local pluginTable = plugin.FindByID(name)

      if pluginTable and pluginTable != Schema then
        if plugin.override[pluginTable.folderName] != nil then
          return plugin.override[pluginTable.folderName]
        end

        return (unloaded[pluginTable.folderName] == true)
      end
    else
      if plugin.override[name] != nil then
        return plugin.override[name]
      end

      return (unloaded[name] == true)
    end

    return false
  end
end

--- Empties the hook cache, so no plugin hooks run until functions are cached again.
function plugin.ClearCache()
  hooksCache = {}
end

--- Sets whether the plugin system has been initialized.
-- @param bInitialized [Boolean Whether the plugin system has initialized]
function plugin.SetInitialized(bInitialized)
  plugin.cwInitialized = bInitialized
end

--- Returns whether the plugin system has been initialized.
-- @return [Boolean Whether `plugin.Initialize` has run]
function plugin.HasInitialized()
  return plugin.cwInitialized
end

--- Initializes the plugin system, restoring the saved list of unloaded plugins on the server.
--
-- Does nothing when already initialized.
-- @warning [Internal] Called by `plugin.IncludePlugins` before the first plugin is loaded.
function plugin.Initialize()
  if plugin.HasInitialized() then
    return
  end

  if SERVER then
    unloaded = cw.core:RestoreSchemaData('plugins')
  end

  plugin.SetInitialized(true)
end

--- Registers a plugin, caches its hooks and loads its contents.
--
-- Unless the plugin is unloaded, its functions are added to the hook cache, its extras (items,
-- commands, entities...) are loaded with `plugin.IncludeExtras` and, on the client, a page is added
-- to the directory. The plugins inside a folder plugin's `plugins` folder are then loaded.
-- @param pluginTable [Plugin The plugin]
function plugin.Register(pluginTable)
  local newBaseDir = cw.core:RemoveTextFromEnd(pluginTable.baseDir, '/schema')
  local files, pluginFolders = _file.Find(newBaseDir..'/plugins/*', 'LUA', 'namedesc')
  local isUnloaded = plugin.IsUnloaded(pluginTable.folderName)

  if !isUnloaded then
    plugin.CacheFunctions(pluginTable)
  end

  stored[pluginTable.name] = pluginTable
  stored[pluginTable.name].plugins = {}

  if !pluginTable:IsSingleFile() then
    for k, v in ipairs(pluginFolders) do
      if v != '..' and v != '.' then
        table.insert(stored[pluginTable.name].plugins, v)
      end
    end
  else
    if SERVER then
      local pathCRC = pluginTable:GetCRC() or 'ERROR'

      CW_SCRIPT_SHARED.plugins[pathCRC] = CW_SCRIPT_SHARED.plugins[pathCRC] or {}
      CW_SCRIPT_SHARED.plugins[pathCRC].name = pluginTable.name
      CW_SCRIPT_SHARED.plugins[pathCRC].description = pluginTable.description
      CW_SCRIPT_SHARED.plugins[pathCRC].author = pluginTable.author
      CW_SCRIPT_SHARED.plugins[pathCRC].compatibility = pluginTable.compatibility
    end
  end

  if !isUnloaded then
    plugin.IncludeExtras(pluginTable:GetBaseDir())

    if CLIENT and Schema != pluginTable then
      pluginTable.helpID = cw.directory:AddCode('Plugins', [[
				<div class="cwTitleSeperator">
					]]..string.upper(pluginTable:GetName())..[[
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">
						[developedBy] ]]..pluginTable:GetAuthor()..[[
					</div>
					]]..pluginTable:GetDescription()..[[
				</div>
				<br>
			]], true, pluginTable:GetAuthor(), function(htmlCode)
        -- This is a language phrase, so it is translated when the page is shown.
        return string.Replace(htmlCode, '[developedBy]', L('#Directory_PluginDevelopedBy'))
      end)
    end
  end

  if !pluginTable:IsSingleFile() then
    plugin.IncludePlugins(newBaseDir)
  end
end

--- Returns a registered plugin by name.
-- @param identifier [String Name of the plugin]
-- @return [Plugin The plugin, or `nil` when not registered]
function plugin.FindByID(identifier)
  return stored[identifier]
end

--- Loads a plugin from its `plugin` folder or from a single Lua file.
--
-- Creates the global `PLUGIN` with `plugin.New`, merges in the `plugin.ini` data (on the server
-- from the file, on the client from `CW_SCRIPT_SHARED`), runs `sh_plugin.lua` unless the plugin
-- is unloaded or disabled, then registers it. A plugin that was already loaded keeps its table on
-- refresh.
--
-- For a single-file plugin the folder name is taken from the parent directory, which is always
-- `plugins`.
-- @param directory [String Lua path of the plugin's `plugin` folder, or of a `.lua` file]
function plugin.Include(directory)
  local schemaFolder = cw.core:GetSchemaFolder()
  local explodeDir = string.Explode('/', directory)
  local folderName = explodeDir[#explodeDir - 1]
  local pathCRC = util.CRC(directory)
  local isFilePlugin = directory:EndsWith('.lua')

  PLUGIN_BASE_DIR = directory
  PLUGIN_FOLDERNAME = folderName

  PLUGIN = plugin.New()

  if SERVER then
    if !isFilePlugin then
      local iniDir = 'gamemodes/'..cw.core:RemoveTextFromEnd(directory, '/plugin')
      local iniTable = config.LoadINI(iniDir..'/plugin.ini', true, true)

      if iniTable then
        if iniTable['Plugin'] then
          iniTable = iniTable['Plugin']
          iniTable.isUnloaded = plugin.IsUnloaded(PLUGIN_FOLDERNAME, true)
            table.Merge(PLUGIN, iniTable)
          CW_SCRIPT_SHARED.plugins[pathCRC] = iniTable
        else
          MsgC(Color(255, 100, 0, 255), '\n[CW:Plugin] The '..PLUGIN_FOLDERNAME..' plugin has no plugin.ini!\n')
        end
      end
    else
      PLUGIN.__crc = pathCRC
      PLUGIN.__singlefile = true

      CW_SCRIPT_SHARED.plugins[pathCRC] = {
        isUnloaded = plugin.IsUnloaded(PLUGIN_FOLDERNAME, true)
      }
    end
  else
    local iniTable = CW_SCRIPT_SHARED.plugins[pathCRC]

    if iniTable then
      table.Merge(PLUGIN, iniTable)

      if iniTable.isUnloaded then
        unloaded[PLUGIN_FOLDERNAME] = true
      end
    else
      MsgC(Color(255, 100, 0, 255), '\n[CW:Plugin] The '..PLUGIN_FOLDERNAME..' plugin has no plugin.ini!\n')
    end
  end

  if stored[PLUGIN.name] then
    PLUGIN = stored[PLUGIN.name] -- Restore plugin's data on refresh.
  end

  local isUnloaded = plugin.IsUnloaded(PLUGIN_FOLDERNAME, true)
  local isDisabled = plugin.IsDisabled(PLUGIN_FOLDERNAME, true)
  local shPluginDir = (!isFilePlugin and directory..'/sh_plugin.lua') or directory
  local addCSLua = true

  if !isUnloaded and !isDisabled then
    if _file.Exists(shPluginDir, 'LUA') then
      util.Include(shPluginDir)
    end

    addCSLua = false
  end

  if SERVER and addCSLua then
    AddCSLuaFile(shPluginDir)
  end

  PLUGIN:Register()
  PLUGIN = nil
end

--- Creates a new plugin table for the plugin being included.
--
-- Uses the `PLUGIN_BASE_DIR` and `PLUGIN_FOLDERNAME` globals set by `plugin.Include`.
-- @return [Plugin The new plugin]
function plugin.New()
  local pluginTable = cw.core:NewMetaTable(PLUGIN_META)
  pluginTable.baseDir = PLUGIN_BASE_DIR
  pluginTable.folderName = PLUGIN_FOLDERNAME

  return pluginTable
end

--- Adds every function of a table to the hook cache, so it runs as a hook of the same name.
-- @param obj [Map The plugin, schema or module table]
-- @param id=nil [String Name shown in hook error messages]
function plugin.CacheFunctions(obj, id)
  for k, v in pairs(obj) do
    if isfunction(v) then
      hooksCache[k] = hooksCache[k] or {}
      table.insert(hooksCache[k], { v, obj, id = id })
    end
  end
end

--- Removes a plugin's or module's functions from the hook cache.
-- @param id [Any The table, or the name of a registered plugin]
function plugin.RemoveFromCache(id)
  local pluginTable = (istable(id) and id) or plugin.FindByID(id)

  -- Awful lot of if's and end's.
  if pluginTable then
    for k, v in pairs(pluginTable) do
      if isfunction(v) and hooksCache[k] then
        for index, tab in ipairs(hooksCache[k]) do
          if tab[2] == pluginTable then
            table.remove(hooksCache[k], index)

            break
          end
        end
      end
    end
  end
end

--- Removes a module added with `plugin.Add` and its hooks.
-- @param name [String Name of the module]
function plugin.Remove(name)
  plugin.RemoveFromCache(modules[name])

  modules[name] = nil
end

--- Adds a table as a module whose functions run as hooks, like a plugin's.
--
-- ```
-- plugin.Add('Voices', cw.voices)
-- ```
--
-- @param name [String Name of the module; also set as the table's `name` when it has none]
-- @param moduleTable [Map The module table]
-- @param hookOrder=0 [Number Stored as the module's `hookOrder`]
-- @see plugin.Remove
function plugin.Add(name, moduleTable, hookOrder)
  if !moduleTable.name then
    moduleTable.name = name
  end

  moduleTable.hookOrder = hookOrder or 0

  modules[name] = moduleTable

  plugin.CacheFunctions(modules[name], name)
end

do
  local entData = {
    weapons = {
      table = 'SWEP',
      func = weapons.Register,
      defaultData = {
        Primary = {},
        Secondary = {},
        Base = 'weapon_base'
      }
    },
    entities = {
      table = 'ENT',
      func = scripted_ents.Register,
      defaultData = {
        Type = 'anim',
        Base = 'base_gmodentity',
        Spawnable = true
      }
    },
    effects = {
      table = 'EFFECT',
      func = effects and effects.Register,
      clientside = true
    }
  }

  --- Loads and registers the weapons, entities and effects in a plugin's `entities` folder.
  --
  -- Each `weapons`, `entities` and `effects` subfolder may hold folders (with `shared.lua`,
  -- `init.lua` and `cl_init.lua`) or single files, loaded with `SWEP`, `ENT` or `EFFECT` set
  -- and registered under the file or folder name. Effects are only registered on the client.
  -- @param folder [String Lua path of the `entities` folder]
  function plugin.IncludeEntities(folder)
    folder = cw.core:RemoveTextFromEnd(folder, '/')

    local _, dirs = file.Find(folder..'/*', 'LUA')

    for k, v in ipairs(dirs) do
      if !entData[v] then continue end

      local dir = folder..'/'..v
      local data = entData[v]
      local files, folders = file.Find(dir..'/*', 'LUA')

      for k, v in ipairs(folders) do
        local path = dir..'/'..v
        local uniqueID = (string.GetFileFromFilename(path) or ''):Replace('.lua', ''):MakeID()
        local register = false
        local var = data.table

        _G[var] = table.Copy(data.defaultData or {})
        _G[var].ClassName = uniqueID

        if file.Exists(path..'/shared.lua', 'LUA') then
          util.Include(path..'/shared.lua')

          register = true
        end

        if file.Exists(path..'/init.lua', 'LUA') then
          util.Include(path..'/init.lua')

          register = true
        end

        if file.Exists(path..'/cl_init.lua', 'LUA') then
          util.Include(path..'/cl_init.lua')

          register = true
        end

        if register then
          if data.clientside and !CLIENT then _G[var] = nil continue end

          data.func(_G[var], uniqueID)
        end

        _G[var] = nil
      end

      for k, v in ipairs(files) do
        local path = dir..'/'..v
        local uniqueID = (string.GetFileFromFilename(path) or ''):Replace('.lua', ''):MakeID()
        local var = data.table

        _G[var] = table.Copy(data.defaultData or {})
        _G[var].ClassName = uniqueID

        util.Include(path)

        if data.clientside and !CLIENT then _G[var] = nil continue end

        data.func(_G[var], uniqueID)

        _G[var] = nil
      end
    end
  end
end

--- Loads every plugin in a directory's `plugins` folder, both single files and folders.
--
-- Initializes the plugin system first when needed.
-- @param directory [String Lua path of the directory that contains the `plugins` folder]
function plugin.IncludePlugins(directory)
  local files, pluginFolders = _file.Find(directory..'/plugins/*', 'LUA', 'namedesc')

  if !plugin.HasInitialized() then
    plugin.Initialize()
  end

  for k, v in ipairs(files) do
    if v:EndsWith('.lua') then
      plugin.Include(directory..'/plugins/'..v)
    end
  end

  for k, v in ipairs(pluginFolders) do
    plugin.Include(directory..'/plugins/'..v..'/plugin')
  end
end

--- Adds a folder name that is loaded from every plugin and the schema.
--
-- `items` folders are loaded with `item.IncludeItems`, others with `util.IncludeDirectory`.
-- @param folderName [String Name of the folder]
function plugin.AddExtra(folderName)
  table.insert(extras, folderName)
end

--- Loads a plugin's or schema's entities and extra folders.
-- @param directory [String Lua path of the plugin or schema folder]
-- @see plugin.AddExtra
function plugin.IncludeExtras(directory)
  local files, folders = _file.Find(directory..'/*', 'LUA', 'namedesc')

  if table.HasValue(folders, 'entities') then
    plugin.IncludeEntities(directory..'/entities')
  end

  for k, v in ipairs(extras) do
    if table.HasValue(folders, v) then
      if v == 'items' then
        item.IncludeItems(directory..'/'..v..'/')
      else
        util.IncludeDirectory(directory..'/'..v..'/')
      end
    end
  end
end

plugin.AddExtra('libraries')
plugin.AddExtra('directory')
plugin.AddExtra('system')
plugin.AddExtra('factions')
plugin.AddExtra('classes')
plugin.AddExtra('attributes')
plugin.AddExtra('items')
plugin.AddExtra('derma')
plugin.AddExtra('commands')
plugin.AddExtra('language')
plugin.AddExtra('config')
plugin.AddExtra('tools')
plugin.AddExtra('themes')

--[[ This table will hold the plugin info, if it doesn't already exist. --]]
CW_SCRIPT_SHARED.plugins = CW_SCRIPT_SHARED.plugins or {}

do
  local oldHookCall = hook.ClockworkCall or hook.Call
  hook.ClockworkCall = oldHookCall

  if cw.DebugMode then
    --- Runs a hook on every cached plugin, module and the schema, then on the gamemode.
    --
    -- Replaces `hook.Call` in debug mode. Each hook is called in a `pcall`; errors are printed and
    -- fire `OnHookError`. The first non-`nil` return stops the call and is returned. Otherwise the
    -- original `hook.Call` (kept as `hook.ClockworkCall`) runs the `hook.Add` hooks and the gamemode.
    -- @param name [String Name of the hook]
    -- @param gamemode [Map The gamemode table, passed on to the original `hook.Call`]
    -- @param ... [Any Arguments passed to the hook]
    -- @return [Any Up to six values returned by the first hook that returned anything]
    function hook.Call(name, gamemode, ...)
      if hooksCache[name] then
        for k, v in ipairs(hooksCache[name]) do
          if v != nil then
            local success, a, b, c, d, e, f = pcall(v[1], v[2], ...)

            if !success then
              MsgC(
                Color(255, 100, 0, 255),
                '\n[CW:'..(v.id or v[2]:GetName()).."]\nThe '"..name.."' hook has failed to run.\n"
              )
              MsgC(Color(255, 100, 0), tostring(a), '\n')

              hook.Run('OnHookError', name, bGamemode, a)
            elseif a != nil then
              return a, b, c, d, e, f
            end
          end
        end
      end

      return oldHookCall(name, gamemode, ...)
    end
  else
    --- Runs a hook on every cached plugin, module and the schema, then on the gamemode.
    --
    -- Replaces `hook.Call` outside debug mode. The first non-`nil` return stops the call and is
    -- returned. Otherwise the original `hook.Call` (kept as `hook.ClockworkCall`) runs the
    -- `hook.Add` hooks and the gamemode.
    -- @param name [String Name of the hook]
    -- @param gamemode [Map The gamemode table, passed on to the original `hook.Call`]
    -- @param ... [Any Arguments passed to the hook]
    -- @return [Any Up to six values returned by the first hook that returned anything]
    function hook.Call(name, gamemode, ...)
      local cache = hooksCache[name]

      if cache then
        for i = 1, #cache do
          local v = cache[i]

          -- A hook can remove entries from the cache while it is being run.
          if v then
            local a, b, c, d, e, f = v[1](v[2], ...)

            if a != nil then
              return a, b, c, d, e, f
            end
          end
        end
      end

      return oldHookCall(name, gamemode, ...)
    end
  end

  --- Calls a hook on every loaded plugin, module and the schema, then on the hooks added with `hook.Add`.
  --
  -- No gamemode table is passed on, so the gamemode's own function of that name is not called; use
  -- `hook.Run` for that.
  --
  -- ```
  -- local canSpawn = plugin.Call('PlayerCanSpawnItem', player, itemTable)
  -- ```
  --
  -- @param name [String Name of the hook]
  -- @param ... [Any Arguments passed to the hook]
  -- @return [Any Up to six values returned by the first hook that returned anything]
  -- @see hook.Call
  function plugin.Call(name, ...)
    return hook.Call(name, nil, ...)
  end
end
