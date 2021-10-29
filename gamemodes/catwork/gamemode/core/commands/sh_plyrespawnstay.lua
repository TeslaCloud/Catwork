--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyRespawnStay")
COMMAND.tip = "#Command_Plyrespawnstay_Description"
COMMAND.text = "#Command_Plyrespawnstay_Syntax"
COMMAND.arguments = 1
COMMAND.access = "o"
COMMAND.alias = {"PlyRStay", "RespawnStay"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		--cw.player:LightSpawn(target, true, true, false)
		local pos = target:GetPos()
		target:Spawn()
		target:SetPos(pos)
		cw.player:Notify(player, target:GetName().." was respawned at their position of death.")
	else
		cw.player:Notify(player, arguments[1].." is not a valid target!")
	end
end

COMMAND:Register();
