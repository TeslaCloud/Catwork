--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorUnlock")
COMMAND.tip = "Unlock a door."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		door:EmitSound("doors/door_latch3.wav")
		door:Fire("unlock", "", 0)

		cw.player:Notify(player, "You have unlocked the target door.")
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();
