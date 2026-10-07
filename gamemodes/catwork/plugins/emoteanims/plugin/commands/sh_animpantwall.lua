--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimPantWall")
COMMAND.tip = "#Command_Animpantwall_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime()

	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2

		local modelClass = cw.animation:GetModelClass(player:GetModel())
		local eyePos = player:EyePos()

		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation()
			local angles = player:GetAngles():Forward()

			if (forcedAnimation
			and (forcedAnimation.animation == "d2_coast03_postbattle_idle01"
			or forcedAnimation.animation == "d2_coast03_postbattle_idle01_entry")) then
				cwEmoteAnims:MakePlayerExitStance(player)
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation]) then
				if (player:Crouching()) then
					cw.player:Notify(player, L("EmoteAnims_CannotWhileCrouching"))
				else
					local traceLine = util.TraceLine({
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					})

					if (traceLine.Hit) then
						player:SetForcedAnimation("d2_coast03_postbattle_idle01_entry", 1.5, nil, function(player)
							player:SetForcedAnimation("d2_coast03_postbattle_idle01", 0, nil, function()
								cwEmoteAnims:MakePlayerExitStance(player)
							end)
						end)

						player:SetEyeAngles(traceLine.HitNormal:Angle() + Angle(0, 180, 0))
						player:SetNetVar("StancePos", player:GetPos())
						player:SetNetVar("StanceAng", player:GetAngles())
						player:SetNetVar("StanceIdle", false)
					else
						cw.player:Notify(player, L("EmoteAnims_MustFaceWall"))
					end
				end
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
	cw.quickmenu:AddCommand("#Emotes_animPantWall", "#Emotes", COMMAND.name)
end
