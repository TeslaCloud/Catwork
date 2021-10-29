--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local GRADIENT = surface.GetTextureID("gui/gradient")
local PANEL = {}

function PANEL:ToggleAllButtons()
	self.closeMenu:Toggle()
	self.characterMenu:Toggle()

	for k, v in pairs(cw.menu.stored) do
		if (v.button) then
			v.button:Toggle()
		end
	end
end

-- Called when the panel is initialized.
function PANEL:Init()
	if (!cw.theme:Call("PreMainMenuInit", self)) then	
		self:SetSize(scrW, scrH)

		self.collapse = vgui.Create("cwFAButton", self)
		self.collapse:SetDrawBackground(true)
		self.collapse:SetSize(210, ScrH())
		self.collapse:SetCollapsible(true)
		self.collapse:SetPos(0, 0)
		self.collapse:SetIcon("bars")
		self.collapse:SetIconSize(24, 24, 4, 4)
		self.collapse:SetOpen(true)
		self.collapse:ShouldHover(false)
		self.collapse:SetCallback(function(btn)
			if (btn.isOpen) then
				timer.Simple(0.25, function()
					self:ToggleAllButtons()
				end)

				btn:SizeTo(220, -1, 0.25)
			else
				self:ToggleAllButtons()

				btn:SizeTo(32, -1, 0.25)
			end

			self._isOpen = btn.isOpen

			cw.option:PlaySound("rollover")
		end)

		self:SetDrawOnTop(false)
		self:SetPaintBackground(false)
		self:SetMouseInputEnabled(true)
		self:SetKeyboardInputEnabled(true)

		cw.core:SetNoticePanel(self)

		self.CreateTime = SysTime()
		self.activePanel = nil

		self._isOpen = true

		cw.theme:Call("PostMainMenuInit", self)
		self:Rebuild()
	end
end

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu(bPerformCheck)
	if (bPerformCheck) then
		if (IsValid(self.activePanel) and self.activePanel:IsVisible()) then
			self.activePanel:MakePopup()
		end

		return
	end

	if (IsValid(self.activePanel) and self.activePanel:IsVisible()) then
		self.activePanel:MakePopup()
		self:FadeOut(0.5, self.activePanel,
			function()
				self.activePanel = nil
			end
		)
	end

	self:MoveTo(self.tabX, self.tabY, 0.4, 0, 4)
end

-- A function to rebuild the panel.
function PANEL:Rebuild(change)
	if (!cw.theme:Call("PreMainMenuRebuild", self)) then
		self.tabX = 24 -- hardcoding this for now
		self.tabY = 256 -- we'll make theme system be able to override this later.

		local activePanel = cw.menu:GetActivePanel();		
		local smallTextFont = cw.option:GetFont("menu_text_small")
		local scrW = ScrW()
		local scrH = ScrH()

		if (IsValid(self.closeMenu)) then
			self.closeMenu:Remove()
			self.characterMenu:Remove()
		end

		self.closeMenu = vgui.Create("cwFAButton", self)
		self.closeMenu:SetIcon("times")
		self.closeMenu:SetIconSize(24, 24, 4, 4)
		self.closeMenu:SetTextOffset(32, 0)
		self.closeMenu:SetOpen(self._isOpen)
		self.closeMenu:SetFont(smallTextFont)
		self.closeMenu:SetText("#CloseMenu")
		self.closeMenu:SetCallback(function(button)
			self:SetOpen(false)
		end)
		self.closeMenu:SetTooltip("#CloseMenuDesc")
		self.closeMenu:SizeToContents()
		self.closeMenu:SetMouseInputEnabled(true)
		self.closeMenu:SetPos(0, 64)

		self.characterMenu = vgui.Create("cwFAButton", self)
		self.characterMenu:SetIcon("users")
		self.characterMenu:SetIconSize(20, 20, 4, 4)
		self.characterMenu:SetTextOffset(32, 0)
		self.characterMenu:SetOpen(self._isOpen)
		self.characterMenu:SetFont(smallTextFont)
		self.characterMenu:SetText("#Characters")
		self.characterMenu:SetCallback(function(button)
			self:SetOpen(false)
			cw.character:SetPanelOpen(true)
		end)
		self.characterMenu:SetTooltip("#CharactersDesc")
		self.characterMenu:SizeToContents()
		self.characterMenu:SetMouseInputEnabled(true)
		self.characterMenu:SetPos(self.closeMenu.x, self.closeMenu.y + self.closeMenu:GetTall() + 8);	

		if (change) then
			self:SetPos(self.tabX, self.tabY);		
		elseif (IsValid(self.activePanel)) then
			local width = self.activePanel:GetWide();			

			self:SetPos(-400, self.tabY)
			self:MoveTo(ScrW() - width - self.tabX - self.closeMenu:GetWide()*1.50, self.tabY, 0.4, 0, 4)
		else			
			self:SetPos(-400, self.tabY)
			self:MoveTo(self.tabX, self.tabY, 0.4, 0, 4)
		end

		local bIsVisible = false
		local width = self.characterMenu:GetWide()
		local scrH = ScrH()
		local scrW = ScrW()
		local y = self.characterMenu.y + self.characterMenu:GetTall() + 16
		local x = 0

		for k, v in pairs(cw.menu:GetItems()) do
			if (IsValid(v.button)) then
				v.button:Remove()
			end
		end

		cw.menuitems.stored = {}
		hook.Run("MenuItemsAdd", cw.menuitems)
		hook.Run("MenuItemsDestroy", cw.menuitems)

		table.sort(cw.menuitems.stored, function(a, b)
			return (a.text < b.text)
		end)

		for k, v in pairs(cw.menuitems.stored) do
			local button, panel = nil, nil

			if (cw.menu.stored[v.panel] and !cw.DebugMode) then
				panel = cw.menu.stored[v.panel].panel
			else
				panel = vgui.Create(v.panel, self)
				panel:SetVisible(false)
				panel:SetSize(cw.menu:GetWidth(), panel:GetTall())
				panel:SetPos(0, self.tabY + (scrH * 0.1))
				panel.Name = v.text
			end

			if (!panel.IsButtonVisible or panel:IsButtonVisible()) then
				button = vgui.Create("cw.menuButton", self)
				button:SetOpen(self._isOpen)
				button:SetTextOffset(32, 0)
				button:NoClipping(true)
			end

			if (button) then
				button:SetupLabel(v, panel, x, y)
				button:SetPos(x, y)

				y = y + button:GetTall() + 6

				bIsVisible = true

				if (button:GetWide() > width) then
					width = button:GetWide()
				end
			end

			cw.menu.stored[v.panel] = {
				button = button,
				panel = panel
			}
		end

		for k, v in pairs(cw.menu:GetItems()) do
			if (activePanel == v.panel) then
				if (!IsValid(v.button)) then
					self:FadeOut(0.5, activePanel, function()
						self.activePanel = nil
					end)
				end
			end
		end

		cw.theme:Call("PostMainMenuRebuild", self)
	end
end

-- A function to open a panel.
function PANEL:OpenPanel(panelToOpen)
	if (!cw.theme:Call("PreMainMenuOpenPanel", self, panelToOpen)) then
		local height = cw.menu:GetHeight()
		local width = cw.menu:GetWidth()
		local scrW = ScrW()
		local scrH = ScrH()

		if (IsValid(self.activePanel)) then
			self:FadeOut(0.5, self.activePanel, function()
				self.activePanel = nil
				self:OpenPanel(panelToOpen)
			end)

			return
		end

		if (panelToOpen.GetMenuWidth) then
			width = panelToOpen:GetMenuWidth()
		end

		self.activePanel = panelToOpen
		self.activePanel:SetSize(width, self.activePanel:GetTall())
		self.activePanel:MakePopup()
		self.activePanel:SetPos(ScrW() + 400, scrH * 0.1)

		self.activePanel.GetPanelName = function(panel)
			return panel.Name
		end

		self.activePanel:SetPos(scrW - width - (scrW * 0.04), scrH * 0.1)
		self.activePanel:SetAlpha(0)
		self:FadeIn(0.5, self.activePanel, function()
			timer.Simple(FrameTime() * 0.5, function()
				if (IsValid(self.activePanel)) then
					if (self.activePanel.OnSelected) then
						self.activePanel:OnSelected()
					end
				end
			end)
		end)

		cw.theme:Call("PostMainMenuOpenPanel", self, panelToOpen)
	end
end

-- A function to make a panel fade out.
function PANEL:FadeOut(speed, panel, Callback)
	local height = cw.menu:GetHeight()
	local width = cw.menu:GetWidth()
	local scrW = ScrW()
	local scrH = ScrH()

	if (panel:GetAlpha() > 0 and (!self.fadeOutAnimation or !self.fadeOutAnimation:Active())) then
		self.fadeOutAnimation = Derma_Anim("Fade Panel", panel, function(panel, animation, delta, data)
			panel:SetAlpha(255 - (delta * 255))

			if (animation.Finished) then
				self.fadeOutAnimation = nil
				panel:SetVisible(false)
			end

			if (animation.Finished and Callback) then
				Callback()
			end
		end)

		if (self.fadeOutAnimation) then
			self.fadeOutAnimation:Start(speed)
		end

		cw.option:PlaySound("rollover")
	else
		panel:SetVisible(false)
		panel:SetAlpha(0)

		if (Callback) then
			Callback()
		end
	end
end

-- A function to make a panel fade in.
function PANEL:FadeIn(speed, panel, Callback)
	if (panel:GetAlpha() == 0 and (!self.fadeInAnimation or !self.fadeInAnimation:Active())) then
		self.fadeInAnimation = Derma_Anim("Fade Panel", panel, function(panel, animation, delta, data)
			local height = cw.menu:GetHeight()
			local width = cw.menu:GetWidth()
			local scrW = ScrW()
			local scrH = ScrH()

			panel:SetVisible(true)
			panel:SetAlpha(delta * 255)

			if (animation.Finished) then
				self.fadeInAnimation = nil
			end

			if (animation.Finished and Callback) then
				Callback()
			end
		end)

		if (self.fadeInAnimation) then
			self.fadeInAnimation:Start(speed)
		end

		cw.option:PlaySound("click_release")
	else
		panel:SetVisible(true)
		panel:SetAlpha(255)

		if (Callback) then
			Callback()
		end
	end
end

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	if (!cw.theme:Call("PreMainMenuPaint", self)) then
		derma.SkinHook("Paint", "Panel", self)
		cw.theme:Call("PostMainMenuPaint", self)
	end

	/*local x, y = self.tabX - GetConVarNumber("cwBackX"), self.tabY - GetConVarNumber("cwBackY")
	local w, h = GetConVarNumber("cwBackW"), GetConVarNumber("cwBackH")
	local scrW, scrH = ScrW(), ScrH()

	if (CW_CONVAR_SHOWGRADIENT:GetInt() == 1) then
		if (ScreenIsRatio(4, 3)) then
			cdraw.DrawSimpleBlurBox(0, 0, ScrW() / 5, ScrH(), Color(110, 110, 110, 50))
		else
			cdraw.DrawSimpleBlurBox(0, 0, ScrW() / 6, ScrH(), Color(110, 110, 110, 50))
		end
	elseif (CW_CONVAR_SHOWMATERIAL:GetInt() == 1) then
		local material = Material(CW_CONVAR_MATERIAL:GetString());	

		surface.SetDrawColor(GetConVarNumber("cwBackColorR"), GetConVarNumber("cwBackColorG"), GetConVarNumber("cwBackColorB"), GetConVarNumber("cwBackColorA"))
		surface.SetMaterial(material)
		surface.DrawTexturedRect(x, y, w, h)
	end*/

	return true
end

-- Called every fame.
function PANEL:Think()
	if (!cw.theme:Call("PreMainMenuThink", self)) then
		self:SetVisible(cw.menu:GetOpen())
		self:SetSize(ScrW(), ScrH())
		self:SetPos(0,0)

		/*if (self.tabX != GetConVarNumber("cwTabPosX") or self.tabY != GetConVarNumber("cwTabPosY")) then
			self.tabX = GetConVarNumber("cwTabPosX")
			self.tabY = GetConVarNumber("cwTabPosY")
			self:Rebuild(true)
		end*/

//		if (self.closeMenu:GetText() and self.closeMenu:GetText() != CW_CONVAR_CLOSESTRING:GetString()) then
//			self.closeMenu:SetText(CW_CONVAR_CLOSESTRING:GetString())
//		end

//		if (self.characterMenu:GetText() and self.characterMenu:GetText() != CW_CONVAR_CHARSTRING:GetString()) then
//			self.characterMenu:SetText(CW_CONVAR_CHARSTRING:GetString())
//		end

		cw.menu.height = ScrH() * 0.75
		cw.menu.width = math.min(ScrW() * 0.7, 768)

		if (self.fadeOutAnimation) then
			self.fadeOutAnimation:Run()
		end

		if (self.fadeInAnimation) then
			self.fadeInAnimation:Run()

		end

		cw.theme:Call("PostMainMenuThink", self)

		local activePanel = cw.menu:GetActivePanel()
		local informationColor = cw.option:GetColor("information")

		self.closeMenu:OverrideTextColor(informationColor)

		for k, v in pairs(cw.menu:GetItems()) do
			if (IsValid(v.button)) then
				if (v.panel == activePanel) then
					v.button:OverrideTextColor(informationColor)
				else
					v.button:OverrideTextColor(false)
				end
			end
		end
	end
end

-- A function to set whether the panel is open.
function PANEL:SetOpen(bIsOpen)
	self:SetVisible(bIsOpen)
	self:ReturnToMainMenu(true)

	cw.menu.bIsOpen = bIsOpen
	gui.EnableScreenClicker(bIsOpen)

	if (bIsOpen) then
		self:Rebuild()
		self.CreateTime = SysTime()

		cw.core:SetNoticePanel(self)
		hook.Run("MenuOpened")
	else
		hook.Run("MenuClosed")
	end
end

vgui.Register("cw.menu", PANEL, "DPanel")

hook.Add("VGUIMousePressed", "cw.menu:VGUIMousePressed", function(panel, code)
	local activePanel = cw.menu:GetActivePanel()
	local menuPanel = cw.menu:GetPanel()

	if (cw.menu:GetOpen() and activePanel and menuPanel == panel) then
		menuPanel:ReturnToMainMenu()
	end
end)

netstream.Hook("MenuOpen", function(data)
	local panel = cw.menu:GetPanel()

	if (panel) then
		cw.menu:SetOpen(data)
	else
		cw.menu:Create(data)
	end
end);
