--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimMotion")
COMMAND.tip = "#Command_Animmotion_Description"
COMMAND.text = "#Command_Animmotion_Syntax"
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
				cw.player:Notify(player, L("CannotActionRightNow"))
			else
				player:SetForcedAnimation(animation, 2.5)
				player:SetNetVar("StancePos", player:GetPos())
				player:SetNetVar("StanceAng", player:GetAngles())
				player:SetNetVar("StanceIdle", false)
			end
		else
			cw.player:Notify(player, L("EmoteAnims_ModelCannotPerform"))
		end
	else
		cw.player:Notify(player, L("EmoteAnims_CannotDoAnotherYet"))
	end
end

COMMAND:Register()

if (CLIENT) then
	cw.quickmenu:AddCommand("#Emotes_animMotion", "#Emotes", COMMAND.name, {
		"#Emotes_animMotion_Left",
		"#Emotes_animMotion_Right",
		"#Emotes_animMotion_Behind"
	})
end
