--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimSitWall")
COMMAND.tip = "Make your character sit back up against a wall."
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime()

	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2

		local modelClass = cw.animation:GetModelClass(player:GetModel())
		local position = player:GetPos() + Vector(0, 0, 16)
		local angles = player:GetAngles():Forward()

		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation()

			if (forcedAnimation and forcedAnimation.animation == "plazaidle4") then
				cwEmoteAnims:MakePlayerExitStance(player)
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				if (player:Crouching()) then
					cw.player:Notify(player, "You cannot do this while you are crouching!")
				else
					local traceLine = util.TraceLine({
						start = position,
						endpos = position + (angles * -20),
						filter = player
					})

					if (traceLine.Hit) then
						player.cwPreviousPos = player:GetPos()

						player:SetPos(player:GetPos() + (angles * 4))
						player:SetEyeAngles(traceLine.HitNormal:Angle())
						player:SetForcedAnimation("plazaidle4", 0, nil, function()
							cwEmoteAnims:MakePlayerExitStance(player)
						end)

						player:SetNetVar("StancePos", player:GetPos())
						player:SetNetVar("StanceAng", player:GetAngles())
						player:SetNetVar("StanceIdle", true)
					else
						cw.player:Notify(player, "You must be facing away from, and near a wall!")
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
	cw.quickmenu:AddCommand("#Emotes_animSitWall", "#Emotes", COMMAND.name)
end
