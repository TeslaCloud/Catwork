--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Su")
COMMAND.tip = "#Command_Su_Description"
COMMAND.text = "#Command_Su_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local listeners = {}

	for k, v in ipairs(_player.GetAll()) do
		if (v:IsSuperAdmin()) then
			listeners[#listeners + 1] = v
		end
	end

	chatbox.AddText(listeners, table.concat(arguments, " "), {filter = "admin", sender = player, prefix = "* [Super Admins] "})
end

COMMAND:Register()
