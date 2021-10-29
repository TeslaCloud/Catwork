--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("PlyResetArmor")
COMMAND.tip = "Resets player's armor to max amount."
COMMAND.text = "<string Player>"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.alias = {"ResetAP", "ResetArmor", "PlyResetAP"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		target:SetArmor(100)

		cw.player:Notify(player, "You have reset "..target:Name().."'s armor to 100.")
	else
		cw.player:Notify(player, arguments[1].." is not a valid target!")
	end
end

COMMAND:Register();