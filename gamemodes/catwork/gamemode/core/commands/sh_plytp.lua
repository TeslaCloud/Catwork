--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyTeleport")
COMMAND.tip = "#Command_Plytp_Description"
COMMAND.text = "#Command_Plytp_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = { "PlyTP", "TP" }

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		cw.player:SetSafePosition(target, player:GetEyeTraceNoCursor().HitPos)
		cw.player:NotifyAll(L("Command_Plytp_Teleported", player:Name(), target:Name()))
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()
