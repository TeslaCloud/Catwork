local cwCTO = cwCTO

cwCTO.printServerDebug = false
cwCTO.cameraData = cwCTO.cameraData or {}
cwCTO.fixedCameras = cwCTO.fixedCameras or false
cwCTO.outputEntity = cwCTO.outputEntity or nil
cwCTO.socioStatus = cwCTO.socioStatus or "GREEN"

function cwCTO:SafelyPrepareCamera(combineCamera)
	if (!IsValid(self.outputEntity)) then
		self.outputEntity = ents.Create("base_entity")
		self.outputEntity:SetName("__cwctohook")

		function self.outputEntity:AcceptInput(inputName, activator, called, data)
			if (data == "OnFoundPlayer") then
				cwCTO:CombineCameraFoundPlayer(called, activator)
			end
		end

		self.outputEntity:Spawn()
		self.outputEntity:Activate()
	end

	combineCamera:Fire("addoutput", "OnFoundPlayer __cwctohook:cwcto:OnFoundPlayer:0:-1")
	self.cameraData[combineCamera] = {}

	if (self.fixedCameras) then
		if (!combineCamera:CreatedByMap()) then
			-- Essentially statics the NPC so that it will load when the server restarts.
			combineCamera:SetNetworkedString( "cw_Name", " " )
			combineCamera:SetNetworkedString( "cw_Title", " " )
		end
	end
end

function cwCTO:CombineCameraFoundPlayer(combineCamera, player)
	if (self.cameraData[combineCamera] and !cw.player:IsNoClipping(player)) then
		if (!self.cameraData[combineCamera][player]) then
			self.cameraData[combineCamera][player] = {}
		end
	end
end

-- Called every tick.
function cwCTO:HalfSecond()
	local networkedCameraData = {}

	for combineCamera, data in pairs(self.cameraData) do
		if (!IsValid(combineCamera)) then
			self.cameraData[combineCamera] = nil
		elseif (combineCamera:GetSequenceName(combineCamera:GetSequence()) == "idlealert") then
			local camPos = combineCamera:GetPos()

			for player, plyData in pairs(data) do
				if (!IsValid(player)) then
					data[player] = nil
				else
					if (camPos:Distance(player:GetPos()) > 450 or !combineCamera:IsLineOfSightClear(player)) then
						data[player] = nil
					elseif (#data[player] < 1) then
						local violations = {}

						if (player:IsRunning()) then
							violations[#violations + 1] = self.VIOLATION_RUNNING
						end

						if (player.m_bJumping) then
							violations[#violations + 1] = self.VIOLATION_JUMPING
						end

						if (player:Crouching()) then
							violations[#violations + 1] = self.VIOLATION_CROUCHING
						end

						if (player:GetRagdollState() ~= RAGDOLL_NONE and player:GetRagdollState() ~= RAGDOLL_RESET) then
							violations[#violations + 1] = self.VIOLATION_FALLEN_OVER
						end

						if (#violations > 0) then
							if !(player:IsCombine() and !player:GetSharedVar("IsBiosignalGone")) then
								data[player] = violations
								combineCamera:Fire("SetIdle")
								combineCamera:Fire("SetAngry")
							end
						end
					end
				end
			end

			networkedCameraData[combineCamera:EntIndex()] = data
		else
			networkedCameraData[combineCamera:EntIndex()] = 0
		end
	end

	local players = {}

	for k, v in ipairs( _player.GetAll() ) do
		if (Schema:PlayerIsCombine(v) and !v:GetSharedVar("IsBiosignalGone")) then
			players[#players + 1] = v
		end
	end

	netstream.Start(players, "UpdateBiosignalCameraData", networkedCameraData)
end

function cwCTO:DoPostBiosignalLoss(player)
	player:SetSharedVar("IsBiosignalGone", true)

	local location = Schema:PlayerGetLocation(player)

	local digits = string.match(player:Name(), "%d%d%d%d?%d?") or 0

	-- Alert all other units.
	Schema:AddCombineDisplayLine("Загрузка потерянного биосигнала...", Color(255, 255, 255, 255))
	--Schema:AddCombineDisplayLine("WARNING! Biosignal lost for protection team unit "..digits.." at "..location.."...", Color(255, 0, 0, 255))
	for k, v in ipairs( _player.GetAll() ) do
		if (Schema:PlayerIsCombine(v) and v ~= player and !v:GetSharedVar("IsBiosignalGone")) then
			v:EmitSound("npc/metropolice/vo/on"..math.random(1, 2)..".wav")
			v:EmitSound("npc/overwatch/radiovoice/lostbiosignalforunit.wav")
		end
	end

	if (digits) then
		local englishDigits = {
			["0"] = "zero",
			["1"] = "one",
			["2"] = "two",
			["3"] = "three",
			["4"] = "four",
			["5"] = "five",
			["6"] = "six",
			["7"] = "seven",
			["8"] = "eight",
			["9"] = "nine"
		}

		for k, v in ipairs( _player.GetAll() ) do
			for i = 1, string.len(digits) do
				timer.Simple(2.1 + ((i - 1) * 0.5), function()
					local voNum = englishDigits[string.sub(digits, i, i)]

					if (Schema:PlayerIsCombine(v) and v ~= player and !v:GetSharedVar("IsBiosignalGone")) then
						v:EmitSound("npc/overwatch/radiovoice/"..voNum..".wav")
					end
				end)
			end
		end

		timer.Simple(2.1 + (string.len(digits) * 0.5), function()
			for k, v in ipairs( _player.GetAll() ) do
				if (Schema:PlayerIsCombine(v) and v ~= player and !v:GetSharedVar("IsBiosignalGone")) then
					v:EmitSound("npc/overwatch/radiovoice/remainingunitscontain.wav")
					timer.Simple(1.4, function()
						v:EmitSound("npc/metropolice/vo/off"..math.random(1, 4)..".wav")
					end)
				end
			end
		end)
	end
end

function cwCTO:SetPlayerBiosignal(player, bEnable)
	if (player:IsCombine()) then
		local isDisabledAlready = player:GetSharedVar("IsBiosignalGone")

		if (bEnable and !isDisabledAlready) then
			return self.ERROR_ALREADY_ENABLED
		elseif (!bEnable and isDisabledAlready) then
			return self.ERROR_ALREADY_DISABLED
		else
			if (bEnable) then
				player:SetSharedVar("IsBiosignalGone", false)

				timer.Simple(0.1, function()

					local location = Schema:PlayerGetLocation(player)

					-- Alert this unit.
					Schema:AddCombineDisplayLine("Соединение восстановлено...", Color(0, 255, 0, 255), player)

					local digits = string.match(player:Name(), "%d%d%d%d?%d?") or 0

					-- Alert all units.
					Schema:AddCombineDisplayLine("Загрузка обнаруженного биосигнала...", Color(255, 255, 255, 255))
					Schema:AddCombineDisplayLine("ТРЕВОГА! Обнаружен некомбинированный биосигнал юнита "..digits..". Локация: "..location.."...", Color(0, 255, 0, 255))

					for k, v in ipairs( _player.GetAll() ) do
						if (Schema:PlayerIsCombine(v) and !v:GetSharedVar("IsBiosignalGone")) then
							v:EmitSound("npc/metropolice/vo/on"..math.random(1, 2)..".wav")
							v:EmitSound("npc/overwatch/radiovoice/engagingteamisnoncohesive.wav")
						end
					end

					timer.Simple(1.5, function()
						for k, v in ipairs( _player.GetAll() ) do
							if (Schema:PlayerIsCombine(v) and !v:GetSharedVar("IsBiosignalGone")) then
								v:EmitSound("npc/metropolice/vo/off"..math.random(1, 4)..".wav")
							end
						end
					end)

				end)
			else
				-- Alert this unit.
				Schema:AddCombineDisplayLine("ERROR! Shutting down...", Color(255, 0, 0, 255), player)

				self:DoPostBiosignalLoss(player)
			end

			return self.ERROR_NONE
		end
	else
		return self.ERROR_NOT_COMBINE
	end
end

-- Called just after a player spawns.
function cwCTO:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	player:SetSharedVar("IsBiosignalGone", false)

	if (player:IsCombine()) then
		netstream.Start(player, "RecalculateHUDObjectives", {cwCTO.socioStatus, Schema.combineObjectives})
	end

	if (!self.fixedCameras) then
		for combineCamera, data in pairs(self.cameraData) do
			-- This is documented as the "Start Inactive" flag by Valve for combine cameras.
			if (!combineCamera:HasSpawnFlags(SF_NPC_WAIT_FOR_SCRIPT)) then
				combineCamera:Fire("Enable")
			end

			if (!combineCamera:CreatedByMap()) then
				-- Essentially statics the NPC so that it will load when the server restarts.
				combineCamera:SetNetworkedString( "cw_Name", " " )
				combineCamera:SetNetworkedString( "cw_Title", " " )
			end
		end

		self.fixedCameras = true
	end
end

function cwCTO:DispatchRequestSignal(player, text)
	local players = {}

	for k, v in ipairs( _player.GetAll() ) do
		if (Schema:PlayerIsCombine(v) and !v:GetSharedVar("IsBiosignalGone")) then
			players[#players + 1] = v

			v:EmitSound("npc/metropolice/vo/on"..math.random(1, 2)..".wav")
			v:EmitSound("npc/overwatch/radiovoice/allteamsrespondcode3.wav")
		end
	end

	timer.Simple(1.8, function()
		for k, v in ipairs( _player.GetAll() ) do
			if (Schema:PlayerIsCombine(v) and !v:GetSharedVar("IsBiosignalGone")) then
				v:EmitSound("npc/metropolice/vo/off"..math.random(1, 4)..".wav")
			end
		end
	end)

	netstream.Start(players, "CombineRequestSignal", {player, text})
end

-- Called when a player has been ragdolled.
function cwCTO:PlayerRagdolled(player, state, ragdoll)
	if (player:IsCombine() and !player:GetSharedVar("IsBiosignalGone")) then
		if (state == RAGDOLL_KNOCKEDOUT) then
			local location = Schema:PlayerGetLocation(player)
			local digits = string.match(player:Name(), "%d%d%d%d?%d?") or 0

			Schema:AddCombineDisplayLine("Загрузка данных о травме...", Color(255, 255, 255, 255))
			Schema:AddCombineDisplayLine("ВНИМАНИЕ! Юнит "..digits.." потерял сознание. Локация: "..location.."...", Color(255, 0, 0, 255))
		end
	end
end

-- Called when Clockwork has loaded all of the entities.
function cwCTO:InitPostEntity()
	for k, v in pairs( ents.FindByClass("npc_combine_camera") ) do
		if (self.cameraData[v] == nil) then
			self:SafelyPrepareCamera(v)
		end
	end
end

-- Called right after an Entity has been created.
function cwCTO:OnEntityCreated(entity)
	if (entity:GetClass() == "npc_combine_camera") then
		if (self.cameraData[entity] == nil) then
			self:SafelyPrepareCamera(entity)
		end
	end
end