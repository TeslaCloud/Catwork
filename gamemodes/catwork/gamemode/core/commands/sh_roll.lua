--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Roll")
COMMAND.tip = "#Commands_RollDesc"
COMMAND.text = "#Command_Roll_Syntax"
COMMAND.cooldown = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local number = math.Clamp(math.floor(tonumber(arguments[1]) or 100), 0, 1000000000)
	local roll = math.random(0, number)
	local target = player:GetEyeTraceNoCursor().Entity
	local PVPMode = false

	if (IsValid(target) and typeof(target) == "player") then
		PVPMode = true
	end

	local adjust, adjust2 = hook.Run("AdjustRollNumber", player, roll, number, (PVPMode and target) or nil)
	adjust = adjust or 0
	adjust2 = adjust2 or 0

	roll = math.Clamp(roll + adjust, 0, number)
	roll = math.floor(roll)

	if (PVPMode) then
		chatbox.AddText(nil, "* PVP:", {filter = "player_events", textColor = Color("#EE7542"), icon = false, position = player:GetPos()})

		chatbox.AddText(nil, L(player, "HasRolled", player:Name(), roll, number), {textColor = Color("#EE7542"), filter = "player_events", icon = "icon16/lightning.png", position = player:GetPos()})
		cw.core:PrintLog(LOGTYPE_GENERIC, player:Name().." has rolled "..roll.." ("..roll - adjust.." + "..adjust..")".." out of "..number)

		local roll2 = math.random(0, number)
		roll2 = math.Clamp(roll2 + adjust2, 0, number)
		roll2 = math.floor(roll2)

		chatbox.AddText(nil, L(target, "HasRolled", target:Name(), roll2, number), {textColor = Color("#EE7542"), filter = "player_events", icon = "icon16/lightning.png", position = player:GetPos()})
		cw.core:PrintLog(LOGTYPE_GENERIC, target:Name().." has rolled "..roll2.." ("..roll2 - adjust2.." + "..adjust2..")".." out of "..number)
	else
		chatbox.AddText(nil, L(player, "HasRolled", player:Name(), roll, number), {textColor = Color("#EE4343"), filter = "player_events", icon = "icon16/lightning.png", position = player:GetPos()})
		cw.core:PrintLog(LOGTYPE_GENERIC, L("LogHasRolled", player:Name(), roll, number))
	end
end

COMMAND:Register();
