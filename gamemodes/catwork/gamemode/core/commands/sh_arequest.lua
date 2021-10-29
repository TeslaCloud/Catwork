--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("ARequest")
COMMAND.tip = "#Command_Arequest_Description"
COMMAND.text = "#Command_Arequest_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = {"AR"}
COMMAND.cooldown = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
   if (!cw.player:IsAdmin(player)) then
	  cw.player:NotifyAdmins("o", L("#RequestFrom", player:Name(), table.concat(arguments, " ")), nil)
   else
	  cw.player:Notify(player, L"#UseA")
   end
end

COMMAND:Register()
