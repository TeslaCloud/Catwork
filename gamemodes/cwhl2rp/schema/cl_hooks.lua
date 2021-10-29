--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function Schema:Initialize()
	if (!file.Exists("catwork", "DATA")) then
		file.CreateDir("catwork")
	end

	self:DownloadMaterial("http://teslacdn.net/files/meow/icon_mrmeow.png", "catwork/icon_mrmeow.png")
	self:DownloadMaterial("http://teslacdn.net/files/meow/icon_luna.png", "catwork/icon_luna.png")
end

-- Called when the local player's business is rebuilt.
function Schema:PlayerBusinessRebuilt(panel, categories)
	local businessName = cw.option:GetKey("name_business", true)

	if (!self.businessPanel) then
		self.businessPanel = panel
	end

	if (config.Get("permits"):Get() and cw.client:GetFaction() == FACTION_CITIZEN) then
		local permits = {}

		for k, v in pairs(item.GetAll()) do
			if (v.cost and v.access and !cw.core:HasObjectAccess(cw.client, v)) then
				if (string.find(v.access, "1")) then
					permits.generalGoods = (permits.generalGoods or 0) + (v.cost * v.batch)
				else
					for k2, v2 in pairs(Schema.customPermits) do
						if (string.find(v.access, v2.flag)) then
							permits[v2.key] = (permits[v2.key] or 0) + (v.cost * v.batch)

							break
						end
					end
				end
			end
		end

		if (table.Count(permits) > 0) then
			local panelList = vgui.Create("DPanelList", panel)

			panel.permitsForm = vgui.Create("DForm")
			panel.permitsForm:SetName("Permits")
			panel.permitsForm:SetPadding(4)

			panelList:SetAutoSize(true)
			panelList:SetPadding(4)
			panelList:SetSpacing(4)

			if (cw.player:HasFlags(cw.client, "x")) then
				for k, v in pairs(permits) do
					panel.customData = {information = v}

					if (k == "generalGoods") then
						panel.customData.description = "Приобретите разрешение, чтобы открыть свой бизнес."
						panel.customData.Callback = function()
							cw.core:RunCommand("PermitBuy", "generalgoods")
						end
						panel.customData.model = "models/props_junk/cardboard_box004a.mdl"
						panel.customData.name = "General Goods"
					else
						for k2, v2 in pairs(Schema.customPermits) do
							if (v2.key == k) then
								panel.customData.description = "Приобретите разрешение, чтобы получить возможность покупать "..string.lower(v2.name).."."
								panel.customData.Callback = function()
									cw.core:RunCommand("PermitBuy", k2)
								end
								panel.customData.model = v2.model
								panel.customData.name = v2.name

								break
							end
						end
					end

					panelList:AddItem(vgui.Create("cwBusinessCustom", panel))
				end
			else
				panel.customData = {
					description = "Создать бизнес, позволяющий приобретать разрешения.",
					information = config.Get("business_cost"):Get(),
					Callback = function()
						cw.core:RunCommand("PermitBuy", "business")
					end,
					model = "models/props_c17/briefcase001a.mdl",
					name = "Создать бизнес"
				}

				panelList:AddItem(vgui.Create("cwBusinessCustom", panel))
			end

			panel.permitsForm:AddItem(panelList)
			panel.panelList:AddItem(panel.permitsForm)
		end
	end
end

-- Called when the target player's fade distance is needed.
function Schema:GetTargetPlayerFadeDistance(player)
	if (IsValid(self:GetScannerEntity(cw.client))) then
		return 512
	end
end

-- Called when an entity's menu options are needed.
function Schema:GetEntityMenuOptions(entity, options)
	if (entity:GetClass() == "prop_ragdoll") then
		local player = cw.entity:GetPlayer(entity)

		if (!player or !player:Alive()) then
			options[L"Loot"] = "cw_corpseLoot"
		end
	elseif (entity:GetClass() == "cw_belongings") then
		options[L"Open"] = "cw_belongingsOpen"
	elseif (entity:GetClass() == "cw_breach") then
		options[L"Charge"] = "cw_breachCharge"
	elseif (entity:GetClass() == "cw_radio") then
		if (!entity:IsOff()) then
			options[L"Turn Off"] = "cw_radioToggle"
		else
			options[L"Turn On"] = "cw_radioToggle"
		end

		options[L"Set Frequency"] = function()
			Derma_StringRequest("Frequency", "What would you like to set the frequency to?", frequency, function(text)
				if (IsValid(entity)) then
					cw.entity:ForceMenuOption(entity, "Set Frequency", text)
				end
			end)
		end

		options[L"Take"] = "cw_radioTake"
	end
end

-- Called when a player's typing display position is needed.
function Schema:GetPlayerTypingDisplayPosition(player)
	local scannerEntity = self:GetScannerEntity(player)

	if (IsValid(scannerEntity)) then
		local position = nil
		local physBone = scannerEntity:LookupBone("Scanner.Body")
		local curTime = CurTime()

		if (physBone) then
			position = scannerEntity:GetBonePosition(physBone)
		end

		if (!position) then
			return scannerEntity:GetPos() + Vector(0, 0, 8)
		else
			return position
		end
	end
end

-- Called when an entity's target ID HUD should be painted.
function Schema:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = cw.option:GetColor("target_id")
	local colorWhite = cw.option:GetColor("white")

	if (entity:GetClass() == "prop_physics") then
		local physDesc = entity:GetNWString("physDesc")

		if (physDesc != "") then
			info.y = cw.core:DrawInfo(physDesc, info.x, info.y, colorWhite, info.alpha)
		end
	elseif (entity:IsNPC()) then
		local name = entity:GetNWString("cw_Name")
		local title = entity:GetNWString("cw_Title")

		if (name != "" and title != "") then
			info.y = cw.core:DrawInfo(name, info.x, info.y, Color(255, 255, 100, 255), info.alpha)
			info.y = cw.core:DrawInfo(title, info.x, info.y, Color(255, 255, 255, 255), info.alpha)
		end
	end
end

-- Called when a text entry has gotten focus.
function Schema:OnTextEntryGetFocus(panel)
	self.textEntryFocused = panel
end

-- Called when a text entry has lost focus.
function Schema:OnTextEntryLoseFocus(panel)
	self.textEntryFocused = nil
end

-- Called when screen space effects should be rendered.
function Schema:RenderScreenspaceEffects()
	if (!cw.core:IsScreenFadedBlack()) then
		local curTime = CurTime()

		if (self.flashEffect) then
			local timeLeft = math.Clamp(self.flashEffect[1] - curTime, 0, self.flashEffect[2])
			local incrementer = 1 / self.flashEffect[2]

			if (timeLeft > 0) then
				modify = {}

				modify["$pp_colour_brightness"] = 0
				modify["$pp_colour_contrast"] = 1 + (timeLeft * incrementer)
				modify["$pp_colour_colour"] = 1 - (incrementer * timeLeft)
				modify["$pp_colour_addr"] = incrementer * timeLeft
				modify["$pp_colour_addg"] = 0
				modify["$pp_colour_addb"] = 0
				modify["$pp_colour_mulr"] = 1
				modify["$pp_colour_mulg"] = 0
				modify["$pp_colour_mulb"] = 0

				DrawColorModify(modify)

				if (!self.flashEffect[3]) then
					DrawMotionBlur(1 - (incrementer * timeLeft), incrementer * timeLeft, self.flashEffect[2])
				end
			end
		end

		if (self:PlayerIsCombine(cw.client)) then
			render.UpdateScreenEffectTexture()

			self.combineOverlay:SetFloat("$refractamount", 0.3)
			self.combineOverlay:SetFloat("$envmaptint", 0)
			self.combineOverlay:SetFloat("$envmap", 0)
			self.combineOverlay:SetFloat("$alpha", 0.5)
			self.combineOverlay:SetInt("$ignorez", 1)

			render.SetMaterial(self.combineOverlay)
			render.DrawScreenQuad()
		end
	end
end

-- Called when the local player's motion blurs should be adjusted.
function Schema:PlayerAdjustMotionBlurs(motionBlurs)
	if (!cw.core:IsScreenFadedBlack()) then
		local curTime = CurTime()

		if (self.flashEffect and self.flashEffect[3]) then
			local timeLeft = math.Clamp(self.flashEffect[1] - curTime, 0, self.flashEffect[2])
			local incrementer = 1 / self.flashEffect[2]

			if (timeLeft > 0) then
				motionBlurs.blurTable["flash"] = 1 - (incrementer * timeLeft)
			end
		end
	end
end

-- Called when the cinematic intro info is needed.
function Schema:GetCinematicIntroInfo()
	return {
		credits = "Разработано "..self:GetAuthor()..".",
		title = config.Get("intro_text_big"):Get(),
		text = config.Get("intro_text_small"):Get()
	}
end

-- Called when the scoreboard's class players should be sorted.
function Schema:ScoreboardSortClassPlayers(class, a, b)
	if (class == "Civil Protection" or class == "Overwatch Transhuman Arm") then
		local rankA = self:GetPlayerCombineRank(a)
		local rankB = self:GetPlayerCombineRank(b)

		if (rankA == rankB) then
			return a:Name() < b:Name()
		else
			return rankA > rankB
		end
	end
end

-- Called when a player's scoreboard class is needed.
function Schema:GetPlayerScoreboardClass(player)
	local customClass = player:GetNetVar("customClass")
	local faction = player:GetFaction()

	if (customClass != "") then
		return customClass
	end

	if (faction == FACTION_MPF) then
		return "#Faction_MPF"
	elseif (faction == FACTION_OTA) then
		return "#Faction_OTA"
	end
end

-- Called when the local player's character screen faction is needed.
function Schema:GetPlayerCharacterScreenFaction(character)
	if (character.customClass and character.customClass != "") then
		return character.customClass
	end
end

-- Called when the local player attempts to zoom.
function Schema:PlayerCanZoom()
	if (!self:PlayerIsCombine(cw.client)) then
		return false
	end
end

-- Called when a player's scoreboard options are needed.
function Schema:GetPlayerScoreboardOptions(player, options, menu)
	if (cw.command:FindByID("PlyAddServerWhitelist")
	or cw.command:FindByID("PlyRemoveServerWhitelist")) then
		if (cw.player:HasFlags(cw.client, cw.command:FindByID("PlyAddServerWhitelist").access)) then
			options["Вайтлист сервера"] = {}

			if (cw.command:FindByID("PlyAddServerWhitelist")) then
				options["Вайтлист сервера"]["Добавить"] = function()
					Derma_StringRequest(player:Name(), "В вайтлист какого сервера Вы хотите добавить этого игрока?", "", function(text)
						cw.core:RunCommand("PlyAddServerWhitelist", player:Name(), text)
					end)
				end
			end

			if (cw.command:FindByID("PlyRemoveServerWhitelist")) then
				options["Вайтлист сервера"]["Изъять"] = function()
					Derma_StringRequest(player:Name(), "Из вайтлиста какого сервера Вы хотите удалить этого игрока?", "", function(text)
						cw.core:RunCommand("PlyRemoveServerWhitelist", player:Name(), text)
					end)
				end
			end
		end
	end

	if (cw.command:FindByID("CharSetCustomClass")) then
		if (cw.player:HasFlags(cw.client, cw.command:FindByID("CharSetCustomClass").access)) then
			options["Польз. класс"] = {}
			options["Польз. класс"]["Установить"] = function()
				Derma_StringRequest(player:Name(), "Каким будет пользовательский класс этого игрока?", player:GetNetVar("customClass"), function(text)
					cw.core:RunCommand("CharSetCustomClass", player:Name(), text)
				end)
			end

			if (player:GetNetVar("customClass") != "") then
				options["Польз. класс"]["Удалить"] = function()
					cw.core:RunCommand("CharTakeCustomClass", player:Name())
				end
			end
		end
	end

	if (cw.command:FindByID("CharPermaKill")) then
		if (cw.player:HasFlags(cw.client, cw.command:FindByID("CharPermaKill").access)) then
			options["Перм. убийство"] = function()
				RunConsoleCommand("aura", "CharPermaKill", player:Name())
			end
		end
	end
end

-- Called when the scoreboard's player info should be adjusted.
function Schema:ScoreboardAdjustPlayerInfo(info)
	if (self:IsPlayerCombineRank(info.player, "SCN")) then
		if (self:IsPlayerCombineRank(info.player, "SYNTH")) then
			info.model = "models/shield_scanner.mdl"
		else
			info.model = "models/combine_scanner.mdl"
		end
	end
end

-- Called when the local player's class model info should be adjusted.
function Schema:PlayerAdjustClassModelInfo(class, info)
	if (class == CLASS_MPS) then
		if (self:IsPlayerCombineRank(cw.client, "SCN")
		and self:IsPlayerCombineRank(cw.client, "SYNTH")) then
			info.model = "models/shield_scanner.mdl"
		else
			info.model = "models/combine_scanner.mdl"
		end
	end
end

-- Called when the local player's default colorify should be set.
function Schema:PlayerSetDefaultColorModify(colorModify)
	colorModify["$pp_colour_brightness"] = -0.02
	colorModify["$pp_colour_contrast"] = 1.2
	colorModify["$pp_colour_colour"] = 0.5
end

-- Called when the local player's colorify should be adjusted.
function Schema:PlayerAdjustColorModify(colorModify)
	local antiDepressants = cw.client:GetNetVar("antidepressants")
	local frameTime = FrameTime()
	local interval = FrameTime() / 10
	local curTime = CurTime()

	if (!self.colorModify) then
		self.colorModify = {
			brightness = colorModify["$pp_colour_brightness"],
			contrast = colorModify["$pp_colour_contrast"],
			color = colorModify["$pp_colour_colour"]
		}
	end

	if (antiDepressants) then
		if (antiDepressants > curTime) then
			self.colorModify.brightness = math.Approach(self.colorModify.brightness, 0,interval)
			self.colorModify.contrast = math.Approach(self.colorModify.contrast, 1, interval)
			self.colorModify.color = math.Approach(self.colorModify.color, 1, interval)
		else
			self.colorModify.brightness = math.Approach(self.colorModify.brightness, colorModify["$pp_colour_brightness"], interval)
			self.colorModify.contrast = math.Approach(self.colorModify.contrast, colorModify["$pp_colour_contrast"], interval)
			self.colorModify.color = math.Approach(self.colorModify.color, colorModify["$pp_colour_colour"], interval)
		end
	end

	colorModify["$pp_colour_brightness"] = self.colorModify.brightness
	colorModify["$pp_colour_contrast"] = self.colorModify.contrast
	colorModify["$pp_colour_colour"] = self.colorModify.color
end

-- Called when the local player attempts to see a class.
function Schema:PlayerCanSeeClass(class)
	if (class.index == CLASS_MPS and !self:IsPlayerCombineRank(cw.client, "SCN")) then
		return false
	elseif (class.index == CLASS_MPR and !self:IsPlayerCombineRank(cw.client, "RCT")) then
		return false
	elseif (class.index == CLASS_EMP and !self:IsPlayerCombineRank(cw.client, "EpU")) then
		return false
	elseif (class.index == CLASS_OWS and !self:IsPlayerCombineRank(cw.client, "OWS")) then
		return false
	elseif (class.index == CLASS_OWC and !self:IsPlayerCombineRank(cw.client, "OWC")) then
		return false
	elseif (class.index == CLASS_EOW and !self:IsPlayerCombineRank(cw.client, "EOW")) then
		return false
	elseif (class.index == CLASS_MPU) then
		if (self:IsPlayerCombineRank(cw.client, "SCN") or self:IsPlayerCombineRank(cw.client, "EpU")
		or self:IsPlayerCombineRank(cw.client, "RCT")) then
			return false
		end
	end
end

-- Called when the target's status should be drawn.
function Schema:DrawTargetPlayerStatus(target, alpha, x, y)
	local informationColor = cw.option:GetColor("information")
	local thirdPerson = "его"
	local mainStatus
	local untieText
	local gender = "Он"
	local action = cw.player:GetAction(target)

	if (target:GetGender() == GENDER_FEMALE) then
		thirdPerson = "ее"
		gender = "Она"
	end

	if (target:Alive()) then
		if (action == "die") then
			mainStatus = gender.." в критическом состоянии."
		end

		if (target:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
			mainStatus = gender.." без сознания."
		end

		if (target:GetNetVar("tied") != 0) then
			if (cw.player:GetAction(cw.client) == "untie") then
				mainStatus = gender.. " развязывается."
			else
				local untieText

				if (target:GetShootPos():Distance(cw.client:GetShootPos()) <= 192) then
					if (cw.client:GetNetVar("tied") == 0) then
						mainStatus = "Нажмите :+use:, чтобы развязать "..thirdPerson.."."

						untieText = true
					end
				end

				if (!untieText) then
					mainStatus = gender.." связан(а)."
				end
			end
		elseif (cw.player:GetAction(cw.client) == "tie") then
			mainStatus = gender.." связывается."
		end

		if (mainStatus) then
			y = cw.core:DrawInfo(cw.core:ParseData(mainStatus), x, y, informationColor, alpha)
		end

		return y
	end
end

-- Called when the player info text is needed.
function Schema:GetPlayerInfoText(playerInfoText)
	local citizenID = cw.client:GetNetVar("citizenID") or "ERROR"

	if (citizenID) then
		if (cw.client:GetFaction() == FACTION_CITIZEN) then
			playerInfoText:Add("CITIZEN_ID", "CID: #"..citizenID)
		end
	end
end

-- Called to check if a player does have an flag.
function Schema:PlayerDoesHaveFlag(player, flag)
	if (!config.GetVal("permits")) then
		if (flag == "x" or flag == "1") then
			return false
		end

		for k, v in pairs(self.customPermits) do
			if (v.flag == flag) then
				return false
			end
		end
	end
end

-- Called to check if a player does recognise another player.
function Schema:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
	if (self:PlayerIsCombine(player) or player:GetFaction() == FACTION_ADMIN) then
		return true
	end
end

-- Called each tick.
function Schema:Tick()
	if (IsValid(cw.client)) then
		if (self:PlayerIsCombine(cw.client)) then
			local curTime = CurTime()
			local health = cw.client:Health()
			local armor = cw.client:Armor()

			if (!self.nextHealthWarning or curTime >= self.nextHealthWarning) then
				if (self.lastHealth) then
					if (health < self.lastHealth) then
						if (health == 0) then
							self:AddCombineDisplayLine("ОШИБКА! Отключение...", Color(255, 0, 0, 255))
						else
							self:AddCombineDisplayLine("ВНИМАНИЕ! Обнаружены телесные травмы...", Color(255, 0, 0, 255))
						end

						self.nextHealthWarning = curTime + 2
					elseif (health > self.lastHealth) then
						if (health == 100) then
							self:AddCombineDisplayLine("Физические показатели организма восстановлены...", Color(0, 255, 0, 255))
						else
							self:AddCombineDisplayLine("Восстановление физ. показателей здоровья...", Color(0, 0, 255, 255))
						end

						self.nextHealthWarning = curTime + 2
					end
				end

				if (self.lastArmor) then
					if (armor < self.lastArmor) then
						if (armor == 0) then
							self:AddCombineDisplayLine("ВНИМАНИЕ! Внешняя защита исчерпана...", Color(255, 0, 0, 255))
						else
							self:AddCombineDisplayLine("ВНИМАНИЕ! Внешняя защита повреждена...", Color(255, 0, 0, 255))
						end

						self.nextHealthWarning = curTime + 2
					elseif (armor > self.lastArmor) then
						if (armor == 100) then
							self:AddCombineDisplayLine("Внешняя защита восстановлена...", Color(0, 255, 0, 255))
						else
							self:AddCombineDisplayLine("Восстановление внешней защиты...", Color(0, 0, 255, 255))
						end

						self.nextHealthWarning = curTime + 2
					end
				end
			end

			if (!self.nextRandomLine or curTime >= self.nextRandomLine) then
				local text = self.randomDisplayLines[math.random(1, #self.randomDisplayLines)]

				if (text and self.lastRandomDisplayLine != text) then
					self:AddCombineDisplayLine(text)

					self.lastRandomDisplayLine = text
				end

				self.nextRandomLine = curTime + 3
			end

			self.lastHealth = health
			self.lastArmor = armor
		end
	end
end

-- Called when the foreground HUD should be painted.
function Schema:HUDPaintForeground()
	local curTime = CurTime()

	if (cw.client:Alive()) then
		if (self.stunEffects) then
			for k, v in pairs(self.stunEffects) do
				local alpha = math.Clamp((255 / v[2]) * (v[1] - curTime), 0, 255)

				if (alpha != 0) then
					draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha))
				else
					table.remove(self.stunEffects, k)
				end
			end
		end
	end
end

-- Called when the top screen HUD should be painted.
function Schema:HUDPaintTopScreen(info)
	local blackFadeAlpha = cw.core:GetBlackFadeAlpha()
	local colorWhite = cw.option:GetColor("white")
	local curTime = CurTime()

	if (self:PlayerIsCombine(cw.client) and self.combineDisplayLines) then
		local height = draw.GetFontHeight("BudgetLabel")

		for k, v in ipairs(self.combineDisplayLines) do
			if (curTime >= v[2]) then
				table.remove(self.combineDisplayLines, k)
			else
				local color = v[4] or colorWhite
				local textColor = Color(color.r, color.g, color.b, 255 - blackFadeAlpha)

				draw.SimpleText(string.sub(v[1], 1, v[3]), "BudgetLabel", info.x, info.y, textColor)

				if (v[3] < string.len(v[1])) then
					v[3] = v[3] + 1
				end

				info.y = info.y + height
			end
		end
	end
end

-- Called to get the screen text info.
function Schema:GetScreenTextInfo()
	local blackFadeAlpha = cw.core:GetBlackFadeAlpha()

	if (cw.client:GetNetVar("permaKilled")) then
		return {
			alpha = blackFadeAlpha,
			title = "ЭТОТ ПЕРСОНАЖ МЕРТВ",
			text = "Выйдите в меню персонажей и создайте нового."
		}
	elseif (cw.client:GetNetVar("beingTied")) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "ВАС СВЯЗЫВАЮТ"
		}
	elseif (cw.client:GetNetVar("tied") != 0) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "ВЫ СВЯЗАНЫ"
		}
	end
end

-- Called when the chat box info should be adjusted.
function Schema:ChatBoxAdjustInfo(info)
	if (IsValid(info.speaker)) then
		if (info.data.anon) then
			info.name = "Кто-то"
		end

		if (self:PlayerIsCombine(info.speaker)) then
			if (self:IsPlayerCombineRank(info.speaker, "SCN")) then
				if (info.class == "radio" or info.class == "radio_eavesdrop") then
					info.name = "Dispatch"
				end
			end
		end
	end
end
