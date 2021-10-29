--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("DoorSetPlayer")
COMMAND.tip = "Assigns the door to a certain player."
COMMAND.text = "<string Player> <string Door Title>"
COMMAND.access = "D"
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local doorName = arguments[2]
	local door = player:GetEyeTraceNoCursor().Entity

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		if (IsValid(target)) then
			cwPermaDoors:SetPermaDoor(target, door, doorName)

			cw.player:Notify(player, "This door was successfully assigned to "..target:Name()..".")
		else
			cw.player:Notify(player, "'"..tostring(arguments[1]).."' is not a valid player!")
		end
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();