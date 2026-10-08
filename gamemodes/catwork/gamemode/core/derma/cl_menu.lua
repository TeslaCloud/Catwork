--- Defines the `cw.menu` panel, the framework's main menu, with a button column that opens the menu tabs.
--
-- `Rebuild` creates the Close and Characters buttons and a `cw.menuButton` for each item collected by the
-- `MenuItemsAdd` and `MenuItemsDestroy` hooks, keeping the tab panels in `cw.menu.stored`; `OpenPanel` fades between
-- tabs. The `MenuOpen` netstream opens, closes or creates the menu.

local GRADIENT = surface.GetTextureID('gui/gradient')
local PANEL = {}

--- Toggles the Close, Characters and every tab button between showing and hiding their text.
function PANEL:ToggleAllButtons()
  self.closeMenu:Toggle()
  self.characterMenu:Toggle()

  for k, v in pairs(cw.menu.stored) do
    if v.button then
      v.button:Toggle()
    end
  end
end

--- Builds the main menu with its collapse bar, which shows or hides the button text when clicked, and
-- builds the tab buttons.
--
-- Skipped when the theme's `PreMainMenuInit` hook returns `true`; `PostMainMenuInit` runs before the
-- buttons are built.
function PANEL:Init()
  if !cw.theme:Call('PreMainMenuInit', self) then
    self:SetSize(scrW, scrH)

    self.collapse = vgui.Create('cwFAButton', self)
    self.collapse:SetDrawBackground(true)
    self.collapse:SetSize(210, ScrH())
    self.collapse:SetCollapsible(true)
    self.collapse:SetPos(0, 0)
    self.collapse:SetIcon('bars')
    self.collapse:SetIconSize(24, 24, 4, 4)
    self.collapse:SetOpen(true)
    self.collapse:ShouldHover(false)
    self.collapse:SetCallback(function(btn)
      if btn.isOpen then
        timer.Simple(0.25, function()
          self:ToggleAllButtons()
        end)

        btn:SizeTo(220, -1, 0.25)
      else
        self:ToggleAllButtons()

        btn:SizeTo(32, -1, 0.25)
      end

      self._isOpen = btn.isOpen

      cw.option:PlaySound('rollover')
    end)

    self:SetDrawOnTop(false)
    self:SetPaintBackground(false)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)

    cw.core:SetNoticePanel(self)

    self.CreateTime = SysTime()
    self.activePanel = nil

    self._isOpen = true

    cw.theme:Call('PostMainMenuInit', self)
    self:Rebuild()
  end
end

--- Fades out the open tab and slides the menu back to its resting position.
-- @param bPerformCheck=nil [Boolean `true` to only bring the open tab to the front, without closing it]
function PANEL:ReturnToMainMenu(bPerformCheck)
  if bPerformCheck then
    if IsValid(self.activePanel) and self.activePanel:IsVisible() then
      self.activePanel:MakePopup()
    end

    return
  end

  if IsValid(self.activePanel) and self.activePanel:IsVisible() then
    self.activePanel:MakePopup()
    self:FadeOut(0.5, self.activePanel,
      function()
        self.activePanel = nil
      end
    )
  end

  self:MoveTo(self.tabX, self.tabY, 0.4, 0, 4)
end

--- Rebuilds the Close and Characters buttons and a button for each menu item.
--
-- Menu items are collected through the `MenuItemsAdd` and `MenuItemsDestroy` hooks, sorted by text and
-- stored in `cw.menu.stored`. Tab panels are created once and reused, except in debug mode. A tab gets a
-- button unless its `IsButtonVisible` method returns `false`. The open tab is closed when it no longer
-- has a button. Skipped when the theme's `PreMainMenuRebuild` hook returns `true`;
-- `PostMainMenuRebuild` runs afterwards.
--
-- @param change=nil [Boolean `true` to place the menu at once instead of sliding it in]
function PANEL:Rebuild(change)
  if !cw.theme:Call('PreMainMenuRebuild', self) then
    self.tabX = 24 -- hardcoding this for now
    self.tabY = 256 -- we'll make theme system be able to override this later.

    local activePanel = cw.menu:GetActivePanel()
    local smallTextFont = cw.option:GetFont('menu_text_small')
    local scrW = ScrW()
    local scrH = ScrH()

    if IsValid(self.closeMenu) then
      self.closeMenu:Remove()
      self.characterMenu:Remove()
    end

    self.closeMenu = vgui.Create('cwFAButton', self)
    self.closeMenu:SetIcon('times')
    self.closeMenu:SetIconSize(24, 24, 4, 4)
    self.closeMenu:SetTextOffset(32, 0)
    self.closeMenu:SetOpen(self._isOpen)
    self.closeMenu:SetFont(smallTextFont)
    self.closeMenu:SetText('#CloseMenu')
    self.closeMenu:SetCallback(function(button)
      self:SetOpen(false)
    end)

    self.closeMenu:SetTooltip('#CloseMenuDesc')
    self.closeMenu:SizeToContents()
    self.closeMenu:SetMouseInputEnabled(true)
    self.closeMenu:SetPos(0, 64)

    self.characterMenu = vgui.Create('cwFAButton', self)
    self.characterMenu:SetIcon('users')
    self.characterMenu:SetIconSize(20, 20, 4, 4)
    self.characterMenu:SetTextOffset(32, 0)
    self.characterMenu:SetOpen(self._isOpen)
    self.characterMenu:SetFont(smallTextFont)
    self.characterMenu:SetText('#Characters')
    self.characterMenu:SetCallback(function(button)
      self:SetOpen(false)
      cw.character:SetPanelOpen(true)
    end)

    self.characterMenu:SetTooltip('#CharactersDesc')
    self.characterMenu:SizeToContents()
    self.characterMenu:SetMouseInputEnabled(true)
    self.characterMenu:SetPos(self.closeMenu.x, self.closeMenu.y + self.closeMenu:GetTall() + 8)

    if change then
      self:SetPos(self.tabX, self.tabY)
    elseif IsValid(self.activePanel) then
      local width = self.activePanel:GetWide()

      self:SetPos(-400, self.tabY)
      self:MoveTo(ScrW() - width - self.tabX - self.closeMenu:GetWide() * 1.50, self.tabY, 0.4, 0, 4)
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
      if IsValid(v.button) then
        v.button:Remove()
      end
    end

    cw.menuitems.stored = {}
    hook.Run('MenuItemsAdd', cw.menuitems)
    hook.Run('MenuItemsDestroy', cw.menuitems)

    table.sort(cw.menuitems.stored, function(a, b)
      return (a.text < b.text)
    end)

    for k, v in pairs(cw.menuitems.stored) do
      local button, panel = nil, nil

      if cw.menu.stored[v.panel] and !cw.DebugMode then
        panel = cw.menu.stored[v.panel].panel
      else
        panel = vgui.Create(v.panel, self)
        panel:SetVisible(false)
        panel:SetSize(cw.menu:GetWidth(), panel:GetTall())
        panel:SetPos(0, self.tabY + (scrH * 0.1))
        panel.Name = v.text
      end

      if !panel.IsButtonVisible or panel:IsButtonVisible() then
        button = vgui.Create('cw.menuButton', self)
        button:SetOpen(self._isOpen)
        button:SetTextOffset(32, 0)
        button:NoClipping(true)
      end

      if button then
        button:SetupLabel(v, panel, x, y)
        button:SetPos(x, y)

        y = y + button:GetTall() + 6

        bIsVisible = true

        if button:GetWide() > width then
          width = button:GetWide()
        end
      end

      cw.menu.stored[v.panel] = {
        button = button,
        panel = panel
      }
    end

    for k, v in pairs(cw.menu:GetItems()) do
      if activePanel == v.panel then
        if !IsValid(v.button) then
          self:FadeOut(0.5, activePanel, function()
            self.activePanel = nil
          end)
        end
      end
    end

    cw.theme:Call('PostMainMenuRebuild', self)
  end
end

--- Opens a tab panel, closing the open one first.
--
-- The panel is sized to the menu width or to its `GetMenuWidth` method, placed on the right of the
-- screen and faded in; its `OnSelected` method is called once it is visible. Skipped when the theme's
-- `PreMainMenuOpenPanel` hook returns `true`; `PostMainMenuOpenPanel` runs afterwards.
--
-- @param panelToOpen [Panel The tab panel to open]
function PANEL:OpenPanel(panelToOpen)
  if !cw.theme:Call('PreMainMenuOpenPanel', self, panelToOpen) then
    local height = cw.menu:GetHeight()
    local width = cw.menu:GetWidth()
    local scrW = ScrW()
    local scrH = ScrH()

    if IsValid(self.activePanel) then
      self:FadeOut(0.5, self.activePanel, function()
        self.activePanel = nil
        self:OpenPanel(panelToOpen)
      end)

      return
    end

    if panelToOpen.GetMenuWidth then
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
        if IsValid(self.activePanel) then
          if self.activePanel.OnSelected then
            self.activePanel:OnSelected()
          end
        end
      end)
    end)

    cw.theme:Call('PostMainMenuOpenPanel', self, panelToOpen)
  end
end

--- Fades a tab panel out and hides it, playing the rollover sound.
--
-- When the panel is already transparent or another fade out is running, it is hidden at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param panel [Panel The panel to fade out]
-- @param Callback=nil [Function Called once the panel is hidden]
function PANEL:FadeOut(speed, panel, Callback)
  local height = cw.menu:GetHeight()
  local width = cw.menu:GetWidth()
  local scrW = ScrW()
  local scrH = ScrH()

  if panel:GetAlpha() > 0 and (!self.fadeOutAnimation or !self.fadeOutAnimation:Active()) then
    self.fadeOutAnimation = Derma_Anim('Fade Panel', panel, function(panel, animation, delta, data)
      panel:SetAlpha(255 - (delta * 255))

      if animation.Finished then
        self.fadeOutAnimation = nil
        panel:SetVisible(false)
      end

      if animation.Finished and Callback then
        Callback()
      end
    end)

    if self.fadeOutAnimation then
      self.fadeOutAnimation:Start(speed)
    end

    cw.option:PlaySound('rollover')
  else
    panel:SetVisible(false)
    panel:SetAlpha(0)

    if Callback then
      Callback()
    end
  end
end

--- Shows a tab panel and fades it in, playing the click sound.
--
-- When the panel is already visible or another fade in is running, it is made fully visible at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param panel [Panel The panel to fade in]
-- @param Callback=nil [Function Called once the panel is fully visible]
function PANEL:FadeIn(speed, panel, Callback)
  if panel:GetAlpha() == 0 and (!self.fadeInAnimation or !self.fadeInAnimation:Active()) then
    self.fadeInAnimation = Derma_Anim('Fade Panel', panel, function(panel, animation, delta, data)
      local height = cw.menu:GetHeight()
      local width = cw.menu:GetWidth()
      local scrW = ScrW()
      local scrH = ScrH()

      panel:SetVisible(true)
      panel:SetAlpha(delta * 255)

      if animation.Finished then
        self.fadeInAnimation = nil
      end

      if animation.Finished and Callback then
        Callback()
      end
    end)

    if self.fadeInAnimation then
      self.fadeInAnimation:Start(speed)
    end

    cw.option:PlaySound('click_release')
  else
    panel:SetVisible(true)
    panel:SetAlpha(255)

    if Callback then
      Callback()
    end
  end
end

--- Draws the skin's panel background unless the theme's `PreMainMenuPaint` hook returns `true`.
function PANEL:Paint(w, h)
  if !cw.theme:Call('PreMainMenuPaint', self) then
    derma.SkinHook('Paint', 'Panel', self)
    cw.theme:Call('PostMainMenuPaint', self)
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

    surface.SetDrawColor(GetConVarNumber("cwBackColorR"), GetConVarNumber("cwBackColorG"),
    GetConVarNumber("cwBackColorB"), GetConVarNumber("cwBackColorA"))
    surface.SetMaterial(material)
    surface.DrawTexturedRect(x, y, w, h)
  end*/

  return true
end

--- Keeps the menu full-screen, updates the menu size, runs the fade animations and highlights the open
-- tab's button.
--
-- Skipped when the theme's `PreMainMenuThink` hook returns `true`; `PostMainMenuThink` runs before the
-- buttons are highlighted.
function PANEL:Think()
  if !cw.theme:Call('PreMainMenuThink', self) then
    self:SetVisible(cw.menu:GetOpen())
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)

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

    if self.fadeOutAnimation then
      self.fadeOutAnimation:Run()
    end

    if self.fadeInAnimation then
      self.fadeInAnimation:Run()
    end

    cw.theme:Call('PostMainMenuThink', self)

    local activePanel = cw.menu:GetActivePanel()
    local informationColor = cw.option:GetColor('information')

    self.closeMenu:OverrideTextColor(informationColor)

    for k, v in pairs(cw.menu:GetItems()) do
      if IsValid(v.button) then
        if v.panel == activePanel then
          v.button:OverrideTextColor(informationColor)
        else
          v.button:OverrideTextColor(false)
        end
      end
    end
  end
end

--- Opens or closes the menu and the screen clicker.
--
-- Opening rebuilds the menu and runs the `MenuOpened` hook; closing runs `MenuClosed`.
--
-- @param bIsOpen [Boolean `true` to open the menu]
function PANEL:SetOpen(bIsOpen)
  self:SetVisible(bIsOpen)
  self:ReturnToMainMenu(true)

  cw.menu.bIsOpen = bIsOpen
  gui.EnableScreenClicker(bIsOpen)

  if bIsOpen then
    self:Rebuild()
    self.CreateTime = SysTime()

    cw.core:SetNoticePanel(self)
    hook.Run('MenuOpened')
  else
    hook.Run('MenuClosed')
  end
end

vgui.Register('cw.menu', PANEL, 'DPanel')

hook.Add('VGUIMousePressed', 'cw.menu:VGUIMousePressed', function(panel, code)
  local activePanel = cw.menu:GetActivePanel()
  local menuPanel = cw.menu:GetPanel()

  if cw.menu:GetOpen() and activePanel and menuPanel == panel then
    menuPanel:ReturnToMainMenu()
  end
end)

netstream.Hook('MenuOpen', function(data)
  local panel = cw.menu:GetPanel()

  if panel then
    cw.menu:SetOpen(data)
  else
    cw.menu:Create(data)
  end
end)
