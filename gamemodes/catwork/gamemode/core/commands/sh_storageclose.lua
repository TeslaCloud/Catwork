--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("StorageClose")
COMMAND.tip = "#Command_Storageclose_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable()

	if (storageTable) then
		cw.storage:Close(player, true)
	else
		cw.player:Notify(player, L("StorageNotOpen"))
	end
end

COMMAND:Register();
