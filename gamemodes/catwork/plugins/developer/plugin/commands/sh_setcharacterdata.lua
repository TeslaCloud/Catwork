--[[
	© 2017 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("SetCharData")
COMMAND.tip = "Sets player's character data."
COMMAND.text = "<string Player> <string key> <any value>"
COMMAND.access = "s"
COMMAND.arguments = 2
COMMAND.alias = {"CharSetData", "SetCharacterData"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local key = arguments[2] or ""
	local val = arguments[3] or ""

	if (catDev and catDev:IsDeveloper(player)) then
		if (IsValid(target)) then
			if (isstring(key) and key != "") then
				local existingData = target:GetCharacterData(key)

				if (existingData) then
					local dataType = type(existingData)

					if (dataType == "string") then
						val = tostring(val)
					elseif (dataType == "number") then
						val = tonumber(val)
					elseif (dataType == "table") then
						cw.player:Notify(player, "Cannot set table values!")

						return
					elseif (IsValid(existingData)) then
						cw.player:Notify(player, "Cannot set UserData values!")

						return
					end

					cw.player:Notify(player, "You have modified a char data key '"..key.."', value: "..tostring(val).." ("..type(val).."). The original data type was: "..dataType)
				else
					cw.player:Notify(player, "You have created a new char data key '"..key.."', value: "..tostring(val).." ("..type(val)..")")
				end

				target:SetCharacterData(key, val)
			else
				cw.player:Notify(player, "The key must be a valid string value!")
			end
		else
			cw.player:Notify(player, arguments[1].." is not a valid target!")
		end
	else
		cw.player:Notify(player, "You are not authorized to use this command!")
	end
end

COMMAND:Register();