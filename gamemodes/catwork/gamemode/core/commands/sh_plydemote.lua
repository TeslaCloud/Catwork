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
				cw.player:NotifyAll(L("Command_Plydemote_Demoted", player:Name(), target:Name(), userGroup))
					target:SetClockworkUserGroup("user")
				cw.player:LightSpawn(target, true, true)
			else
				cw.player:Notify(player, L("Command_Plydemote_OnlyUser"))
			end
		else
			cw.player:Notify(player, L("Command_PlayerProtected", target:Name()))
		end
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register();
