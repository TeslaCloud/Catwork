--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharBan")
COMMAND.tip = "#Command_Charban_Description"
COMMAND.text = "#Command_Charban_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o8"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(table.concat(arguments, " "))

	if (target) then
		if (!cw.player:IsProtected(target)) then
			cw.player:SetBanned(target, true)
			cw.player:NotifyAll(player:Name().." banned the character '"..target:Name().."'.")

			target:KillSilent()
		else
			cw.player:Notify(player, target:Name().." is protected!")
		end
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
