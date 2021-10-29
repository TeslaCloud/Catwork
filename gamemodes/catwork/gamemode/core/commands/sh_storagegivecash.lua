--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("StorageGiveCash")
COMMAND.tip = "#Command_Storagegivecash_Description"
COMMAND.text = "#Command_Storagegivecash_Syntax"
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

		if (cash and cash > 1 and cw.player:CanAfford(player, cash)) then
			if (!storageTable.CanGiveCash
			or (storageTable.CanGiveCash(player, storageTable, cash) != false)) then
				if (!target or !target:IsPlayer()) then
					local cashWeight = config.GetVal("cash_weight")
					local myWeight = cw.storage:GetWeight(player)

					local cashSpace = config.GetVal("cash_space")
					local mySpace = cw.storage:GetSpace(player)

					if (cw.storage:GetWeight(player) + (config.GetVal("cash_weight") * cash) <= storageTable.weight and mySpace + (cashSpace * cash) <= storageTable.space) then
						cw.player:GiveCash(player, -cash, nil, true)
						cw.storage:UpdateCash(player, storageTable.cash + cash)
					end
				else
					cw.player:GiveCash(player, -cash, nil, true)
					cw.player:GiveCash(target, cash, nil, true)
					cw.storage:UpdateCash(player, target:GetCash())
				end

				if (storageTable.OnGiveCash
				and storageTable.OnGiveCash(player, storageTable, cash)) then
					cw.storage:Close(player)
				end
			end
		end
	else
		cw.player:Notify(player, L("StorageNotOpen"))
	end
end

COMMAND:Register();
