--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharFallOver")
COMMAND.tip = "#Command_Charfallover_Description"
COMMAND.text = "#Command_Charfallover_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.optionalArguments = 1
COMMAND.alias = {"Fallover"}
COMMAND.cooldown = 5

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime()

	if (!player.cwNextFallTime or curTime >= player.cwNextFallTime) then
		player.cwNextFallTime = curTime + 5

		if (!player:InVehicle() and !cw.player:IsNoClipping(player)) then
			local seconds = tonumber(arguments[1])

			if (seconds) then
				seconds = math.Clamp(seconds, 2, 30)
			elseif (seconds == 0) then
				seconds = nil
			end

			if (!player:IsRagdolled()) then
				cw.player:SetRagdollState(player, RAGDOLL_FALLENOVER, seconds)

				player:SetDTBool(BOOL_FALLENOVER, true)
			end
		else
			cw.player:Notify(player, "You cannot do this action at the moment!")
		end
	end
end

COMMAND:Register();
