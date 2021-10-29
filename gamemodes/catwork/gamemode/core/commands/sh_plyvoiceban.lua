--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyVoiceBan")
COMMAND.tip = "#Command_Plyvoiceban_Description"
COMMAND.text = "#Command_Plyvoiceban_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = {"VoiceBan", "PlyBanVoice"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (IsValid(target)) then
		if (!target:GetData("VoiceBan")) then
			target:SetData("VoiceBan", true)
		else
			cw.player:Notify(player, target:Name().." is already banned from using voice!")
		end
	end
end

COMMAND:Register();
