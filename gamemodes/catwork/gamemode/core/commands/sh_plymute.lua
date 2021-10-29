--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyMute")
COMMAND.tip = "#Command_Plymute_Description"
COMMAND.text = "#Command_Plymute_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.alias = {"Mute"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local duration = tonumber(arguments[2])

	if (target) then
		if (!cw.player:IsProtected(arguments[1])) then
			local curTime = CurTime()
			local seconds = duration * 60

			target.cwNextTalkOOC = curTime + seconds
			target.cwNextTalkLOOC = curTime + seconds

			cw.player:NotifyAll(player:Name().." has disabled '"..target:Name().."' OOC chat for "..duration.." minutes.")
		else
			cw.player:Notify(player, target:Name().." is protected!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
