--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimWave")
COMMAND.tip = "Make your character wave at another character."
COMMAND.text = "[string Close|Normal]"
COMMAND.flags = CMD_DEFAULT
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime()

	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2.5

		local modelClass = cw.animation:GetModelClass(player:GetModel())

		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation()
			local action = string.lower(arguments[1] or "")

			if (forcedAnimation and cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				cw.player:Notify(player, "You cannot do this action at the moment!")
			else
				if (action == "close") then
					player:SetForcedAnimation("wave_close", 2)
				else
					player:SetForcedAnimation("wave", 2)
				end

				player:SetNetVar("StancePos", player:GetPos())
				player:SetNetVar("StanceAng", player:GetAngles())
				player:SetNetVar("StanceIdle", false)
			end
		else
			cw.player:Notify(player, "The model that you are using cannot perform this action!")
		end
	else
		cw.player:Notify(player, "You cannot do another stance or gesture yet!")
	end
end

COMMAND:Register()

if (CLIENT) then
	cw.quickmenu:AddCommand("#Emotes_animWave", "#Emotes", COMMAND.name, {"#Emotes_animWave_Close", "#Emotes_animWave_Normal"})
end
