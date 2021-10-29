--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("InvAction")
COMMAND.tip = "#Command_Invaction_Description"
COMMAND.text = "#Command_Invaction_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.cooldown = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local itemAction = string.lower(arguments[1])
	itemAction = itemAction:Replace("#", "")
	local itemTable = player:FindItemByID(arguments[2], tonumber(arguments[3]))

	if (itemTable) then
		local customFunctions = itemTable.customFunctions

		if (customFunctions) then
			for k, v in pairs(customFunctions) do
				if (string.lower(v) == itemAction) then
					if (itemTable.OnCustomFunction) then
						itemTable:OnCustomFunction(player, v)
						return
					end
				end
			end
		end

		if (itemAction == "destroy") then
			if (hook.Run("PlayerCanDestroyItem", player, itemTable)) then
				item.Destroy(player, itemTable)
			end
		elseif (itemAction == "drop") then
			local position = player:GetEyeTraceNoCursor().HitPos

			if (player:GetShootPos():Distance(position) <= 192) then
				if (hook.Run("PlayerCanDropItem", player, itemTable, position)) then
					item.Drop(player, itemTable)
				end
			else
				cw.player:Notify(player, "You cannot drop the item that far away!")
			end
		elseif (itemAction == "use") then
			if (player:InVehicle() and itemTable.useInVehicle == false) then
				cw.player:Notify(player, "You cannot use this item in a vehicle!")

				return
			end

			if (hook.Run("PlayerCanUseItem", player, itemTable)) then
				print("Using item: "..tostring(itemTable))

				return item.Use(player, itemTable)
			end
		else
			hook.Run("PlayerUseUnknownItemFunction", player, itemTable, itemAction)
		end
	else
		cw.player:Notify(player, "You do not own this item!")
	end
end

COMMAND:Register();
