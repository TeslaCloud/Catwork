--[[
	© 2014 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New("Apply")
COMMAND.tip = "Says your Name and CID."
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player)
	local citizenID = player:GetNetVar("citizenID")
	local name = player:Name()
	local radius = config.Get("talk_radius"):Get()

	if (!player:IsCombine()) then
		chatbox.AddText(nil, '"'..name..', #'..citizenID..'."', {sender = player, isPlayerMessage = true, filter = "ic", radius = radius, textColor = Color(255, 255, 200, 255)})
	else
		cw.player:Notify(player, "You do not appear to have a CID. Use /Name instead!")
	end

	for k, v in ipairs(_player.GetAll()) do
		if (v:GetPos():Distance(player:GetPos()) <= radius and config.Get("apply_recognise_enable"):Get()
		and IsValid(v) and v:HasInitialized()) then
			cw.player:SetRecognises(v, player, RECOGNISE_TOTAL)
		end
	end
end

COMMAND:Register();