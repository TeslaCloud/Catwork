--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("DoorResetPlayer")
COMMAND.tip = "Removes currently assigned player from the door."
COMMAND.text = "<string Door Title>"
COMMAND.access = "D"
COMMAND.arguments = 1
COMMAND.alias = {"DoorRemovePlayer"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity
	local doorName = arguments[1]

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		cwPermaDoors:ResetPermaDoor(door, doorName)

		cw.player:Notify(player, "This door's owner has been removed.")
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();