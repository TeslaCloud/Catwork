--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Dispatch")
COMMAND.tip = "#Command_Dispatch_Description"
COMMAND.text = "#Command_Dispatch_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:IsCombine()) then
		if (Schema:IsPlayerCombineRank(player, {"SCN", "OfC", "EpU", "DvL", "CmD", "SeC"}) or player:GetFaction() == FACTION_OTA) then
			local text = table.concat(arguments, " ")

			if (text == "") then
				cw.player:Notify(player, "You did not specify enough text!")

				return
			end

			Schema:SayDispatch(player, text)
		else
			cw.player:Notify(player, "You are not ranked high enough to use this command!")
		end
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end

COMMAND:Register();
