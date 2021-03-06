--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimLean")
COMMAND.tip = "Make your character lean back up against a wall."
COMMAND.text = "[string ArmsBack|ArmsDown]"
COMMAND.flags = CMD_DEFAULT
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime()

	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2

		local modelClass = cw.animation:GetModelClass(player:GetModel())
		local eyePos = player:EyePos()

		if (modelClass == "maleHuman" or modelClass == "femaleHuman" or modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation()
			local action = string.lower(arguments[1] or "")

			if (forcedAnimation and (forcedAnimation.animation == "lean_back" or forcedAnimation.animation == "plazaidle1"
			or forcedAnimation.animation == "plazaidle2" or forcedAnimation.animation == "idle_baton")) then
				cwEmoteAnims:MakePlayerExitStance(player)
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				if (player:Crouching()) then
					cw.player:Notify(player, "You cannot do this while you are crouching!")
				else
					local animation = "lean_back"
					local traceLine = util.TraceLine({
						start = eyePos,
						endpos = eyePos + (player:GetAngles():Forward() * -20),
						filter = player
					})

					if (modelClass != "civilProtection") then
						if (action == "armsback") then
							animation = "plazaidle2"
						elseif (action == "armsdown") then
							animation = "plazaidle1"
						end
					else
						animation = "idle_baton"
					end

					if (traceLine.Hit) then
						player:SetNetVar("stance", true)
						player:SetEyeAngles(traceLine.HitNormal:Angle())
						player:SetForcedAnimation(animation, 0, nil, function()
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
	cw.quickmenu:AddCommand("#Emotes_animLean", "#Emotes", COMMAND.name, {{"#Emotes_animLean_ArmsBack", "ArmsBack"}, {"#Emotes_animLean_ArmsDown", "ArmsDown"}, "#Emotes_animLean_Normal"})
end
