--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("StorageTakeItem")
COMMAND.tip = "#Command_Storagetakeitem_Description"
COMMAND.text = "#Command_Storagetakeitem_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2
COMMAND.cooldown = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable()
	local uniqueID = arguments[1]
	local itemID = tonumber(arguments[2])

	if (storageTable and (!storageTable.entity or IsValid(storageTable.entity))) then
		local itemTable = cw.inventory:FindItemByID(
			storageTable.inventory, uniqueID, itemID
		)

		if (!itemTable) then
			cw.player:Notify(player, L("StorageNoInstance"))
			return
		end

		cw.storage:TakeFrom(player, itemTable)
	else
		cw.player:Notify(player, L("StorageNotOpen"))
	end
end

COMMAND:Register();
