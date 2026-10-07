--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("SpawnPointAdd")
COMMAND.tip = "#Command_Spawnpointadd_Description"
COMMAND.text = "#Command_Spawnpointadd_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = faction.FindByID(arguments[1])
	local class = cw.class:FindByID(arguments[1])
	local name = nil
	local rotate = tonumber(arguments[2]) or nil

	if (class or faction) then
		if (faction) then
			name = faction.name
		else
			name = class.name
		end

		cwSpawnPoints.spawnPoints[name] = cwSpawnPoints.spawnPoints[name] or {}
		cwSpawnPoints.spawnPoints[name][#cwSpawnPoints.spawnPoints[name] + 1] = { position = player:GetEyeTraceNoCursor().HitPos, rotate = rotate }
		cwSpawnPoints:SaveSpawnPoints()

		cw.player:Notify(player, L("SpawnPoints_Added", name))
	elseif (string.lower(arguments[1]) == "default") then
		cwSpawnPoints.spawnPoints["default"] = cwSpawnPoints.spawnPoints["default"] or {}
		cwSpawnPoints.spawnPoints["default"][#cwSpawnPoints.spawnPoints["default"] + 1] = { position = player:GetEyeTraceNoCursor().HitPos, rotate = rotate }
		cwSpawnPoints:SaveSpawnPoints()

		cw.player:Notify(player, L("SpawnPoints_AddedDefault"))
	else
		cw.player:Notify(player, L("SpawnPoints_NotValidClassOrFaction"))
	end
end

COMMAND:Register()
