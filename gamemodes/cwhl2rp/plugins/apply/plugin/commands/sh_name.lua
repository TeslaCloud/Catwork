--[[
	© 2014 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("Name")
COMMAND.tip = "Says your Name."
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player)
	local name = player:Name()
	local radius = config.Get("talk_radius"):Get()

	if (!player:IsCombine()) then
		chatbox.AddText(nil, '"'..name..'."', {sender = player, isPlayerMessage = true, filter = "ic", radius = radius, textColor = Color(255, 255, 200, 255)})
	else
		chatbox.AddText(nil, '"Юнит '..name..'."', {sender = player, isPlayerMessage = true, filter = "ic", radius = radius, textColor = Color(255, 255, 200, 255)})
	end

	for k, v in ipairs(_player.GetAll()) do
		if(v:GetPos():Distance(player:GetPos()) <= radius
		and config.Get("apply_recognise_enable"):Get()
		and IsValid(v) and v:HasInitialized()) then
			cw.player:SetRecognises(v, player, RECOGNISE_TOTAL)
		end
	end
end

COMMAND:Register();