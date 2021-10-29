--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlySetHealth")
COMMAND.tip = "#Command_Plysethealth_Description"
COMMAND.text = "#Command_Plysethealth_Syntax"
COMMAND.arguments = 2
COMMAND.access = "o"
COMMAND.alias = {"PlyHealth", "Health", "SetHealth"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local health = tonumber(arguments[2])

	if (isnumber(health)) then
		target:SetHealth(health)
		cw.player:Notify(player, target:GetName().."'s health set to "..health..".")
		cw.player:Notify(target, "Your health was set to "..health.." by "..player:GetName()..".")
	end
end

COMMAND:Register();
