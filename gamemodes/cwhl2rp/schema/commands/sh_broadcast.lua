--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Broadcast")
COMMAND.tip = "#Command_Broadcast_Description"
COMMAND.text = "#Command_Broadcast_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:GetFaction() == FACTION_ADMIN) then
		local text = table.concat(arguments, " ")

		if (text == "") then
			cw.player:Notify(player, "You did not specify enough text!")

			return
		end

		Schema:SayBroadcast(player, text)
	else
		cw.player:Notify(player, "You are not an Administrator!")
	end
end

COMMAND:Register();
