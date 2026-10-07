--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyMute")
COMMAND.tip = "#Command_Plymute_Description"
COMMAND.text = "#Command_Plymute_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.alias = { "Mute" }

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local duration = tonumber(arguments[2])

	if (target) then
		if (!cw.player:IsProtected(arguments[1])) then
			local curTime = CurTime()
			local seconds = duration * 60

			target.cwNextTalkOOC = curTime + seconds
			target.cwNextTalkLOOC = curTime + seconds

			cw.player:NotifyAll(L("Command_Plymute_Muted", player:Name(), target:Name(), duration))
		else
			cw.player:Notify(player, L("Command_PlayerProtected", target:Name()))
		end
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()
