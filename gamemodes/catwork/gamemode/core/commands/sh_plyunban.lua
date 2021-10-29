--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyUnban")
COMMAND.tip = "#Command_Plyunban_Description"
COMMAND.text = "#Command_Plyunban_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = {"Unban"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playersTable = config.GetVal("mysql_players_table")
	local schemaFolder = cw.core:GetSchemaFolder()
	local identifier = string.upper(arguments[1])

	if (cw.bans.stored[identifier]) then
		cw.player:NotifyAll(player:Name().." has unbanned '"..cw.bans.stored[identifier].steamName.."'.")
		cw.bans:Remove(identifier)
	else
		cw.player:Notify(player, "There are no banned players with the '"..identifier.."' identifier!")
	end
end

COMMAND:Register();
