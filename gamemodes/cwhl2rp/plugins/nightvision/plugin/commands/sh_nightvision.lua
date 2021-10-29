--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/cw.html
--]]

local Clockwork = Clockwork

local COMMAND = cw.command:New("Nightvision")
COMMAND.tip = "Enable/disable nightvision googles."
COMMAND.text = ""
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE, CMD_FALLENOVER)
COMMAND.arguments = 0

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if Schema:PlayerCanUseNightvision(player) then
		if player:GetNWBool("nightvisionfx") then
			player:EmitSound(Sound("items/nvg_off.wav"))
			player:SetNWBool("nightvisionfx", false)
		else
			player:EmitSound(Sound("items/nvg_on.wav"))
			player:SetNWBool("nightvisionfx", true)
		end
	else
		cw.player:Notify(player, "У вас нет очков ночного видения.")
	end
end

COMMAND:Register();