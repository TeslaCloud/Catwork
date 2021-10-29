--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyDemote")
COMMAND.tip = "#Command_Plydemote_Description"
COMMAND.text = "#Command_Plydemote_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 1
COMMAND.alias = {"Demote"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		if (!cw.player:IsProtected(target)) then
			local userGroup = target:GetClockworkUserGroup()

			if (userGroup != "user") then
				cw.player:NotifyAll(player:Name().." has demoted "..target:Name().." from "..userGroup.." to user.")
					target:SetClockworkUserGroup("user")
				cw.player:LightSpawn(target, true, true)
			else
				cw.player:Notify(player, "This player is only a user and cannot be demoted!")
			end
		else
			cw.player:Notify(player, target:Name().." is protected!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
