--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("It")
COMMAND.tip = "#Command_It_Description"
COMMAND.text = "#Command_It_Syntax"
COMMAND.arguments = 1
COMMAND.cooldown = 3

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ")

	if (string.utf8len(text) < 8) then
		cw.player:Notify(player, L(player, "NotEnoughText"))

		return
	end

	chatbox.AddText(nil, text, {position = player:GetPos(), textColor = Color("#3599D2"), filter = "player_events", icon = false})
end

COMMAND:Register()
