--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("CharSetAttribute")
COMMAND.tip = "Sets attribute's value for a character."
COMMAND.text = "<string Player> <string Attribute> <number Amount>"
COMMAND.access = "s"
COMMAND.arguments = 3
COMMAND.alias = {"SetAttribute"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local rawAttribute = string.utf8lower(arguments[2])
	local attribute = cw.attribute:FindByID(rawAttribute)
	local amt = tonumber(arguments[3]) or 0

	if (IsValid(target)) then
		if (attribute) then
			cw.attributes:Update(target, attribute.uniqueID, amt)

			cw.player:Notify(player, "You have set "..target:Name().."'s "..(attribute.name or "Unknown").." ["..attribute.uniqueID.."] attribute to "..tostring(amt)..".")
		else
			cw.player:Notify(player, arguments[2].." is not a valid attribute!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid target!")
	end
end

COMMAND:Register();