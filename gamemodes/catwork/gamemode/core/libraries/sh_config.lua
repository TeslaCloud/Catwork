--- Defines the global `config` library, the framework's saved and networked configuration keys.
--
-- The server declares a key and its default with `config.Add`, and `config.Get(key)` returns an object with `Get`,
-- `Set`, `GetNumber`, `GetDefault` and similar methods. Changed values are saved per schema or globally, shared keys
-- are sent to clients over the `Config` message, and the client lists keys in the config system menu with
-- `config.AddToSystem`.

if config and !cw.DebugMode then return end

library.New('config', _G)
local indexes = config.indexes or {}
local stored = config.stored or {}
local cache = config.cache or {}
local map = config.map or {}
config.indexes = indexes
config.stored = stored
config.cache = cache
config.map = map

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = { __index = CLASS_TABLE }

--- Queries a field of the config entry when the config object is called like a function.
--
-- ```
-- local default = config.Get('cash_enabled')('default')
-- ```
--
-- @param parameter [String Field of the config entry to read, e.g. `'default'` or `'isShared'`]
-- @param failSafe=nil [Any Value returned when the field is not set]
-- @return [Any The field's value, or `failSafe`]
-- @see CLASS_TABLE:Query
function CLASS_TABLE:__call(parameter, failSafe)
  return self:Query(parameter, failSafe)
end

--- Converts the config object to a string of the form `CONFIG[key]`.
--
-- The function is declared without a `self` parameter, so it indexes the global `self` and errors
-- when called.
-- @return [String The string representation]
function CLASS_TABLE.__tostring()
  return 'CONFIG['..self('key')..']'
end

--- Creates a new config object wrapping the stored entry for a key.
--
-- The object is created even when no entry exists for the key; check it with `CLASS_TABLE:IsValid`.
-- Use `config.Get` instead, which caches the objects.
-- @param key [String The config key]
-- @return [Config The new config object]
function CLASS_TABLE:Create(key)
  local cfg = cw.core:NewMetaTable(CLASS_TABLE)
    cfg.data = stored[key]
    cfg.key = key
  return cfg
end

--- Returns whether the config object wraps an existing config entry.
-- @return [Boolean Whether the key has been added with `config.Add`]
function CLASS_TABLE:IsValid()
  return self.data != nil
end

--- Returns a field of the config entry, such as `'value'`, `'default'` or `'isShared'`.
-- @param key [String Name of the field to read]
-- @param failSafe=nil [Any Value returned when the entry or the field does not exist]
-- @return [Any The field's value, or `failSafe`]
function CLASS_TABLE:Query(key, failSafe)
  if self.data and self.data[key] != nil then
    return self.data[key]
  else
    return failSafe
  end
end

--- Returns the config's value as a boolean.
--
-- `true`, `'true'`, `'yes'`, `'1'` and `1` count as true; every other value is false.
-- @param failSafe=nil [Boolean Value returned when the entry does not exist; `false` when not given]
-- @return [Boolean The value as a boolean]
function CLASS_TABLE:GetBoolean(failSafe)
  if self.data then
    return (self.data.value == true or self.data.value == 'true'
    or self.data.value == 'yes' or self.data.value == '1' or self.data.value == 1)
  elseif failSafe != nil then
    return failSafe
  else
    return false
  end
end

--- Returns the config's value as a number.
-- @param failSafe=nil [Number Value returned when the entry does not exist or its value is not numeric; `0` when not
-- given]
-- @return [Number The value as a number]
function CLASS_TABLE:GetNumber(failSafe)
  if self.data then
    return tonumber(self.data.value) or failSafe or 0
  else
    return failSafe or 0
  end
end

--- Returns the config's value converted to a string.
-- @param failSafe=nil [String Value returned when the entry does not exist; `''` when not given]
-- @return [String The value as a string]
function CLASS_TABLE:GetString(failSafe)
  if self.data then
    return tostring(self.data.value)
  else
    return failSafe or ''
  end
end

--- Returns the config's default value, the value it was added with.
-- @param failSafe=nil [Any Value returned when the entry does not exist]
-- @return [Any The default value, or `failSafe`]
function CLASS_TABLE:GetDefault(failSafe)
  if self.data then
    return self.data.default
  else
    return failSafe
  end
end

--- Returns the value the config will take after the next restart.
--
-- Only set for keys added with `needsRestart` whose value was changed while the server was running.
-- @param failSafe=nil [Any Value returned when no next value is pending]
-- @return [Any The pending value, or `failSafe`]
function CLASS_TABLE:GetNext(failSafe)
  if self.data and self.data.nextValue != nil then
    return self.data.nextValue
  else
    return failSafe
  end
end

--- Returns the config's current value.
--
-- ```
-- if config.Get('cash_enabled'):Get(false) then
--   print('Cash is enabled.')
-- end
-- ```
--
-- @param failSafe=nil [Any Value returned when the entry does not exist or has no value]
-- @return [Any The current value, or `failSafe`]
-- @see config.GetVal
function CLASS_TABLE:Get(failSafe)
  if self.data and self.data.value != nil then
    return self.data.value
  else
    return failSafe
  end
end

--- Sets whether the config has been initialized.
--
-- On the server, config changes are only saved and `ClockworkConfigChanged` is only fired once this is
-- set; on the client it is set when the first `Config` message arrives from the server.
-- @param bInitalized [Boolean Whether the config has initialized]
function config.SetInitialized(bInitalized)
  config.cwInitialized = bInitalized
end

--- Returns whether the config has been initialized.
-- @return [Boolean Whether `config.SetInitialized` has been called with `true`]
function config.HasInitialized()
  return config.cwInitialized
end

--- Returns whether a value can be stored in a config key.
-- @param value [Any The value to check]
-- @return [Boolean Whether the value is a string, number or boolean]
function config.IsValidValue(value)
  return isstring(value) or isnumber(value) or isbool(value)
end

--- Registers a short CRC index for a config key so it is networked under the index instead of its name.
--
-- Call it in both realms with the same key; the server maps the key to the index and the client
-- maps the index back to the key.
-- @param key [String The config key]
function config.ShareKey(key)
  local shortCRC = cw.core:GetShortCRC(key)

  if SERVER then
    indexes[key] = shortCRC
  else
    indexes[shortCRC] = key
  end
end

--- Returns the table of every config entry, indexed by key.
-- @return [Map Config entries indexed by key, each with `value`, `default` and flag fields]
function config.GetStored()
  return stored
end

--- Imports config keys from a text file and adds or updates them.
--
-- Each line has the form `<class> <key> = <value>;`, where the class contains any of `boolean`,
-- `number`, `force`, `global`, `shared`, `static`, `private` and `restart` to set the type and
-- flags. Lines starting with `//` and `[section]` lines are skipped. Existing keys are set, with
-- `force` bypassing the static flag; new keys are added with `config.Add`.
--
-- ```
-- shared number default_attribute_points = 30;
-- ```
--
-- @param fileName [String Path of the file, relative to the `GAME` mount]
function config.Import(fileName)
  local data = _file.Read(fileName, 'GAME') or ''

  for k, v in pairs(string.Explode('\n', data)) do
    if v != '' and !string.find(v, '^%s$') then
      if !string.find(v, '^%[.+%]$') and !string.find(v, '^//') then
        local class, key, value = string.match(v, '^(.-)%s(.-)%s=%s(.+);')

        if class and key and value then
          if string.find(class, 'boolean') then
            value = (value == 'true' or value == 'yes' or value == '1')
          elseif string.find(class, 'number') then
            value = tonumber(value)
          end

          local forceSet = string.find(class, 'force') != nil
          local isGlobal = string.find(class, 'global') != nil
          local isShared = string.find(class, 'shared') != nil
          local isStatic = string.find(class, 'static') != nil
          local isPrivate = string.find(class, 'private') != nil
          local needsRestart = string.find(class, 'restart') != nil

          if value then
            local cfg = config.Get(key)

            if !cfg:IsValid() then
              config.Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart)
            else
              cfg:Set(value, nil, forceSet)
            end
          end
        end
      end
    end
  end
end

--- Reads an INI file into a table of sections.
--
-- Comments starting with `;` or `#` are stripped. Numeric and `true`/`false` values are converted.
-- @param fileName [String Path of the file]
-- @param bFromGame=nil [Boolean Read from the `GAME` mount instead of `DATA`]
-- @param bStripQuotes=nil [Boolean Remove double quotes from every line]
-- @return [Map Sections indexed by name, each a `Map` of keys to values; `false` when a line appears before the
-- first section or a section header is not closed, `nil` when the file cannot be read]
function config.LoadINI(fileName, bFromGame, bStripQuotes)
  local bSuccess, value = pcall(file.Read, fileName, (bFromGame and 'GAME' or 'DATA'))

  if bSuccess and value != nil then
    local explodedData = string.Explode('\n', value)
    local outputTable = {}
    local currentNode = ''

    local function StripComment(line)
      local startPos, endPos = line:find('[;#]')

      if startPos then
        line = line:sub(1, startPos - 1):Trim()
      end

      return line
    end

    local function StripQuotes(line)
      return line:gsub('["]', ''):Trim()
    end

    for k, v in pairs(explodedData) do
      local line = StripComment(v):gsub('\n', '')

      if line != '' then
        if bStripQuotes then
          line = StripQuotes(line)
        end

        if line:sub(1, 1) == '[' then
          local startPos, endPos = line:find('%]')

          if startPos then
            currentNode = line:sub(2, startPos - 1)

            if !outputTable[currentNode] then
              outputTable[currentNode] = {}
            end
          else
            return false
          end
        elseif currentNode == '' then
          return false
        else
          local data = string.Explode('=', line)

          if #data > 1 then
            local key = data[1]
            local value = table.concat(data, '=', 2)

            if tonumber(value) then
              outputTable[currentNode][key] = tonumber(value)
            elseif value == 'true' or value == 'false' then
              outputTable[currentNode][key] = (value == 'true')
            else
              outputTable[currentNode][key] = value
            end
          end
        end
      end
    end

    return outputTable
  end
end

--- Replaces every `$key$` in a text with the value of that config key.
--
-- Unknown keys are left in the text as they are.
--
-- ```
-- config.Parse('Players start with $default_cash$ tokens.')
-- ```
--
-- @param text [String The text to parse]
-- @return [String The text with the config values filled in]
function config.Parse(text)
  for key in string.gmatch(text, '%$(.-)%$') do
    local value = config.Get(key):Get()

    if value != nil then
      text = cw.core:Replace(text, '$'..key..'$', tostring(value))
    end
  end

  return text
end

--- Returns the config object for a key.
--
-- Objects for existing keys are cached. An object is returned even for keys that do not exist, so
-- check it with `CLASS_TABLE:IsValid` when the key might be missing.
--
-- ```
-- local walkSpeed = config.Get('walk_speed'):GetNumber(100)
-- ```
--
-- @param key [String The config key]
-- @return [Config The config object]
function config.Get(key)
  if !cache[key] then
    local configObject = CLASS_TABLE:Create(key)

    if configObject.data then
      cache[key] = configObject
    end

    return configObject
  else
    return cache[key]
  end
end

--- Returns the current value of a config key without creating a config object.
-- @param key [String The config key]
-- @param failSafe=nil [Any Value returned when the key does not exist]
-- @return [Any The current value, or `failSafe`]
-- @see CLASS_TABLE:Get
function config.GetVal(key, failSafe)
  local configEntry = stored[key]

  if configEntry then
    return configEntry.value
  else
    return failSafe
  end
end

if SERVER then
  --- Saves the config entries that differ from their defaults.
  --
  -- Global keys are saved with `cw.core:SaveClockworkData` and schema keys with
  -- `cw.core:SaveSchemaData`. Map-specific, temporary and `mysql_` keys are skipped, and a pending
  -- `nextValue` is saved in place of the current value. When `configTable` is `nil`, both saved files
  -- are deleted instead.
  -- @param fileName [String Name of the data file, e.g. `'config'` or `'config/gm_construct'`]
  -- @param configTable=nil [Map Config entries indexed by key, as returned by `config.GetStored`]
  function config.Save(fileName, configTable)
    if configTable then
      local cfg = { global = {}, schema = {} }

      for k, v in pairs(configTable) do
        if !v.map and !v.temporary and !string.find(k, 'mysql_') then
          local value = v.value

          if v.nextValue != nil then
            value = v.nextValue
          end

          if value != v.default then
            if v.isGlobal then
              cfg.global[k] = {
                value = value,
                default = v.default
              }
            else
              cfg.schema[k] = {
                value = value,
                default = v.default
              }
            end
          end
        end
      end

      cw.core:SaveClockworkData(fileName, cfg.global)
      cw.core:SaveSchemaData(fileName, cfg.schema)
    else
      cw.core:DeleteClockworkData(fileName)
      cw.core:DeleteSchemaData(fileName)
    end
  end

  --- Sends shared config values to players over the `Config` netstream message.
  --
  -- Only keys added as shared are sent. Bots are marked as config initialized straight away and fire
  -- `PlayerConfigInitialized` instead of being sent anything.
  -- @param player=nil [Player The player to send to; every player when `nil`]
  -- @param key=nil [String The key to send; every shared key when `nil`]
  function config.Send(player, key)
    if player and player:IsBot() then
      hook.Run('PlayerConfigInitialized', player)
        player.cwConfigInitialized = true
      return
    end

    if !player then
      player = _player.GetAll()
    else
      player = { player }
    end

    if key then
      if stored[key] then
        local value = stored[key].value

        if stored[key].isShared then
          if indexes[key] then
            key = indexes[key]
          end

          netstream.Start(player, 'Config', { [key] = value })
        end
      end
    else
      local cfg = {}

      for k, v in pairs(stored) do
        if v.isShared then
          local index = indexes[k]

          if index then
            cfg[index] = v.value
          else
            cfg[k] = v.value
          end
        end
      end

      netstream.Start(player, 'Config', cfg)
    end
  end

  --- Loads saved config values from a data file, or applies every saved config file when no file is given.
  --
  -- Without a file name, the default and current map config files are read into `config.global` or
  -- `config.schema` and applied to existing keys whose saved default matches their current default,
  -- map values only applying on that map.
  -- @param fileName=nil [String Name of the data file to read and return]
  -- @param loadGlobal=nil [Boolean Use the framework's data folder instead of the schema's]
  -- @return [Map The saved entries when `fileName` is given; nothing otherwise]
  function config.Load(fileName, loadGlobal)
    if !fileName then
      local configClasses = { 'default', 'map' }
      local configTable
      local map = string.lower(game.GetMap())

      if loadGlobal then
        config.global = {
          default = config.Load('config', true),
          map = config.Load('config/'..map, true)
        }

        configTable = config.global
      else
        config.schema = {
          default = config.Load('config'),
          map = config.Load('config/'..map)
        }

        configTable = config.schema
      end

      for k, v in pairs(configClasses) do
        for k2, v2 in pairs(configTable[v]) do
          local configObject = config.Get(k2)

          if configObject:IsValid() then
            if configObject('default') == v2.default then
              if v == 'map' then
                configObject:Set(v2.value, map, true)
              else
                configObject:Set(v2.value, nil, true)
              end
            end
          end
        end
      end
    elseif loadGlobal then
      return cw.core:RestoreClockworkData(fileName)
    else
      return cw.core:RestoreSchemaData(fileName)
    end
  end

  --- Adds a new config key with a default value.
  --
  -- Values saved in the global or schema config files are applied to the new key, and shared keys are
  -- sent to every player. The key's category is the name of the plugin being loaded, if any. Does
  -- nothing when the key already exists or the value is not a string, number or boolean.
  --
  -- ```
  -- config.Add('default_attribute_points', 30, true)
  -- config.Add('mysql_host', '', nil, nil, true, true, true)
  -- ```
  --
  -- @param key [String Unique name of the key]
  -- @param value [Any Default value; a string, number or boolean]
  -- @param isShared=nil [Boolean Network the value to clients]
  -- @param isGlobal=nil [Boolean Save the value for every schema instead of the current one]
  -- @param isStatic=nil [Boolean Prevent the value from changing unless forced]
  -- @param isPrivate=nil [Boolean Mark the key as private]
  -- @param needsRestart=nil [Boolean Apply changes only after a restart]
  -- @return [Config The new config object, or `nil` when the key was not added]
  function config.Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart)
    if config.IsValidValue(value) then
      if !stored[key] then
        stored[key] = {
          category = PLUGIN and PLUGIN:GetName(),
          needsRestart = needsRestart,
          isPrivate = isPrivate,
          isShared = isShared,
          isStatic = isStatic,
          isGlobal = isGlobal,
          default = value,
          value = value
        }

        local configClasses = { 'global', 'schema' }
        local configObject = CLASS_TABLE:Create(key)

        if !isGlobal then
          table.remove(configClasses, 1)
        end

        for k, v in pairs(configClasses) do
          local configTable = config[v]
          local map = string.lower(game.GetMap())

          if configTable and configTable.default and configTable.default[key] then
            if configObject('default') == configTable.default[key].default then
              configObject:Set(configTable.default[key].value, nil, true)
            end
          end

          if configTable and configTable.map and configTable.map[key] then
            if configObject('default') == configTable.map[key].default then
              configObject:Set(configTable.map[key].value, map, true)
            end
          end
        end

        config.Send(nil, key)

        return configObject
      end
    end
  end

  --- Sets the config's value, saving and networking it.
  --
  -- The value is converted to the type of the current value; `'!default'` resets it to the default.
  -- Static keys only change when `forceSet` is true. For keys that need a restart, the value is
  -- stored as the next value instead once the config has initialized. Shared keys are sent to every
  -- player and `ClockworkConfigChanged` is fired when the value changes.
  --
  -- The `map` parameter shadows the file's `config.map` table, so setting a map-specific value after
  -- initialization indexes the map name string instead of that table.
  -- @param value [Any The new value, or `'!default'`]
  -- @param map=nil [String Only apply the value on this map]
  -- @param forceSet=nil [Boolean Ignore the static and restart flags]
  -- @param temporary=nil [Boolean Do not save the value]
  -- @return [Any The converted value, or `nil` when the entry does not exist or the value is invalid]
  function CLASS_TABLE:Set(value, map, forceSet, temporary)
    if map then
      map = string.lower(map)
    end

    if tostring(value) == '-1.#IND' then
      value = 0
    end

    if self.data and config.IsValidValue(value) then
      if self.data.value != value then
        local previousValue = self.data.value
        local default = (value == '!default')

        if !default then
          if isnumber(self.data.value) then
            value = tonumber(value) or self.data.value
          elseif isbool(self.data.value) then
            value = (value == true or value == 'true'
            or value == 'yes' or value == '1' or value == 1)
          end
        else
          value = self.data.default
        end

        if !self.data.isStatic or forceSet then
          if !map or string.lower(game.GetMap()) == map then
            if (!config.HasInitialized() and self.data.value == self.data.default)
            or !self.data.needsRestart or forceSet then
              self.data.value = value

              if self.data.isShared then
                config.Send(nil, self.key)
              end
            end
          end

          if config.HasInitialized() then
            self.data.temporary = temporary
            self.data.forceSet = forceSet
            self.data.map = map

            if self.data.needsRestart then
              if self.data.forceSet then
                self.data.nextValue = nil
              else
                self.data.nextValue = value
              end
            end

            if !self.data.map and !self.data.temporary then
              config.Save('config', stored)
            end

            if self.data.map then
              if default then
                if map[self.data.map] then
                  map[self.data.map][self.key] = nil
                end
              else
                if !map[self.data.map] then
                  map[self.data.map] = {}
                end

                map[self.data.map][self.key] = {
                  default = self.data.default,
                  global = self.data.isGlobal,
                  value = value
                }
              end

              if !self.data.temporary then
                config.Save('config/'..self.data.map, map[self.data.map])
              end
            end
          end
        end

        if self.data.value != previousValue and config.HasInitialized() then
          hook.Run('ClockworkConfigChanged', self.key, self.data, previousValue, self.data.value)
        end
      end

      return value
    end
  end

  netstream.Hook('ConfigInitialized', function(player, data)
    if !player:HasConfigInitialized() then
      player:SetConfigInitialized(true)
      hook.Run('PlayerConfigInitialized', player)
    end
  end)
else
  config.system = config.system or {}

  netstream.Hook('Config', function(data)
    for k, v in pairs(data) do
      if indexes[k] then
        k = indexes[k]
      end

      if !stored[k] then
        config.Add(k, v)
      else
        config.Get(k):Set(v)
      end
    end

    if !config.HasInitialized() then
      config.SetInitialized(true)

      for k, v in pairs(stored) do
        hook.Run('ClockworkConfigInitialized', k, v.value)
      end

      if IsValid(cw.client) and !config.HasSentInitialized() then
        netstream.Start('ConfigInitialized', true)
        config.SetSentInitialized(true)
      end
    end
  end)

  --- Sets whether the client has told the server that its config has initialized.
  -- @param sentInitialized [Boolean Whether the `ConfigInitialized` message was sent]
  function config.SetSentInitialized(sentInitialized)
    config.sentInitialized = sentInitialized
  end

  --- Returns whether the client has told the server that its config has initialized.
  -- @return [Boolean Whether the `ConfigInitialized` message was sent]
  function config.HasSentInitialized()
    return config.sentInitialized
  end

  --- Adds a config key to the client's config system menu.
  --
  -- The `category` argument is ignored: it is always replaced by the name of the plugin being loaded,
  -- falling back to `'Clockwork'`.
  -- @param name [String Display name; the key when `nil`]
  -- @param key [String The config key]
  -- @param help [String Help text; `'#ConfigNoHelp'` when `nil`]
  -- @param minimum=0 [Number Minimum value for numeric keys]
  -- @param maximum=100 [Number Maximum value for numeric keys]
  -- @param decimals=0 [Number Number of decimals for numeric keys]
  -- @param category=nil [String Unused]
  function config.AddToSystem(name, key, help, minimum, maximum, decimals, category)
    category = PLUGIN and PLUGIN:GetName()

    config.system[key] = {
      name = name or key,
      decimals = tonumber(decimals) or 0,
      maximum = tonumber(maximum) or 100,
      minimum = tonumber(minimum) or 0,
      help = help or '#ConfigNoHelp',
      category = category or 'Clockwork'
    }
  end

  --- Returns a config key's entry in the config system menu.
  -- @param key [String The config key]
  -- @return [Map The entry with `name`, `help`, `minimum`, `maximum`, `decimals` and `category`, or `nil`]
  function config.GetFromSystem(key)
    return config.system[key]
  end

  --- Adds a config key on the client, usually when the server sends its value.
  --
  -- Does nothing when the key already exists or the value is not a string, number or boolean.
  -- @param key [String Name of the key]
  -- @param value [Any Value of the key, also used as its default]
  -- @return [Config The new config object, or `nil` when the key was not added]
  function config.Add(key, value)
    if config.IsValidValue(value) then
      if !stored[key] then
        stored[key] = {
          default = value,
          value = value
        }

        return CLASS_TABLE:Create(key)
      end
    end
  end

  --- Sets the config's value on the client.
  --
  -- The value is converted to the type of the current value, and values of another type are
  -- rejected; `'!default'` resets it to the default. Fires `ClockworkConfigChanged` when the value
  -- changes after initialization.
  -- @param value [Any The new value, or `'!default'`]
  -- @return [Any The new value, or `nil` when the entry does not exist or the value is invalid]
  function CLASS_TABLE:Set(value)
    if tostring(value) == '-1.#IND' then
      value = 0
    end

    if self.data and config.IsValidValue(value) then
      if self.data.value != value then
        local previousValue = self.data.value
        local default = (value == '!default')

        if !default then
          if type(self.data.value) == 'number' then
            value = tonumber(value) or self.data.value
          elseif type(self.data.value) == 'boolean' then
            value = (value == true or value == 'true'
            or value == 'yes' or value == '1' or value == 1)
          elseif type(self.data.value) != type(value) then
            return
          end

          self.data.value = value
        else
          self.data.value = self.data.default
        end

        if self.data.value != previousValue and config.HasInitialized() then
          hook.Run('ClockworkConfigChanged', self.key, self.data, previousValue, self.data.value)
        end
      end

      return self.data.value
    end
  end
end
