--- Defines the `cwFAButton` panel, a button that draws a Font Awesome icon with an optional text label next to it.
--
-- The icon is drawn with `cw.FontIcons:Draw` and set up with `SetIcon`, `SetIconSize` and `SetText`; `SetCallback`
-- sets what a click does. A collapsible button toggles between showing and hiding its text when clicked, and `FadeIn`
-- and `FadeOut` animate its alpha. It is the base of the main menu's buttons, such as `cw.menuButton`.

local colorWhite = Color(255, 255, 255)
local colorOutline = Color(8, 8, 8)
local colorBackground = Color(35, 35, 35)
local colorBackgroundHovered = Color(60, 60, 60)

local PANEL = {}

PANEL.isCollapsible = false
PANEL.isOpen = true
PANEL.shouldHover = true
PANEL.iconW = 0
PANEL.iconH = 0
PANEL.iconX = 0
PANEL.iconY = 0

--- Sets whether the button is open, which shows its text next to the icon.
-- @param bIsOpen [Boolean `true` to show the text]
function PANEL:SetOpen(bIsOpen)
  self.isOpen = bIsOpen
end

--- Sets whether the button draws its dark background box.
-- @param bDrawBackground [Boolean `true` to draw the background]
function PANEL:SetDrawBackground(bDrawBackground)
  self.drawBackground = bDrawBackground
end

--- Sets the Font Awesome icon drawn on the button.
-- @param id [String Icon name, as accepted by `cw.FontIcons:Draw`]
function PANEL:SetIcon(id)
  self.iconID = id
end

--- Sets the icon's size and offset.
-- @param w=16 [Number Icon width]
-- @param h=16 [Number Icon height, also used as the icon's draw size]
-- @param x=0 [Number Horizontal offset of the icon]
-- @param y=0 [Number Vertical offset of the icon]
function PANEL:SetIconSize(w, h, x, y)
  self.iconW = w or 16
  self.iconH = h or 16
  self.iconX = x or 0
  self.iconY = y or 0
end

--- Sets the button's text and makes it visible.
-- @param text [String Text to draw]
function PANEL:SetText(text)
  self.drawText = text
  self.shouldDrawText = true
end

--- Sets the font of the button's text.
-- @param font [String Font name; `Derma16` is used when unset]
-- @alias [PANEL.SetTextFont]
function PANEL:SetFont(font)
  self.m_Font = font
end

--- Sets the position of the text inside the button, replacing the default placement after the icon.
-- @param x [Number Horizontal offset]
-- @param y [Number Vertical offset]
function PANEL:SetTextOffset(x, y)
  self.textOX = x
  self.textOY = y
end

PANEL.SetTextFont = PANEL.SetFont

--- Resizes the button to fit its icon and text.
-- @alias [PANEL.SizeToContents]
function PANEL:SizeToText()
  local w, h = util.GetTextSize((self.m_Font or 'Derma16'), self.drawText)

  self:SetSize((self.iconW + self.iconX or 0) + w + 8 + (self.textOX or 0), (self.iconH + self.iconY * 2 or h + 8))
end

PANEL.SizeToContents = PANEL.SizeToText

--- Toggles whether the button is open.
function PANEL:Toggle()
  if self.isOpen then
    self.isOpen = false
  else
    self.isOpen = true
  end
end

--- Sets whether clicking the button toggles it open and closed.
-- @param coll [Boolean `true` to toggle on click]
function PANEL:SetCollapsible(coll)
  self.isCollapsible = coll
end

--- Toggles the button when it is collapsible and runs its callback, reporting any error it throws.
function PANEL:OnMousePressed()
  if self.isCollapsible then
    self:Toggle()
  end

  if self._callback then
    local bSuccess, val = pcall(self._callback, self)

    if !bSuccess then
      ErrorNoHalt('[Catwork - FAButton] '..val..'\n')
    end
  end
end

--- Sets whether the button highlights itself when hovered.
-- @param hover [Boolean `true` to highlight on hover]
function PANEL:ShouldHover(hover)
  self.shouldHover = hover
end

--- Sets the function called when the button is clicked.
-- @param cb [Function Called with the button; errors are caught and printed]
function PANEL:SetCallback(cb)
  self._callback = cb
end

--- Draws the background, when enabled, then the icon and text, highlighted when hovered.
function PANEL:Paint(w, h)
  local bHovered = self:IsHovered() and self.shouldHover

  if self.drawBackground then
    local drawColor = colorBackground

    if bHovered then
      drawColor = colorBackgroundHovered
    else
      self:OverrideTextColor(colorWhite)
    end

    draw.RoundedBox(0, 0, 0, w, h, colorOutline)
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, drawColor)
  end

  local textColor = colorWhite

  if bHovered then
    textColor = cw.option:GetColor('information') or colorWhite
  end

  textColor = self.overrideColor or textColor

  if self.iconID then
    cw.FontIcons:Draw(
      self.iconID,
      (self.iconX or 0) + 1,
      (self.iconY or 0) - 1,
      (self.iconH or 16),
      textColor
    )
  end

  if self.shouldDrawText then
    local offsetX = 0

    if self.iconW then
      offsetX = self.iconW + 8
    end

    if self.drawText then
      draw.SimpleText(
        self.drawText,
        (self.m_Font or 'Derma16'),
        (self.textOX or offsetX),
        (self.textOY or 0),
        textColor
      )
    end
  end
end

--- Shows the text only while the button is open.
function PANEL:Think()
  self.shouldDrawText = self.isOpen and true or false
end

--- Starts fading the button out and hiding it, playing the rollover sound.
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the button is hidden]
function PANEL:FadeOut(speed, Callback)
  self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
    panel:SetAlpha(255 - (delta * 255))

    if animation.Finished then
      panel:SetVisible(false)

        if Callback then
          Callback()
        end

      self.animation = nil
    end
  end)

  if self.animation then
    self.animation:Start(speed)
  end

  cw.option:PlaySound('rollover')
end

--- Shows the button and starts fading it in, playing the click sound.
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the button is fully visible]
function PANEL:FadeIn(speed, Callback)
  self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
    panel:SetAlpha(delta * 255)

    if animation.Finished then
      if Callback then
        Callback()
      end

      self.animation = nil
    end
  end)

  if self.animation then
    self.animation:Start(speed)
  end

  cw.option:PlaySound('click_release')
  self:SetVisible(true)
end

--- Sets a color that replaces the text and icon color, including the hover color.
-- @param color [Color Color to use, or `nil` to use the default colors]
function PANEL:OverrideTextColor(color)
  self.overrideColor = color
end

vgui.Register('cwFAButton', PANEL, 'Panel')
