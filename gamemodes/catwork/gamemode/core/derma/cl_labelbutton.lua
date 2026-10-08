--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

PANEL.BackgroundColor = Color(100, 100, 100)

--- Sets whether the label ignores hovering and clicks and is drawn greyed out.
-- @param disabled [Boolean `true` to disable the label]
function PANEL:SetDisabled(disabled)
  self.Disabled = disabled
end

--- Returns whether the label is disabled.
-- @return [Boolean Whether the label is disabled]
function PANEL:GetDisabled()
  return self.Disabled
end

--- Sets whether the label is held down.
-- @param depressed [Boolean `true` while the mouse button is held on it]
function PANEL:SetDepressed(depressed)
  self.Depressed = depressed
end

--- Returns whether the label is held down.
-- @return [Boolean Whether the label is held down]
function PANEL:GetDepressed()
  return self.Depressed
end

--- Sets whether the label is hovered.
-- @param hovered [Boolean `true` while the cursor is over it]
function PANEL:SetHovered(hovered)
  self.Hovered = hovered
end

--- Returns whether the label is hovered.
-- @return [Boolean Whether the label is hovered]
function PANEL:GetHovered()
  return self.Hovered
end

--- Marks the label as hovered unless it is disabled.
function PANEL:OnCursorEntered()
  if !self:GetDisabled() then
    self:SetHovered(true)
  end

  self:InvalidateLayout()
end

--- Sets whether a translucent box is drawn behind the label.
-- @param bDraw=false [Boolean `true` to draw the box]
function PANEL:SetDrawBackground(bDraw)
  self.ShouldDrawBackground = bDraw or false
end

--- Sets the size of the background box, or makes it follow the text size.
--
-- The size is only stored once the box has been drawn, since the size table is created then.
--
-- @param w=nil [Number Width of the box; leave out with `h` to fit the text]
-- @param h=nil [Number Height of the box; leave out with `w` to fit the text]
function PANEL:SetBackgroundSize(w, h)
  if w == nil or h == nil then
    self.BackgroundIsContentSize = true
    return
  end

  self.BackgroundSize.w = w
  self.BackgroundSize.h = h
end

--- Clears the label's hovered state.
function PANEL:OnCursorExited()
  self:SetHovered(false)
  self:InvalidateLayout()
end

--- Captures the mouse and marks the label as held down.
function PANEL:OnMousePressed(code)
  self:MouseCapture(true)
  self:SetDepressed(true)
end

--- Releases the mouse and calls `DoClick` when the left button is released over an enabled label.
function PANEL:OnMouseReleased(code)
  self:MouseCapture(false)

  if !self:GetDepressed() then
    return
  end

  self:SetDepressed(false)

  if !self:GetHovered() then
    return
  end

  if code == MOUSE_LEFT and self.DoClick
  and !self:GetDisabled() then
    self.DoClick(self)
  end
end

--- Starts fading the label out and hiding it, playing the rollover sound.
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the label is hidden]
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

--- Shows the label and starts fading it in, playing the click sound.
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the label is fully visible]
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

--- Sets a text color that replaces the default white, with a darker variant used when hovered or disabled.
-- @param color [Color Text color, or `nil`/`false` to use the default colors]
function PANEL:OverrideTextColor(color)
  if color then
    self.OverrideColorNormal = color
    self.OverrideColorHover =
      Color(math.max(color.r - 50, 0), math.max(color.g - 50, 0), math.max(color.b - 50, 0), color.a)
  else
    self.OverrideColorNormal = nil
    self.OverrideColorHover = nil
  end
end

--- Runs the fade animation, sizes the label to its background box and colors the text for its disabled,
-- hovered or normal state.
function PANEL:Think()
  if self.animation then
    self.animation:Run()
  end

  local colorWhite = cw.option:GetColor('white')
  local colorDisabled = Color(
    math.max(colorWhite.r - 50, 0),
    math.max(colorWhite.g - 50, 0),
    math.max(colorWhite.b - 50, 0),
    255
  )
  local colorInfo = cw.option:GetColor('information')

  if self.ShouldDrawBackground then
    self.BackgroundSize = self.BackgroundSize or {}

    if self.BackgroundIsContentSize then
      local w, h = util.GetTextSize(self.m_FontName, self:GetText())

      self.BackgroundSize.w = w
      self.BackgroundSize.h = h
    end

    if !self.BackgroundSize.w or !self.BackgroundSize.h then
      self.BackgroundSize.w = 200
      self.BackgroundSize.h = 32
    end

    self:SetSize(self.BackgroundSize.w + 8, self.BackgroundSize.h)
  end

  if self:GetDisabled() then
    self:SetTextColor(self.OverrideColorHover or colorDisabled)
  elseif self:GetHovered() then
    self:SetTextColor(self.OverrideColorHover or colorInfo)
  else
    self:SetTextColor(self.OverrideColorNormal or colorWhite)
  end

  self:SetExpensiveShadow(1, Color(0, 0, 0, 150))
end

--- Draws the background box, when enabled, lighter while hovered.
function PANEL:Paint(w, h)
  DisableClipping(true)

    if self.ShouldDrawBackground and self.BackgroundSize then
      if self.Hovered then
        draw.RoundedBox(0, -2, -2, self.BackgroundSize.w + 4, h + 4, Color(255, 255, 255, 80))
      else
        draw.RoundedBox(0, -2, -2, self.BackgroundSize.w + 4, h + 4, Color(160, 160, 160, 80))
      end
    end

  DisableClipping(false)
end

--- Sets the function called when the label is clicked, playing the click sound first.
-- @param Callback [Function Called with the label]
function PANEL:SetCallback(Callback)
  self.DoClick = function(button)
    cw.option:PlaySound('click')
    Callback(button)
  end
end

vgui.Register('cwLabelButton', PANEL, 'DLabel')
