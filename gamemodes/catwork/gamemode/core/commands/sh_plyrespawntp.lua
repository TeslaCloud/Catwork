--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyRespawnTP")
COMMAND.tip = "#Command_Plyrespawntp_Description"
COMMAND.text = "#Command_Plyrespawntp_Syntax"
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.access = "o"
COMMAND.alias = {"PlyRTP", "RespawnTP"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local isSilent = cw.core:ToBool(arguments[2])
	local trace = player:GetEyeTraceNoCursor()

	if (target) then
		cw.player:LightSpawn(target, true, true, true)
		cw.player:SetSafePosition(target, trace.HitPos)
		cw.player:Notify(player, target:GetName().." was respawned and teleported to your target position.")
	else
		cw.player:Notify(player, arguments[2].." is not a valid target!")
	end
end

COMMAND:Register();
