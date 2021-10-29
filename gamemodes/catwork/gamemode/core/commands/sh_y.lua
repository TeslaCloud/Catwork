--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Y")
COMMAND.tip = "#Commands_YDesc"
COMMAND.text = "#Command_Y_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE)
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ")

	if string.Left(text, 2) == "y " then
		text = string.gsub(text, "y ", "", 1)
	end

	if (text == "") then
		cw.player:Notify(player, L(player, "NotEnoughText"))

		return
	end

	chatbox.AddText(nil, "\""..text.."\"", {suffix = " #Suffix_Yell ", sender = player, isPlayerMessage = true, filter = "ic", radius = talkRadius, textColor = Color(255, 255, 180, 255), data = {sizeMultiplier = 1.15}})
end

COMMAND:Register();
