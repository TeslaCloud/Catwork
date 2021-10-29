--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharCheckFlags")
COMMAND.tip = "#Command_Charcheckflags_Description"
COMMAND.text = "#Command_Charcheckflags_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 1
COMMAND.alias = {"CheckFlags"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		cw.player:Notify(player, "This player has "..target:GetFlags().." flags.")
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
