--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharSetModel")
COMMAND.tip = "#Command_Charsetmodel_Description"
COMMAND.text = "#Command_Charsetmodel_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.alias = {"SetModel"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		local model = table.concat(arguments, " ", 2)

		target:SetCharacterData("Model", model, true)
		target:SetModel(model)

		cw.player:NotifyAll(player:Name().." set "..target:Name().."'s model to "..model..".")
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
