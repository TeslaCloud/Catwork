--[[
  mysql - 1.0.2
  A simple MySQL wrapper for Garry's Mod.

  Alexander Grist-Hucker
  http://www.alexgrist.com
--]]

--- Defines the `cw.database` library, the server's query builder and connection layer for SQLite and MySQL.
--
-- Query objects made with `cw.database:Select`, `Insert`, `Update`, `Delete`, `Create`, `Drop` and `Truncate` are
-- filled in with `Where`, `Limit`, `Callback` and similar methods and sent with `Execute`; `EasyRead` and `EasyWrite`
-- cover the common select and update-or-insert cases. `cw.database:Connect` uses the module named in
-- `cw.database.Module` (`sqlite` by default, `mysqloo` for MySQLOO 9; the `tmysql4` path is kept but untested), queues
-- queries until the connection is ready and retries a failed MySQLOO connection after 30 seconds. Once connected,
-- `OnConnected` creates the `bans`, `players` and `characters` tables and runs the `DatabaseConnected` hook.

cw.database = cw.database or {}
cw.database.connections = cw.database.connections or {}

local QueueTable = {}
cw.database.Module = cw.database.Module or 'sqlite'
local Connected = false

-- The database module is required lazily in cw.database:Connect, because cw.database.Module is only set
-- by GM:Initialize, after this file has been included.

local type = type
local tostring = tostring
local table = table

--[[
  Phrases
--]]

local MODULE_NOT_EXIST = '[CW:Database] The %s module does not exist!\n'
local MODULE_LOAD_FAILED = '[CW:Database] Unable to load the %s binary module (gmsv_%s_*.dll in garrysmod/lua/bin)!'..
  '\n%s\n'

-- Seconds to wait before retrying a failed MySQLOO connection attempt.
local RECONNECT_DELAY = 30

-- A function to require a database module without halting when its binary is absent.
local function RequireModule(moduleName)
  local bSuccess, errorText = pcall(require, moduleName)

  if !bSuccess then
    ErrorNoHalt(string.format(MODULE_LOAD_FAILED, moduleName, moduleName, tostring(errorText)))
  end

  return bSuccess
end

-- A function to get whether queries can be sent to the current connection right now.
local function IsReady(database)
  local connection = database.connection

  if database.Module == 'mysqloo' then
    return istable(mysqloo) and connection != nil and connection:status() == mysqloo.DATABASE_CONNECTED
  elseif database.Module == 'tmysql4' then
    return connection != nil
  end

  return true
end

-- A pure Lua equivalent of mysql_real_escape_string for the default (backslash escaping) SQL mode.
-- MySQLOO 9 throws when Database:escape is called before the connection is established.
local MYSQL_ESCAPES = {
  ['\0'] = '\\0',
  ['\n'] = '\\n',
  ['\r'] = '\\r',
  ['\26'] = '\\Z',
  ['\\'] = '\\\\',
  ["'"] = "\\'",
  ['"'] = '\\"'
}

local function EscapeMySQL(text)
  return (string.gsub(text, '[%z\n\r\26\\\'"]', MYSQL_ESCAPES))
end

--[[
  Begin Query Class.
--]]

local QUERY_CLASS = {}
QUERY_CLASS.__index = QUERY_CLASS

--- Creates a query object for a table.
--
-- Query objects are normally made through the `cw.database` constructors
-- (`cw.database:Select`, `cw.database:Insert`, `cw.database:Update`,
-- `cw.database:Delete`, `cw.database:Create`, `cw.database:Drop` and
-- `cw.database:Truncate`). The builder methods add clauses, then
-- `QUERY_CLASS:Execute` builds the SQL and sends it. Values are escaped and
-- quoted; column and table names are only wrapped in backticks, so never
-- build them from player input.
--
-- ```
-- local queryObj = cw.database:Select(config.Get('mysql_characters_table'):Get())
--   queryObj:Where('_SteamID', player:SteamID())
--   queryObj:Where('_Schema', cw.core:GetSchemaFolder())
--   queryObj:OrderByDesc('_LastPlayed')
--   queryObj:Limit(5)
--   queryObj:Callback(function(result, status, lastID)
--     if cw.database:IsResult(result) then
--       print(result[1]._Name)
--     end
--   end)
-- queryObj:Execute()
-- ```
--
-- @param tableName [String Name of the table the query acts on]
-- @param queryType [String One of `'SELECT'`, `'INSERT'`, `'UPDATE'`, `'DELETE'`, `'DROP'`, `'TRUNCATE'` or `'CREATE'`]
-- @return [QUERY_CLASS The new query object]
function QUERY_CLASS:New(tableName, queryType)
  local newObject = setmetatable({}, QUERY_CLASS)
    newObject.queryType = queryType
    newObject.tableName = tableName
    newObject.selectList = {}
    newObject.insertList = {}
    newObject.updateList = {}
    newObject.createList = {}
    newObject.whereList = {}
    newObject.orderByList = {}
  return newObject
end

--- Escapes a value for use inside a quoted SQL string with the current database module.
-- @param text [Any The value; it is converted with `tostring` first]
-- @return [String The escaped text, without surrounding quotes]
-- @see cw.database:Escape
function QUERY_CLASS:Escape(text)
  return cw.database:Escape(tostring(text))
end

--- Changes the table the query acts on.
-- @param tableName [String Name of the table]
function QUERY_CLASS:ForTable(tableName)
  self.tableName = tableName
end

--- Adds a `key = value` condition to the query's WHERE clause.
--
-- Conditions are joined with AND. Used by SELECT, UPDATE and DELETE queries.
-- @param key [String Column name]
-- @param value [Any Value the column must equal; it is escaped and quoted]
-- @see QUERY_CLASS:WhereEqual
function QUERY_CLASS:Where(key, value)
  self:WhereEqual(key, value)
end

--- Adds a `key = value` condition to the query's WHERE clause.
-- @param key [String Column name]
-- @param value [Any Value the column must equal; it is escaped and quoted]
function QUERY_CLASS:WhereEqual(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` = "'..self:Escape(value)..'"'
end

--- Adds a `key != value` condition to the query's WHERE clause.
-- @param key [String Column name]
-- @param value [Any Value the column must not equal; it is escaped and quoted]
function QUERY_CLASS:WhereNotEqual(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` != "'..self:Escape(value)..'"'
end

--- Adds a `key LIKE value` condition to the query's WHERE clause.
--
-- `%` and `_` in the value keep their LIKE meaning.
-- @param key [String Column name]
-- @param value [String Pattern the column must match; it is escaped and quoted]
function QUERY_CLASS:WhereLike(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` LIKE "'..self:Escape(value)..'"'
end

--- Adds a `key NOT LIKE value` condition to the query's WHERE clause.
-- @param key [String Column name]
-- @param value [String Pattern the column must not match; it is escaped and quoted]
function QUERY_CLASS:WhereNotLike(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` NOT LIKE "'..self:Escape(value)..'"'
end

--- Adds a `key > value` condition to the query's WHERE clause.
-- @param key [String Column name]
-- @param value [Any Value the column must be greater than; it is escaped and quoted]
function QUERY_CLASS:WhereGT(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` > "'..self:Escape(value)..'"'
end

--- Adds a `key < value` condition to the query's WHERE clause.
-- @param key [String Column name]
-- @param value [Any Value the column must be less than; it is escaped and quoted]
function QUERY_CLASS:WhereLT(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` < "'..self:Escape(value)..'"'
end

--- Adds a `key >= value` condition to the query's WHERE clause.
-- @param key [String Column name]
-- @param value [Any Value the column must be greater than or equal to; it is escaped and quoted]
function QUERY_CLASS:WhereGTE(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` >= "'..self:Escape(value)..'"'
end

--- Adds a `key <= value` condition to the query's WHERE clause.
-- @param key [String Column name]
-- @param value [Any Value the column must be less than or equal to; it is escaped and quoted]
function QUERY_CLASS:WhereLTE(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` <= "'..self:Escape(value)..'"'
end

--- Sorts the results of a SELECT query by a column, highest first.
--
-- Several calls sort by each column in the order they were added.
-- @param key [String Column name]
function QUERY_CLASS:OrderByDesc(key)
  self.orderByList[#self.orderByList + 1] = '`'..key..'` DESC'
end

--- Sorts the results of a SELECT query by a column, lowest first.
--
-- Several calls sort by each column in the order they were added.
-- @param key [String Column name]
function QUERY_CLASS:OrderByAsc(key)
  self.orderByList[#self.orderByList + 1] = '`'..key..'` ASC'
end

--- Sets the function that receives the result once the query has run.
--
-- Errors in the callback are caught and printed. The callback is not called
-- when the query fails.
-- @param queryCallback [Function Called as `queryCallback(result, status, lastID)`: the list of row maps (or
-- `nil` for queries without rows), `true`, and the last inserted ID for INSERT queries]
function QUERY_CLASS:Callback(queryCallback)
  self.callback = queryCallback
end

--- Adds a column to the list a SELECT query returns.
--
-- Without any calls the query selects every column.
-- @param fieldName [String Column name]
function QUERY_CLASS:Select(fieldName)
  self.selectList[#self.selectList + 1] = '`'..fieldName..'`'
end

--- Sets a column value for an INSERT query.
-- @param key [String Column name]
-- @param value [Any Value to insert; it is escaped and quoted]
function QUERY_CLASS:Insert(key, value)
  self.insertList[#self.insertList + 1] = { '`'..key..'`', '"'..self:Escape(value)..'"' }
end

--- Sets a column value for an UPDATE query.
-- @param key [String Column name]
-- @param value [Any New value; it is escaped and quoted]
function QUERY_CLASS:Update(key, value)
  self.updateList[#self.updateList + 1] = { '`'..key..'`', '"'..self:Escape(value)..'"' }
end

--- Adds a column definition to a CREATE query.
--
-- With the SQLite module, `AUTO_INCREMENT`/`AUTOINCREMENT` are removed from
-- the definition and `INT ` becomes `INTEGER `.
-- @param key [String Column name]
-- @param value [String Column type and constraints, such as `'int(11) NOT NULL AUTO_INCREMENT'`; inserted as is]
-- @see QUERY_CLASS:PrimaryKey
function QUERY_CLASS:Create(key, value)
  self.createList[#self.createList + 1] = { '`'..key..'`', value }
end

--- Sets the primary key column of a CREATE query.
-- @param key [String Column name]
function QUERY_CLASS:PrimaryKey(key)
  self.primaryKey = '`'..key..'`'
end

--- Limits how many rows a SELECT or DELETE query affects.
-- @param value [Number Maximum number of rows]
function QUERY_CLASS:Limit(value)
  self.limit = value
end

--- Sets a row offset for the query.
--
-- Only UPDATE queries add it, as an `OFFSET` clause; SELECT queries ignore it.
-- @param value [Number Number of rows to skip]
function QUERY_CLASS:Offset(value)
  self.offset = value
end

local function BuildSelectQuery(queryObj)
  local queryString = { 'SELECT' }

  if !istable(queryObj.selectList) or #queryObj.selectList == 0 then
    queryString[#queryString + 1] = ' *'
  else
    queryString[#queryString + 1] = ' '..table.concat(queryObj.selectList, ', ')
  end

  if isstring(queryObj.tableName) then
    queryString[#queryString + 1] = ' FROM `'..queryObj.tableName..'` '
  else
    ErrorNoHalt('[CW:Database] No table name specified!\n')
    return
  end

  if istable(queryObj.whereList) and #queryObj.whereList > 0 then
    queryString[#queryString + 1] = ' WHERE '
    queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
  end

  if istable(queryObj.orderByList) and #queryObj.orderByList > 0 then
    queryString[#queryString + 1] = ' ORDER BY '
    queryString[#queryString + 1] = table.concat(queryObj.orderByList, ', ')
  end

  if isnumber(queryObj.limit) then
    queryString[#queryString + 1] = ' LIMIT '
    queryString[#queryString + 1] = queryObj.limit
  end

  return table.concat(queryString)
end

local function BuildInsertQuery(queryObj)
  local queryString = { 'INSERT INTO' }
  local keyList = {}
  local valueList = {}

  if isstring(queryObj.tableName) then
    queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
  else
    ErrorNoHalt('[CW:Database] No table name specified!\n')
    return
  end

  for i = 1, #queryObj.insertList do
    keyList[#keyList + 1] = queryObj.insertList[i][1]
    valueList[#valueList + 1] = queryObj.insertList[i][2]
  end

  if #keyList == 0 then
    return
  end

  queryString[#queryString + 1] = ' ('..table.concat(keyList, ', ')..')'
  queryString[#queryString + 1] = ' VALUES ('..table.concat(valueList, ', ')..')'

  return table.concat(queryString)
end

local function BuildUpdateQuery(queryObj)
  local queryString = { 'UPDATE' }

  if isstring(queryObj.tableName) then
    queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
  else
    ErrorNoHalt('[CW:Database] No table name specified!\n')
    return
  end

  if istable(queryObj.updateList) and #queryObj.updateList > 0 then
    local updateList = {}

    queryString[#queryString + 1] = ' SET'

    for i = 1, #queryObj.updateList do
      updateList[#updateList + 1] = queryObj.updateList[i][1]..' = '..queryObj.updateList[i][2]
    end

    queryString[#queryString + 1] = ' '..table.concat(updateList, ', ')
  end

  if istable(queryObj.whereList) and #queryObj.whereList > 0 then
    queryString[#queryString + 1] = ' WHERE '
    queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
  end

  if isnumber(queryObj.offset) then
    queryString[#queryString + 1] = ' OFFSET '
    queryString[#queryString + 1] = queryObj.offset
  end

  return table.concat(queryString)
end

local function BuildDeleteQuery(queryObj)
  local queryString = { 'DELETE FROM' }

  if isstring(queryObj.tableName) then
    queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
  else
    ErrorNoHalt('[CW:Database] No table name specified!\n')
    return
  end

  if istable(queryObj.whereList) and #queryObj.whereList > 0 then
    queryString[#queryString + 1] = ' WHERE '
    queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
  end

  if isnumber(queryObj.limit) then
    queryString[#queryString + 1] = ' LIMIT '
    queryString[#queryString + 1] = queryObj.limit
  end

  return table.concat(queryString)
end

local function BuildDropQuery(queryObj)
  local queryString = { 'DROP TABLE' }

  if isstring(queryObj.tableName) then
    queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
  else
    ErrorNoHalt('[CW:Database] No table name specified!\n')
    return
  end

  return table.concat(queryString)
end

local function BuildTruncateQuery(queryObj)
  local queryString = { 'TRUNCATE TABLE' }

  if isstring(queryObj.tableName) then
    queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
  else
    ErrorNoHalt('[CW:Database] No table name specified!\n')
    return
  end

  return table.concat(queryString)
end

local function BuildCreateQuery(queryObj)
  local queryString = { 'CREATE TABLE IF NOT EXISTS' }

  if isstring(queryObj.tableName) then
    queryString[#queryString + 1] = ' `'..queryObj.tableName..'`'
  else
    ErrorNoHalt('[CW:Database] No table name specified!\n')
    return
  end

  queryString[#queryString + 1] = ' ('

  if istable(queryObj.createList) and #queryObj.createList > 0 then
    local createList = {}

    for i = 1, #queryObj.createList do
      if cw.database.Module == 'sqlite' then
        createList[#createList + 1] = queryObj.createList[i][1]..' '..string.gsub(
          string.gsub(string.gsub(queryObj.createList[i][2], 'AUTO_INCREMENT', ''), 'AUTOINCREMENT', ''),
          'INT ',
          'INTEGER '
        )
      else
        createList[#createList + 1] = queryObj.createList[i][1]..' '..queryObj.createList[i][2]
      end
    end

    queryString[#queryString + 1] = ' '..table.concat(createList, ', ')
  end

  if isstring(queryObj.primaryKey) then
    queryString[#queryString + 1] = ', PRIMARY KEY'
    queryString[#queryString + 1] = ' ('..queryObj.primaryKey..')'
  end

  queryString[#queryString + 1] = ' )'

  return table.concat(queryString)
end

--- Builds the SQL for the query and sends it to the database.
--
-- Does nothing if the query could not be built (no table name, or an INSERT
-- without values). The query runs immediately when the connection is ready
-- and is queued otherwise. With MySQLOO the callback runs asynchronously;
-- with SQLite it runs before this returns.
-- @param bQueueQuery=false [Boolean Add the query to the queue instead of running it now]
-- @see cw.database:RawQuery
function QUERY_CLASS:Execute(bQueueQuery)
  local queryString = nil
  local queryType = string.lower(self.queryType)

  if queryType == 'select' then
    queryString = BuildSelectQuery(self)
  elseif queryType == 'insert' then
    queryString = BuildInsertQuery(self)
  elseif queryType == 'update' then
    queryString = BuildUpdateQuery(self)
  elseif queryType == 'delete' then
    queryString = BuildDeleteQuery(self)
  elseif queryType == 'drop' then
    queryString = BuildDropQuery(self)
  elseif queryType == 'truncate' then
    queryString = BuildTruncateQuery(self)
  elseif queryType == 'create' then
    queryString = BuildCreateQuery(self)
  end

  if isstring(queryString) then
    if !bQueueQuery then
      return cw.database:RawQuery(queryString, self.callback)
    else
      return cw.database:Queue(queryString, self.callback)
    end
  end
end

--[[
  End Query Class.
--]]

--- Creates a SELECT query object for a table.
--
-- See `QUERY_CLASS:New` for the builder methods and an example.
-- @param tableName [String Name of the table]
-- @return [QUERY_CLASS The query object]
function cw.database:Select(tableName)
  return QUERY_CLASS:New(tableName, 'SELECT')
end

--- Creates an INSERT query object for a table.
--
-- ```
-- local queryObj = cw.database:Insert(config.Get('mysql_bans_table'):Get())
--   queryObj:Insert('_Identifier', player:SteamID())
--   queryObj:Insert('_Schema', cw.core:GetSchemaFolder())
-- queryObj:Execute()
-- ```
--
-- @param tableName [String Name of the table]
-- @return [QUERY_CLASS The query object]
function cw.database:Insert(tableName)
  return QUERY_CLASS:New(tableName, 'INSERT')
end

--- Creates an UPDATE query object for a table.
-- @param tableName [String Name of the table]
-- @return [QUERY_CLASS The query object]
function cw.database:Update(tableName)
  return QUERY_CLASS:New(tableName, 'UPDATE')
end

--- Creates a DELETE query object for a table.
--
-- Without any `Where` conditions the query deletes every row.
-- @param tableName [String Name of the table]
-- @return [QUERY_CLASS The query object]
function cw.database:Delete(tableName)
  return QUERY_CLASS:New(tableName, 'DELETE')
end

--- Creates a DROP TABLE query object for a table.
-- @param tableName [String Name of the table]
-- @return [QUERY_CLASS The query object]
function cw.database:Drop(tableName)
  return QUERY_CLASS:New(tableName, 'DROP')
end

--- Creates a TRUNCATE TABLE query object for a table.
-- @param tableName [String Name of the table]
-- @return [QUERY_CLASS The query object]
function cw.database:Truncate(tableName)
  return QUERY_CLASS:New(tableName, 'TRUNCATE')
end

--- Creates a CREATE TABLE IF NOT EXISTS query object for a table.
-- @param tableName [String Name of the table]
-- @return [QUERY_CLASS The query object]
-- @see QUERY_CLASS:Create
function cw.database:Create(tableName)
  return QUERY_CLASS:New(tableName, 'CREATE')
end

--- Switches the connection that queries are sent through.
--
-- Only MySQLOO supports several connections; other modules always use
-- `'main'`, as does an unknown ID.
-- @param id [String ID of a connection made with `cw.database:Connect`]
function cw.database:SetCurrentConnection(id)
  if self.Module != 'mysqloo' then
    id = 'main'
  end

  if self.connections[id] then
    self.connection = self.connections[id]
    self.currentConnectionID = id
  else
    self.connection = self.connections['main']
    self.currentConnectionID = 'main'
  end
end

--- Creates a MySQLOO 9 database object, stores it under an ID and starts connecting.
--
-- A MySQLOO database object can only connect once, so every attempt creates a
-- new one. Auto-reconnect is enabled for lost connections, and a failed attempt
-- is retried after 30 seconds. Success calls `cw.database:OnConnected`,
-- failure `cw.database:OnConnectionFailed`.
-- @param id [String Connection ID]
-- @param host [String Database host]
-- @param username [String Database user]
-- @param password [String Database password]
-- @param database [String Database name]
-- @param port [Number Database port]
-- @param socket=nil [String Unix socket path; ignored unless it is a string]
-- @warning [Internal] Called by `cw.database:Connect`.
function cw.database:ConnectMySQLOO(id, host, username, password, database, port, socket)
  local connection = mysqloo.connect(
    tostring(host),
    tostring(username),
    tostring(password),
    tostring(database),
    port,
    isstring(socket) and socket or nil
  )

  -- Lost connections are re-established by the module itself (must be set before connecting).
  connection:setAutoReconnect(true)

  connection.onConnected = function(dbObj)
    timer.Remove('cw.Database.Reconnect.'..id)

    self:OnConnected()
  end

  connection.onConnectionFailed = function(dbObj, errorText)
    -- Queries issued in the meantime stay in the queue and are flushed once a connection is established.
    timer.Create('cw.Database.Reconnect.'..id, RECONNECT_DELAY, 1, function()
      if self.connections[id] == connection then
        self:ConnectMySQLOO(id, host, username, password, database, port, socket)
      end
    end)

    self:OnConnectionFailed(errorText)
  end

  self.connections[id] = connection

  if self.currentConnectionID == id then
    self.connection = connection
  end

  connection:connect()
end

--- Connects to the database with the module set in `cw.database.Module`.
--
-- With SQLite this only calls `cw.database:OnConnected`. Otherwise the binary
-- module is required first; if it is missing, an error is printed and nothing
-- else happens. Queries sent before the connection is ready are queued.
-- @param host [String Database host]
-- @param username [String Database user]
-- @param password [String Database password]
-- @param database [String Database name]
-- @param port=3306 [Number Database port]
-- @param socket=nil [String Unix socket path]
-- @param flags=nil [Number Client flags, only passed to tmysql4]
-- @param id=nil [String Connection ID for an additional MySQLOO connection; defaults to the current one or
-- `'main'`]
-- @see cw.database:SetCurrentConnection
function cw.database:Connect(host, username, password, database, port, socket, flags, id)
  port = tonumber(port) or 3306

  if !id then
    id = self.currentConnectionID or 'main'
  else
    print('[CW:Database] Creating multi-connection with ID: '..id)
  end

  if self.Module != 'sqlite' then
    print('[Catwork] Using '..self.Module..' as MySQL module...')

    if !RequireModule(self.Module) then
      return
    end

    if self.Module == 'tmysql4' then
      id = 'main'
    end
  else
    self:OnConnected()

    return
  end

  -- NOTE: tmysql4 is unsupported and untested (Catwork only ships MySQLOO 9). It is kept so that it compiles.
  if self.Module == 'tmysql4' then
    if !istable(tmysql) then
      require('tmysql4')
    end

    if tmysql then
      local errorText = nil

      self.connections[id], errorText = tmysql.initialize(host, username, password, database, port, socket, flags)

      if !self.connections[id] then
        self:OnConnectionFailed(errorText)
      else
        self:OnConnected()
      end
    else
      ErrorNoHalt(string.format(MODULE_NOT_EXIST, self.Module))
    end
  elseif self.Module == 'mysqloo' then
    if !istable(mysqloo) then
      require('mysqloo')
    end

    if mysqloo then
      if (tonumber(mysqloo.VERSION) or 0) < 9 then
        ErrorNoHalt('[CW:Database] MySQLOO 9 or newer is required, found version '..tostring(mysqloo.VERSION)..'!\n')
      end

      self:ConnectMySQLOO(id, host, username, password, database, port, socket)
    else
      ErrorNoHalt(string.format(MODULE_NOT_EXIST, self.Module))
    end
  end

  self:SetCurrentConnection(id)
end

--- Runs an SQL string on the current connection.
--
-- The query is queued if the connection is not ready yet. Query and callback
-- errors are printed, not thrown, and the callback is not called when the
-- query fails.
-- @param query [String The SQL to run]
-- @param callback=nil [Function Called as `callback(result, status, lastID)`; `status` is always `true`]
-- @param flags=nil [Number Query flags, only used by tmysql4]
-- @param ... [Any Extra arguments, only passed to tmysql4]
-- @see QUERY_CLASS:Execute
function cw.database:RawQuery(query, callback, flags, ...)
  if !IsReady(self) then
    self:Queue(query, callback)

    return
  end

  -- NOTE: tmysql4 is unsupported and untested (Catwork only ships MySQLOO 9).
  if self.Module == 'tmysql4' then
    local queryFlag = flags or QUERY_FLAG_ASSOC

    self.connection:Query(query, function(result)
      local queryStatus = result[1]['status']

      if queryStatus then
        if isfunction(callback) then
          local bStatus, value = pcall(callback, result[1]['data'], queryStatus, result[1]['lastid'])

          if !bStatus then
            ErrorNoHalt(string.format('[CW:Database] MySQL Callback Error!\n%s\n', value))
          end
        end
      else
        ErrorNoHalt(string.format('[CW:Database] MySQL Query Error!\nQuery: %s\n%s\n', query, result[1]['error']))
      end
    end, queryFlag, ...)
  elseif self.Module == 'mysqloo' then
    local queryObj = self.connection:query(query)

    -- Named fields are the default in MySQLOO 9, where this option is a no-op.
    if mysqloo.OPTION_NAMED_FIELDS then
      queryObj:setOption(mysqloo.OPTION_NAMED_FIELDS)
    end

    queryObj.onSuccess = function(queryObj, result)
      if callback then
        -- MySQLOO 9 queries have no status(); onSuccess implies success, so the status is always true.
        local bStatus, value = pcall(callback, result, true, queryObj:lastInsert())

        if !bStatus then
          ErrorNoHalt(string.format('[CW:Database] MySQL Callback Error!\n%s\n', value))
        end
      end
    end

    queryObj.onError = function(queryObj, errorText)
      ErrorNoHalt(string.format('[CW:Database] MySQL Query Error!\nQuery: %s\n%s\n', query, errorText))
    end

    queryObj:start()
  elseif cw.database.Module == 'sqlite' then
    local result = sql.Query(query)

    if result == false then
      ErrorNoHalt(string.format('[CW:Database] SQL Query Error!\nQuery: %s\n%s\n', query, sql.LastError()))
    else
      if callback then
        local lastID = nil

        if string.find(query, '^%s*[Ii][Nn][Ss][Ee][Rr][Tt]') then
          lastID = tonumber(sql.QueryValue('SELECT last_insert_rowid()'))
        end

        local bStatus, value = pcall(callback, result, true, lastID)

        if !bStatus then
          ErrorNoHalt(string.format('[CW:Database] SQL Callback Error!\n%s\n', value))
        end
      end
    end
  else
    ErrorNoHalt(string.format('[CW:Database] Unsupported module "%s"!\n', cw.database.Module))
  end
end

--- Adds an SQL string to the queue of queries waiting for the connection.
--
-- Queued queries run one per second while the connection is ready, and all at
-- once when it connects.
-- @param queryString [String The SQL to run; anything else is ignored]
-- @param callback=nil [Function Called as for `cw.database:RawQuery`]
function cw.database:Queue(queryString, callback)
  if isstring(queryString) then
    QueueTable[#QueueTable + 1] = { queryString, callback }
  end
end

--- Runs every queued query in order.
--
-- Queries that still cannot run are queued again.
-- @warning [Internal] Called by `cw.database:OnConnected`.
function cw.database:FlushQueue()
  local queue = QueueTable

  -- Queries that still cannot be run are queued again into the new table by RawQuery.
  QueueTable = {}

  for i = 1, #queue do
    self:RawQuery(queue[i][1], queue[i][2])
  end
end

--- Escapes a value for use inside a quoted SQL string.
--
-- MySQLOO uses the connection's escape function when connected and a Lua
-- equivalent of `mysql_real_escape_string` otherwise. SQLite replaces double
-- quotes with single quotes and escapes with `sql.SQLStr`.
-- @param text [Any The value; it is converted with `tostring` first]
-- @return [String The escaped text, without surrounding quotes]
function cw.database:Escape(text)
  text = tostring(text)

  if self.Module == 'tmysql4' and self.connection then
    return self.connection:Escape(text)
  elseif self.Module == 'mysqloo' then
    if IsReady(self) then
      local bSuccess, escaped = pcall(self.connection.escape, self.connection, text)

      if bSuccess then
        return escaped
      end
    end

    return EscapeMySQL(text)
  end

  return sql.SQLStr(string.gsub(text, '"', "'"), true)
end

--- Closes the current connection and cancels any pending MySQLOO reconnect.
--
-- MySQLOO waits for queries that have already started.
-- @param id [Any Unused; the current connection is always closed]
-- @return [Any The result of tmysql4's `Disconnect`; nothing for other modules]
function cw.database:Disconnect(id)
  if self.connection then
    if self.Module == 'tmysql4' then
      return self.connection:Disconnect()
    elseif self.Module == 'mysqloo' then
      timer.Remove('cw.Database.Reconnect.'..(self.currentConnectionID or 'main'))

      -- Waits for the queries that have already been started to finish.
      self.connection:disconnect(true)
    end
  end

  Connected = false
end

--- Runs the first queued query if the connection is ready.
-- @warning [Internal] Called every second by the `cw.Database.Think` timer.
function cw.database:Think()
  if #QueueTable > 0 and IsReady(self) then
    if istable(QueueTable[1]) then
      local queueObj = QueueTable[1]
      local queryString = queueObj[1]
      local callback = queueObj[2]

      if isstring(queryString) then
        self:RawQuery(queryString, callback)
      end

      table.remove(QueueTable, 1)
    end
  end
end

--- Sets the database module used by `cw.database:Connect`.
-- @param moduleName [String `'sqlite'`, `'mysqloo'` or `'tmysql4'`]
function cw.database:SetModule(moduleName)
  cw.database.Module = moduleName
end

--- Returns whether a query result contains at least one row.
-- @param result [Any The `result` passed to a query callback]
-- @return [Boolean Whether it is a non-empty table]
function cw.database:IsResult(result)
  return (istable(result) and #result > 0)
end

--- Called when the database connects; creates the default tables and runs queued queries.
--
-- Creates the `bans`, `players` and `characters` tables if they do not exist,
-- flushes the query queue, marks the database connected and fires the
-- `DatabaseConnected` hook.
-- @warning [Internal] Called by `cw.database:Connect` and the MySQLOO connection callback.
function cw.database:OnConnected()
  MsgC(Color(25, 235, 25), '[CW:Database] Connected to the database using '..cw.database.Module..'!\n')

  if self.Module == 'sqlite' then
    local queryObj = self:Create('bans')
      queryObj:Create('_Key', 'INTEGER AUTOINCREMENT')
      queryObj:Create('_Identifier', 'TEXT')
      queryObj:Create('_UnbanTime', 'INTEGER')
      queryObj:Create('_SteamName', 'TEXT')
      queryObj:Create('_Duration', 'INTEGER')
      queryObj:Create('_Reason', 'TEXT')
      queryObj:Create('_Schema', 'TEXT')
      queryObj:PrimaryKey('_Key')
    queryObj:Execute()

    local queryObj = self:Create('players')
      queryObj:Create('_Key', 'INTEGER AUTOINCREMENT')
      queryObj:Create('_Data', 'TEXT')
      queryObj:Create('_Schema', 'TEXT')
      queryObj:Create('_SteamID', 'TEXT')
      queryObj:Create('_Donations', 'TEXT')
      queryObj:Create('_UserGroup', 'TEXT')
      queryObj:Create('_IPAddress', 'TEXT')
      queryObj:Create('_SteamName', 'TEXT')
      queryObj:Create('_OnNextPlay', 'TEXT')
      queryObj:Create('_LastPlayed', 'INTEGER')
      queryObj:Create('_TimeJoined', 'INTEGER')
      queryObj:PrimaryKey('_Key')
    queryObj:Execute()

    local queryObj = self:Create('characters')
      queryObj:Create('_Key', 'INTEGER AUTOINCREMENT')
      queryObj:Create('_Data', 'TEXT')
      queryObj:Create('_Name', 'TEXT')
      queryObj:Create('_Ammo', 'TEXT')
      queryObj:Create('_Cash', 'INTEGER')
      queryObj:Create('_Model', 'TEXT')
      queryObj:Create('_Flags', 'TEXT')
      queryObj:Create('_Schema', 'TEXT')
      queryObj:Create('_Gender', 'TEXT')
      queryObj:Create('_Faction', 'TEXT')
      queryObj:Create('_SteamID', 'TEXT')
      queryObj:Create('_SteamName', 'TEXT')
      queryObj:Create('_Inventory', 'TEXT')
      queryObj:Create('_OnNextLoad', 'TEXT')
      queryObj:Create('_Attributes', 'TEXT')
      queryObj:Create('_LastPlayed', 'INTEGER')
      queryObj:Create('_TimeCreated', 'INTEGER')
      queryObj:Create('_CharacterID', 'INTEGER')
      queryObj:Create('_RecognisedNames', 'TEXT')
      queryObj:Create('_Traits', 'TEXT')
      queryObj:PrimaryKey('_Key')
    queryObj:Execute()
  else
    local queryObj = self:Create('bans')
      queryObj:Create('_Key', 'int(11) NOT NULL AUTO_INCREMENT')
      queryObj:Create('_Identifier', 'text NOT NULL')
      queryObj:Create('_UnbanTime', 'int(11) NOT NULL')
      queryObj:Create('_SteamName', 'varchar(150) NOT NULL')
      queryObj:Create('_Duration', 'int(11) NOT NULL')
      queryObj:Create('_Reason', 'text NOT NULL')
      queryObj:Create('_Schema', 'text NOT NULL')
      queryObj:PrimaryKey('_Key')
    queryObj:Execute()

    local queryObj = self:Create('characters')
      queryObj:Create('_Key', 'smallint(11) NOT NULL AUTO_INCREMENT')
      queryObj:Create('_Data', 'text NOT NULL')
      queryObj:Create('_Name', 'varchar(150) NOT NULL')
      queryObj:Create('_Ammo', 'text NOT NULL')
      queryObj:Create('_Cash', 'varchar(150) NOT NULL')
      queryObj:Create('_Model', 'varchar(250) NOT NULL')
      queryObj:Create('_Flags', 'text NOT NULL')
      queryObj:Create('_Schema', 'text NOT NULL')
      queryObj:Create('_Gender', 'varchar(50) NOT NULL')
      queryObj:Create('_Faction', 'varchar(50) NOT NULL')
      queryObj:Create('_SteamID', 'varchar(60) NOT NULL')
      queryObj:Create('_SteamName', 'varchar(150) NOT NULL')
      queryObj:Create('_Inventory', 'text NOT NULL')
      queryObj:Create('_OnNextLoad', 'text NOT NULL')
      queryObj:Create('_Attributes', 'text NOT NULL')
      queryObj:Create('_LastPlayed', 'varchar(50) NOT NULL')
      queryObj:Create('_TimeCreated', 'varchar(50) NOT NULL')
      queryObj:Create('_CharacterID', 'varchar(50) NOT NULL')
      queryObj:Create('_RecognisedNames', 'text NOT NULL')
      queryObj:Create('_Traits', 'text NOT NULL')
      queryObj:PrimaryKey('_Key')
    queryObj:Execute()

    local queryObj = self:Create('players')
      queryObj:Create('_Key', 'smallint(11) NOT NULL AUTO_INCREMENT')
      queryObj:Create('_Data', 'text NOT NULL')
      queryObj:Create('_Schema', 'text NOT NULL')
      queryObj:Create('_SteamID', 'varchar(60) NOT NULL')
      queryObj:Create('_Donations', 'text NOT NULL')
      queryObj:Create('_UserGroup', 'text NOT NULL')
      queryObj:Create('_IPAddress', 'varchar(50) NOT NULL')
      queryObj:Create('_SteamName', 'varchar(150) NOT NULL')
      queryObj:Create('_OnNextPlay', 'text NOT NULL')
      queryObj:Create('_LastPlayed', 'varchar(50) NOT NULL')
      queryObj:Create('_TimeJoined', 'varchar(50) NOT NULL')
      queryObj:PrimaryKey('_Key')
    queryObj:Execute()
  end

  -- Run everything that was queued while there was no connection (after the tables above exist).
  self:FlushQueue()

  Connected = true
  hook.Run('DatabaseConnected')
end

--- Called when a connection attempt fails; prints the error and fires `DatabaseConnectionFailed`.
-- @param errorText [String The error reported by the database module]
-- @warning [Internal] Called by the database module callbacks.
function cw.database:OnConnectionFailed(errorText)
  ErrorNoHalt('[CW:Database] Unable to connect to the database!\n'..tostring(errorText)..'\n')

  hook.Run('DatabaseConnectionFailed', errorText)
end

--- Prints a database error to the console.
--
-- Called by `GM:DatabaseConnectionFailed`. Does nothing if `errorText` is `nil`.
-- @param errorText [String The error message]
function cw.database:Error(errorText)
  if errorText then
    ErrorNoHalt('[CW:Database] MySQL error: '..tostring(errorText)..'\n')
  end
end

--- Returns whether the database has connected.
-- @return [Boolean Whether `cw.database:OnConnected` has run since the last disconnect]
function cw.database:IsConnected()
  return Connected
end

--- Updates the rows matching a condition, or inserts a new row if none match.
--
-- ```
-- cw.database:EasyWrite('cw_notes', { '_SteamID', player:SteamID() }, {
--   _SteamID = player:SteamID(),
--   _Text = text
-- })
-- ```
--
-- @param tableName [String Name of the table]
-- @param where [List A `{ column, value }` pair, or a list of such pairs that must all match]
-- @param data [Map Column names mapped to the values to write]
-- @see cw.database:EasyRead
function cw.database:EasyWrite(tableName, where, data)
  if !data or !istable(data) then
    ErrorNoHalt('[Catwork] Easy MySQL error! Data has unexpected value type (table expected, got '..type(data)..')\n')

    return
  end

  if !where then
    ErrorNoHalt(
      "[Catwork] Easy MySQL error! 'where' table is malformed! ([1] = "..type(where[1])..', [2] = '..type(where[2])..
        ')\n'
    )

    return
  end

  local query = self:Select(tableName)

    if istable(where[1]) then
      for k, v in pairs(where) do
        query:Where(v[1], v[2])
      end
    else
      query:Where(where[1], where[2])
    end

    query:Callback(function(result, status, lastID)
      if istable(result) and #result > 0 then
        local updateObj = self:Update(tableName)

          for k, v in pairs(data) do
            updateObj:Update(k, v)
          end

          updateObj:Where(where[1], where[2])
          updateObj:Callback(function()
            cw.core:Debug("Easy MySQL updated data. ('"..tableName.."' WHERE "..where[1]..' = '..where[2]..')')
          end)

        updateObj:Execute()
      else
        local insertObj = self:Insert(tableName)

          for k, v in pairs(data) do
            insertObj:Insert(k, v)
          end

          insertObj:Callback(function(result)
            if !istable(where[1]) then
              cw.core:Debug("Easy MySQL inserted data into '"..tableName.."' WHERE "..where[1]..' = '..where[2]..'.')
            else
              local msg = "Easy MySQL inserted data into '"..tableName.."' WHERE "
              local i = 0

              for k, v in pairs(where) do
                i = i + 1
                msg = msg..v[1]..' = '..v[2]

                if table.Count(where) != i then
                  msg = msg..' AND '
                end
              end

              cw.core:Debug(msg)
            end
          end)

        insertObj:Execute()
      end
    end)

  query:Execute()
end

--- Selects the rows matching a condition and passes them to a callback.
-- @param tableName [String Name of the table]
-- @param where [List A `{ column, value }` pair, or a list of such pairs that must all match]
-- @param callback [Function Called as `callback(result, bHasRows)`; errors in it are caught and printed]
-- @return [Boolean `false` if `where` is missing; nothing otherwise]
-- @see cw.database:EasyWrite
function cw.database:EasyRead(tableName, where, callback)
  if !where then
    ErrorNoHalt(
      "[Catwork] Easy MySQL Read error! 'where' table is malformed! ([1] = "..type(where[1])..', [2] = '..
        type(where[2])..
        ')\n'
    )
    return false
  end

  local query = self:Select(tableName)

    if istable(where[1]) then
      for k, v in pairs(where) do
        query:Where(v[1], v[2])
      end
    else
      query:Where(where[1], where[2])
    end

    query:Callback(function(result)
      cw.core:Debug('Easy MySQL has successfully read the data!')

      local success, value = pcall(callback, result, (istable(result) and #result > 0))

      if !success then
        ErrorNoHalt('[CW:EasyRead Error] '..value..'\n')
      end
    end)

  query:Execute()
end

timer.Create('cw.Database.Think', 1, 0, function()
  cw.database:Think()
end)
