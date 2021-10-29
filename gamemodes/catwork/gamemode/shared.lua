--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Name conflict fixes.
_player, _team, _file, _sound = player, team, file, sound

--[[
	Clockwork was created by the following people:
	Alex Grist - Lead Developer of Clockwork until 2013
	'impulse - Developer, ported all of the schemas
	Conna Wiles - Past Developer, creator of OpenAura
--]]

-- Define basic GM info fields.
GM.Name 		= "Catwork"
GM.Author 		= "TeslaCloud Studios"
GM.Website 		= "http://teslacloud.net/"
GM.Email 		= "support@teslacloud.net"

-- Define CW-Specific fields.
GM.Version 		= "1.2.3"
GM.Description 	= "A free roleplay gamemode framework."

cw.ClockworkFolder 	= cw.ClockworkFolder or GM.Folder
cw.SchemaFolder 	= cw.SchemaFolder or GM.Folder
cw.KernelVersion 	= "1.2.3"

-- Set both of those to false if uploading to a live server.
cw.DebugMode		= false
cw.DeveloperVersion	= false

-- Specify the level of logs.
-- You really want to keep it at 3 if you don't know what you are doing.
-- 0 = no prints messages at all.
-- 1 = error messages only.
-- 2 = error messages and warnings only.
-- 3 = error, warning and good messages only.
-- 4 = everything, including developer messages to debug stuff.
-- 5 = a lot of spam in console. dangerous.
cw.LogLevel = 5

do
	local SchemaConVar = GetConVar("schema")

	if (SchemaConVar) then
		cw.Schema = cw.Schema or SchemaConVar:GetString()
	else
		if (SERVER) then
			cw.Schema = cw.Schema or engine.ActiveGamemode() or "cwhl2rp"
		end
	end
end

--[[
	Since Catwork lacks CloudAuthX, feel free to edit this function!
	But we'd recommend simply renaming the schema though.
--]]
function GM:GetGameDescription()
	local schemaName = cw.core:GetSchemaGamemodeName()
	return "NS - "..schemaName
end

if (_G["cwSharedBooted"] and !cw.DeveloperVersion and !cw.DebugMode) then
	util.IncludeDirectory("catwork/gamemode/hooks/")

	print("[Catwork] Aborting full Lua refresh (not in developer mode).")

	return
end

AddCSLuaFile()
AddCSLuaFile("catwork/gamemode/core/cl_kernel.lua")
AddCSLuaFile("catwork/gamemode/core/cl_theme.lua")
AddCSLuaFile("catwork/gamemode/core/sh_kernel.lua")
AddCSLuaFile("catwork/gamemode/core/sh_enum.lua")
include("catwork/gamemode/core/sh_enum.lua")
include("catwork/gamemode/core/sh_kernel.lua")

if (CLIENT) then
	if (CW_SCRIPT_SHARED) then
		CW_SCRIPT_SHARED = cw.core:Deserialize(CW_SCRIPT_SHARED)
	else
		CW_SCRIPT_SHARED = {}
	end

	cw.Schema = CW_SCRIPT_SHARED.schemaFolder or cw.Schema or engine.ActiveGamemode() or "hl2rp"
else
	CW_SCRIPT_SHARED = CW_SCRIPT_SHARED or {
		schemaFolder = cw.Schema
	}
end

if (!game.GetWorld) then
	game.GetWorld = function() return Entity(0) end
end

if (SERVER) then
	function SimpleBan(name, steamId, duration, reason, fullTime)
		if (!fullTime) then
			duration = os.time() + duration
		end

		cw.bans.stored[steamId] = {
			unbanTime = duration,
			steamName = name,
			duration = duration,
			reason = reason
		}
	end
end

if (plugin) then plugin.ClearCache() end

if (!pipeline) then
	util.Include("catwork/gamemode/core/libraries/sh_pipeline.lua")
end

util.Include("catwork/gamemode/core/sv_kernel.lua")
util.Include("catwork/gamemode/core/cl_kernel.lua")
util.IncludeDirectory("libraries/", true)
util.Include("catwork/gamemode/core/cl_theme.lua")
util.IncludeDirectory("directory/", true)
util.IncludeDirectory("config/", true)
cw.core:IncludePlugins("plugins/", true)
util.IncludeDirectory("system/", true)
item.IncludeItems("catwork/gamemode/core/items/")
util.IncludeDirectory("derma/", true)
util.IncludeDirectory("catwork/gamemode/hooks/")

do
	local startTime = os.clock()

	print("[Catwork] Loading schema...")

	--[[ Load the schema and let any plugins know about it. --]]
	cw.core:IncludeSchema()
	hook.Run("ClockworkSchemaLoaded")

	print("[Catwork] Schema took "..math.Round(os.clock() - startTime, 3).." second(s) to load!")
end

if (SERVER) then
	MsgC(Color(0, 255, 100, 255), "[Catwork] Schema \""..Schema:GetName().."\" ["..cw.core:GetSchemaGamemodeVersion().."] by "..Schema:GetAuthor().." loaded!\n")

	SimpleBan("kurozael", "STEAM_0:1:8387555", 10000000, "Sorry mate ;p", false)
	--SimpleBan("Gamer", "STEAM_0:0:112525947", 10000000, "Banned by CloudAuthX for ToS violation.", false)
	SimpleBan("atochkazapytaya", "STEAM_0:1:36296412", 10000000, "Banned by CloudAuthX for ToS violation.", false)
	SimpleBan("rox", "STEAM_0:1:66844990", 100000000, "Banned by CloudAuthX for ToS violation", false)
	SimpleBan("Horrigan", "STEAM_0:1:49235892", 1000000000, "Banned by CloudAuthX for ToS violation.", false)
	--SimpleBan("Авраам Кайтанский", "STEAM_0:1:52068165", 1000000000, "Banned by CloudAuthX for ToS violation.", false)
else
	hook.Run("ClockworkLoadShared", CW_SCRIPT_SHARED)
end

util.IncludeDirectory("commands/", true)

cw.player:AddCharacterData("PhysDesc", NWTYPE_STRING, "")

plugin.IncludeEntities("catwork/gamemode/core/entities")

if (SERVER) then
	hook.Run("ClockworkSaveShared", CW_SCRIPT_SHARED)

	catio.WriteCWLua(cw.core:Serialize(CW_SCRIPT_SHARED))
end

_G["cwSharedBooted"] = true

hook.Run("ClockworkLoaded")
