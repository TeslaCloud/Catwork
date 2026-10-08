--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

--- Sizes the settings menu tab to the menu, creates its list and builds it.
function PANEL:Init()
  self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

  self.panelList = vgui.Create('cwPanelList', self)
  self.panelList:SetPadding(8)
  self.panelList:SetSpacing(8)
  self.panelList:StretchToParent(4, 4, 4, 4)
  self.panelList:HideBackground()
  self.panelList:EnableVerticalScrollbar()

  self:Rebuild()
end

--- Rebuilds the settings list from `cw.setting.stored`, one form per category.
--
-- Settings whose `Condition` returns false are left out. Inside a category, settings are sorted by
-- control class, then by text. Each setting gets the control for its `class`: `numberSlider`,
-- `multiChoice`, `numberWang`, `textEntry`, `checkBox` or `colorMixer`, bound to its console variable
-- (a color mixer uses the variable name with `R`, `G`, `B` and `A` appended).
function PANEL:Rebuild()
  self.panelList:Clear()

  local availableCategories = {}
  local categories = {}

  for k, v in pairs(cw.setting.stored) do
    if !v.Condition or v.Condition() then
      local category = v.category

      if !availableCategories[category] then
        availableCategories[category] = {}
      end

      availableCategories[category][#availableCategories[category] + 1] = v
    end
  end

  for k, v in pairs(availableCategories) do
    table.sort(v, function(a, b)
      if a.class == b.class then
        return a.text < b.text
      else
        return a.class < b.class
      end
    end)

    categories[#categories + 1] = { category = k, settings = v }
  end

  table.sort(categories, function(a, b)
    return a.category < b.category
  end)

  if table.Count(categories) > 0 then
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#SettingsInfoText')
      label:SetInfoColor('blue')
    self.panelList:AddItem(label)

    for k, v in pairs(categories) do
      local form = vgui.Create('cwBasicForm', self)
      form:SetPadding(8)
      form:SetSpacing(8)
      form:SetAutoSize(true)
      form:SetText(v.category, nil, 'basic_form_highlight', 18)

      local panel = nil

      for k2, v2 in pairs(v.settings) do
        if v2.class == 'numberSlider' then
          panel = form:NumSlider(v2.text, v2.conVar, v2.minimum, v2.maximum, v2.decimals)
        elseif v2.class == 'multiChoice' then
          local label = vgui.Create('DLabel')
          local conVar = GetConVar(v2.conVar)

          panel = vgui.Create('DComboBox')

          label:SetText(v2.text)
          label:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
          label:SetTextColor(cw.option:GetColor('basic_form_color'))
          label:SetTooltip(v2.toolTip)

          panel:SetConVar(v2.conVar)

          for k3, v3 in pairs(v2.options) do
            panel:AddChoice(k3, v3)
          end

          function panel:OnSelect(index, value, data)
            if !self.m_strConVar then return end

            RunConsoleCommand(self.m_strConVar, tostring(data or value))
          end

          form:AddItem(label)
          form:AddItem(panel)
        elseif v2.class == 'numberWang' then
          panel = form:NumberWang(v2.text, v2.conVar, v2.minimum, v2.maximum, v2.decimals)
        elseif v2.class == 'textEntry' then
          local label = vgui.Create('DLabel')
          local textEntry = vgui.Create('DTextEntry')

          label:SetText(v2.text)
          label:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
          label:SetTextColor(cw.option:GetColor('basic_form_color'))
          label:SetTooltip(v2.toolTip)
          textEntry:SetConVar(v2.conVar)

          panel = textEntry

          form:AddItem(label)
          form:AddItem(textEntry)
        elseif v2.class == 'checkBox' then
          panel = form:CheckBox(v2.text, v2.conVar)
        elseif v2.class == 'colorMixer' then
          local mixer = vgui.Create('DColorMixer')
          local label = vgui.Create('DLabel')

          label:SetText(v2.text)
          label:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
          label:SetTextColor(cw.option:GetColor('basic_form_color'))
          label:SetTooltip(v2.toolTip)

          mixer:SetPalette(true)
          mixer:SetAlphaBar(true)
          mixer:SetWangs(true)
          mixer:SetConVarR(v2.conVar..'R')
          mixer:SetConVarG(v2.conVar..'G')
          mixer:SetConVarB(v2.conVar..'B')
          mixer:SetConVarA(v2.conVar..'A')

          panel = mixer

          form:AddItem(label)
          form:AddItem(mixer)
        end

        if IsValid(panel) then
          if v2.class == 'checkBox' then
            panel.Button:SetTooltip(v2.toolTip)
          else
            panel:SetTooltip(v2.toolTip)
          end
        end
      end

      self.panelList:AddItem(form)
    end
  else
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#NoSettingsInfoText')
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
  draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
  draw.RoundedBox(0, 1, 1, w - 2, h - 2, cw.option:GetColor('panel_background'))

  return true
end

vgui.Register('cwSettings', PANEL, 'EditablePanel')
