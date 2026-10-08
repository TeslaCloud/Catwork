--- Main file of the Combine Civil Authority plugin, which aliases it as `cca`, includes its files and defines the civil
-- record log.
--
-- `cca.AppendLog` adds an entry to a player's civil record, stored in the `CCA_Logs` character data and networked as a
-- net var of the same name; `cca.TrimLogs` keeps the record to its newest 50 entries. `cca.AddLogType` and
-- `cca.GetLogType` set how each entry type (loyalty, crime and work points, jail and unjail) is colored and
-- highlighted.

PLUGIN:SetGlobalAlias('cca')

util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')

-- The record is saved with the character and sent whole to every client each time it changes, so it has to stay small.
local maxLogEntries = 50

local typeTranslations = {
  ['default'] = {
    color = Color(180, 180, 180),
    important = false
  }
}

--- Registers how a type of civil record entry is displayed.
--
-- ```
-- cca.AddLogType('jail', {
--   color = Color(240, 130, 130),
--   important = true
-- })
-- ```
--
-- @param type [String Name of the entry type, as passed to `cca.AppendLog`]
-- @param data [Map Display options: `color` (Color of the entry) and `important` (Boolean, highlights the entry)]
-- @see cca.GetLogType
function cca.AddLogType(type, data)
  typeTranslations[type] = data
end

--- Returns the display options of a civil record entry type.
-- @param type [String Name of the entry type]
-- @return [Map The type's options, or those of the `default` type when it is not registered]
function cca.GetLogType(type)
  return typeTranslations[type] or typeTranslations['default'] or {}
end

--- Drops the oldest entries of a civil record until it holds no more than 50.
-- @param logs [List The record, oldest entry first; changed in place]
-- @return [List The same record]
function cca.TrimLogs(logs)
  local count = #logs
  local excess = count - maxLogEntries

  if excess > 0 then
    for i = 1, count do
      logs[i] = logs[i + excess]
    end
  end

  return logs
end

--- Adds an entry to a player's civil record.
--
-- The record is stored in the `CCA_Logs` character data and networked to clients as the
-- `CCA_Logs` net var; only its newest 50 entries are kept. On the server a valid appender is told
-- to refresh their PDA. Does nothing when `player` is not valid.
--
-- ```
-- cca.AppendLog(officer, citizen, L('PDA_Log_Jail'), 'jail')
-- ```
--
-- @param appender [Player The player who writes the entry; entries without a valid player are signed by Overwatch]
-- @param player [Player The player whose record gets the entry]
-- @param entry [String Text of the entry]
-- @param type [String Entry type, registered with `cca.AddLogType`]
function cca.AppendLog(appender, player, entry, type)
  if IsValid(player) then
    local logs = player:GetCharacterData('CCA_Logs') or {}
    local appenderName = (IsValid(appender) and appender:Name()) or '#PDA_Log_Overwatch'

    table.insert(logs, { entry = entry, type = type, time = os.time(), appender = appenderName })
    cca.TrimLogs(logs)

    player:SetCharacterData('CCA_Logs', logs)
    player:SetNetVar('CCA_Logs', logs)

    -- Without a recipient the netstream would go to every player.
    if SERVER and IsValid(appender) then netstream.Start(appender, 'CCA::Response::Update', true) end
  end
end

cca.AddLogType('loyalty_add', {
  color = Color(130, 240, 155),
  important = true
})

cca.AddLogType('loyalty_remove', {
  color = Color(240, 240, 130)
})

cca.AddLogType('crime_add', {
  color = Color(240, 130, 130)
})

cca.AddLogType('crime_remove', {
  color = Color(240, 240, 130)
})

cca.AddLogType('work_add', {
  color = Color(130, 240, 155),
  important = true
})

cca.AddLogType('work_remove', {
  color = Color(240, 240, 130)
})

cca.AddLogType('jail', {
  color = Color(240, 130, 130),
  important = true
})

cca.AddLogType('unjail', {
  color = Color(240, 240, 130)
})
