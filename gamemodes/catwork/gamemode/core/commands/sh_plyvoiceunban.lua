--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyVoiceUnban")
COMMAND.tip = "#Command_Plyvoiceunban_Description"
COMMAND.text = "#Command_Plyvoiceunban_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = {"VoiceUnban", "PlyUnbanVoice"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		if (target:GetData("VoiceBan")) then
			target:SetData("VoiceBan", false)
		else
			cw.player:Notify(player, target:Name().." is not banned from using voice!")
		end
	end
end

COMMAND:Register();
