--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("Overwatch")
COMMAND.tip = "Sends a message to all civil protection units."
COMMAND.text = "<string Message>"
COMMAND.access = "s"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local message = tostring(table.concat(arguments, " "))

	if (isstring(message) and string.len(message) >= 6) then
		local listeners = {}

		for k, v in ipairs(_player.GetAll()) do
			if (Schema:PlayerIsCombine(v)) then
				table.insert(listeners, v)
			end
		end

		chatbox.AddText(listeners, message, {
			suffix = " сообщает: ",
			playerName = "Надзор",
			sender = player,
			isPlayerMessage = true,
			filter = "ic",
			radius = 0,
			textColor = Color(10, 200, 10, 255),
			forceName = true,
			data = {overwatch = true}
		})
	else
		cw.player:Notify(player, "Your message must be 6 or more letters long!")
	end
end

COMMAND:Register();