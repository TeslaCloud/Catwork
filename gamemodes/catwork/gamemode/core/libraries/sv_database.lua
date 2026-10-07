--[[
  mysql - 1.0.2
  A simple MySQL wrapper for Garry's Mod.

  Alexander Grist-Hucker
  http://www.alexgrist.com
--]]

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

function QUERY_CLASS:Escape(text)
  return cw.database:Escape(tostring(text))
end

function QUERY_CLASS:ForTable(tableName)
  self.tableName = tableName
end

function QUERY_CLASS:Where(key, value)
  self:WhereEqual(key, value)
end

function QUERY_CLASS:WhereEqual(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` = "'..self:Escape(value)..'"'
end

function QUERY_CLASS:WhereNotEqual(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` != "'..self:Escape(value)..'"'
end

function QUERY_CLASS:WhereLike(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` LIKE "'..self:Escape(value)..'"'
end

function QUERY_CLASS:WhereNotLike(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` NOT LIKE "'..self:Escape(value)..'"'
end

function QUERY_CLASS:WhereGT(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` > "'..self:Escape(value)..'"'
end

function QUERY_CLASS:WhereLT(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` < "'..self:Escape(value)..'"'
end

function QUERY_CLASS:WhereGTE(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` >= "'..self:Escape(value)..'"'
end

function QUERY_CLASS:WhereLTE(key, value)
  self.whereList[#self.whereList + 1] = '`'..key..'` <= "'..self:Escape(value)..'"'
end

function QUERY_CLASS:OrderByDesc(key)
  self.orderByList[#self.orderByList + 1] = '`'..key..'` DESC'
end

function QUERY_CLASS:OrderByAsc(key)
  self.orderByList[#self.orderByList + 1] = '`'..key..'` ASC'
end

function QUERY_CLASS:Callback(queryCallback)
  self.callback = queryCallback
end

function QUERY_CLASS:Select(fieldName)
  self.selectList[#self.selectList + 1] = '`'..fieldName..'`'
end

function QUERY_CLASS:Insert(key, value)
  self.insertList[#self.insertList + 1] = { '`'..key..'`', '"'..self:Escape(value)..'"' }
end

function QUERY_CLASS:Update(key, value)
  self.updateList[#self.updateList + 1] = { '`'..key..'`', '"'..self:Escape(value)..'"' }
end

function QUERY_CLASS:Create(key, value)
  self.createList[#self.createList + 1] = { '`'..key..'`', value }
end

function QUERY_CLASS:PrimaryKey(key)
  self.primaryKey = '`'..key..'`'
end

function QUERY_CLASS:Limit(value)
  self.limit = value
end

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

function cw.database:Select(tableName)
  return QUERY_CLASS:New(tableName, 'SELECT')
end

function cw.database:Insert(tableName)
  return QUERY_CLASS:New(tableName, 'INSERT')
end

function cw.database:Update(tableName)
  return QUERY_CLASS:New(tableName, 'UPDATE')
end

function cw.database:Delete(tableName)
  return QUERY_CLASS:New(tableName, 'DELETE')
end

function cw.database:Drop(tableName)
  return QUERY_CLASS:New(tableName, 'DROP')
end

function cw.database:Truncate(tableName)
  return QUERY_CLASS:New(tableName, 'TRUNCATE')
end

function cw.database:Create(tableName)
  return QUERY_CLASS:New(tableName, 'CREATE')
end

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

-- A function to create a MySQLOO 9 database object and start connecting it.
-- mysqloo.connect(host, username, password, database [, port, socket]) no longer takes client flags, and a
-- database object can only be connected once, so every (re)connection attempt needs a new object.
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

-- A function to connect to the MySQL database.
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

-- A function to query the MySQL database.
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

-- A function to add a query to the queue.
function cw.database:Queue(queryString, callback)
  if isstring(queryString) then
    QueueTable[#QueueTable + 1] = { queryString, callback }
  end
end

-- A function to run every queued query in order, with its callback.
function cw.database:FlushQueue()
  local queue = QueueTable

  -- Queries that still cannot be run are queued again into the new table by RawQuery.
  QueueTable = {}

  for i = 1, #queue do
    self:RawQuery(queue[i][1], queue[i][2])
  end
end

-- A function to escape a string for MySQL.
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

-- A function to disconnect from the MySQL database.
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

-- A function to set the module that should be used.
function cw.database:SetModule(moduleName)
  cw.database.Module = moduleName
end

function cw.database:IsResult(result)
  return (istable(result) and #result > 0)
end

-- Called when the database connects sucessfully.
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

-- Called when the database connection fails.
function cw.database:OnConnectionFailed(errorText)
  ErrorNoHalt('[CW:Database] Unable to connect to the database!\n'..tostring(errorText)..'\n')

  hook.Run('DatabaseConnectionFailed', errorText)
end

-- A function to report a database error (called by GM:DatabaseConnectionFailed).
function cw.database:Error(errorText)
  if errorText then
    ErrorNoHalt('[CW:Database] MySQL error: '..tostring(errorText)..'\n')
  end
end

-- A function to check whether or not the module is connected to a database.
function cw.database:IsConnected()
  return Connected
end

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
            fl.core:DevPrint("Easy MySQL updated data. ('"..tableName.."' WHERE "..where[1]..' = '..where[2]..')')
          end)

        updateObj:Execute()
      else
        local insertObj = self:Insert(tableName)

          for k, v in pairs(data) do
            insertObj:Insert(k, v)
          end

          insertObj:Callback(function(result)
            if !istable(where[1]) then
              fl.core:DevPrint("Easy MySQL inserted data into '"..tableName.."' WHERE "..where[1]..' = '..where[2]..'.')
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

              fl.core:DevPrint(msg)
            end
          end)

        insertObj:Execute()
      end
    end)

  query:Execute()
end

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
      fl.core:DevPrint('Easy MySQL has successfully read the data!')

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
