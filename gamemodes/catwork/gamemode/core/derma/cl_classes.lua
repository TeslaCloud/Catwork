--- Defines the `cwClasses` menu tab, which lists the classes the local player can switch to, and its `cwClassesItem`
-- entries.
--
-- Classes are filtered with the `PlayerCanSeeClass` hook and sorted by wages; an entry shows the class name and player
-- count and runs the `SetClass` command when clicked. `cwClassesItem` is reused by the class step of character
-- creation.

local PANEL = {}

--- Sizes the classes menu tab to the menu, creates its list and builds it.
function PANEL:Init()
  self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

  self.panelList = vgui.Create('cwPanelList', self)
  self.panelList:SetPadding(8)
  self.panelList:SetSpacing(8)
  self.panelList:StretchToParent(4, 4, 4, 4)
  self.panelList:HideBackground()

  self:Rebuild()
end

--- Returns whether the classes tab should be shown in the menu.
-- @return [Boolean `true` when the player can see a class other than their current one, otherwise `nil`]
function PANEL:IsButtonVisible()
  for k, v in pairs(cw.class:GetStored()) do
    if cw.core:HasObjectAccess(cw.client, v) then
      if hook.Run('PlayerCanSeeClass', v) then
        if cw.client:Team() != v.index then
          return true
        end
      end
    end
  end
end

--- Rebuilds the list of classes the local player can see.
--
-- Classes are sorted by wages, highest first, then by name. A class is listed as a `cwClassesItem`
-- when the player has access to it and the `PlayerCanSeeClass` hook allows it.
function PANEL:Rebuild()
  self.panelList:Clear(true)
  self.classTable = nil

  local available = nil
  local classes = {}

  for k, v in pairs(cw.class:GetStored()) do
    classes[#classes + 1] = v
  end

  table.sort(classes, function(a, b)
    local aWages = a.wages or 0
    local bWages = b.wages or 0

    if aWages == bWages then
      return a.name < b.name
    else
      return aWages > bWages
    end
  end)

  if #classes > 0 then
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#ClassesMenu_NoStay')
      label:SetInfoColor('blue')
    self.panelList:AddItem(label)

    for k, v in pairs(classes) do
      if cw.core:HasObjectAccess(cw.client, v) then
        if hook.Run('PlayerCanSeeClass', v) then
          self.classTable = cw.class:GetStored()[v.name]
          self.panelList:AddItem(vgui.Create('cwClassesItem', self))
        end
      end
    end
  else
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#ClassesMenu_NoAccess')
      label:SetInfoColor('red')
    self.panelList:AddItem(label)
  end

  self.panelList:InvalidateLayout(true)
end

--- Rebuilds the list when the menu is opened while this tab is active.
function PANEL:OnMenuOpened()
  if cw.menu:IsPanelActive(self) then
    self:Rebuild()
  end
end

--- Rebuilds the list when the tab is selected in the menu.
function PANEL:OnSelected() self:Rebuild() end

--- Does nothing; the list lays itself out.
function PANEL:PerformLayout(w, h) end

--- Draws the white panel background.
function PANEL:Paint(w, h)
  cdraw.DrawBox(0, 0, w, h, COLOR_WHITE)

  return true
end

--- Rebuilds the list when the local player's class changes.
function PANEL:Think()
  local team = cw.client:Team()

  if !self.playerClass then
    self.playerClass = team
  end

  if team != self.playerClass then
    self.playerClass = team
    self:Rebuild()
  end
end

vgui.Register('cwClasses', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds a class entry (`cwClassesItem`) for the parent's `classTable`, with its name, player count and
-- model or image.
--
-- When the parent has an `overrideData` table, its `information` replaces the player count and its
-- `Callback` runs with the class table on click instead of the `SetClass` command. The model can be
-- changed through the `PlayerAdjustClassModelInfo` hook.
function PANEL:Init()
  local colorWhite = Color(0, 0, 0, 200)
  local parent = self:GetParent()

  self.classTable = parent.classTable
  self:SetSize(parent:GetWide(), 32)

  if parent.overrideData then
    self.overrideData = parent.overrideData
  else
    self.overrideData = {}
  end

  local players = _team.NumPlayers(self.classTable.index)
  local limit = cw.class:GetLimit(self.classTable.name)

  self.nameLabel = vgui.Create('DLabel', self)
  self.nameLabel:SetText(self.classTable.name)
  self.nameLabel:SetDark(true)

  self.information = vgui.Create('DLabel', self)

  if self.overrideData.information then
    self.information:SetText(self.overrideData.information)
  else
    self.information:SetText('#ClassesMenu_CurrentPlayers:'..players..','..limit..';')
  end

  self.information:SetDark(true)
  self.information:SizeToContents()

  local model, skin = cw.class:GetAppropriateModel(self.classTable.index, cw.client)
  local info = {
    model = model,
    skin = skin
  }

  hook.Run('PlayerAdjustClassModelInfo', self.classTable.index, info)

  if !self.classTable.image then
    self.spawnIcon = vgui.Create('cwSpawnIcon', self)
    self.spawnIcon:SetModel(info.model, info.skin)
    self.spawnIcon:SetTooltip(self.classTable.description)
    self.spawnIcon:SetSize(32, 32)
  else
    self.spawnIcon = vgui.Create('DImageButton', self)
    self.spawnIcon:SetTooltip(self.classTable.description)
    self.spawnIcon:SetImage(self.classTable.image..'.png')
    self.spawnIcon:SetSize(32, 32)
  end

  -- Called when the spawn icon is clicked.
  function self.spawnIcon.DoClick(spawnIcon)
    if self.overrideData.Callback then
      self.overrideData.Callback(self.classTable)
    else
      cw.core:RunCommand('SetClass', tonumber(self.classTable.index))
    end
  end
end

--- Refreshes the class entry's player count and keeps its icon in place.
function PANEL:Think()
  if self.classTable and !self.overrideData.information then
    self.information:SetText(
      '#ClassesMenu_CurrentPlayers:'.._team.NumPlayers(self.classTable.index)..','..
        cw.class:GetLimit(self.classTable.name)..';'
    )
    self.information:SizeToContents()
  end

  self.spawnIcon:SetPos(1, 1)
  self.spawnIcon:SetSize(30, 30)
end

--- Places the class entry's icon, name and information labels.
function PANEL:PerformLayout(w, h)
  self.nameLabel:SizeToContents()
  self.information:SizeToContents()

  self.spawnIcon:SetPos(1, 1)
  self.nameLabel:SetPos(40, 2)
  self.spawnIcon:SetSize(30, 30)
  self.information:SetPos(40, 30 - self.information:GetTall())
end

vgui.Register('cwClassesItem', PANEL, 'DPanel')
