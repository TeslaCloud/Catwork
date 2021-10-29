--[[
	© 2017 TeslaCloud Studios.
	Do not share, re-distribute or sell.
--]]

PLUGIN:SetGlobalAlias("cca")

util.Include("cl_plugin.lua")
util.Include("sv_plugin.lua")

local typeTranslations = {
	["default"] = {
		color = Color(180, 180, 180),
		important = false
	}
}

function cca.AddLogType(type, data)
	typeTranslations[type] = data
end

function cca.GetLogType(type)
	return typeTranslations[type] or typeTranslations["default"] or {}
end

function cca.AppendLog(appender, player, entry, type)
	if (IsValid(player)) then
		local logs = player:GetCharacterData("CCA_Logs") or {}
		local appenderName = (IsValid(appender) and appender:Name()) or "Overwatch"

		table.insert(logs, {entry = entry, type = type, time = os.time(), appender = appenderName})

		player:SetCharacterData("CCA_Logs", logs)
		player:SetNetVar("CCA_Logs", table.Copy(logs))

		if (SERVER) then netstream.Start(appender, "CCA::Response::Update", true) end
	end
end

cca.AddLogType("loyalty_add", {
	color = Color(130, 240, 155),
	important = true
})

cca.AddLogType("loyalty_remove", {
	color = Color(240, 240, 130)
})

cca.AddLogType("crime_add", {
	color = Color(240, 130, 130)
})

cca.AddLogType("crime_remove", {
	color = Color(240, 240, 130)
})

cca.AddLogType("work_add", {
	color = Color(130, 240, 155),
	important = true
})

cca.AddLogType("work_remove", {
	color = Color(240, 240, 130)
})

cca.AddLogType("jail", {
	color = Color(240, 130, 130),
	important = true
})

cca.AddLogType("unjail", {
	color = Color(240, 240, 130)
})