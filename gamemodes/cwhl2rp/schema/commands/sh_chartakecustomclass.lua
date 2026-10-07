--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharTakeCustomClass")
COMMAND.tip = "#Command_Chartakecustomclass_Description"
COMMAND.text = "#Command_Chartakecustomclass_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		target:SetCharacterData("customclass", nil)

		cw.player:NotifyAll(L("CustomClass_Taken", player:Name(), target:Name()))
	else
		cw.player:Notify(player, L("NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register()
