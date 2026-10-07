--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("ObjectPhysDesc")
COMMAND.tip = "#Command_Objectphysdesc_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity

	if (IsValid(target)) then
		if (target:GetPos():Distance(player:GetShootPos()) <= 192) then
			if (cw.entity:IsPhysicsEntity(target)) then
				if (player:QueryCharacter("key") == target:GetOwnerKey()) then
					player.objectPhysDesc = target

					netstream.Start(player, "ObjectPhysDesc", target)
				else
					cw.player:Notify(player, L("Err_NotEntityOwner"))
				end
			else
				cw.player:Notify(player, L("Err_NotPhysicsEntity"))
			end
		else
			cw.player:Notify(player, L("Err_EntityTooFar"))
		end
	else
		cw.player:Notify(player, L("Err_MustLookAtEntity"))
	end
end

COMMAND:Register()
