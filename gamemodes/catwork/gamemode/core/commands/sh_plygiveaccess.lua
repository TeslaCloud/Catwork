--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyGiveAccess")
COMMAND.tip = "#Command_Plygiveaccess_Description"
COMMAND.text = "#Command_Plygiveaccess_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 2
COMMAND.alias = {"GiveAccess"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local permission = string.lower(arguments[2])

	if (IsValid(target)) then
		if (isstring(permission) and permission != "") then
			local commandTable = cw.command:FindByAlias(permission)

			if (commandTable) then
				target:GivePermission(commandTable.uniqueID)

				cw.player:Notify(player, "You have granted "..target:Name().." access to "..commandTable.name..".")
				cw.player:Notify(target, player:Name().." has granted you access to "..commandTable.name..".")
			else
				cw.player:Notify(player, arguments[2].." is not a valid command or alias!")
			end
		else
			cw.player:Notify(player, "You must enter permission's name!")
		end
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
