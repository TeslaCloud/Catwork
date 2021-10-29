--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimWindow")
COMMAND.tip = "Make your character look out of a window."
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

			if (forcedAnimation and (forcedAnimation.animation == "d1_t03_tenements_look_out_window_idle" or forcedAnimation.animation == "d1_t03_lookoutwindow")) then
				cwEmoteAnims:MakePlayerExitStance(player)
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation]) then
				if (player:Crouching()) then
					cw.player:Notify(player, "You cannot do this while you are crouching!")
				else
					local traceLine = util.TraceLine({
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					})

					if (traceLine.Hit) then
						if (modelClass == "maleHuman") then
							player:SetForcedAnimation("d1_t03_tenements_look_out_window_idle", 0, nil, function()
								cwEmoteAnims:MakePlayerExitStance(player)
							end)
						else
							player:SetForcedAnimation("d1_t03_lookoutwindow", 0, nil, function()
								cwEmoteAnims:MakePlayerExitStance(player)
							end)
						end

						player:SetEyeAngles(traceLine.HitNormal:Angle() + Angle(0, 180, 0))
						player:SetNetVar("StancePos", player:GetPos())
						player:SetNetVar("StanceAng", player:GetAngles())
						player:SetNetVar("StanceIdle", true)
					else
						cw.player:Notify(player, "You must be facing, and near a wall!")
					end
				end
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
	cw.quickmenu:AddCommand("#Emotes_animWindow", "#Emotes", COMMAND.name)
end
