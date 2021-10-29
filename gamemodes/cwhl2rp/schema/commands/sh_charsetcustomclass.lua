--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharSetCustomClass")
COMMAND.tip = "#Command_Charsetcustomclass_Description"
COMMAND.text = "#Command_Charsetcustomclass_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		target:SetCharacterData("customclass", arguments[2])

		cw.player:NotifyAll(player:Name().." set "..target:Name().."'s custom class to "..arguments[2]..".")
	else
		cw.player:Notify(player, arguments[1].." is not a valid character!")
	end
end

COMMAND:Register();
