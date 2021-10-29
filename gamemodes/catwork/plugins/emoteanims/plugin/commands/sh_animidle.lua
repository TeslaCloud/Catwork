--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AnimIdle")
COMMAND.tip = "Put your character into an idle stance."
COMMAND.text = "[bool ArmsCrossed]"
COMMAND.flags = CMD_DEFAULT
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local modelClass = cw.animation:GetModelClass(player:GetModel())
	local curTime = CurTime()

	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2

		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation()

			if (forcedAnimation and string.find(forcedAnimation.animation, "lineidle")) then
				cwEmoteAnims:MakePlayerExitStance(player)
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				if (player:Crouching()) then
					cw.player:Notify(player, "You cannot do this while you are crouching!")
				else
					local animation = nil

					if (cw.core:ToBool(arguments[1])) then
						if (modelClass == "maleHuman") then
							animation = "lineidle02"
						else
							animation = "lineidle01"
						end
					else
						if (modelClass == "femaleHuman") then
							animation = "lineidle0"..math.random(1, 2)
						else
							animation = "lineidle04"
						end
					end

					if (player:IsOnGround() or IsValid(player:GetGroundEntity())) then
						player:SetNetVar("StancePos", player:GetPos())
						player:SetNetVar("StanceAng", player:GetAngles())
						player:SetNetVar("StanceIdle", true)
						player:SetForcedAnimation(animation, 0, nil, function()
							cwEmoteAnims:MakePlayerExitStance(player)
						end)
					else
						cw.player:Notify(player, "You must be standing on the ground!")
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
	cw.quickmenu:AddCommand("#Emotes_animIdle", "#Emotes", COMMAND.name, {{"#Emotes_animIdle_CrossHands", "1"}, {"#Emotes_animIdle_HandsInPockets", "0"}})
end
