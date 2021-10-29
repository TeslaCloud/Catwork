--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PM")
COMMAND.tip = "#Commands_PMDesc"
COMMAND.text = "#Command_Pm_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2
COMMAND.cooldown = 5

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		local voicemail = target:GetCharacterData("Voicemail")

		if (voicemail and voicemail != "") then
			chatbox.AddText({target, player}, voicemail, {sender = player, isPlayerMessage = true, filter = "pm", textColor = Color("#FFFF00")})
		else
			chatbox.AddText({target, player}, table.concat(arguments, " ", 2), {sender = player, isPlayerMessage = true, filter = "pm", type = "pm", textColor = Color("#65DBAC"), icon = false})
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
