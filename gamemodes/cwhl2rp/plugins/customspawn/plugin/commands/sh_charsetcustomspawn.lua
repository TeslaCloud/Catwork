--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("CharSetCustomSpawn")
COMMAND.tip = "Sets player's custom spawn point."
COMMAND.text = "<string Player>"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.alias = {"SetCustomSpawn", "SetCustomSpawnPoint", "CustomSpawnSet"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		local position = target:GetPos()
		local posTable = {
			map = game.GetMap(),
			x = position.x,
			y = position.y,
			z = position.z,
			angles = player:EyeAngles()
		}

		target:SetCharacterData("CustomSpawn", posTable)

		cw.player:Notify(player, target:Name().."'s custom spawn point was set to their current location.")
	else
		cw.player:Notify(player, "'"..tostring(arguments[1]).."' is not a valid player!")
	end
end

COMMAND:Register();