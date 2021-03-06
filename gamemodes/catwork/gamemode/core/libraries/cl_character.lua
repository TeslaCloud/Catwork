--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("character", cw)

cw.character.stored = cw.character.stored or {}
cw.character.whitelisted = cw.character.whitelisted or {}
cw.character.creationPanels = cw.character.creationPanels or {}

--[[
	@codebase Client
	@details Register a new creation panel.
	@param String The friendly name of the creation process.
	@param String The name of the VGUI panel to use.
	@param Function A callback to get the visibility of the process. Return false to hide.
--]]
function cw.character:RegisterCreationPanel(friendlyName, vguiName, index, Condition)
	-- Prevent duplicates from being created on AutoRefresh.
	for k, v in ipairs(cw.character.creationPanels) do
		if (v.friendlyName == friendlyName) then
			return
		end
	end

	if (index) then
		for k, v in pairs(cw.character.creationPanels) do
			if (v.index >= index) then
				v.index = v.index + 1
			end
		end
	end

	table.insert(cw.character.creationPanels, index or #cw.character.creationPanels + 1, {
		index = index or #cw.character.creationPanels + 1,
		vguiName = vguiName,
		Condition = Condition,
		friendlyName = friendlyName
	})
end

--[[
	@codebase Client
	@details Used to remove a character creation panel from use.
--]]
function cw.character:RemoveCreationPanel(name)
	local removed = false
	local index

	for k, v in pairs(self.creationPanels) do
		if (name == v.vguiName or name == v.friendlyName) then
			index = v.index
			removed = true

			table.remove(self.creationPanels, k)
		end
	end

	if (removed == true) then
		for k, v in pairs(cw.character.creationPanels) do
			if (v.index >= index) then
				v.index = v.index - 1
			end
		end
	end
end

--[[
	@codebase Client
	@details Get the previous creation panel.
	@returns Table The previous creation panel info.
--]]
function cw.character:GetPreviousCreationPanel()
	local info = self:GetCreationInfo()
	local index = info.index - 1

	while (self.creationPanels[index]) do
		local panelInfo = self.creationPanels[index]

		if (!panelInfo.Condition
		or panelInfo.Condition(info)) then
			return panelInfo
		end

		index = index - 1
	end
end

--[[
	@codebase Client
	@details Get the next creation panel.
	@returns Table The next creation panel info.
--]]
function cw.character:GetNextCreationPanel()
	local info = self:GetCreationInfo()
	local index = info.index + 1

	while (self.creationPanels[index]) do
		local panelInfo = self.creationPanels[index]

		if (!panelInfo.Condition
		or panelInfo.Condition(info)) then
			return panelInfo
		end

		index = index + 1
	end
end

--[[
	@codebase Client
	@details Reset the active character creation info.
--]]
function cw.character:ResetCreationInfo()
	self:GetPanel().info = {index = 0}
end

--[[
	@codebase Client
	@details Get the active character creation info.
	@returns Table The active character creation info.
--]]
function cw.character:GetCreationInfo()
	return self:GetPanel().info
end

--[[
	@codebase Client
	@details Get the creation progress as a percentage.
	@returns Float A percentage of the creation progress.
--]]
function cw.character:GetCreationProgress()
	return (100 / #self.creationPanels) * self:GetCreationInfo().index
end

-- A function to get whether the creation process is active.
function cw.character:IsCreationProcessActive()
	local activePanel = self:GetActivePanel()

	if (activePanel and activePanel.bIsCreationProcess) then
		return true
	else
		return false
	end
end

-- A function to open the previous character creation panel.
function cw.character:OpenPreviousCreationPanel()
	local previousPanel = self:GetPreviousCreationPanel()
	local activePanel = self:GetActivePanel()
	local panel = self:GetPanel()
	local info = self:GetCreationInfo()

	if (info.index > 0 and activePanel and activePanel.OnPrevious
	and activePanel:OnPrevious() == false) then
		return
	end

	if (previousPanel) then
		info.index = previousPanel.index
		panel:OpenPanel(previousPanel.vguiName, info)
	end
end

-- A function to open the next character creation panel.
function cw.character:OpenNextCreationPanel()
	local activePanel = self:GetActivePanel()
	local nextPanel = self:GetNextCreationPanel()
	local panel = self:GetPanel()
	local info = self:GetCreationInfo()

	if (info.index > 0 and activePanel and activePanel.OnNext
	and activePanel:OnNext() == false) then
		return
	end

	if (!nextPanel) then
		hook.Run(
			"PlayerAdjustCharacterCreationInfo", self:GetActivePanel(), info
		)

		netstream.Start("CreateCharacter", info)
	else
		info.index = nextPanel.index
		panel:OpenPanel(nextPanel.vguiName, info)
	end
end

-- A function to get the creation panels.
function cw.character:GetCreationPanels()
	return self.creationPanels
end

-- A function to get the active panel.
function cw.character:GetActivePanel()
	if (IsValid(self.activePanel)) then
		return self.activePanel
	end
end

-- A function to set whether the character panel is loading.
function cw.character:SetPanelLoading(loading)
	self.loading = loading
end

-- A function to get whether the character panel is loading.
function cw.character:IsPanelLoading()
	return self.isLoading
end

-- A function to get the character panel list.
function cw.character:GetPanelList()
	local panel = self:GetActivePanel()

	if (panel and panel.isCharacterList) then
		return panel
	end
end

-- A function to get the whitelisted factions.
function cw.character:GetWhitelisted()
	return self.whitelisted
end

-- A function to get whether the local player is whitelisted for a faction.
function cw.character:IsWhitelisted(faction)
	return table.HasValue(self:GetWhitelisted(), faction)
end

-- A function to get the local player's characters.
function cw.character:GetAll()
	return self.stored
end

-- A function to get the character fault.
function cw.character:GetFault()
	return self.fault
end

-- A function to set the character fault.
function cw.character:SetFault(fault)
	if (type(fault) == "string") then
		cw.core:AddCinematicText(
			fault, Color(255, 255, 255, 255), 32, 6, cw.option:GetFont("menu_text_tiny"), true
		)
	end

	self.fault = fault
end

-- A function to get the character panel.
function cw.character:GetPanel()
	return self.panel
end

-- A function to fade in the navigation.
function cw.character:FadeInNavigation()
	if (IsValid(self.panel)) then
		self.panel:FadeInNavigation()
	end
end

-- A function to refresh the character panel list.
function cw.character:RefreshPanelList()
	local factionScreens = {}
	local factionList = {}
	local panelList = self:GetPanelList()

	if (panelList) then
		panelList:Clear()

		for k, v in pairs(self:GetAll()) do
			local faction = hook.Run("GetPlayerCharacterScreenFaction", v)
			if (!factionScreens[faction]) then factionScreens[faction] = {}; end

			factionScreens[faction][#factionScreens[faction] + 1] = v
		end

		for k, v in pairs(factionScreens) do
			table.sort(v, function(a, b)
				return hook.Run("CharacterScreenSortFactionCharacters", k, a, b)
			end)

			factionList[#factionList + 1] = {name = k, characters = v}
		end

		table.sort(factionList, function(a, b)
			return a.name < b.name
		end)

		for k, v in pairs(factionList) do
			for k2, v2 in pairs(v.characters) do
				panelList.customData = {
					name = v2.name,
					model = v2.model,
					banned = v2.banned,
					faction = v.name,
					details = v2.details,
					charTable = v2,
					characterID = v2.characterID
				}

				v2.panel = vgui.Create("cw.characterPanel", panelList)

				if (IsValid(v2.panel)) then
					panelList:AddPanel(v2.panel)
				end
			end
		end
	end
end

-- A function to get whether the character panel is open.
function cw.character:IsPanelOpen()
	return self.isOpen
end

-- A function to set the character panel to the main menu.
function cw.character:SetPanelMainMenu()
	local panel = self:GetPanel()

	if (panel) then
		panel:ReturnToMainMenu()
	end
end

-- A function to set whether the character panel is polling.
function cw.character:SetPanelPolling(polling)
	self.isPolling = polling
end

-- A function to get whether the character panel is polling.
function cw.character:IsPanelPolling()
	return self.isPolling
end

-- A function to get whether the character menu is reset.
function cw.character:IsMenuReset()
	return self.isMenuReset
end

-- A function to set whether the character panel is open.
function cw.character:SetPanelOpen(open, bReset)
	local panel = self:GetPanel()

	if (!open) then
		if (!bReset) then
			self.isOpen = false
		else
			self.isOpen = true
		end

		if (panel) then
			panel:SetVisible(self:IsPanelOpen())
		end
	elseif (panel) then
		panel:SetVisible(true)
		panel.createTime = SysTime()
		self.isOpen = true
	else
		self:SetPanelPolling(true)
	end

	gui.EnableScreenClicker(self:IsPanelOpen())
end

-- A function to add a character.
function cw.character:Add(characterID, data)
	self.stored[characterID] = data
end
