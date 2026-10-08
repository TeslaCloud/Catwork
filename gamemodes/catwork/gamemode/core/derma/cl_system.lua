--- Defines the `cwSystem` menu tab, which lists the systems registered with `cw.system` and shows the page of the one
-- that is opened.
--
-- A system's Open button is enabled when its `HasAccess` allows it, and its page is filled by its `OnDisplay` method.
-- The tab stores itself as `cw.system.panel`.

local PANEL = {}

--- Sizes the system menu tab to the menu, registers itself as `cw.system.panel` and builds it.
function PANEL:Init()
  self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

  self.panelList = vgui.Create('cwPanelList', self)
  self.panelList:SetPadding(4)
  self.panelList:StretchToParent(4, 4, 4, 4)

  cw.system.panel = self

  self:Rebuild()
end

--- Rebuilds the tab: the list of systems, or the open system's page with a button back to the list.
--
-- Each system in the list gets an Open button, enabled when its `HasAccess` method allows it. An open
-- system's page gets its own form when the system sets `doesCreateForm`, and is filled by the system's
-- `OnDisplay` method, called with this panel and that form.
function PANEL:Rebuild()
  self.panelList:Clear()

  if self.system then
    self.navigationForm = vgui.Create('DForm', self)
      self.navigationForm:SetPadding(4)
      self.navigationForm:SetName('#SystemMenu_Navigation')
      self.navigationForm:SetTall(100)
    self.panelList:AddItem(self.navigationForm)

    local backButton = vgui.Create('DButton', self)
      backButton:SetText('#SystemMenu_BackToNavigation')
      backButton:SetWide(self:GetParent():GetWide())

      -- Called when the button is clicked.
      function backButton.DoClick(button)
        self.system = nil
        self:Rebuild()
      end

    self.navigationForm:AddItem(backButton)

    local systemTable = cw.system:FindByID(self.system)

    if systemTable then
      if systemTable.doesCreateForm then
        self.systemForm = vgui.Create('DForm', self)
          self.systemForm:SetPadding(4)
          self.systemForm:SetName(systemTable.name)
          self.systemForm:SetTall(100)
        self.panelList:AddItem(self.systemForm)
      end

      systemTable:OnDisplay(self, self.systemForm)
    end
  else
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#SystemMenu_Info:'..L(cw.option:GetKey('name_system'))..';')
      label:SetInfoColor('blue')
    self.panelList:AddItem(label)

    for k, v in pairs(cw.system:GetAll()) do
      self.systemCategoryForm = vgui.Create('DForm', self)
        self.systemCategoryForm:SetPadding(4)
        self.systemCategoryForm:SetName(v.name)
        self.systemCategoryForm:SetTall(100)
      self.panelList:AddItem(self.systemCategoryForm)

      local tooltip = self.systemCategoryForm:Help(v.toolTip)

      tooltip:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 18))
      tooltip:SetTextColor(cw.option:GetColor('basic_form_color'))

      local systemButton = vgui.Create('cwInfoText', self)
        systemButton:SetText('#SystemMenu_Open')
        systemButton:SetTextToLeft(true)

        if v:HasAccess() then
          systemButton:SetButton(true)
          systemButton:SetInfoColor('green')
          systemButton:SetTooltip(L('#SystemMenu_OpenTip'))

          -- Called when the button is clicked.
          function systemButton.DoClick(button)
            self.system = v.name
            self:Rebuild()
          end
        else
          systemButton:SetInfoColor('red')
          systemButton:SetTooltip(L('#SystemMenu_NoAccessTip'))
        end

        systemButton:SetShowIcon(false)
      self.systemCategoryForm:AddItem(systemButton)
    end
  end

  self.panelList:InvalidateLayout(true)
end

--- Returns whether the system tab should be shown in the menu.
-- @return [Boolean `true` when the player has access to at least one system, otherwise `nil`]
function PANEL:IsButtonVisible()
  for k, v in pairs(cw.system:GetAll()) do
    if v:HasAccess() then
      return true
    end
  end
end

--- Rebuilds the tab when it is selected in the menu.
function PANEL:OnSelected() self:Rebuild() end

--- Does nothing; the list lays itself out.
function PANEL:PerformLayout(w, h) end

--- Draws nothing.
function PANEL:Paint(w, h)
  return true
end

vgui.Register('cwSystem', PANEL, 'EditablePanel')
