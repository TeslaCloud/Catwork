--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlySetGroup")
COMMAND.tip = "#Command_Plysetgroup_Description"
COMMAND.text = "#Command_Plysetgroup_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 2
COMMAND.alias = {"SetGroup"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local userGroup = arguments[2]

	if (userGroup != "superadmin" and userGroup != "admin"
	and userGroup != "operator") then
		cw.player:Notify(player, "The user group must be superadmin, admin or operator!")

		return
	end

	if (target) then
		if (!cw.player:IsProtected(target)) then
			cw.player:NotifyAll(player:Name().." has set "..target:Name().."'s user group to "..userGroup..".")
				target:SetClockworkUserGroup(userGroup)
			cw.player:LightSpawn(target, true, true)
		else
			cw.player:Notify(player, target:Name().." is protected!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
