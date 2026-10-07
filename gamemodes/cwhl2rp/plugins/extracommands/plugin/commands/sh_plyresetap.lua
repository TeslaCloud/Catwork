--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("PlyResetArmor")
COMMAND.tip = "#Command_Plyresetarmor_Description"
COMMAND.text = "#Command_Plyresetarmor_Syntax"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.alias = {"ResetAP", "ResetArmor", "PlyResetAP"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		target:SetArmor(100)

		cw.player:Notify(player, L("ExtraCommands_ArmorReset", target:Name()))
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register();