--- Defines the server-side `cw.bans` library, which keeps Steam ID and IP address bans in the database for the current
-- schema.
--
-- `cw.bans:Load` reads them into `cw.bans.stored`, `cw.bans:Add` bans an identifier for a duration and kicks any
-- matching player, and `cw.bans:Remove` lifts a ban.

library.New('bans', cw)

local stored = cw.bans.stored or {}
cw.bans.stored = stored

--[[
  A local function to handle ban deletion.
  INTERNAL USE ONLY. DO NOT USE.
--]]

local function DELETE_BAN(identifier)
  stored[identifier] = nil

  local bansTable = config.Get('mysql_bans_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()

  local queryObj = cw.database:Delete(bansTable)
    queryObj:Where('_Schema', schemaFolder)
    queryObj:Where('_Identifier', identifier)
  queryObj:Execute()
end

--[[
  A local function to store a ban and write it to the database.
  INTERNAL USE ONLY. DO NOT USE.
--]]

local function STORE_BAN(identifier, steamName, duration, reason, bSaveless)
  -- A ban that is replaced must not leave its row behind, or either one could be loaded after a restart.
  if stored[identifier] and !bSaveless then
    DELETE_BAN(identifier)
  end

  stored[identifier] = {
    unbanTime = (duration == 0 and 0) or os.time() + duration,
    steamName = steamName,
    duration = duration,
    reason = reason
  }

  if !bSaveless then
    local queryObj = cw.database:Insert(config.Get('mysql_bans_table'):Get())
      queryObj:Insert('_Identifier', identifier)
      queryObj:Insert('_UnbanTime', stored[identifier].unbanTime)
      queryObj:Insert('_SteamName', steamName)
      queryObj:Insert('_Duration', duration)
      queryObj:Insert('_Reason', reason)
      queryObj:Insert('_Schema', cw.core:GetSchemaFolder())
    queryObj:Execute()
  end
end

--[[
  A local function to handle the loading of bans.
  INTERNAL USE ONLY. DO NOT USE.
--]]

local function BANS_LOAD_CALLBACK(result)
  if !cw.database:IsResult(result) then return end

  local bansTable = config.Get('mysql_bans_table'):Get()
  local unixTime = os.time()
  local loaded = {}

  for k, v in pairs(result) do
    local identifier = v._Identifier
    local unbanTime = tonumber(v._UnbanTime) or 0

    if unbanTime > 0 and unixTime >= unbanTime then
      -- Deleted by key, as a newer ban for the same identifier may still be running.
      local queryObj = cw.database:Delete(bansTable)
        queryObj:Where('_Key', v._Key)
      queryObj:Execute()
    elseif !loaded[identifier] or (loaded[identifier] != 0 and (unbanTime == 0 or unbanTime > loaded[identifier])) then
      -- If an identifier has several rows, the ban that lasts the longest counts.
      loaded[identifier] = unbanTime

      stored[identifier] = {
        unbanTime = unbanTime,
        steamName = v._SteamName,
        duration = tonumber(v._Duration) or 0,
        reason = v._Reason
      }
    end
  end
end

--- Loads the current schema's bans from the database into `cw.bans.stored`.
--
-- Timed bans whose unban time has passed are deleted instead, both from the
-- database and from memory, as are malformed entries.
-- @see cw.bans:Add
function cw.bans:Load()
  local bansTable = config.Get('mysql_bans_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()

  local queryObj = cw.database:Select(bansTable)
    queryObj:Callback(BANS_LOAD_CALLBACK)
    queryObj:Where('_Schema', schemaFolder)
  queryObj:Execute()

  local unixTime = os.time()

  for k, v in pairs(stored) do
    if type(v) == 'table' then
      local unbanTime = tonumber(v.unbanTime) or 0

      if unbanTime > 0 and unixTime >= unbanTime then
        self:Remove(k)
      end
    else
      DELETE_BAN(k)
    end
  end
end

--- Bans a Steam ID or IP address and kicks any matching player.
--
-- Every connected player whose Steam ID or IP matches, or who `player.Find`
-- returns for the identifier, fires the `PlayerBanned` hook and is kicked
-- with the reason. The ban is stored in `cw.bans.stored`, replacing any ban
-- already stored for the identifier, and, unless `bSaveless` is set, inserted
-- into the bans table for the current schema. For offline Steam IDs and IPs
-- the Steam name is looked up in the players table first, so the callback
-- runs asynchronously in that case. An identifier that is neither a Steam ID
-- nor an IP address and matches no connected player is not banned, and the
-- callback is called without arguments.
--
-- ```
-- cw.bans:Add('STEAM_0:1:123456', 3600, 'Mic spam.', function(steamName, duration, reason)
--   cw.player:NotifyAll(steamName..' has been banned for one hour.')
-- end)
-- ```
--
-- @param identifier [String Steam ID, IP address or player name; Steam IDs are upper-cased]
-- @param duration [Number Ban length in seconds; `0` bans permanently]
-- @param reason=nil [String Kick and ban reason; defaults to 'Banned for an unspecified reason.']
-- @param Callback=nil [Function Called as `Callback(steamName, duration, reason)` once the ban is stored]
-- @param bSaveless=false [Boolean Keep the ban in memory only and do not write it to the database]
-- @see cw.bans:Remove
function cw.bans:Add(identifier, duration, reason, Callback, bSaveless)
  if !isstring(identifier) then
    if Callback then
      Callback()
    end

    return
  end

  local steamName = nil
  local playerGet = _player.Find(identifier)

  identifier = string.upper(identifier)

  if !reason then
    reason = 'Banned for an unspecified reason.'
  end

  for k, v in ipairs(_player.GetAll()) do
    -- Player:IPAddress includes the port, which a banned IP address does not.
    local playerIP = string.gsub(v:IPAddress(), ':%d+$', '')
    local playerSteam = v:SteamID()

    if playerSteam == identifier or playerIP == identifier or playerGet == v then
      hook.Run('PlayerBanned', v, duration, reason)

      if playerIP == identifier then
        identifier = playerIP
      else
        identifier = playerSteam
      end

      steamName = v:SteamName()
      v:Kick(reason)
    end
  end

  if steamName then
    STORE_BAN(identifier, steamName, duration, reason, bSaveless)

    if Callback then
      Callback(steamName, duration, reason)
    end

    return
  end

  local bIsSteamID = string.find(identifier, 'STEAM_(%d+):(%d+):(%d+)') != nil

  if !bIsSteamID and !string.find(identifier, '%d+%.%d+%.%d+%.%d+') then
    if Callback then
      Callback()
    end

    return
  end

  -- The player is offline, so use the Steam name they were last seen with.
  local queryObj = cw.database:Select(config.Get('mysql_players_table'):Get())
    queryObj:Where(bIsSteamID and '_SteamID' or '_IPAddress', identifier)
    queryObj:Callback(function(result)
      local steamName = identifier

      if cw.database:IsResult(result) then
        steamName = result[1]._SteamName
      end

      STORE_BAN(identifier, steamName, duration, reason, bSaveless)

      if Callback then
        Callback(steamName, duration, reason)
      end
    end)
  queryObj:Execute()
end

--- Lifts a ban and deletes it from the database.
--
-- Does nothing if no ban is stored under the identifier.
-- @param identifier [String The Steam ID or IP address the ban is stored under]
-- @param bSaveless=false [Boolean Only remove the ban from memory and keep the database row]
-- @see cw.bans:Add
function cw.bans:Remove(identifier, bSaveless)
  if !stored[identifier] then return end

  if bSaveless then
    stored[identifier] = nil
  else
    DELETE_BAN(identifier)
  end
end
