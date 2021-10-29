
function PLUGIN:PlayerCharacterDataChanged(player, key, oldValue, value)
	if (key == "diseases") then
		player:SetNetVar("diseases", value)
	end
end

-- Called when a player's character data should be restored.
function PLUGIN:PlayerRestoreCharacterData(player, data)
	if (!data["diseases"]) then
		data["diseases"] = "none"
	end
end

local coughSounds = {
"ambient/voices/cough1.wav",
"ambient/voices/cough2.wav",
"ambient/voices/cough3.wav",
"ambient/voices/cough4.wav"
}

function PLUGIN:OnePlayerSecond(player, curTime, infoTable)
	local faction = player:GetFaction()
	local curTime = CurTime()
	
	if (player:Alive()) then
		if (player:GetCharacterData("diseases") == "cough" or player:GetCharacterData("diseases") == "pneumonia") then
			if (math.random(1, 50) == 1 and player:GetCharacterData("diseases") == "cough") then
				player:SetCharacterData("diseases", "pneumonia")
			end

			if (!player.nextCough or curTime > player.nextCough) then
				if (!player:IsNoClipping()) then
					if (player:GetCharacterData("diseases") == "pneumonia") then
						player:EmitSound(table.Random(coughSounds), 100, 100)

						if (math.random(1, 2) == 1) then
							chatbox.AddText(nil, "очень сильно кашляет, отхаркивая мокроту из легких.", {isPlayerMessage = true, sender = player, noStyling = true, fakeName = true, position = player:GetPos(), textColor = Color("#89D235"), filter = "player_events", icon = false})
						else
							chatbox.AddText(nil, "начинает задыхаться и жадно глотать воздух.", {isPlayerMessage = true, sender = player, noStyling = true, fakeName = true, position = player:GetPos(), textColor = Color("#89D235"), filter = "player_events", icon = false})
						end

						player.nextCough = curTime + math.random(15,45)
					else
						player:EmitSound(table.Random(coughSounds), 100, 100)
						chatbox.AddText(nil, "кашляет.", {isPlayerMessage = true, sender = player, noStyling = true, fakeName = true, position = player:GetPos(), textColor = Color("#89D235"), filter = "player_events", icon = false})
						player.nextCough = curTime + math.random(15,45)
					end
				end
			end
		elseif (player:GetCharacterData("diseases") == "fever") then
			if (!player.nextFever or curTime > player.nextFever) then
				if (!player:IsNoClipping()) then
					chatbox.AddText(nil, "чувствует головокружение и жар.", {isPlayerMessage = true, sender = player, noStyling = true, fakeName = true, position = player:GetPos(), textColor = Color("#89D235"), filter = "player_events", icon = false})
					player.nextFever = curTime + math.random(120,300)
				end
			end
		elseif (player:GetCharacterData("diseases") == "gastrits") then
			if (!player.nextStomach or curTime > player.nextStomach) then
				if (!player:IsNoClipping()) then
					player:EmitSound(table.Random(coughSounds), 100, 100)
					chatbox.AddText(nil, "невольно сгибается из-за боли в животе.", {isPlayerMessage = true, sender = player, noStyling = true, fakeName = true, position = player:GetPos(), textColor = Color("#89D235"), filter = "player_events", icon = false})
					player.nextStomach = curTime + math.random(60, 90)
				end
			end
		else 
			if (!player.nextTrigger or curTime > player.nextTrigger) then
				if (math.random(1, 200) == 1) then
					player:SetCharacterData("diseases", "cough")
				end

				if (math.random(1, 600) == 1) then
					player:SetCharacterData("diseases", "fever")
				end

				if (math.random(1, 200) == 1 and player:GetCharacterData("Hunger") >= 65) then
					player:SetCharacterData("diseases", "diarrhea")
				end

				if (math.random(1, 1000) == 1) then
					player:SetCharacterData("diseases", "colorblindness")
				end

				player.nextTrigger = curTime + math.random(300,600)
			end
		end

		-- This should effect all type of players.
		if (player:GetCharacterData("diseases") == "slow_deathinjection" or player:GetCharacterData("diseases") == "fast_deathinjection") then
			if (!player.nextInject or curTime > player.nextInject) then
				if (!player:IsNoClipping()) then
					if (player:GetGender() == GENDER_FEMALE) then
						player:EmitSound("vo/npc/female01/pain0"..math.random(1, 9)..".wav", 30, 100 )
					else
						player:EmitSound("vo/npc/male01/pain0"..math.random(1, 9)..".wav", 30, 100 )
					end
					
					if (player:Health() >= 5) then
						player:SetHealth(player:Health() - 1)
					else
						Schema:PermaKillPlayer(player, player:GetRagdollEntity())
						cw.player:Notify(player, "Вы были перманентно убиты из-за интоксикации...")
					end

					if (player:GetCharacterData("diseases") == "fast_deathinjection") then
						player.nextInject = curTime + 0.5
					else
						player.nextInject = curTime + math.random(4,6)
					end
				end
			end
		end
	end
end

-- Called when a player has been healed.
function PLUGIN:PlayerHealed(player, healer, itemTable)
	if (itemTable.uniqueID == "special_ration") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 20, true)
	elseif (itemTable.uniqueID == "antibiotics") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 25, true)
	elseif (itemTable.uniqueID == "allergy_tablet") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 2, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 15, true)
	elseif (itemTable.uniqueID == "bandage") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 5, true)
	elseif (itemTable.uniqueID == "activated_coal") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 5, true)
	elseif (itemTable.uniqueID == "ingall") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 3, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 15, true)
	elseif (itemTable.uniqueID == "snot") then
		healer:ProgressAttribute(ATB_MEDICAL, 15, true)
	elseif (itemTable.uniqueID == "snotbad") then
		healer:ProgressAttribute(ATB_MEDICAL, 10, true)
	elseif (itemTable.uniqueID == "probiotics") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 2, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 20, true)
	elseif (itemTable.uniqueID == "sorbent") then
		player:BoostAttribute(itemTable.name, ATB_DEXTERITY, 1, 120)
		healer:ProgressAttribute(ATB_MEDICAL, 15, true)
	end
end

-- Called when a player uses an item.
function PLUGIN:PlayerUseItem(player, itemTable, itemEntity)
	local allergyFood = {
		"choko",
		"orange",
		"apple",
		"bread"
	}
	local lowQualityFood = {
		"chips",
		"chinese_takeout"
	}

	if (player:GetCharacterData("diseases") == "none") then
		if (math.random(1, 10) == 1 and table.HasValue(allergyFood, itemTable.name)) then
			player:SetCharacterData("diseases", "allergy")

			timer.Simple(math.random(60, 180), function()
				cw.player:Notify(player, "Вы замечаете сыпь на Ваших руках.")
			end)
		elseif (math.random(1, 4) == 1 and table.HasValue(lowQualityFood, itemTable.name)) then
			player:SetCharacterData("diseases", "gastrits")

			timer.Simple(math.random(60, 180), function()
				cw.player:Notify(player, "Вы чувствуете боль в животе.")
			end)
		elseif (math.random(1, 5) == 1 and itemTable.name == "Coffee") then
			player:SetCharacterData("diseases", "insomnia")
		end
	end

	if (player:GetCharacterData("diseases") == "allergy" and table.HasValue(allergyFood, itemTable.name)) then
		timer.Simple(math.random(5, 15), function()
			cw.player:Notify(player, "Вам стало плохо после употребления ".. itemTable.name ..".")
			player:TakeDamage(math.random(5, 15))
		end)
	end

	if (player:GetCharacterData("diseases") == "diarrhea" and (itemTable.hunger or itemTable.thirst or itemTable.fatigue)) then
		timer.Simple(math.random(5, 15), function()
			chatbox.AddText(nil, "вырвало.", {isPlayerMessage = true, sender = player, noStyling = true, fakeName = true, position = player:GetPos(), textColor = Color("#89D235"), filter = "player_events", icon = false})
			player:TakeDamage(math.random(5, 30))
		end)
	end	
end