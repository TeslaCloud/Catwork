--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("ViewObjectives")
COMMAND.tip = "#Command_Viewobjectives_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:IsCombine()) then
		netstream.Start(player, "EditObjectives", Schema.combineObjectives)

		player.editObjectivesAuthorised = true
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end

COMMAND:Register();
