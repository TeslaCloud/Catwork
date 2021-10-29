--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	if (!cw.theme:Call("PreCharacterMenuInit", self)) then
		local smallTextFont = cw.option:GetFont("menu_text_small")
		local tinyTextFont = cw.option:GetFont("menu_text_tiny")
		local hugeTextFont = cw.option:GetFont("menu_text_huge")
		local scrH = ScrH()
		local scrW = ScrW()

		self:SetPos(0, 0)
		self:SetSize(scrW, scrH)
		self:SetDrawOnTop(false)
		self:SetFocusTopLevel(true)
		self:SetPaintBackground(false)
		self:SetMouseInputEnabled(true)

		self.titleLabel = vgui.Create("cwLabelButton", self)
		self.titleLabel:SetDisabled(true)
		self.titleLabel:SetFont(hugeTextFont)
		self.titleLabel:SetText(string.upper(Schema:GetName()))

		local schemaLogo = cw.option:GetKey("schema_logo")

		self.subLabel = vgui.Create("cwLabelButton", self)
		self.subLabel:SetDisabled(true)
		self.subLabel:SetFont(tinyTextFont)
		self.subLabel:SetText(cw.lang:TranslateText("#HL2RP_Description"):utf8upper())
		self.subLabel:SizeToContents()

		if (schemaLogo == "") then
			self.titleLabel:SetVisible(true)
			self.titleLabel:SizeToContents()
			self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.4)
			self.subLabel:SetPos((scrW / 2) - (self.subLabel:GetWide() / 2), self.titleLabel.y + self.titleLabel:GetTall() + 8)
		else
			self.titleLabel:SetVisible(false)
			self.titleLabel:SetSize(512, 256)
			self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.4 - 128)
			self.subLabel:SetPos(self.titleLabel.x + (self.titleLabel:GetWide() / 2) - (self.subLabel:GetWide() / 2), self.titleLabel.y + self.titleLabel:GetTall() + 8)
		end

		self.authorLabel = vgui.Create("cwLabelButton", self)
		self.authorLabel:SetDisabled(true)
		self.authorLabel:SetFont(tinyTextFont)
		self.authorLabel:SetText("#MainMenu_DevelopedBy:"..string.upper(Schema:GetAuthor())..";")
		self.authorLabel:SizeToContents()
		self.authorLabel:SetPos(self.subLabel.x + (self.subLabel:GetWide() - self.authorLabel:GetWide()), self.subLabel.y + self.subLabel:GetTall() + 4)

		self.lmaoCopyright = vgui.Create("cwLabelButton", self)
		self.lmaoCopyright:SetDisabled(true)
		self.lmaoCopyright:SetFont(tinyTextFont)
		self.lmaoCopyright:SetText("CATWORK "..cw.KernelVersion:upper())
		self.lmaoCopyright:SizeToContents()
		self.lmaoCopyright:SetPos(self.authorLabel.x + (self.authorLabel:GetWide() - self.lmaoCopyright:GetWide()), self.authorLabel.y + self.authorLabel:GetTall() + 4)

		self.communityButton = vgui.Create("cwLabelButton", self)
		self.communityButton:SetFont(smallTextFont)
		self.communityButton:SetText("ФОРУМ")
		self.communityButton:SetContentAlignment(4)
		self.communityButton:FadeIn(0.5)
		self.communityButton:SetCallback(function(panel)
			gui.OpenURL("https://iron-wall.com/")
		end)
		self.communityButton:SizeToContents()
		self.communityButton:SetMouseInputEnabled(true)
		self.communityButton:SetPos(scrW * 0.1, scrH * 0.65)

		self.createButton = vgui.Create("cwLabelButton", self)
		self.createButton:SetFont(smallTextFont)
		self.createButton:SetText(cw.lang:TranslateText("#MainMenu_New"):utf8upper())
		self.createButton:SetContentAlignment(4)
		self.createButton:FadeIn(0.5)
		self.createButton:SetCallback(function(panel)
			if (table.Count(cw.character:GetAll()) >= cw.player:GetMaximumCharacters()) then
				return cw.character:SetFault("#CharCreation_CannotCreateMoreChars")
			end

			cw.character:ResetCreationInfo()
			cw.character:OpenNextCreationPanel()
		end)
		self.createButton:SizeToContents()
		self.createButton:SetMouseInputEnabled(true)
		self.createButton:SetPos(scrW * 0.1, scrH * 0.72)

		self.loadButton = vgui.Create("cwLabelButton", self)
		self.loadButton:SetFont(smallTextFont)
		self.loadButton:SetText(cw.lang:TranslateText("#MainMenu_Load"):utf8upper())
		self.loadButton:SetContentAlignment(4)
		self.loadButton:FadeIn(0.5)
		self.loadButton:SetCallback(function(panel)
			self:OpenPanel("cw.characterList", nil, function(panel)
				cw.character:RefreshPanelList()
			end)
		end)
		self.loadButton:SizeToContents()
		self.loadButton:SetMouseInputEnabled(true)
		self.loadButton:SetPos(scrW * 0.1, scrH * 0.79)

		self.forumButton = vgui.Create("cwLabelButton", self)
		self.forumButton:SetFont(smallTextFont)
		self.forumButton:SetText(cw.lang:TranslateText("#MainMenu_Forum"):utf8upper())
		self.forumButton:SetContentAlignment(4)
		self.forumButton:FadeIn(0.5)
		self.forumButton:SetCallback(function(panel)
			gui.OpenURL("http://404")
		end)
		self.forumButton:SizeToContents()
		self.forumButton:SetMouseInputEnabled(true)
		self.forumButton:SetPos(scrW * 0.1, scrH * 0.86)

		self.disconnectButton = vgui.Create("cwLabelButton", self)
		self.disconnectButton:SetFont(smallTextFont)
		self.disconnectButton:SetText(cw.lang:TranslateText("#MainMenu_Leave"):utf8upper())
		self.disconnectButton:SetContentAlignment(4)
		self.disconnectButton:FadeIn(0.5)
		self.disconnectButton:SetCallback(function(panel)
			if (cw.client:HasInitialized() and !cw.character:IsMenuReset()) then
				cw.character:SetPanelMainMenu()
				cw.character:SetPanelOpen(false)
			else
				RunConsoleCommand("disconnect")
			end
		end)
		self.disconnectButton:SizeToContents()
		self.disconnectButton:SetMouseInputEnabled(true)
		self.disconnectButton:SetPos(scrW * 0.1, self.forumButton.y + (scrH * 0.07))

		self.previousButton = vgui.Create("cwLabelButton", self)
		self.previousButton:SetFont(tinyTextFont)
		self.previousButton:SetText(cw.lang:TranslateText("#CharCreation_Previous"):utf8upper())
		self.previousButton:SetCallback(function(panel)
			if (!cw.character:IsCreationProcessActive()) then
				local activePanel = cw.character:GetActivePanel()

				if (activePanel and activePanel.OnPrevious) then
					activePanel:OnPrevious()
				end
			else
				cw.character:OpenPreviousCreationPanel()
			end
		end)
		self.previousButton:SizeToContents()
		self.previousButton:SetMouseInputEnabled(true)
		self.previousButton:SetPos((scrW * 0.2) - (self.previousButton:GetWide() / 2), scrH * 0.9)

		self.nextButton = vgui.Create("cwLabelButton", self)
		self.nextButton:SetFont(tinyTextFont)
		self.nextButton:SetText(cw.lang:TranslateText("#CharCreation_Next"):utf8upper())
		self.nextButton:SetCallback(function(panel)
			if (!cw.character:IsCreationProcessActive()) then
				local activePanel = cw.character:GetActivePanel()

				if (activePanel and activePanel.OnNext) then
					activePanel:OnNext()
				end
			else
				cw.character:OpenNextCreationPanel()
			end
		end)
		self.nextButton:SizeToContents()
		self.nextButton:SetMouseInputEnabled(true)
		self.nextButton:SetPos((scrW * 0.8) - (self.nextButton:GetWide() / 2), scrH * 0.9)

		self.cancelButton = vgui.Create("cwLabelButton", self)
		self.cancelButton:SetFont(tinyTextFont)
		self.cancelButton:SetText(cw.lang:TranslateText("#CharCreation_Cancel"):utf8upper())
		self.cancelButton:SetCallback(function(panel)
			self:ReturnToMainMenu()
		end)
		self.cancelButton:SizeToContents()
		self.cancelButton:SetMouseInputEnabled(true)
		self.cancelButton:SetPos((scrW * 0.5) - (self.cancelButton:GetWide() / 2), scrH * 0.9)

		local modelSize = math.min(ScrW() * 0.25, ScrH() * 0.9)

		self.characterModel = vgui.Create("cw.characterModel", self)
		self.characterModel:SetSize(modelSize, modelSize)
		self.characterModel:SetAlpha(0)
		self.characterModel:SetModel("models/error.mdl")
		self.createTime = SysTime()

		cw.theme:Call("PostCharacterMenuInit", self)
	end
end

-- A function to fade in the model panel.
function PANEL:FadeInModelPanel(model)
	if (ScrH() < 768) then
		return true
	end

	local panel = cw.character:GetActivePanel()
	local x, y = ScrW() - self.characterModel:GetWide() - 8, 16

	if (panel) then
		x, y = panel.x + panel:GetWide() - 16, panel.y - 80
	end

	self.characterModel:SetPos(x, y)

	if (self.characterModel:FadeIn(0.5)) then
		self:SetModelPanelModel(model)
		return true
	else
		return false
	end
end

-- A function to fade out the model panel.
function PANEL:FadeOutModelPanel()
	self.characterModel:FadeOut(0.5)
end

-- A function to set the model panel's model.
function PANEL:SetModelPanelModel(model)
	if (self.characterModel.currentModel != model) then
		self.characterModel.currentModel = model
		self.characterModel:SetModel(model)
	end

	local modelPanel = self.characterModel
	local weaponModel = hook.Run(
		"GetModelSelectWeaponModel", model
	)
	local sequence = hook.Run(
		"GetModelSelectSequence", modelPanel.Entity, model
	)

	if (weaponModel) then
		self.characterModel:SetWeaponModel(weaponModel)
	else
		self.characterModel:SetWeaponModel(false)
	end

	if (sequence) then
		modelPanel.Entity:ResetSequence(sequence)
	end
end

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu()
	local panel = cw.character:GetActivePanel()

	if (panel) then
	--	if (CW_CONVAR_FADEPANEL:GetInt() == 1) then
			panel:FadeOut(0.5, function()
				cw.character.activePanel = nil
					panel:Remove()
				self:FadeInTitle()
			end)
--		else
--			cw.character.activePanel = nil
	--		panel:Remove()
--		end
	else
		self:FadeInTitle()
	end

	self:FadeOutModelPanel()
	self:FadeOutNavigation()
end

-- A function to fade out the navigation.
function PANEL:FadeOutNavigation()
	if (!cw.theme:Call("PreCharacterFadeOutNavigation", self)) then
		self.previousButton:FadeOut(0.5)
		self.cancelButton:FadeOut(0.5)
		self.nextButton:FadeOut(0.5)
	end
end

-- A function to fade in the navigation.
function PANEL:FadeInNavigation()
	if (!cw.theme:Call("PreCharacterFadeInNavigation", self)) then
		self.previousButton:FadeIn(0.5)
		self.cancelButton:FadeIn(0.5)
		self.nextButton:FadeIn(0.5)
	end
end

-- A function to fade out the title.
function PANEL:FadeOutTitle()
	if (!cw.theme:Call("PreCharacterFadeOutTitle", self)) then
		self.subLabel:FadeOut(0.5)
		self.titleLabel:FadeOut(0.5)
		self.authorLabel:FadeOut(0.5)
		self.lmaoCopyright:FadeOut(0.5)
		self.communityButton:FadeOut(0.5)
		self.createButton:FadeOut(0.5)
		self.loadButton:FadeOut(0.5)
		self.forumButton:FadeOut(0.5)
		self.disconnectButton:FadeOut(0.5)
	end
end

-- A function to fade in the title.
function PANEL:FadeInTitle()
	if (!cw.theme:Call("PreCharacterFadeInTitle", self)) then
		self.subLabel:FadeIn(0.5)
		self.titleLabel:FadeIn(0.5)
		self.authorLabel:FadeIn(0.5)
		self.lmaoCopyright:FadeIn(0.5)
		self.communityButton:FadeIn(0.5)
		self.createButton:FadeIn(0.5)
		self.loadButton:FadeIn(0.5)
		self.forumButton:FadeIn(0.5)
		self.disconnectButton:FadeIn(0.5)
	end
end

-- A function to open a panel.
function PANEL:OpenPanel(vguiName, childData, Callback)
	if (!cw.theme:Call("PreCharacterMenuOpenPanel", self, vguiName, childData, Callback)) then
		local panel = cw.character:GetActivePanel()

		local y  = ScrH() * 0.275

		if (ScrH() < 768) then
			y = ScrH() * 0.11
		end

		if (panel) then
			panel:FadeOut(0.5, function()
				panel:Remove(); self.childData = childData

				cw.character.activePanel = vgui.Create(vguiName, self)
				cw.character.activePanel:SetAlpha(0)
				cw.character.activePanel:FadeIn(0.5)
				cw.character.activePanel:MakePopup()


				cw.character.activePanel:SetPos(ScrW() * 0.2, y)

				if (Callback) then
					Callback(cw.character.activePanel)
				end

				if (childData) then
					cw.character.activePanel.bIsCreationProcess = true
					cw.character:FadeInNavigation()
				end
			end)
		else
			self.childData = childData
			self:FadeOutTitle()

			cw.character.activePanel = vgui.Create(vguiName, self)
			cw.character.activePanel:SetAlpha(0)
			cw.character.activePanel:FadeIn(0.5)
			cw.character.activePanel:MakePopup()
			cw.character.activePanel:SetPos(ScrW() * 0.2, y)

			if (Callback) then
				Callback(cw.character.activePanel)
			end

			if (childData) then
				cw.character.activePanel.bIsCreationProcess = true
				cw.character:FadeInNavigation()
			end
		end

		--[[Fade out the model panel, we probably don't need it now! --]]
		self:FadeOutModelPanel()

		cw.theme:Call("PostCharacterMenuOpenPanel", self)
	end
end

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	if (!cw.theme:Call("PreCharacterMenuPaint", self)) then
		local schemaLogo = cw.option:GetKey("schema_logo")
		local subLabelAlpha = self.subLabel:GetAlpha()

		if (schemaLogo != "" and subLabelAlpha > 0) then
			if (!self.logoTextureID) then
				self.logoTextureID = Material(schemaLogo..".png")
			end

			self.logoTextureID:SetFloat("$alpha", subLabelAlpha)

			surface.SetDrawColor(255, 255, 255, subLabelAlpha)
			surface.SetMaterial(self.logoTextureID)
			surface.DrawTexturedRect(self.titleLabel.x, self.titleLabel.y - 64, 512, 256)
		end

		local backgroundColor = cw.option:GetColor("background")
		local foregroundColor = cw.option:GetColor("foreground")
		local colorTargetID = cw.option:GetColor("target_id")
		local tinyTextFont = cw.option:GetFont("menu_text_tiny")
		local colorWhite = cw.option:GetColor("white")
		local scrW, scrH = ScrW(), ScrH()
		local height = (self.createButton.y * 2) + self.createButton:GetTall()
		local x, y = x, 0

		cw.core:DrawSimpleGradientBox(0, 0, y, scrW, height, Color(
			backgroundColor.r, backgroundColor.g, backgroundColor.b, 100
		))

		surface.SetDrawColor(
			foregroundColor.r, foregroundColor.g, foregroundColor.b, 200
		)
		surface.DrawRect(0, y + height, scrW, 1)

		if (cw.character:IsCreationProcessActive()) then
			local creationPanels = cw.character:GetCreationPanels()
			local numCreationPanels = #creationPanels
			local creationProgress = cw.character:GetCreationProgress()
			local progressHeight = 20
			local creationInfo = cw.character:GetCreationInfo()
			local progressY = y + height + 1
			local boxColor = Color(
				math.min(backgroundColor.r + 50, 255),
				math.min(backgroundColor.g + 50, 255),
				math.min(backgroundColor.b + 50, 255),
				100
			)

			cw.core:DrawSimpleGradientBox(0, 0, progressY, scrW, progressHeight, boxColor)
				for i = 1, numCreationPanels do
					surface.SetDrawColor(
						foregroundColor.r, foregroundColor.g, foregroundColor.b, 150
					)
					surface.DrawRect((scrW / numCreationPanels) * i, progressY, 1, progressHeight)
				end
			cw.core:DrawSimpleGradientBox(
				0, 0, progressY, (scrW / 100) * creationProgress, progressHeight, colorTargetID
			)

			if (creationProgress > 0 and creationProgress < 100) then
				surface.SetDrawColor(
					foregroundColor.r, foregroundColor.g, foregroundColor.b, 200
				)
				surface.DrawRect((scrW / 100) * creationProgress, progressY, 1, progressHeight)
			end

			for i = 1, numCreationPanels do
				local Condition = creationPanels[i].Condition
				local textX = (scrW / numCreationPanels) * (i - 0.5)
				local textY = progressY + (progressHeight / 2)
				local color = Color(colorWhite.r, colorWhite.g, colorWhite.b, 200)

				if (Condition and !Condition(creationInfo)) then
					color = Color(colorWhite.r, colorWhite.g, colorWhite.b, 100)
				end

				cw.core:DrawSimpleText(creationPanels[i].friendlyName, textX, textY - 1, color, 1, 1)
			end

			surface.SetDrawColor(
				foregroundColor.r, foregroundColor.g, foregroundColor.b, 200
			)
			surface.DrawRect(0, progressY + progressHeight, scrW, 1)
		end

		cw.theme:Call("PostCharacterMenuPaint", self)
	end

	return true
end

-- Called each frame.
function PANEL:Think()
	if (!cw.theme:Call("PreCharacterMenuThink", self)) then
		local characters = table.Count(cw.character:GetAll())
		local bIsLoading = cw.character:IsPanelLoading()
		local schemaLogo = cw.option:GetKey("schema_logo")
		local activePanel = cw.character:GetActivePanel()
		local fault = cw.character:GetFault()

		if (hook.Run("ShouldDrawCharacterBackgroundBlur")) then
			cw.core:RegisterBackgroundBlur(self, self.createTime)
		else
			cw.core:RemoveBackgroundBlur(self)
		end

		if (self.characterModel) then
			if (!self.characterModel.currentModel
			or self.characterModel.currentModel == "models/error.mdl") then
				self.characterModel:SetAlpha(0)
			end
		end

		if (!cw.character:IsCreationProcessActive()) then
			if (activePanel) then
				if (activePanel.GetNextDisabled
				and activePanel:GetNextDisabled()) then
					self.nextButton:SetDisabled(true)
				else
					self.nextButton:SetDisabled(false)
				end

				if (activePanel.GetPreviousDisabled
				and activePanel:GetPreviousDisabled()) then
					self.previousButton:SetDisabled(true)
				else
					self.previousButton:SetDisabled(false)
				end
			end
		else
			local previousPanelInfo = cw.character:GetPreviousCreationPanel()

			if (previousPanelInfo) then
				self.previousButton:SetDisabled(false)
			else
				self.previousButton:SetDisabled(true)
			end

			self.nextButton:SetDisabled(false)
		end

		if (schemaLogo == "") then
			self.titleLabel:SetVisible(true)
		else
			self.titleLabel:SetVisible(false)
		end

		if (config.GetVal("community_button_enable")) then
			self.communityButton:SetVisible(true)
		else
			self.communityButton:SetVisible(false)
		end

		if (config.GetVal("forum_button_enable")) then
			self.forumButton:SetVisible(true)
		else
			self.forumButton:SetVisible(false)
		end

		if (!config.GetVal("forum_button_enable")) then
			self.disconnectButton:SetPos(ScrW() * 0.1, self.forumButton.y)
		end

		if (config.GetVal("community_name")) then

			self.communityButton:SetText(string.utf8upper(config.GetVal("community_name")))
		elseif (config.GetVal("community_link")) then

			self.communityButton:SetCallback(function(panel)
				gui.OpenURL(string.lower(config.GetVal("community_link")))
			end)
		elseif (config.GetVal("community_link")) then

			self.forumButton:SetCallback(function(panel)
				gui.OpenURL(string.lower(config.GetVal("forum_link")))
			end)
		end

		if (characters == 0 or bIsLoading) then
			self.loadButton:SetDisabled(true)
		else
			self.loadButton:SetDisabled(false)
		end

		if (characters >= cw.player:GetMaximumCharacters()
		or cw.character:IsPanelLoading()) then
			self.createButton:SetDisabled(true)
		else
			self.createButton:SetDisabled(false)
		end

		if (cw.client:HasInitialized() and !cw.character:IsMenuReset()) then
			self.disconnectButton:SetText("#CharCreation_Cancel")
			self.disconnectButton:SizeToContents()
		else
			self.disconnectButton:SetText("#MainMenu_Leave")
			self.disconnectButton:SizeToContents()
		end

		if (self.animation) then
			self.animation:Run()
		end

		self:SetSize(ScrW(), ScrH())

		cw.theme:Call("PostCharacterMenuThink", self)
	end
end

vgui.Register("cw.characterMenu", PANEL, "DPanel");
