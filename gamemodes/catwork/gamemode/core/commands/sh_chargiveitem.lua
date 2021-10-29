--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local amountTable = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"}

local COMMAND = cw.command:New("CharGiveItem")
COMMAND.tip = "#Command_Chargiveitem_Description"
COMMAND.text = "#Command_Chargiveitem_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.alias = {"PlyGiveItem", "GiveItem"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (cw.player:HasFlags(player, "G")) then
		local target = _player.Find(arguments[1])
		local amount = tonumber(arguments[3]) or 1

		if (target) then
			if (amount > 0 and amount <= 10) then
				local itemTable = item.FindByID(arguments[2])

				if (itemTable and !itemTable.isBaseItem) then
					for i = 1, amount do
						local itemTable = item.CreateInstance(itemTable.uniqueID)
						local bSuccess, fault = target:GiveItem(itemTable, true)

						if (!bSuccess) then
							cw.player:Notify(player, fault)

							break
						end
					end

					if (string.utf8sub(itemTable.name, -1) == "s" and amount == 1) then
						cw.player:Notify(player, "Вы выдали "..target:Name().." "..itemTable.PrintName..".")
					elseif (amount > 1) then
						cw.player:Notify(player, "Вы выдали "..target:Name().." "..amountTable[amount].." х "..itemTable.PrintName..".")
					else
						cw.player:Notify(player, "Вы выдали "..target:Name().." "..itemTable.PrintName..".")
					end

					if (player != target) then
						if (string.utf8sub(itemTable.name, -1) == "s" and amount == 1) then
							cw.player:Notify(target, player:Name().." выдал Вам "..itemTable.PrintName..".")
						elseif (amount > 1) then
							cw.player:Notify(target, player:Name().." выдал Вам "..amountTable[amount].." х "..itemTable.PrintName..".")
						else
							cw.player:Notify(target, player:Name().." выдал Вам "..itemTable.PrintName..".")
						end
					end
				else
					cw.player:Notify(player, "Предмет недействителен!")
				end
			else
				cw.player:Notify(player, "Вы должны ввести число в диапазоне 1-10!")
			end
		else
			cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
		end
	else
		cw.player:Notify(player, "У Вас нет доступа к этй команде!")
	end
end

COMMAND:Register();
