--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local NAME_CASH = cw.option:GetKey("name_cash")

local COMMAND = cw.command:New("StorageTakeCash")
COMMAND.tip = "#Command_Storagetakecash_Description"
COMMAND.text = "#Command_Storagetakecash_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.cooldown = 5

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable()

	if (storageTable) then
		local target = storageTable.entity
		local cash = math.floor(tonumber(arguments[1]))

		if ((target and !IsValid(target)) or !config.GetVal("cash_enabled")) then
			return
		end

		if (cash and cash > 1 and cash <= storageTable.cash) then
			if (!storageTable.CanTakeCash
			or (storageTable.CanTakeCash(player, storageTable, cash) != false)) then
				if (!target or !target:IsPlayer()) then
					cw.player:GiveCash(player, cash, nil, true)
					cw.storage:UpdateCash(player, storageTable.cash - cash)
				else
					cw.player:GiveCash(player, cash, nil, true)
					cw.player:GiveCash(target, -cash, nil, true)
					cw.storage:UpdateCash(player, target:GetCash())
				end

				if (storageTable.OnTakeCash
				and storageTable.OnTakeCash(player, storageTable, cash)) then
					cw.storage:Close(player)
				end
			end
		end
	else
		cw.player:Notify(player, L("StorageNotOpen"))
	end
end

COMMAND:Register();
