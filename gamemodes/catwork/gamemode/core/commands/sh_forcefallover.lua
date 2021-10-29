--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("ForceFallOver")
COMMAND.tip = "#Command_Forcefallover_Description"
COMMAND.text = "#Command_Forcefallover_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.access = "o"
COMMAND.alias = {"ForceCharFallover"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		local seconds = tonumber(arguments[2])

		if (seconds) then
			seconds = math.Clamp(seconds, 2, 30)
		elseif (seconds == 0) then
			seconds = nil
		end

		if (!target:IsRagdolled()) then
			cw.player:SetRagdollState(target, RAGDOLL_FALLENOVER, seconds)

			target:SetDTBool(BOOL_FALLENOVER, true)
		end
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
