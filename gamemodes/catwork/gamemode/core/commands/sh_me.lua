--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Me")
COMMAND.tip = "#Commands_MeDesc"
COMMAND.text = "#Command_Me_Syntax"
COMMAND.arguments = 1
COMMAND.alias = {"Perform", "me"}
COMMAND.cooldown = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = ""

	for k, v in ipairs(arguments) do
		text = text..v.." "
	end

	if string.Left(text, 3) == "me " then
		text = string.gsub(text, "me ", "", 1)
	end

	if (text == "") then
		cw.player:Notify(player, L(player, "NotEnoughText"))

		return
	end

	chatbox.AddText(nil, text, {isPlayerMessage = true, sender = player, noStyling = true, fakeName = true, position = player:GetPos(), textColor = Color("#89D235"), filter = "player_events", icon = false})
end

COMMAND:Register();
