--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

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
						cw.player:Notify(player, L("Command_Chargiveitem_Gave", target:Name(), itemTable.PrintName))
					elseif (amount > 1) then
						cw.player:Notify(player, L("Command_Chargiveitem_GaveAmount", target:Name(), amount, itemTable.PrintName))
					else
						cw.player:Notify(player, L("Command_Chargiveitem_Gave", target:Name(), itemTable.PrintName))
					end

					if (player != target) then
						if (string.utf8sub(itemTable.name, -1) == "s" and amount == 1) then
							cw.player:Notify(target, L("Command_Chargiveitem_Received", player:Name(), itemTable.PrintName))
						elseif (amount > 1) then
							cw.player:Notify(target, L("Command_Chargiveitem_ReceivedAmount", player:Name(), amount, itemTable.PrintName))
						else
							cw.player:Notify(target, L("Command_Chargiveitem_Received", player:Name(), itemTable.PrintName))
						end
					end
				else
					cw.player:Notify(player, L("GiveInvalidItem"))
				end
			else
				cw.player:Notify(player, L("Command_Chargiveitem_AmountRange"))
			end
		else
			cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
		end
	else
		cw.player:Notify(player, L("Commands_cwLua_accessDenied", player:Name()))
	end
end

COMMAND:Register();
