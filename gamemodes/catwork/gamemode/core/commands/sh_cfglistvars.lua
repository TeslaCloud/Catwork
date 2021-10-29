--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CfgListVars")
COMMAND.tip = "#Command_Cfglistvars_Description"
COMMAND.text = "#Command_Cfglistvars_Syntax"
COMMAND.access = "s"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local searchData = arguments[1] or ""
		netstream.Start(player, "CfgListVars", searchData)
	cw.player:Notify(player, L(player, "ConfigVariablesPrinted"))
end

COMMAND:Register()
