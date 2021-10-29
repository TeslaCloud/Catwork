--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharCheckAtts")
COMMAND.tip = "#Command_Charcheckatts_Description"
COMMAND.text = "#Command_Charcheckatts_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 1
COMMAND.alias = {"CheckAtts"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		cw.player:Notify(player, "Навыки "..target:GetName()..":")
		for k, v in pairs(cw.attribute:GetAll()) do
			cw.player:Notify(player, v.name..": "..cw.attributes:Get(target, k, nil, true))
		end
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
