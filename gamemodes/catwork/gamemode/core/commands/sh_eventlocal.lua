--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("EventLocal")
COMMAND.tip = "#Command_Eventlocal_Description"
COMMAND.text = "#Command_Eventlocal_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = {"LocalEvent", "EL"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ")

	if string.Left(text, 11) == "eventlocal " then
		text = string.gsub(text, "eventlocal ", "", 1)
	end

	chatbox.AddText(nil, "* "..text, {filter = "player_events", textColor = Color("#FFAB00"), icon = false, position = player:GetPos()})
end

COMMAND:Register();
