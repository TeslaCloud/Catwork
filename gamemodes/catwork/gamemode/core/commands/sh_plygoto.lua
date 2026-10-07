--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyGoTo")
COMMAND.tip = "#Command_Plygoto_Description"
COMMAND.text = "#Command_Plygoto_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = { "GoTo" }

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		cw.player:SetSafePosition(player, target:GetPos())
		cw.player:NotifyAll(L("Command_Plygoto_Gone", player:Name(), target:Name()))
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()
