--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = cw.command:New("EmplacementAdd")
COMMAND.tip = "#Command_Emplacementadd_Description"
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
		cw.player:Notify(player, L("Emplacement_Added"))
	end
end

COMMAND:Register();