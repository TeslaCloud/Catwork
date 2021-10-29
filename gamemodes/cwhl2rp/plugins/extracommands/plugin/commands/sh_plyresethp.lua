--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("PlyResetHealth")
COMMAND.tip = "Resets player's health to max amount."
COMMAND.text = "<string Player>"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.alias = {"ResetHP", "ResetHealth", "PlyResetHP"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		target:SetHealth(target:GetMaxHealth())

		cw.player:Notify(player, "You have reset "..target:Name().."'s health to "..target:GetMaxHealth()..".")
	else
		cw.player:Notify(player, arguments[1].." is not a valid target!")
	end
end

COMMAND:Register();