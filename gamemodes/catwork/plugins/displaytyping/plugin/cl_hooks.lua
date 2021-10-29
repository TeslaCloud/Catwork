--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[
	Micro-optimizations, because local variables are faster
	to access than global variables.
--]]

local UnPredictedCurTime = UnPredictedCurTime
local cwDisplayTyping = cwDisplayTyping
local playerGetAll = _player.GetAll
local string = string
local pairs = pairs

-- Called to draw the text over each player's head if needed.
function cwDisplayTyping:PostDrawTranslucentRenderables()
	if (!cw.client or !cw.client:HasInitialized()) then return end

	local realEyeAngles = cw.client:EyeAngles()
	local clientPos = cw.client:GetPos()
	local colorWhite = cw.option:GetColor("white")
	local large3D2DFont = cw.option:GetFont("large_3d_2d")

	for k, player in ipairs(playerGetAll()) do
		local eyeAngles = Angle(realEyeAngles)

		if (player:HasInitialized() and player:Alive() and player:GetMoveType() != MOVETYPE_NOCLIP) then
			local typing = player:GetNetVar("Typing") or false

			if (typing != 0) then		
				local plyPos = player:GetPos()
				local fadeDistance = 192

				if (typing == TYPING_YELL or typing == TYPING_PERFORM) then
					fadeDistance = config.Get("talk_radius"):Get() * 2
				elseif (typing == TYPING_WHISPER) then
					fadeDistance = config.Get("talk_radius"):Get() / 3

					if (fadeDistance > 80) then
						fadeDistance = 80
					end
				else
					fadeDistance = config.Get("talk_radius"):Get()
				end

				if (plyPos and clientPos and plyPos:Distance(clientPos) <= fadeDistance) then
					local color = player:GetColor();	
					local curTime = UnPredictedCurTime()

					if (player:GetMaterial() != "sprites/heatwave" and (a != 0 or player:IsRagdolled())) then
						local alpha = cw.core:CalculateAlphaFromDistance(fadeDistance, cw.client, player)
						local position = hook.Run("GetPlayerTypingDisplayPosition", player)
						local headBone = "ValveBiped.Bip01_Head1"

						if (string.find(player:GetModel(), "vortigaunt")) then
							headBone = "ValveBiped.Head"
						end

						if (!position) then
							local bonePosition = nil
							local offset = Vector(0, 0, 80)

							if (player:IsRagdolled()) then
								local entity = player:GetRagdollEntity()

								if (IsValid(entity)) then
									local physBone = entity:LookupBone(headBone)

									if (physBone) then
										bonePosition = entity:GetBonePosition(physBone)
									end
								end
							else
								local physBone = player:LookupBone(headBone)

								if (physBone) then
									bonePosition = player:GetBonePosition(physBone)
								end
							end

							if (player:InVehicle()) then
								offset = Vector(0, 0, 128)
							elseif (player:IsRagdolled()) then
								offset = Vector(0, 0, 16)
							elseif (player:Crouching()) then
								offset = Vector(0, 0, 64)
							end

							if (bonePosition) then
								position = bonePosition + Vector(0, 0, 16)
							else
								position = player:GetPos() + offset
							end
						end

						if (position) then
							local drawText = ""

							position = position + eyeAngles:Up()
							eyeAngles:RotateAroundAxis(eyeAngles:Forward(), 90)
							eyeAngles:RotateAroundAxis(eyeAngles:Right(), 90)

							if (typing == TYPING_WHISPER) then
								drawText = "#TD_Whispering"
							elseif (typing == TYPING_PERFORM) then
								drawText = "#TD_Performing"
							elseif (typing == TYPING_NORMAL) then
								drawText = "#TD_Talking"
							elseif (typing == TYPING_RADIO) then
								drawText = "#TD_Radioing"
							elseif (typing == TYPING_YELL) then
								drawText = "#TD_Yelling"
							elseif (typing == TYPING_OOC) then
								drawText = "#TD_Typing"
							end

							if (drawText != "") then
								local textWidth, textHeight = cw.core:GetCachedTextSize(cw.option:GetFont("main_text"), drawText)

								if (textWidth and textHeight) then
									cam.Start3D2D(position, Angle(0, eyeAngles.y, 90), 0.04)
										cw.core:OverrideMainFont(large3D2DFont)
											cw.core:DrawInfo(drawText, 0, 0, colorWhite, alpha, nil, nil, 4)
										cw.core:OverrideMainFont(false)
									cam.End3D2D()
								end
							end
						end
					end
				end
			end
		end
	end
end

-- Called when the chat box is closed.
function cwDisplayTyping:ChatBoxClosed(textTyped)
	if (textTyped) then
		RunConsoleCommand("cwTypingFinish", "1")
	else
		RunConsoleCommand("cwTypingFinish")
	end
end

-- Called when the chat box text has changed.
function cwDisplayTyping:ChatBoxTextChanged(previousText, newText)
	local prefix = config.Get("command_prefix"):Get()

	if (string.utf8sub(newText, 1, string.utf8len(prefix) + 5) == prefix.."radio") then
		if (string.utf8sub(previousText, 1, string.utf8len(prefix) + 5) != prefix.."radio") then
			RunConsoleCommand("cwTypingStart", "r")
		end
	elseif (string.utf8sub(newText, 1, string.utf8len(prefix) + 2) == prefix.."me") then
		if (string.utf8sub(previousText, 1, string.utf8len(prefix) + 2) != prefix.."me") then
			RunConsoleCommand("cwTypingStart", "p")
		end
	elseif (string.utf8sub(newText, 1, string.utf8len(prefix) + 2) == prefix.."pm") then
		if (string.utf8sub(previousText, 1, string.utf8len(prefix) + 2) != prefix.."pm") then
			RunConsoleCommand("cwTypingStart", "o")
		end
	elseif (string.utf8sub(newText, 1, string.utf8len(prefix) + 1) == prefix.."w") then
		if (string.utf8sub(previousText, 1, string.utf8len(prefix) + 1) != prefix.."w") then
			RunConsoleCommand("cwTypingStart", "w")
		end
	elseif (string.utf8sub(newText, 1, string.utf8len(prefix) + 1) == prefix.."y") then
		if (string.utf8sub(previousText, 1, string.utf8len(prefix) + 1) != prefix.."y") then
			RunConsoleCommand("cwTypingStart", "y")
		end
	elseif (string.utf8sub(newText, 1, 2) == "//") then
		if (string.utf8sub(previousText, 1, 2) != prefix.."//") then
			RunConsoleCommand("cwTypingStart", "o")
		end
	elseif (string.utf8sub(newText, 1, 3) == ".//") then
		if (string.utf8sub(previousText, 1, 3) != prefix..".//") then
			RunConsoleCommand("cwTypingStart", "o")
		end
	elseif (newText != "" and string.utf8len(newText) >= 4 and previousText != "" and string.utf8len(previousText) < 4) then
		RunConsoleCommand("cwTypingStart", "n")
	end
end
