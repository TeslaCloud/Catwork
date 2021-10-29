--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DropWeapon")
COMMAND.tip = "#Command_Dropweapon_Description"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.alias = {"Drop"}
COMMAND.cooldown = 5

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local weapon = player:GetActiveWeapon()

	if (IsValid(weapon)) then
		local class = weapon:GetClass()
		local itemTable = item.GetByWeapon(weapon)

		if (!itemTable) then
			cw.player:Notify(player, "This is not a valid weapon!")
			return
		end

		if (hook.Run("PlayerCanDropWeapon", player, itemTable, weapon)) then
			local trace = player:GetEyeTraceNoCursor()

			if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
				local entity = cw.entity:CreateItem(player, itemTable, trace.HitPos)

				if (IsValid(entity)) then
					cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
						player:TakeItem(itemTable, true)
						player:StripWeapon(class)
						player:SelectWeapon("cw_hands")
					hook.Run("PlayerDropWeapon", player, itemTable, entity, weapon)
				end
			else
				cw.player:Notify(player, "You cannot drop your weapon that far away!")
			end
		end
	else
		cw.player:Notify(player, "This is not a valid weapon!")
	end
end

COMMAND:Register();
