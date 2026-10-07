--[[
	© 2017 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("SetCharData")
COMMAND.tip = "#Command_Setchardata_Description"
COMMAND.text = "#Command_Setchardata_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 2
COMMAND.alias = { "CharSetData", "SetCharacterData" }

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
						cw.player:Notify(player, L("Developer_CannotSetTable"))

						return
					elseif (IsValid(existingData)) then
						cw.player:Notify(player, L("Developer_CannotSetUserData"))

						return
					end

					cw.player:Notify(player, L("Developer_ModifiedKey").." '"..key.."', "..L("Developer_Value").." "..tostring(val).." ("..type(val).."). "..L("Developer_OriginalType").." "..dataType)
				else
					cw.player:Notify(player, L("Developer_CreatedKey").." '"..key.."', "..L("Developer_Value").." "..tostring(val).." ("..type(val)..")")
				end

				target:SetCharacterData(key, val)
			else
				cw.player:Notify(player, L("Developer_KeyMustBeString"))
			end
		else
			cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
		end
	else
		cw.player:Notify(player, L("Developer_NotAuthorized"))
	end
end

COMMAND:Register()
