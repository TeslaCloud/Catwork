--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyKick")
COMMAND.tip = "#Command_Plykick_Description"
COMMAND.text = "#Command_Plykick_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.alias = {"Kick"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local reason = table.concat(arguments, " ", 2)

	if (!reason or reason == "") then
		reason = "N/A"
	end

	if (target) then
		if (!cw.player:IsProtected(arguments[1])) then
			cw.player:NotifyAll(player:Name().." has kicked '"..target:Name().."' ("..reason..").")
				target:Kick(reason)
			target.kicked = true
		else
			cw.player:Notify(player, target:Name().." is protected!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
