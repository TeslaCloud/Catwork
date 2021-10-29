--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("CharSetBodyGroup")
COMMAND.tip = "Sets player's bodygroup."
COMMAND.text = "<string Player> <number BodyGroup> [number BodyGroup Value]"
COMMAND.access = "a"
COMMAND.arguments = 2
COMMAND.alias = {"SetBodyGroup", "CharBodyGroup"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local bg = tonumber(arguments[2])
	local val = tonumber(arguments[3] or 0)

	if (bg != nil and val != nil) then
		if (IsValid(target)) then
			target:SetBodygroup(bg, val)

			local bodyGroups = target:GetCharacterData("CustomBodyGroup", {})
			bodyGroups[bg] = val

			target:SetCharacterData("CustomBodyGroup", bodyGroups)
		end
	end
end

COMMAND:Register();