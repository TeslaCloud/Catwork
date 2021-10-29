--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("A")
COMMAND.tip = "#Command_A_Description"
COMMAND.text = "#Command_A_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = {"AD", "OP"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local listeners = {}

	for k, v in ipairs(_player.GetAll()) do
		if (v:IsUserGroup("operator") or v:IsAdmin()
		or v:IsSuperAdmin()) then
			listeners[#listeners + 1] = v
		end
	end

	chatbox.AddText(listeners, table.concat(arguments, " "), {filter = "admin", sender = player})
end

COMMAND:Register()
