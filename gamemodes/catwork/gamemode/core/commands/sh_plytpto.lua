--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyTeleportTo")
COMMAND.tip = "#Command_Plytpto_Description"
COMMAND.text = "#Command_Plytpto_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.alias = {"PlyTPTo", "TPTo"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local ply = _player.Find(arguments[2])
	local isSilent = cw.core:ToBool(arguments[3])

	if (target) then
		if (ply) then
			cw.player:SetSafePosition(target, ply:GetPos())

			if (!isSilent) then
				cw.player:NotifyAll(player:Name().." has teleported "..target:Name().." to "..ply:Name()..".")
			end
		else
			cw.player:Notify(player, arguments[2].." is not a valid player!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
