--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

netstream.Hook("RunCommand", function(data)
	RunConsoleCommand(unpack(data))
end)

netstream.Hook("SharedTables", function(data)
	cw.SharedTables = data
end)

netstream.Hook("SetSharedTableVar", function(data)
	cw.SharedTables[data.sharedTable] = cw.SharedTables[data.sharedTable] or {}
	cw.SharedTables[data.sharedTable][data.key] = data.value
end)

netstream.Hook("HiddenCommands", function(data)
	for k, v in pairs(data) do
		for k2, v2 in pairs(cw.command:GetAll()) do
			if (cw.core:GetShortCRC(k2) == v) then
				cw.command:SetHidden(k2, true)

				break
			end
		end
	end
end)

netstream.Hook("OrderTime", function(data)
	cw.OrderCooldown = data

	local activePanel = cw.menu:GetActivePanel()

	if (activePanel and activePanel:GetPanelName() == cw.option:GetKey("name_business")) then
		activePanel:Rebuild()
	end
end)

netstream.Hook("CharacterInit", function(data)
	hook.Run("PlayerCharacterInitialized", data)
end)

netstream.Hook("Log", function(data)
	local logType = data.logType
	local text = data.text

	cw.core:PrintColoredText(cw.core:GetLogTypeColor(logType), text)
end)

netstream.Hook("StartSound", function(data)
	if (IsValid(cw.client)) then
		local uniqueID = data.uniqueID
		local sound = data.sound
		local volume = data.volume

		if (!cw.clientSounds) then
			cw.clientSounds = {}
		end

		if (cw.clientSounds[uniqueID]) then
			cw.clientSounds[uniqueID]:Stop()
		end

		cw.clientSounds[uniqueID] = CreateSound(cw.client, sound)
		cw.clientSounds[uniqueID]:PlayEx(volume, 100)
	end
end)

netstream.Hook("StopSound", function(data)
	local uniqueID = data.uniqueID
	local fadeOut = data.fadeOut

	if (!cw.clientSounds) then
		cw.clientSounds = {}
	end

	if (cw.clientSounds[uniqueID]) then
		if (fadeOut != 0) then
			cw.clientSounds[uniqueID]:FadeOut(fadeOut)
		else
			cw.clientSounds[uniqueID]:Stop()
		end

		cw.clientSounds[uniqueID] = nil
	end
end)

netstream.Hook("InfoToggle", function(data)
	if (IsValid(cw.client) and cw.client:HasInitialized()) then
		if (!cw.InfoMenuOpen) then
			cw.InfoMenuOpen = true
			cw.core:RegisterBackgroundBlur("InfoMenu", SysTime())
		else
			cw.core:RemoveBackgroundBlur("InfoMenu")
			cw.core:CloseActiveDermaMenus()
			cw.InfoMenuOpen = false
		end
	end
end)

netstream.Hook("PlaySound", function(data)
	surface.PlaySound(data)
end)

netstream.Hook("DataStreaming", function(data)
	netstream.Start("DataStreamInfoSent", true)
end)

netstream.Hook("DataStreamed", function(data)
	cw.DataHasStreamed = true
end)

netstream.Hook("QuizCompleted", function(data)
	if (!data) then
		if (!cw.quiz:GetCompleted()) then
			gui.EnableScreenClicker(true)

			cw.quiz.panel = vgui.Create("cw.quiz")
			cw.quiz.panel:Populate()
			cw.quiz.panel:MakePopup()
		end
	else
		local characterPanel = cw.character:GetPanel()
		local quizPanel = cw.quiz:GetPanel()

		cw.quiz:SetCompleted(true)

		if (quizPanel) then
			quizPanel:Remove()
		end
	end
end)

netstream.Hook("RecogniseMenu", function(data)
	local menuPanel = cw.core:AddMenuFromData(nil, {
		["#RecogniseMenu_whisper"] = function()
			netstream.Start("RecogniseOption", "whisper")
		end,
		["#RecogniseMenu_yell"] = function()
			netstream.Start("RecogniseOption", "yell")
		end,
		["#RecogniseMenu_talk"] = function()
			netstream.Start("RecogniseOption", "talk")
		end,
		["#RecogniseMenu_look"] = function()
			netstream.Start("RecogniseOption", "look")
		end
	})

	if (IsValid(menuPanel)) then
		menuPanel:SetPos(
			(ScrW() / 2) - (menuPanel:GetWide() / 2), (ScrH() / 2) - (menuPanel:GetTall() / 2)
		)
	end

	cw.core:SetRecogniseMenu(menuPanel)
end)

netstream.Hook("ClockworkIntro", function(data)
	if (!cw.ClockworkIntroFadeOut) then
		local introImage = cw.option:GetKey("intro_image")
		local introSound = cw.option:GetKey("intro_sound")
		local duration = 8
		local curTime = UnPredictedCurTime()

		if (introImage != "") then
			duration = 16
		end

		cw.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8)
		cw.ClockworkIntroFadeOut = curTime + duration
		cw.ClockworkIntroSound = CreateSound(cw.client, introSound)
		cw.ClockworkIntroSound:PlayEx(0.75, 100)

		timer.Simple(duration - 4, function()
			cw.ClockworkIntroSound:FadeOut(4)
			cw.ClockworkIntroSound = nil
		end)

		surface.PlaySound("buttons/button1.wav")
	end
end)

netstream.Hook("SharedVar", function(data)
	local key = data.key
	local sharedVars = cw.core:GetSharedVars():Player()

	if (sharedVars and sharedVars[key]) then
		local sharedVarData = sharedVars[key]

		if (sharedVarData) then
			sharedVarData.value = data.value
		end
	end
end)

netstream.Hook("HideCommand", function(data)
	local index = data.index

	for k, v in pairs(cw.command:GetAll()) do
		if (cw.core:GetShortCRC(k) == index) then
			cw.command:SetHidden(k, data.hidden)

			break
		end
	end
end)

netstream.Hook("CfgListVars", function(data)
	cw.client:PrintMessage(2, "######## [Catwork] Config ########\n")
		local sSearchData = data
		local tConfigRes = {}

		if (sSearchData) then
			sSearchData = string.lower(sSearchData)
		end

		for k, v in pairs(config.GetStored()) do
			if (type(v.value) != "table" and (!sSearchData
			or string.find(string.lower(k), sSearchData)) and !v.isStatic) then
				if (v.isPrivate) then
					tConfigRes[#tConfigRes + 1] = {
						k, string.rep("*", string.utf8len(tostring(v.value)))
					}
				else
					tConfigRes[#tConfigRes + 1] = {
						k, tostring(v.value)
					}
				end
			end
		end

		table.sort(tConfigRes, function(a, b)
			return a[1] < b[1]
		end)

		for k, v in pairs(tConfigRes) do
			local systemValues = config.GetFromSystem(v[1])

			if (systemValues) then
				cw.client:PrintMessage(2, "// "..systemValues.help.."\n")
			end

			cw.client:PrintMessage(2, v[1].." = \""..v[2].."\";\n")
		end
	cw.client:PrintMessage(2, "######## [Catwork] Config ########\n")
end)

netstream.Hook("ClearRecognisedNames", function(data)
	cw.RecognisedNames = {}
end)

netstream.Hook("RecognisedName", function(data)
	local key = data.key
	local status = data.status

	if (status > 0) then
		cw.RecognisedNames[key] = status
	else
		cw.RecognisedNames[key] = nil
	end
end)

netstream.Hook("Hint", function(data)
	if (istable(data)) then
		if (data.center) then
			cw.core:AddCenterHint(
				cw.core:ParseData(data.text), data.delay, data.color, data.noSound, data.showDuplicates
			)
		else
			cw.core:AddTopHint(
				cw.core:ParseData(data.text), data.delay, data.color, data.noSound, data.showDuplicates
			)
		end
	end
end)

netstream.Hook("WeaponItemData", function(data)
	local weapon = Entity(data.weapon)

	if (IsValid(weapon)) then
		weapon.cwItemTable = item.CreateInstance(
			data.definition.index, data.definition.itemID, data.definition.data
		)
	end
end)

netstream.Hook("CinematicText", function(data)
	if (istable(data)) then
		cw.core:AddCinematicText(data.text, data.color, data.barLength, data.hangTime)
	end
end)

netstream.Hook("AddAccessory", function(data)
	cw.AccessoryData[data.itemID] = data.uniqueID
end)

netstream.Hook("RemoveAccessory", function(data)
	cw.AccessoryData[data.itemID] = nil
end)

netstream.Hook("AllAccessories", function(data)
	cw.AccessoryData = {}

	for k, v in pairs(data) do
		cw.AccessoryData[k] = v
	end
end)

netstream.Hook("Notification", function(data)
	local text = data.text
	local class = data.class
	local sound = "ambient/water/drip2.wav"

	if (class == 1) then
		sound = "buttons/button10.wav"
	elseif (class == 2) then
		sound = "buttons/button17.wav"
	elseif (class == 3) then
		sound = "buttons/bell1.wav"
	elseif (class == 4) then
		sound = "buttons/button15.wav"
	end

	local info = {
		class = class,
		sound = sound,
		text = text
	}

	if (hook.Run("NotificationAdjustInfo", info)) then
		cw.core:AddNotify(info.text, info.class, 10)
			surface.PlaySound(info.sound)
		print(info.text)
	end
end)
