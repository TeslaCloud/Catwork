--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

--- Creates the notice's comment icon and text label on a blue background.
function PANEL:Init()
  self:SetPos(4, 4)
  self:SetSize(self:GetWide() - 8, 24)
  self:SetBackgroundColor(Color(139, 174, 179, 255))

  self.icon = vgui.Create('DImage', self)
  self.icon:SetImage('icon16/comment.png')
  self.icon:SizeToContents()

  local font = cw.fonts:GetSize(cw.option:GetFont('info_text_font'), 16)

  self.label = vgui.Create('DLabel', self)
  self.label:SetText('')
  self.label:SetFont(font)
  self.label:SetTextColor(cw.option:GetColor('white'))
  self.label:SetExpensiveShadow(1, Color(0, 0, 0, 150))
end

--- Centres the text, or aligns it to the left when `SetTextToLeft` is set, and moves the icon next to it.
function PANEL:PerformLayout(w, h)
  if self.textToLeft then
    if self.icon:IsVisible() then
      self.label:SetPos(self.icon.x + self.icon:GetWide() + 12, h / 2 - self.label:GetTall() / 2)
    else
      self.label:SetPos(8, h / 2 - self.label:GetTall() / 2)
    end
  else
    self.label:SetPos(w / 2 - self.label:GetWide() / 2, h / 2 - self.label:GetTall() / 2)
  end

  self:UpdateIconPosition()

  derma.SkinHook('Layout', 'Panel', self)
end

--- Draws the notice's background, shrunk while pressed and lightened while a hovered button.
function PANEL:Paint(w, h)
  if self:GetPaintBackground() then
    local width, height = self:GetSize()
    local x, y = 0, 0

    if self:IsDepressed() then
      height = height - 2
      width = width - 2
      x = x + 1
      y = y + 1
    end

    cdraw.DrawBox(x, y, width, height, self:GetBackgroundColor())

    if self:IsButton() and self:IsHovered() then
      surface.SetDrawColor(255, 255, 255, 50)
      surface.DrawRect(x, y, width, height)
    end
  end

  return true
end

--- Sets whether the text is aligned to the left instead of centred.
-- @param bValue [Boolean `true` to align the text to the left]
function PANEL:SetTextToLeft(bValue)
  self.textToLeft = bValue
end

--- Sets the notice's text and resizes the label to fit it.
-- @param text [String Text to show; may be a language phrase]
function PANEL:SetText(text)
  self.label:SetText(text)
  self.label:SizeToContents()

  self:UpdateIconPosition()
end

--- Sets whether the notice acts as a button that calls `DoClick` when clicked.
-- @param isButton [Boolean `true` to make the notice clickable]
function PANEL:SetButton(isButton)
  self.isButton = isButton
end

--- Returns whether the notice acts as a button.
-- @return [Boolean Whether the notice is clickable]
function PANEL:IsButton()
  return self.isButton
end

--- Sets whether the notice is held down.
-- @param isDepressed [Boolean `true` while the mouse button is held on it]
function PANEL:SetDepressed(isDepressed)
  self.isDepressed = isDepressed
end

--- Returns whether the notice is held down.
-- @return [Boolean Whether the notice is held down]
function PANEL:IsDepressed()
  return self.isDepressed
end

--- Sets whether the notice is hovered.
-- @param isHovered [Boolean `true` while the cursor is over it]
function PANEL:SetHovered(isHovered)
  self.isHovered = isHovered
end

--- Returns whether the notice is hovered.
-- @return [Boolean Whether the notice is hovered]
function PANEL:IsHovered()
  return self.isHovered
end

--- Sets the color of the notice's text.
-- @param color [Color Text color]
function PANEL:SetTextColor(color)
  self.label:SetTextColor(color)
end

--- Marks the notice as held down and captures the mouse when it is a button.
function PANEL:OnMousePressed(mouseCode)
  if self:IsButton() then
    self:SetDepressed(true)
    self:MouseCapture(true)
  end
end

--- Plays the click sound and calls `DoClick` when a held button is released over the notice.
function PANEL:OnMouseReleased(mouseCode)
  if self:IsButton() and self:IsDepressed()
  and self:IsHovered() then
    if self.DoClick then
      cw.option:PlaySound('click')
      self:DoClick()
    end
  end

  self:SetDepressed(false)
  self:MouseCapture(false)
end

--- Marks the notice as hovered.
function PANEL:OnCursorEntered()
  self:SetHovered(true)
end

--- Clears the notice's hovered state.
function PANEL:OnCursorExited()
  self:SetHovered(false)
end

--- Shows or hides the notice's icon.
-- @param showIcon [Boolean `true` to show the icon]
function PANEL:SetShowIcon(showIcon)
  self.icon:SetVisible(showIcon)
end

--- Sets and shows the notice's icon.
-- @param icon [String Image path of the icon]
-- @param size=nil [Number Width and height of the icon; defaults to the `info_text_icon_size` option]
function PANEL:SetIcon(icon, size)
  if !size then
    size = cw.option:GetKey('info_text_icon_size')
  end

  self.icon:SetImage(icon)
  self.icon:SetVisible(true)
  self.icon:SetSize(size, size)

  self:UpdateIconPosition()
end

--- Moves the icon next to the text, or to the left edge when the text is aligned left.
function PANEL:UpdateIconPosition()
  local size = self.icon:GetWide()

  if !self.textToLeft then
    self.icon:SetPos(self.label.x - size - 12, 12 - (size / 2))
  else
    self.icon:SetPos(8, 16 - (size / 2))
  end
end

--- Sets the notice's background color and icon from a preset, or a custom color without an icon.
--
-- The presets are `'red'`, `'orange'`, `'green'` and `'blue'`, each with the icon from the matching
-- `info_text_*_icon` option.
--
-- @param color [String Preset name, or a `Color` for a custom background]
function PANEL:SetInfoColor(color)
  if color == 'red' then
    self:SetBackgroundColor(Color(179, 46, 49, 255))
    self:SetIcon(cw.option:GetKey('info_text_red_icon'))
  elseif color == 'orange' then
    self:SetBackgroundColor(Color(223, 154, 72, 255))
    self:SetIcon(cw.option:GetKey('info_text_orange_icon'))
  elseif color == 'green' then
    self:SetBackgroundColor(Color(139, 215, 113, 255))
    self:SetIcon(cw.option:GetKey('info_text_green_icon'))
  elseif color == 'blue' then
    self:SetBackgroundColor(Color(139, 174, 179, 255))
    self:SetIcon(cw.option:GetKey('info_text_blue_icon'))
  else
    self:SetShowIcon(false)
    self:SetBackgroundColor(color)
  end
end

vgui.Register('cwInfoText', PANEL, 'DPanel')
