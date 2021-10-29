--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyRemoveSeverWhitelist")
COMMAND.tip = "#Command_Plyremoveseverwhitelist_Description"
COMMAND.text = "#Command_Plyremoveseverwhitelist_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local identity = string.lower(arguments[2])

	if (target) then
		if (target:GetData("serverwhitelist")) then
			if (!target:GetData("serverwhitelist")[identity]) then
				cw.player:Notify(player, target:Name().." is not on the '"..identity.."' server whitelist!")

				return
			else
				target:GetData("serverwhitelist")[identity] = nil
			end
		end

		cw.player:SaveCharacter(target)

		cw.player:NotifyAll(player:Name().." has removed "..target:Name().." from the '"..identity.."' server whitelist.")
	else
		cw.player:Notify(player, arguments[1].." is not a valid character!")
	end
end

COMMAND:Register();
