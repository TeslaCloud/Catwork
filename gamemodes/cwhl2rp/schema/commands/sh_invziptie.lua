--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("InvZipTie")
COMMAND.tip = "#Command_Invziptie_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local itemTable = player:FindItemByID("zip_tie")

	if (!itemTable) then
		cw.player:Notify(player, "You do not own a zip tie!")

		return
	end

	cw.player:RunClockworkCommand(player, "InvAction", "use", itemTable.uniqueID, tostring(itemTable.itemID))
end

COMMAND:Register();
