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
  A local function to handle the loading of bans.
  INTERNAL USE ONLY. DO NOT USE.
--]]

local function BANS_LOAD_CALLBACK(result)
  if cw.database:IsResult(result) then
    stored = stored or {}

    for k, v in pairs(result)do
      stored[v._Identifier] = {
        unbanTime = tonumber(v._UnbanTime),
        steamName = v._SteamName,
        duration = tonumber(v._Duration),
        reason = v._Reason
      }
    end
  end
end

--- Loads the current schema's bans from the database into `cw.bans.stored`.
--
-- Also removes timed bans whose unban time has passed from memory (without
-- deleting their database rows) and deletes malformed entries.
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
      if v.unbanTime > 0 and unixTime >= v.unbanTime then
        self:Remove(k, true)
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
-- with the reason. The ban is stored in `cw.bans.stored` and, unless
-- `bSaveless` is set, inserted into the bans table for the current schema.
-- For offline Steam IDs and IPs the Steam name is looked up in the players
-- table first, so the callback runs asynchronously in that case.
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
  local steamName = nil
  local playerGet = _player.Find(identifier)
  local bansTable = config.Get('mysql_bans_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()

  if identifier then
    identifier = string.upper(identifier)
  end

  for k, v in ipairs(_player.GetAll()) do
    local playerIP = v:IPAddress()
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

  if !reason then
    reason = 'Banned for an unspecified reason.'
  end

  if steamName then
    if duration == 0 then
      stored[identifier] = {
        unbanTime = 0,
        steamName = steamName,
        duration = duration,
        reason = reason
      }
    else
      stored[identifier] = {
        unbanTime = os.time() + duration,
        steamName = steamName,
        duration = duration,
        reason = reason
      }
    end

    if !bSaveless then
      local queryObj = cw.database:Insert(bansTable)
        queryObj:Insert('_Identifier', identifier)
        queryObj:Insert('_UnbanTime', stored[identifier].unbanTime)
        queryObj:Insert('_SteamName', stored[identifier].steamName)
        queryObj:Insert('_Duration', stored[identifier].duration)
        queryObj:Insert('_Reason', stored[identifier].reason)
        queryObj:Insert('_Schema', schemaFolder)
      queryObj:Execute()
    end

    if Callback then
      Callback(steamName, duration, reason)
    end

    return
  end

  local playersTable = config.Get('mysql_players_table'):Get()

  if string.find(identifier, 'STEAM_(%d+):(%d+):(%d+)') then
    local queryObj = cw.database:Select(playersTable)
      queryObj:Where('_SteamID', identifier)
      queryObj:Callback(function(result)
        local steamName = identifier

        if cw.database:IsResult(result) then
          steamName = result[1]._SteamName
        end

        if duration == 0 then
          stored[identifier] = {
            unbanTime = 0,
            steamName = steamName,
            duration = duration,
            reason = reason
          }
        else
          stored[identifier] = {
            unbanTime = os.time() + duration,
            steamName = steamName,
            duration = duration,
            reason = reason
          }
        end

        if !bSaveless then
          local insertObj = cw.database:Insert(bansTable)
            insertObj:Insert('_Identifier', identifier)
            insertObj:Insert('_UnbanTime', stored[identifier].unbanTime)
            insertObj:Insert('_SteamName', stored[identifier].steamName)
            insertObj:Insert('_Duration', stored[identifier].duration)
            insertObj:Insert('_Reason', stored[identifier].reason)
            insertObj:Insert('_Schema', schemaFolder)
          insertObj:Execute()
        end

        if Callback then
          Callback(steamName, duration, reason)
        end
      end)

    queryObj:Execute()

    return
  end

  --[[ In this case we're banning them by their IP address. --]]
  if string.find(identifier, '%d+%.%d+%.%d+%.%d+') then
    local queryObj = cw.database:Select(playersTable)
      queryObj:Callback(function(result)
        local steamName = identifier

        if cw.database:IsResult(result) then
          steamName = result[1]._SteamName
        end

        if duration == 0 then
          stored[identifier] = {
            unbanTime = 0,
            steamName = steamName,
            duration = duration,
            reason = reason
          }
        else
          stored[identifier] = {
            unbanTime = os.time() + duration,
            steamName = steamName,
            duration = duration,
            reason = reason
          }
        end

        if !bSaveless then
          local insertObj = cw.database:Insert(bansTable)
            insertObj:Insert('_Identifier', identifier)
            insertObj:Insert('_UnbanTime', stored[identifier].unbanTime)
            insertObj:Insert('_SteamName', stored[identifier].steamName)
            insertObj:Insert('_Duration', stored[identifier].duration)
            insertObj:Insert('_Reason', stored[identifier].reason)
            insertObj:Insert('_Schema', schemaFolder)
          insertObj:Execute()
        end

        if Callback then
          Callback(steamName, duration, reason)
        end
      end)

      queryObj:Where('_IPAddress', identifier)
    queryObj:Execute()

    return
  end

  if duration == 0 then
    stored[identifier] = {
      unbanTime = 0,
      steamName = steamName,
      duration = duration,
      reason = reason
    }
  else
    stored[identifier] = {
      unbanTime = os.time() + duration,
      steamName = steamName,
      duration = duration,
      reason = reason
    }
  end

  if !bSaveless then
    local queryObj = cw.database:Insert(bansTable)
      queryObj:Insert('_Identifier', identifier)
      queryObj:Insert('_UnbanTime', stored[identifier].unbanTime)
      queryObj:Insert('_SteamName', stored[identifier].steamName)
      queryObj:Insert('_Duration', stored[identifier].duration)
      queryObj:Insert('_Reason', stored[identifier].reason)
      queryObj:Insert('_Schema', schemaFolder)
    queryObj:Execute()
  end

  if Callback then
    Callback(steamName, duration, reason)
  end
end

--- Lifts a ban and deletes it from the database.
--
-- Does nothing if no ban is stored under the identifier.
-- @param identifier [String The Steam ID or IP address the ban is stored under]
-- @param bSaveless=false [Boolean Only remove the ban from memory and keep the database row]
-- @see cw.bans:Add
function cw.bans:Remove(identifier, bSaveless)
  local bansTable = config.Get('mysql_bans_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()

  if stored[identifier] then
    stored[identifier] = nil

    if !bSaveless then
      local queryObj = cw.database:Delete(bansTable)
        queryObj:Where('_Schema', schemaFolder)
        queryObj:Where('_Identifier', identifier)
      queryObj:Execute()
    end
  end
end
