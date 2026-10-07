--[[
	© 2017 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("PlySetIcon")
COMMAND.tip = "#Command_Plyseticon_Description"
COMMAND.text = "#Command_Plyseticon_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 2
COMMAND.alias = {"SetIcon"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local icon = arguments[2]
	local bIsIcon = icon:lower():EndsWith(".png")

	if (IsValid(target)) then
		if (bIsIcon) then
			local path = ""

			if (icon:find("^http[s]?://")) then
				path = "catwork/icon_"..target:SteamID64()..".png"
			else
				path = icon
			end

			target:SetData("CustomIcon", {icon = icon, path = path})
			Schema:SendIconData(target, true)

			cw.player:Notify(player, L("ExtraCommands_IconSet", target:Name()).." "..icon.." ["..path.."].")
		else
			cw.player:Notify(player, arguments[2].." "..L("ExtraCommands_NotPng"))
		end
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register();