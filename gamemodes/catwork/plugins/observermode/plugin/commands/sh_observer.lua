--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Observer")
COMMAND.tip = "Enter or exit observer mode."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:Alive() and !player:IsRagdolled() and !player.cwObserverReset) then
		if (player:GetMoveType(player) == MOVETYPE_NOCLIP) then
			cwObserverMode:MakePlayerExitObserverMode(player)
		else
			cwObserverMode:MakePlayerEnterObserverMode(player)
		end
	end
end

COMMAND:Register();
