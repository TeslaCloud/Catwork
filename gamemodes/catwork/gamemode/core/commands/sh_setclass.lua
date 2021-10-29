--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("SetClass")
COMMAND.tip = "#Command_Setclass_Description"
COMMAND.text = "#Command_Setclass_Syntax"
COMMAND.flags = CMD_HEAVY
COMMAND.arguments = 1
COMMAND.alias = {"CharSetClass", "ChangeClass"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local class = cw.class:FindByID(arguments[2])
	local target = _player.Find(arguments[1])

	if (target:InVehicle()) then
		cw.player:Notify(player, L("CannotActionRightNow"))
		return
	end

	if (class) then
		local limit = cw.class:GetLimit(class.name)

		if (hook.Run("PlayerCanBypassClassLimit", target, class.index)) then
			limit = game.MaxPlayers()
		end

		if (_team.NumPlayers(class.index) < limit) then
			local previousTeam = target:Team()

			if (target:Team() != class.index) then
				if (hook.Run("PlayerCanChangeClass", target, class)) then
					local bSuccess, fault = cw.class:Set(target, class.index, nil, true)

					if (!bSuccess) then
						cw.player:Notify(player, fault)
					else
						cw.player:Notify(target, L("ClassSetTarget", class.name, player:Name()))
						cw.player:Notify(player, L("ClassSetPlayer", class.name, target:Name()))
					end
				end
			else
				cw.player:Notify(player, L("ClassNoAccess"))
			end
		else
			cw.player:Notify(player, L("ClassTooMany"))
		end
	else
		cw.player:Notify(player, L("ClassNotValid"))
	end
end

COMMAND:Register();
