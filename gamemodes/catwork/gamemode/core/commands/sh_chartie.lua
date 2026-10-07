--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharTie")
COMMAND.tip = "#Command_Chartie_Description"
COMMAND.text = "#Command_Chartie_Syntax"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.alias = { "Tie" }

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (!cw.command:FindByID("InvZipTie")) then
		player:Notify(L("Command_Chartie_NotSupported"))
		return
	end

	if (target) then
		if (target:GetNetVar("tied") != 0) then
			Schema:TiePlayer(target, false)
			player:Notify(L("Command_Chartie_Untied", target:GetName()))
			target:Notify(L("Command_Chartie_UntiedBy", player:GetName()))
		else
			Schema:TiePlayer(target, true)
			player:Notify(L("Command_Chartie_Tied", target:GetName()))
			target:Notify(L("Command_Chartie_TiedBy", player:GetName()))
		end
	else
		player:Notify(L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()
