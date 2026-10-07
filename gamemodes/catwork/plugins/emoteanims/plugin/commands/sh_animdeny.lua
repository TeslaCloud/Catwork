--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimDeny")
COMMAND.tip = "#Command_Animdeny_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime()

	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2

		local modelClass = cw.animation:GetModelClass(player:GetModel())

		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation()

			if (forcedAnimation and cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				cw.player:Notify(player, L("CannotActionRightNow"))
			else
				player:SetForcedAnimation("harassfront2", 1.5)
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
	cw.quickmenu:AddCommand("#Emotes_animDeny", "#Emotes", COMMAND.name)
end
