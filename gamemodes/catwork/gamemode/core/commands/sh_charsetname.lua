--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharSetName")
COMMAND.tip = "#Command_Charsetname_Description"
COMMAND.text = "#Command_Charsetname_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.alias = {"SetName"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		local name = table.concat(arguments, " ", 2)

		cw.player:NotifyAll(player:Name().." set "..target:Name().."'s name to "..name..".")

		cw.player:SetName(target, name)
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register()
