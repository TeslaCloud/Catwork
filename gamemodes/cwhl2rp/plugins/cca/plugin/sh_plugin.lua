--[[
  © 2017 TeslaCloud Studios.
  Do not share, re-distribute or sell.
--]]

PLUGIN:SetGlobalAlias('cca')

util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')

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

--- Adds an entry to a player's civil record.
--
-- The record is stored in the `CCA_Logs` character data and networked to clients as the
-- `CCA_Logs` net var. On the server the appender is told to refresh their PDA. Does nothing when
-- `player` is not valid.
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

    player:SetCharacterData('CCA_Logs', logs)
    player:SetNetVar('CCA_Logs', table.Copy(logs))

    if SERVER then netstream.Start(appender, 'CCA::Response::Update', true) end
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
