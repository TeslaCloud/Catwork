--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("CharResetCustomSpawn")
COMMAND.tip = "Removes player's custom spawn point."
COMMAND.text = "<string Player>"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.alias = {"ResetCustomSpawn", "RemoveCustomSpawn", "CustomSpawnRemove", "CustomSpawnReset"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		target:SetCharacterData("CustomSpawn", nil)

		cw.player:Notify(player, target:Name().."'s custom spawn point has been removed.")
	else
		cw.player:Notify(player, "'"..tostring(arguments[1]).."' is not a valid player!")
	end
end

COMMAND:Register();