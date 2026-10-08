--- Defines the `cwAttributes` menu tab, which lists the attributes the local player has access to, and its
-- `cwAttributesItem` rows.
--
-- Each row shows an attribute with an animated points bar and its boosted value out of the maximum. The tab stores
-- itself as `cw.attributes.panel` and rebuilds when it is opened or selected in the menu.

local barBackgroundColor = Color(50, 50, 50, 255)
local barMainColor = Color(100, 100, 100, 255)
local barHinderColor = Color(255, 50, 50, 255)
local barBoostColor = Color(50, 255, 50, 255)
local barProgressColor = Color(175, 175, 175, 255)

local PANEL = {}

--- Sizes the attributes menu tab to the menu, creates its list and registers itself as `cw.attributes.panel`.
function PANEL:Init()
  self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

  self.panelList = vgui.Create('cwPanelList', self)
  self.panelList:SetPadding(8)
  self.panelList:SetSpacing(8)
  self.panelList:StretchToParent(4, 4, 4, 4)
  self.panelList:HideBackground()

  cw.attributes.panel = self
  cw.attributes.panel.boosts = {}
  cw.attributes.panel.progress = {}
  cw.attributes.panel.attributes = {}

  self:Rebuild()
end

--- Rebuilds the list of attributes the local player has access to.
--
-- Attributes with a `category` are grouped under a form per category and sorted by translated name; the
-- rest are listed on their own. Each entry is a `cwAttributesItem` row. Shows a notice instead when the
-- player cannot access any attribute.
function PANEL:Rebuild()
  self.panelList:Clear()

  local miscellaneous = {}
  local categories = {}
  local attributes = {}

  for k, v in pairs(cw.attribute:GetAll()) do
    if cw.core:HasObjectAccess(cw.client, v) then
      if v.category then
        local category = v.category

        attributes[category] = attributes[category] or {}
        attributes[category][#attributes[category] + 1] = { k, cw.lang:TranslateText(v.name) }
      else
        miscellaneous[#miscellaneous + 1] = { k, cw.lang:TranslateText(v.name) }
      end
    end
  end

  for k, v in pairs(attributes) do
    categories[#categories + 1] = {
      attributes = v,
      category = k
    }
  end

  table.sort(miscellaneous, function(a, b)
    return a[2] < b[2]
  end)

  table.sort(categories, function(a, b)
    return a.category < b.category
  end)

  if #categories > 0 or #miscellaneous > 0 then
    for k, v in pairs(miscellaneous) do
      local categoryForm = vgui.Create('cwBasicForm', self)
      categoryForm:SetPadding(0)
      categoryForm:SetSpacing(0)
      categoryForm:SetAutoSize(true)
      categoryForm:SetText(v[2], nil, nil, 18)

      self.currentAttribute = v[1]

      categoryForm:AddItem(
        vgui.Create('cwAttributesItem', self)
      )

      self.panelList:AddItem(categoryForm)
    end

    for k, v in pairs(categories) do
      local categoryForm = vgui.Create('cwBasicForm', self)
      categoryForm:SetPadding(0)
      categoryForm:SetSpacing(8)
      categoryForm:SetAutoSize(true)
      categoryForm:SetText(v.category, nil, 'basic_form_highlight', 25)

      local panelList = vgui.Create('DPanelList', self)

      table.sort(v.attributes, function(a, b)
        return a[2] < b[2]
      end)

      for k2, v2 in pairs(v.attributes) do
        local attributeForm = vgui.Create('cwBasicForm', self)
        attributeForm:SetPadding(0)
        attributeForm:SetSpacing(4)
        attributeForm:SetAutoSize(true)
        attributeForm:SetText(v2[2], nil, nil, 18)

        self.currentAttribute = v2[1]

        attributeForm:AddItem(
          vgui.Create('cwAttributesItem', self)
        )

        panelList:AddItem(attributeForm)
      end

      panelList:SetAutoSize(true)
      panelList:SetPadding(4)
      panelList:SetSpacing(8)

      categoryForm:AddItem(panelList)

      self.panelList:AddItem(categoryForm)
    end
  else
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#AttributesMenu_NoAccess:'..cw.option:GetKey('name_attributes', true)..';')
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

--- Draws the outlined panel background.
function PANEL:Paint(w, h)
  draw.RoundedBox(0, 0, 0, w, h, cw.option:GetColor('panel_outline'))
  draw.RoundedBox(0, 1, 1, w - 2, h - 2, cw.option:GetColor('panel_background'))

  return true
end

vgui.Register('cwAttributes', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds an attribute row (`cwAttributesItem`) for the parent's `currentAttribute`, with an animated points bar,
-- a progress bar, a value label and the attribute's icon when it has one.
function PANEL:Init()
  self.attribute = cw.attribute:FindByID(
    self:GetParent().currentAttribute
  )

  self:SetBackgroundColor(Color(80, 70, 60, 255))
  self:SetTooltip(cw.lang:TranslateText(self.attribute.description))
  self:SetSize(self:GetParent():GetWide() - 8, 32)

  self.baseBar = vgui.Create('DPanel', self)
  self.baseBar:SetSize(self:GetWide() - 4, 20)

  self.progressBar = vgui.Create('DPanel', self)
  self.progressBar:SetSize(self:GetWide() - 4, 8)

  self.percentageText = vgui.Create('DLabel', self)
  self.percentageText:SetText('0%')
  self.percentageText:SetTextColor(cw.option:GetColor('white'))
  self.percentageText:SetExpensiveShadow(1, Color(0, 0, 0, 150))
  self.percentageText:SizeToContents()
  self.percentageText:SetPos(
    self:GetWide() - self.percentageText:GetWide() - 16,
    self.baseBar.y + (self.baseBar:GetTall() / 2) - (self.percentageText:GetTall() / 2)
  )

  -- Called when the panel should be painted.
  function self.baseBar.Paint(baseBar)
    local attributes = cw.attributes.panel.attributes
    local frameTime = FrameTime() * 10
    local uniqueID = self.attribute.uniqueID
    local maximum = self.attribute.maximum
    local default = cw.attributes.stored[uniqueID]
    local boosts = cw.attributes.panel.boosts
    local target = default and default.amount or 0
    local boost = 0

    attributes[uniqueID] = math.Approach(attributes[uniqueID] or target, target, frameTime)

    if cw.attributes.boosts[uniqueID] then
      for k, v in pairs(cw.attributes.boosts[uniqueID]) do
        boost = boost + v.amount
      end
    end

    boost = math.Clamp(boost, -maximum, maximum)
    boosts[uniqueID] = math.Approach(boosts[uniqueID] or 0, boost, frameTime)

    local barWidth, barHeight = baseBar:GetWide(), baseBar:GetTall()
    local width = (barWidth / maximum) * attributes[uniqueID]
    local boostAmount = math.abs(boosts[uniqueID])
    local boostWidth = math.ceil((barWidth / maximum) * boostAmount)
    local barLineWidth = width

    surface.SetDrawColor(barBackgroundColor)
    surface.DrawRect(0, 0, barWidth, barHeight)
    self:SetPercentageText(maximum, attributes[uniqueID], boosts[uniqueID])

    if boosts[uniqueID] < 0 then
      if attributes[uniqueID] - boostAmount >= 0 then
        boostWidth = math.min(boostWidth, width)
        barLineWidth = math.max(width - boostWidth, 0)

        surface.SetDrawColor(barMainColor)
        surface.DrawRect(0, 0, barLineWidth, barHeight)

        local hinderX = barLineWidth

        surface.SetDrawColor(barHinderColor)
        surface.DrawRect(hinderX, 0, boostWidth, barHeight)
        surface.SetDrawColor(255, 255, 255, 255)

        if boostWidth > 4 and hinderX + boostWidth < barWidth - 2 then
          surface.DrawRect(hinderX + boostWidth, 0, 1, barHeight)
        end
      else
        surface.SetDrawColor(barHinderColor)
        surface.DrawRect(0, 0, boostWidth, barHeight)

        if boostWidth > 4 and boostWidth < barWidth - 2 then
          surface.DrawRect(boostWidth, 0, 1, barHeight)
        end
      end
    else
      surface.SetDrawColor(barMainColor)
      surface.DrawRect(0, 0, width, barHeight)

      local clampedWidth = math.min(boostWidth, barWidth)

      surface.SetDrawColor(barBoostColor)
      surface.DrawRect(width, 0, clampedWidth, barHeight)

      if boostWidth > 4 and clampedWidth < barWidth - 2 then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(width + clampedWidth, 0, 1, barHeight)
      end
    end

    if barLineWidth > 4 and barLineWidth < barWidth - 2 then
      surface.SetDrawColor(255, 255, 255, 255)
      surface.DrawRect(barLineWidth, 0, 1, barHeight)
    end

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(0, barHeight - 1, barWidth, 1)
  end

  -- Called when the panel should be painted.
  function self.progressBar.Paint(progressBar)
    local uniqueID = self.attribute.uniqueID
    local progress = cw.attributes.panel.progress
    local default = cw.attributes.stored[uniqueID]

    if default then
      progress[uniqueID] = math.Approach(progress[uniqueID] or default.progress, default.progress, 1)
    else
      progress[uniqueID] = math.Approach(progress[uniqueID] or 0, 0, FrameTime() * 2)
    end

    local barWidth, barHeight = progressBar:GetWide(), progressBar:GetTall()
    local width = math.ceil((barWidth / 100) * progress[uniqueID])

    surface.SetDrawColor(barMainColor)
    surface.DrawRect(0, 0, barWidth, barHeight)
    surface.SetDrawColor(barProgressColor)
    surface.DrawRect(0, 0, width, barHeight)

    if width > 4 and width < barWidth - 2 then
      surface.SetDrawColor(255, 255, 255, 255)
      surface.DrawRect(width, 0, 1, barHeight)
    end
  end

  if self.attribute.image then
    self.spawnIcon = vgui.Create('DImageButton', self)
    self.spawnIcon:SetTooltip(cw.lang:TranslateText(self.attribute.description))
    self.spawnIcon:SetImage(self.attribute.image..'.png')
    self.spawnIcon:SetSize(32, 32)

    self.baseBar:SetPos(32, 2)
    self.progressBar:SetPos(32, 22)
  else
    self.baseBar:SetPos(2, 2)
    self.progressBar:SetPos(2, 22)
  end
end

--- Updates the row's value label to show the boosted value out of the maximum and keeps it right-aligned.
-- @param maximum [Number Maximum value of the attribute]
-- @param default [Number Current base value of the attribute]
-- @param boost [Number Total boost applied to the attribute; negative when hindered]
function PANEL:SetPercentageText(maximum, default, boost)
  local value = math.Round(default + boost)

  if self.shownValue != value or self.shownMaximum != maximum then
    self.shownValue = value
    self.shownMaximum = maximum

    self.percentageText:SetText(value..'/'..maximum)
    self.percentageText:SizeToContents()
  end

  self.percentageText:SetPos(
    self:GetWide() - self.percentageText:GetWide() - 16,
    self.baseBar.y + (self.baseBar:GetTall() / 2) - (self.percentageText:GetTall() / 2)
  )
end

--- Draws the attribute row's gradient background.
function PANEL:Paint(w, h)
  local x, y = 0, 0

  cw.core:DrawSimpleGradientBox(4, x, y, w, h, self:GetBackgroundColor())

  return true
end

--- Resizes the attribute row's bars to leave room for the icon when there is one.
function PANEL:Think()
  if self.spawnIcon then
    self.progressBar:SetSize(self:GetWide() - 34, 8)
    self.baseBar:SetSize(self:GetWide() - 34, 20)
    self.spawnIcon:SetPos(1, 1)
    self.spawnIcon:SetSize(30, 30)
  else
    self.progressBar:SetSize(self:GetWide() - 4, 8)
    self.baseBar:SetSize(self:GetWide() - 4, 20)
  end
end

--- Keeps the attribute row's icon in the top left corner.
function PANEL:PerformLayout(w, h)
  if self.spawnIcon then
    self.spawnIcon:SetPos(1, 1)
    self.spawnIcon:SetSize(30, 30)
  end
end

vgui.Register('cwAttributesItem', PANEL, 'DPanel')
