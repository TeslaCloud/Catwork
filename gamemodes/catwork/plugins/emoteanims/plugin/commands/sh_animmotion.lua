--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimMotion")
COMMAND.tip = "Make your character motion to something in a direction."
COMMAND.text = "<string Left|Right|Behind>"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime()

	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2.5

		local modelClass = cw.animation:GetModelClass(player:GetModel())
		local action = string.lower(arguments[1] or "")

		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation()
			local animation = "luggage"

			if (action == "left") then
				animation = "motionleft"
			elseif (action == "right") then
				animation = "motionright"
			end

			if (forcedAnimation and cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				cw.player:Notify(player, "You cannot do this action at the moment!")
			else
				player:SetForcedAnimation(animation, 2.5)
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
	cw.quickmenu:AddCommand("#Emotes_animMotion", "#Emotes", COMMAND.name, {"#Emotes_animMotion_Left", "#Emotes_animMotion_Right", "#Emotes_animMotion_Behind"})
end
