--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- GetTargetRecognises datastream callback.
netstream.Hook("GetTargetRecognises", function(player, data)
	if (IsValid(data) and data:IsPlayer()) then
		player:SetNetVar("TargetKnows", cw.player:DoesRecognise(data, player))
	end
end)

-- EntityMenuOption datastream callback.
netstream.Hook("EntityMenuOption", function(player, data)
	local entity = data[1]
	local option = data[2]
	local shootPos = player:GetShootPos()
	local arguments = data[3]
	local curTime = CurTime()

	if (IsValid(entity) and type(option) == "string") then
		if (entity:NearestPoint(shootPos):Distance(shootPos) <= 80) then
			if (hook.Run("PlayerUse", player, entity)) then
				if (!player.nextEntityHandle or player.nextEntityHandle <= curTime) then
					hook.Run("EntityHandleMenuOption", player, entity, option, arguments)

					player.nextEntityHandle = curTime + config.Get("entity_handle_time"):Get()
				else
					cw.player:Notify(player, L(player, "EntityOptionWaitTime"))
				end
			end
		end
	end
end)

-- MenuOption datastream callback.
netstream.Hook("MenuOption", function(player, data)
	local itemID = data.item
	local option = data.option
	local entity = data.entity
	local data = data.data
	local shootPos = player:GetShootPos()

	if (type(data) != "table") then
		data = {data}
	end

	local itemTable = item.FindInstance(itemID)
	if (itemTable and itemTable:IsInstance() and type(option) == "string") then
		if (itemTable.HandleOptions) then
			if (player:HasItemInstance(itemTable)) then
				itemTable:HandleOptions(option, player, data)
			elseif (IsValid(entity) and entity:GetClass() == "cw_item" and entity:GetItemTable() == itemTable and entity:NearestPoint(shootPos):Distance(shootPos) <= 80) then
				itemTable:HandleOptions(option, player, data, entity)
			end
		end
	end
end)

-- DataStreamInfoSent datastream callback.
netstream.Hook("DataStreamInfoSent", function(player, data)
	if (!player.cwDatastreamInfoSent) then
		hook.Run("PlayerDataStreamInfoSent", player)

		timer.Simple(FrameTime() * 32, function()
			if (IsValid(player)) then
				netstream.Start(player, "DataStreamed", true)
			end
		end)

		player.cwDatastreamInfoSent = true
	end
end)

-- LocalPlayerCreated datastream callback.
netstream.Hook("LocalPlayerCreated", function(player, data)
	if (IsValid(player) and !player:HasConfigInitialized()) then
		timer.Create("SendCfg"..player:UniqueID(), FrameTime(), 1, function()
			if (IsValid(player)) then
				config.Send(player)
			end
		end);		
	end
end)

-- InteractCharacter datastream callback.
netstream.Hook("InteractCharacter", function(player, data)
	local characterID = data.characterID
	local action = data.action

	if (characterID and action) then
		local character = player:GetCharacters()[characterID]

		if (character) then
			local fault = hook.Run("PlayerCanInteractCharacter", player, action, character)

			if (fault == false or type(fault) == "string") then
				return cw.player:SetCreateFault(fault or "You cannot interact with this character!")
			elseif (action == "delete") then
				local bSuccess, fault = cw.player:DeleteCharacter(player, characterID)

				if (!bSuccess) then
					cw.player:SetCreateFault(player, fault)
				end
			elseif (action == "use") then
				local bSuccess, fault = cw.player:UseCharacter(player, characterID)

				if (!bSuccess) then
					cw.player:SetCreateFault(player, fault)
				end
			else
				hook.Run("PlayerSelectCustomCharacterOption", player, action, character)
			end
		end
	end
end)

-- GetQuizStatus datastream callback.
netstream.Hook("GetQuizStatus", function(player, data)
	if (!cw.quiz:GetEnabled() or cw.quiz:GetCompleted(player)) then
		netstream.Start(player, "QuizCompleted", true)
	else
		netstream.Start(player, "QuizCompleted", false)
	end
end)

-- DoorManagement datastream callback.
netstream.Hook("DoorManagement", function(player, data)
	if (IsValid(data[1]) and player:GetEyeTraceNoCursor().Entity == data[1]) then
		if (data[1]:GetPos():Distance(player:GetPos()) <= 192) then
			if (data[2] == "Purchase") then
				if (!cw.entity:GetOwner(data[1])) then
					if (hook.Run("PlayerCanOwnDoor", player, data[1]) != false) then
						local doors = cw.player:GetDoorCount(player)

						if (doors == config.Get("max_doors"):Get()) then
							cw.player:Notify(player, L(player, "CannotPurchaseAnotherDoor"))
						else
							local doorCost = config.Get("door_cost"):Get()

							if (doorCost == 0 or cw.player:CanAfford(player, doorCost)) then
								local doorName = cw.entity:GetDoorName(data[1])

								if (doorName == "false" or doorName == "hidden" or doorName == "") then
									doorName = "Door"
								end

								if (doorCost > 0) then
									cw.player:GiveCash(player, -doorCost, doorName)
								end

								cw.player:GiveDoor(player, data[1])
							else
								local amount = doorCost - player:GetCash()

								cw.player:Notify(player, L(player, "YouNeedAnother",
									cw.core:FormatCash(amount, nil, true))
								)
							end
						end
					end
				end
			elseif (data[2] == "Access") then
				if (cw.player:HasDoorAccess(player, data[1], DOOR_ACCESS_COMPLETE)) then
					if (IsValid(data[3]) and data[3] != player and data[3] != cw.entity:GetOwner(data[1])) then
						if (data[4] == DOOR_ACCESS_COMPLETE) then
							if (cw.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE)) then
								cw.player:GiveDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC)
							else
								cw.player:GiveDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE)
							end
						elseif (data[4] == DOOR_ACCESS_BASIC) then
							if (cw.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC)) then
								cw.player:TakeDoorAccess(data[3], data[1])
							else
								cw.player:GiveDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC)
							end
						end

						if (cw.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_COMPLETE)) then
							netstream.Start(player, "DoorAccess", {data[3], DOOR_ACCESS_COMPLETE})
						elseif (cw.player:HasDoorAccess(data[3], data[1], DOOR_ACCESS_BASIC)) then
							netstream.Start(player, "DoorAccess", {data[3], DOOR_ACCESS_BASIC})
						else
							netstream.Start(player, "DoorAccess", {data[3]})
						end
					end
				end
			elseif (data[2] == "Unshare") then
				if (cw.entity:IsDoorParent(data[1])) then
					if (data[3] == "Text") then
						netstream.Start(player, "SetSharedText", false)

						data[1].cwDoorSharedTxt = nil
					else
						netstream.Start(player, "SetSharedAccess", false)

						data[1].cwDoorSharedAxs = nil
					end
				end
			elseif (data[2] == "Share") then
				if (cw.entity:IsDoorParent(data[1])) then
					if (data[3] == "Text") then
						netstream.Start(player, "SetSharedText", true)

						data[1].cwDoorSharedTxt = true
					else
						netstream.Start(player, "SetSharedAccess", true)

						data[1].cwDoorSharedAxs = true
					end
				end
			elseif (data[2] == "Text" and data[3] != "") then
				if (cw.player:HasDoorAccess(player, data[1], DOOR_ACCESS_COMPLETE)) then
					if (!string.find(string.gsub(string.lower(data[3]), "%s", ""), "thisdoorcanbepurchased") and string.find(data[3], "%w")) then
						cw.entity:SetDoorText(data[1], string.utf8sub(data[3], 1, 32))
					end
				end
			elseif (data[2] == "Sell") then
				if (cw.entity:GetOwner(data[1]) == player) then
					if (!cw.entity:IsDoorUnsellable(data[1])) then
						cw.player:TakeDoor(player, data[1])
					end
				end
			end
		end
	end
end)

-- CreateCharacter datastream callback.
netstream.Hook("CreateCharacter", function(player, data)
	cw.player:CreateCharacterFromData(player, data)
end)

-- RecogniseOption datastream callback.
netstream.Hook("RecogniseOption", function(player, data)
	local recogniseData = data

	if (config.Get("recognise_system"):Get()) then
		if (type(recogniseData) == "string") then	
			local playSound = false

			if (recogniseData == "look") then
				local target = player:GetEyeTraceNoCursor().Entity

				if (target:HasInitialized() and !cw.player:IsNoClipping(target) and target != player) then
					cw.player:SetRecognises(target, player, RECOGNISE_SAVE)

					playSound = true
				end
			else
				local position = player:GetPos()
				local plyTable = _player.GetAll()
				local talkRadius = config.Get("talk_radius"):Get()

				for k, v in ipairs(plyTable) do
					if (v:HasInitialized() and player != v) then
						if (!cw.player:IsNoClipping(v)) then
							local distance = v:GetPos():Distance(position)
							local recognise = false

							if (recogniseData == "whisper") then
								if (distance <= math.min(talkRadius / 3, 80)) then
									recognise = true
								end
							elseif (recogniseData == "yell") then
								if (distance <= talkRadius * 2) then
									recognise = true
								end
							elseif (recogniseData == "talk") then
								if (distance <= talkRadius) then
									recognise = true
								end
							end

							if (recognise) then
								cw.player:SetRecognises(v, player, RECOGNISE_SAVE)

								if (!playSound) then
									playSound = true
								end
							end
						end
					end
				end
			end

			if (playSound) then
				cw.player:PlaySound(player, "buttons/button17.wav")
			end
		end
	end
end)

-- QuizCompleted datastream callback.
netstream.Hook("QuizCompleted", function(player, data)
	if (player.cwQuizAnswers and !cw.quiz:GetCompleted(player)) then
		local questionsAmount = cw.quiz:GetQuestionsAmount()
		local correctAnswers = 0
		local quizQuestions = cw.quiz:GetQuestions()

		for k, v in pairs(quizQuestions) do
			if (player.cwQuizAnswers[k]) then
				if (cw.quiz:IsAnswerCorrect(k, player.cwQuizAnswers[k])) then
					correctAnswers = correctAnswers + 1
				end
			end
		end

		if (correctAnswers < math.Round(questionsAmount * (cw.quiz:GetPercentage() / 100))) then
			cw.quiz:CallKickCallback(player, correctAnswers)
		else
			cw.quiz:SetCompleted(player, true)
		end
	end
end)

-- UnequipItem datastream callback.
netstream.Hook("UnequipItem", function(player, data)
	local arguments = data[3]
	local uniqueID = data[1]
	local itemID = data[2]

	if (!player:Alive() or player:IsRagdolled()) then
		return
	end

	local itemTable = player:FindItemByID(uniqueID, itemID)

	if (!itemTable) then
		itemTable = player:FindWeaponItemByID(uniqueID, itemID)
	end

	itemTable = item.Validate(itemTable, true)

	if (itemTable and itemTable.OnPlayerUnequipped and itemTable.HasPlayerEquipped) then
		if (itemTable:HasPlayerEquipped(player, arguments)) then
			itemTable:OnPlayerUnequipped(player, arguments)

			player:RebuildInventory()
		end
	end
end)

-- QuizAnswer datastream callback.
netstream.Hook("QuizAnswer", function(player, data)
	if (!player.cwQuizAnswers) then
		player.cwQuizAnswers = {}
	end

	local question = data[1]
	local answer = data[2]

	if (cw.quiz:GetQuestion(question)) then
		player.cwQuizAnswers[question] = answer
	end
end)
