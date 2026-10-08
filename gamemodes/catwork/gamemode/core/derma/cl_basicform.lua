--- Defines `cwBasicForm`, a `DPanelList`-based form with helpers for adding labelled controls bound to console
-- variables.
--
-- Offers the same helpers as `DForm` (`TextEntry`, `ComboBox`, `NumberWang`, `NumSlider`, `CheckBox`, `Help`,
-- `ControlHelp`, `Button`, `PanelSelect`, `ListBox`) plus `SetText` for the header.

local headerColor = Color(120, 75, 235)

local PANEL = {}

--- Sets the form's header text, creating the header label on first use.
--
-- The label is drawn over a highlighted box and stretched to the form's width.
--
-- @param text [String Text of the header]
-- @param fontName=nil [String Font to use; defaults to the `menu_text_tiny` theme font]
-- @param color=nil [Color Text color, or the name of a theme color; defaults to `basic_form_color`]
-- @param size=nil [Number Font size; defaults to 16 when no font is given, otherwise keeps the font's size]
function PANEL:SetText(text, fontName, color, size)
  local label = self.Label
  local wasCreated = false

  if !label then
    label = vgui.Create('DLabel', self)
    wasCreated = true
    self.Label = label
  end

  if !fontName then
    fontName = cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), size or 16)
  elseif size then
    fontName = cw.fonts:GetSize(fontName, size)
  end

  label:SetFont(fontName)

  if isstring(color) then
    color = cw.option:GetColor(color)
  end

  if color then
    label:SetTextColor(color)
  else
    label:SetTextColor(cw.option:GetColor('basic_form_color'))
  end

  label:SetText(text)
  label:SizeToContents()
  label:SetWidth(self:GetWide())

  label.Paint = function(lbl, w, h)
    DisableClipping(true)
      draw.RoundedBox(0, -2, -2, w + 4, h + 4, headerColor)
    DisableClipping(false)
  end

  if wasCreated then
    self:AddItem(label)
  end
end

--- Adds a row to the form made of a label and a control.
--
-- When `right` is valid, both panels are placed side by side in a new row, with `right` offset 110 pixels
-- from the left. Otherwise `left` is added on its own; nothing is added when neither is valid.
--
-- @param left [Panel Panel shown on the left, usually a label]
-- @param right=nil [Panel Panel shown on the right]
function PANEL:AddLeftRight(left, right)
  if IsValid(right) then
    local panel = vgui.Create('DSizeToContents', self)

    panel:SetSizeX(false)
    panel:InvalidateLayout()

    left:SetParent(panel)
    left:Dock(LEFT)
    left:InvalidateLayout(true)
  --	left:SetSize(100, 20)

    right:SetParent(panel)
    right:SetPos(110, 0)
    right:InvalidateLayout(true)

    self:AddItem(panel)
  elseif IsValid(left) then
    self:AddItem(left)
  end
end

--- Adds a labelled text entry bound to a console variable.
-- @param strLabel [String Label text]
-- @param strConVar [String Console variable the entry reads and writes]
-- @return [Panel The `DTextEntry`, Panel The label]
function PANEL:TextEntry(strLabel, strConVar)
  local left = vgui.Create('DLabel', self)
  left:SetText(strLabel)
  left:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
  left:SetTextColor(cw.option:GetColor('basic_form_color'))

  local right = vgui.Create('DTextEntry', self)
  right:SetConVar(strConVar)
  right:Dock(TOP)

  self:AddLeftRight(left, right)

  return right, left
end

--- Adds a labelled combo box that sets a console variable when an option is picked.
--
-- The console variable is set to the option's data, or its text when it has no data.
--
-- @param strLabel [String Label text]
-- @param strConVar [String Console variable to set]
-- @return [Panel The `DComboBox`, Panel The label]
function PANEL:ComboBox(strLabel, strConVar)
  local left = vgui.Create('DLabel', self)
  left:SetText(strLabel)
  left:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
  left:SetTextColor(cw.option:GetColor('basic_form_color'))

  local right = vgui.Create('DComboBox', self)
  right:SetConVar(strConVar)
  right:Dock(FILL)

  function right:OnSelect(index, value, data)
    if !self.m_strConVar then return end

    RunConsoleCommand(self.m_strConVar, tostring(data or value))
  end

  self:AddLeftRight(left, right)

  return right, left
end

--- Adds a labelled number wang bound to a console variable.
-- @param strLabel [String Label text]
-- @param strConVar [String Console variable the wang reads and writes]
-- @param numMin [Number Smallest allowed value]
-- @param numMax [Number Largest allowed value]
-- @param numDecimals=nil [Number Number of decimal places to show]
-- @return [Panel The `DNumberWang`, Panel The label]
function PANEL:NumberWang(strLabel, strConVar, numMin, numMax, numDecimals)
  local left = vgui.Create('DLabel', self)
  left:SetText(strLabel)
  left:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
  left:SetTextColor(cw.option:GetColor('basic_form_color'))

  local right = vgui.Create('DNumberWang', self)
  right:SetMinMax(numMin, numMax)

  if numDecimals != nil then
    right:SetDecimals(numDecimals)
  end

  right:SetConVar(strConVar)
  right:Dock(TOP)

  self:AddLeftRight(left, right)

  return right, left
end

--- Adds a number slider bound to a console variable.
-- @param strLabel [String Label text]
-- @param strConVar [String Console variable the slider reads and writes]
-- @param numMin [Number Smallest allowed value]
-- @param numMax [Number Largest allowed value]
-- @param numDecimals=nil [Number Number of decimal places to show]
-- @return [Panel The `DNumSlider`]
function PANEL:NumSlider(strLabel, strConVar, numMin, numMax, numDecimals)
  local left = vgui.Create('DNumSlider', self)
  left:SetText(strLabel)
  left:SetMinMax(numMin, numMax)
  left.Label:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
  left.Label:SetTextColor(cw.option:GetColor('basic_form_color'))

  if numDecimals != nil then
    left:SetDecimals(numDecimals)
  end

  left:SetConVar(strConVar)
  left:SizeToContents()

  self:AddLeftRight(left, nil)

  return left
end

--- Adds a labelled check box bound to a console variable.
-- @param strLabel [String Label text]
-- @param strConVar [String Console variable the check box reads and writes]
-- @return [Panel The `DCheckBoxLabel`]
function PANEL:CheckBox(strLabel, strConVar)
  local left = vgui.Create('DCheckBoxLabel', self)
  left:SetText(strLabel)
  left.Label:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
  left.Label:SetTextColor(cw.option:GetColor('basic_form_color'))
  left:SetConVar(strConVar)

  self:AddLeftRight(left, nil)

  return left
end

--- Adds a wrapped help text label to the form.
-- @param strHelp [String Help text]
-- @return [Panel The label]
function PANEL:Help(strHelp)
  local left = vgui.Create('DLabel', self)

  left:SetWrap(true)
  left:SetTextInset(0, 0)
  left:SetText(strHelp)
  left:SetContentAlignment(7)
  left:SetAutoStretchVertical(true)
  left:DockMargin(8, 0, 8, 8)
  left:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 14))
  left:SetTextColor(cw.option:GetColor('basic_form_color'))

  self:AddLeftRight(left, nil)

  left:InvalidateLayout(true)

  return left
end

--- Adds a centred, wrapped help label for the control above it.
-- @param strHelp [String Help text]
-- @return [Panel The label]
function PANEL:ControlHelp(strHelp)
  local panel = vgui.Create('DSizeToContents', self)
  panel:SetSizeX(false)
  panel:Dock(TOP)
  panel:InvalidateLayout()

  local left = vgui.Create('DLabel', panel)
  left:SetDark(true)
  left:SetWrap(true)
  left:SetTextInset(0, 0)
  left:SetText(strHelp)
  left:SetContentAlignment(5)
  left:SetAutoStretchVertical(true)
  left:DockMargin(32, 0, 32, 8)
  left:Dock(TOP)
  left:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 14))
  left:SetTextColor(cw.option:GetColor('basic_form_color'))

  table.insert(self.Items, panel)

  return left
end

--- Adds a button, optionally running a console command when clicked.
-- @param strName [String Button text]
-- @param strConCommand=nil [String Console command to run on click]
-- @param ... [Any Arguments passed to the console command]
-- @return [Panel The `DButton`]
function PANEL:Button(strName, strConCommand, ...)
  local left = vgui.Create('DButton', self)

  if strConCommand then
    left:SetConsoleCommand(strConCommand, ...)
  end

  left:SetText(strName)
  self:AddLeftRight(left)

  return left
end

--- Adds an empty panel select to the form.
-- @return [Panel The `DPanelSelect`]
function PANEL:PanelSelect()
  local left = vgui.Create('DPanelSelect', self)
  self:AddLeftRight(left)
  return left
end

--- Adds a list box, preceded by a label when one is given.
-- @param strLabel=nil [String Label text shown above the list box]
-- @return [Panel The `DListBox`, Panel The label, or `nil` when no label text was given]
function PANEL:ListBox(strLabel)
  local left

  if strLabel then
    left = vgui.Create('DLabel', self)
    left:SetText(strLabel)
    left:SetFont(cw.fonts:GetSize(cw.option:GetFont('menu_text_tiny'), 16))
    left:SetTextColor(cw.option:GetColor('basic_form_color'))

    self:AddLeftRight(left)
  end

  local right = vgui.Create('DListBox', self)
  right.Stretch = true

  self:AddLeftRight(right)

  return right, left
end

vgui.Register('cwBasicForm', PANEL, 'DPanelList')
