--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Event")
COMMAND.tip = "#Command_Event_Description"
COMMAND.text = "#Command_Event_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "z"
COMMAND.arguments = 1
COMMAND.alias = {"E"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ")

	if string.Left(text, 6) == "event " then
		text = string.gsub(text, "event ", "", 1)
	end

	chatbox.AddText(nil, "** "..text, {filter = "events", textColor = Color("#FFAB00"), icon = false})
end

COMMAND:Register();
