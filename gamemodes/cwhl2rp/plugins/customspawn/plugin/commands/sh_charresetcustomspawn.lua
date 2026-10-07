--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("CharResetCustomSpawn")
COMMAND.tip = "#Command_Charresetcustomspawn_Description"
COMMAND.text = "#Command_Charresetcustomspawn_Syntax"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.alias = {"ResetCustomSpawn", "RemoveCustomSpawn", "CustomSpawnRemove", "CustomSpawnReset"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		target:SetCharacterData("CustomSpawn", nil)

		cw.player:Notify(player, L("CustomSpawn_Removed", target:Name()))
	else
		cw.player:Notify(player, L("NotValidPlayer", tostring(arguments[1])))
	end
end

COMMAND:Register();