--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharGetUp")
COMMAND.tip = "#Command_Chargetup_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:GetRagdollState() == RAGDOLL_FALLENOVER and player:GetDTBool(BOOL_FALLENOVER) and cw.player:GetAction(player) != "unragdoll") then
		if (hook.Run("PlayerCanGetUp", player)) then
			cw.player:SetUnragdollTime(player, 5)
			player:SetDTBool(BOOL_FALLENOVER, false)
		end
	end
end

COMMAND:Register();
