local cwCTO = cwCTO

cwCTO.biosignalLocations = {}
cwCTO.requestLocations = {}

cwCTO.cameraData = cwCTO.cameraData or {}
cwCTO.hudObjectives = cwCTO.hudObjectives or {}
cwCTO.socioStatus = cwCTO.socioStatus or "GREEN"

cwCTO.debug_paintBenchmark = cwCTO.debug_paintBenchmark or 0

function cwCTO:UpdateBiosignalLocations()
	local curTime = CurTime()

	-- Clear expired requests.
	for i, data in ipairs(self.requestLocations) do
		if (curTime - data.time >= 60) then
			self.requestLocations[i] = nil
		end
	end

	-- Clear active biosignals and expired lost biosignals.
	for unit, data in pairs(self.biosignalLocations) do
		if (!IsValid(unit) or !Schema:PlayerIsCombine(unit) or (!cw.client:GetSharedVar("IsBiosignalGone") and !unit:GetSharedVar("IsBiosignalGone")) or curTime - data.time >= 120) then
			self.biosignalLocations[unit] = nil
		end

		data.isLost = true
	end

	-- Add active biosignals, update camera data.
	if (!cw.client:GetSharedVar("IsBiosignalGone")) then
		for _, v in pairs( _player.GetAll() ) do
			if (Schema:PlayerIsCombine(v) and v ~= cw.client and !v:GetSharedVar("IsBiosignalGone") and v:Alive()) then
				local physBone = v:LookupBone("ValveBiped.Bip01_Head1")
				local position

				if (physBone) then
					local bonePosition = v:GetBonePosition(physBone)

					if (bonePosition) then
						position = bonePosition + Vector(0, 0, 16)
					end
				else
					position = v:GetPos() + Vector(0, 0, 80)
				end

				self.biosignalLocations[v] = {
					pos = position,
					time = curTime,
					isLost = false,
					isKnockedOut = v:GetRagdollState() == RAGDOLL_KNOCKEDOUT,
					digits = string.match(v:Name(), "%d%d%d%d?%d?") or "???"
				}
			end
		end
	end
end

-- Called when the foreground HUD should be painted.
function cwCTO:HUDPaintForeground()
	local startTime = SysTime()

	if (Schema:PlayerIsCombine(cw.client)) then
		local colorWhite = cw.option:GetColor("white")
		local colorRed = Color(255, 0, 0, 255)
		local colorObject = Color(150, 150, 200, 255)
		local fontHeight = draw.GetFontHeight("BudgetLabel")

		local curTime = CurTime()

		local lowDetailBox = math.floor(ScrW() / 10)
		local halfScrVector = Vector(ScrW() / 2, ScrH() / 2)
		local lowDetailText = "<...>"

		local requestColor = Color(175, 125, 100, 255)

		for unit, data in pairs(self.biosignalLocations) do
			if (!IsValid(unit) or curTime - data.time >= 120) then
				self.biosignalLocations[unit] = nil
			elseif (!cw.player:IsNoClipping(unit)) then
				local toScreen = data.pos:ToScreen()

				if (toScreen.visible) then
					local text = "<:: " .. data.digits .. " ::>"
					local color = _team.GetColor(unit:Team()) or colorWhite

					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)

					if (showDetail) then
						text = "<:: " .. unit:Name() .. " ::>"
					end

					local timeSince = math.Round(curTime - data.time, 2)
					timeSince = timeSince .. string.rep(0, (string.len(math.floor(timeSince)) + 3) - string.len(timeSince))

					if (data.isLost) then
						local text2 = "<:: Потерян " .. timeSince .. "с ::>"

						local timeUntil = math.Round((120 - (curTime - data.time)), 2)
						timeUntil = timeUntil .. string.rep(0, (string.len(math.floor(timeUntil)) + 3) - string.len(timeUntil))

						draw.SimpleText(text, "BudgetLabel", toScreen.x, toScreen.y, color, 1, 1)
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText(text2, "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText("<:: Удаление " .. timeUntil .. "с ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
					else
						local text2 = "<:: Получен " .. timeSince .. "с ::>"
						draw.SimpleText(text, "BudgetLabel", toScreen.x, toScreen.y, color, 1, 1)
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText(showDetail and text2 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, colorWhite, 1, 1)

						if (data.isKnockedOut) then
							toScreen.y = toScreen.y + fontHeight
							draw.SimpleText("<:: Без сознания ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
						end
					end
				end
			end
		end

		for i, data in ipairs(self.requestLocations) do
			if (curTime - data.time >= 60) then
				self.requestLocations[i] = nil
			else
				local toScreen = data.pos:ToScreen()

				if (toScreen.visible) then
					local text2 = "<:: " .. data.text .. " ::>"

					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)

					local timeUntil = math.Round((60 - (curTime - data.time)), 2)
					timeUntil = timeUntil .. string.rep(0, (string.len(math.floor(timeUntil)) + 3) - string.len(timeUntil))

					draw.SimpleText("<:: Запрос помощи ::>", "BudgetLabel", toScreen.x, toScreen.y, requestColor, 1, 1)
					toScreen.y = toScreen.y + fontHeight
					draw.SimpleText(showDetail and text2 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, colorWhite, 1, 1)
					toScreen.y = toScreen.y + fontHeight
					draw.SimpleText("<:: Удаление " .. timeUntil .. "s ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
				end
			end
		end

		for combineCamera, data in pairs(self.cameraData) do
			if (IsValid(combineCamera)) then
				local toScreen = combineCamera:GetPos():ToScreen()

				if (toScreen.visible) then
					local text1 = "<:: C-i" .. combineCamera:EntIndex() .. " ::>"
					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)

					draw.SimpleText(showDetail and text1 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, colorObject, 1, 1)

					if (type(data) == "table") then
						local text2 = "<:: " .. table.Count(data) .. " в поле видимости ::>"

						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText(showDetail and text2 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, colorWhite, 1, 1)

						local violations = {}

						for player, vios in pairs(data) do
							for i, vio in ipairs(vios) do
								if (vio == self.VIOLATION_RUNNING) then
									violations[#violations + 1] = "<:: 1 x Бег ::>"
								elseif (vio == self.VIOLATION_JUMPING) then
									violations[#violations + 1] = "<:: 1 x Прыжок ::>"
								elseif (vio == self.VIOLATION_CROUCHING) then
									violations[#violations + 1] = "<:: 1 x сидя ::>"
								elseif (vio == self.VIOLATION_FALLEN_OVER) then
									violations[#violations + 1] = "<:: 1 x Нахождение лёжа ::>"
								end
							end
						end

						if (#violations > 0) then
							toScreen.y = toScreen.y + fontHeight
							draw.SimpleText("<:: Нарушения в поле видимости ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)

							for i, violation in ipairs(violations) do
								toScreen.y = toScreen.y + fontHeight
								draw.SimpleText(showDetail and violation or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, colorWhite, 1, 1)
							end
						end
					else
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText("<:: Отключено ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
					end
				end
			end
		end

		local clientEyePos = cw.client:EyePos()
		local maximumDistance = 2048

		-- If we are using suit zoom.
		if (cw.client:GetFOV() < 40) then
			maximumDistance = maximumDistance * 3
		end

		for _, v in pairs( _player.GetAll() ) do
			if (!(Schema:PlayerIsCombine(v) and !v:GetSharedVar("IsBiosignalGone")) and clientEyePos:Distance(v:GetPos()) <= maximumDistance and !cw.player:IsNoClipping(v)) then
				local physBone = v:LookupBone("ValveBiped.Bip01_Head1")
				local position = nil
									
				if (physBone) then
					local bonePosition = v:GetBonePosition(physBone)

					if (bonePosition) then
						position = bonePosition + Vector(0, 0, 16)
					end
				else
					position = v:GetPos() + Vector(0, 0, 80)
				end

				local toScreen = position:ToScreen()

				if (toScreen.visible and cw.client:IsLineOfSightClear(v)) then
					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)

					local violations = {}

					if (v:IsRunning()) then
						violations[#violations + 1] = "<:: 1 x Бег ::>"
					end

					if (v.m_bJumping) then
						violations[#violations + 1] = "<:: 1 x Прыжок ::>"
					end

					if (v:Crouching()) then
						violations[#violations + 1] = "<:: 1 x Нахождение сидя ::>"
					end

					if (v:GetRagdollState() ~= RAGDOLL_NONE and v:GetRagdollState() ~= RAGDOLL_RESET) then
						violations[#violations + 1] = "<:: 1 x Нахождение лёжа ::>"
					end

					if (#violations > 0) then
						draw.SimpleText("<:: Возможное нарушение ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)

						for i, violation in ipairs(violations) do
							toScreen.y = toScreen.y + fontHeight
							draw.SimpleText(showDetail and violation or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, colorWhite, 1, 1)
						end
					end
				end
			end
		end
	end

	self.debug_paintBenchmark = SysTime() - startTime
end

netstream.Hook("CombineRequestSignal", function(data)
	local player = data[1]
	local text = data[2]

	if (IsValid(player)) then
		local physBone = player:LookupBone("ValveBiped.Bip01_Head1")
		local position

		if (physBone) then
			local bonePosition = player:GetBonePosition(physBone)

			if (bonePosition) then
				position = bonePosition + Vector(0, 0, 16)
			end
		else
			position = player:GetPos() + Vector(0, 0, 80)
		end

		table.insert(cwCTO.requestLocations, {
			time = CurTime(),
			pos = position,
			text = text
		})
	end
end)

netstream.Hook("UpdateBiosignalCameraData", function(data)
	local newCameraData = {}

	for entIndex, players in pairs(data) do
		local combineCamera = Entity(entIndex)

		if (IsValid(combineCamera)) then
			newCameraData[combineCamera] = players
		end
	end

	cwCTO.cameraData = newCameraData
end)

netstream.Hook("RecalculateHUDObjectives", function(data)
	local lines = {}

	for k, v in pairs( string.Split(data[2], "\n") ) do
		if (string.StartWith(v, "^")) then
			table.insert(lines, "<:: " .. string.sub(v, 2) .. " ::>")
		end
	end

	cwCTO.socioStatus = data[1]
	cwCTO.hudObjectives = lines
end)

-- Called when the top screen HUD should be painted.
function cwCTO:HUDPaintTopScreen()
	local blackFadeAlpha = cw.core:GetBlackFadeAlpha()
	local colorWhite = cw.option:GetColor("white")

	local info = { x = ScrW() - 8, y = 8 }

	if (Schema:PlayerIsCombine(cw.client)) then
		local height = draw.GetFontHeight("BudgetLabel")

		local socioColor = self.sociostatusColors[self.socioStatus] or colorWhite

		if (self.socioStatus == "BLACK") then
			local tsin = TimedSin(1, 0, 255, 0)
			socioColor = Color(tsin, tsin, tsin)
		end

		socioColor = Color(socioColor.r, socioColor.g, socioColor.b, 255 - blackFadeAlpha)

		draw.SimpleText("<:: Социальный статус: "..self.socioStatus.." ::>", "BudgetLabel", info.x, info.y, socioColor, TEXT_ALIGN_RIGHT)
		info.y = info.y + height

		for k, v in ipairs(self.hudObjectives) do
			local textColor = Color(colorWhite.r, colorWhite.g, colorWhite.b, 255 - blackFadeAlpha)
				
			draw.SimpleText(v, "BudgetLabel", info.x, info.y, textColor, TEXT_ALIGN_RIGHT)
				
			info.y = info.y + height
		end
	end
end