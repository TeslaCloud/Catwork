--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = cw.command:New("EmplacementAdd")
COMMAND.tip = "Add an emplacement gun at your target position."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	if (!trace.Hit) then return end

	local shouldDissolve = cw.core:ToBool(arguments[1])

	local emplacementGun = ents.Create("cw_emplacementgun")
	local entity = emplacementGun:SpawnFunction(player, trace)
	emplacementGun:Remove()

	if (IsValid(entity)) then
		cw.player:Notify(player, "You have added an emplacement gun.")
	end
end

COMMAND:Register();