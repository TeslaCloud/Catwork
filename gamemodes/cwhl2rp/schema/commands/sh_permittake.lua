--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PermitTake")
COMMAND.tip = "#Command_Permittake_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:IsCombine()) then
		if (!Schema:IsPlayerCombineRank(player, "RCT")) then
			local target = player:GetEyeTraceNoCursor().Entity

			if (target and target:IsPlayer()) then
				if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
					if (target:GetFaction() == FACTION_CITIZEN) then
						for k, v in pairs(Schema.customPermits) do
							cw.player:TakeFlags(target, v)
						end

						cw.player:Notify(player, "You have taken this character's permit(s)!")
					else
						cw.player:Notify(player, "This character is not a citizen!")
					end
				else
					cw.player:Notify(player, "This character is too far away!")
				end
			else
				cw.player:Notify(player, "You must look at a character!")
			end
		else
			cw.player:Notify(player, "You are not ranked high enough for this!")
		end
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end

COMMAND:Register();
