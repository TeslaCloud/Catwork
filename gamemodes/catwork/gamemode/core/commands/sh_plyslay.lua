--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlySlay")

COMMAND.tip = "#Command_Plyslay_Description"
COMMAND.text = "#Command_Plyslay_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.access = "o"
COMMAND.alias = {"Slay", "Kill", "PlyKill"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local isSilent = cw.core:ToBool(arguments[2])

	if (target) then
		target:Kill()

		if (!isSilent) then
			cw.player:Notify(target:Name().." was slain by "..player:Name()..".")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid target!")
	end
end

COMMAND:Register()
