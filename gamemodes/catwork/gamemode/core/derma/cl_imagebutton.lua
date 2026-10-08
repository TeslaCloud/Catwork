--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

--- Sets whether the button ignores hovering and clicks.
-- @param disabled [Boolean `true` to disable the button]
function PANEL:SetDisabled(disabled)
  self.Disabled = disabled
end

--- Returns whether the button is disabled.
-- @return [Boolean Whether the button is disabled]
function PANEL:GetDisabled()
  return self.Disabled
end

--- Sets whether the button is held down.
-- @param depressed [Boolean `true` while the mouse button is held on it]
function PANEL:SetDepressed(depressed)
  self.Depressed = depressed
end

--- Returns whether the button is held down.
-- @return [Boolean Whether the button is held down]
function PANEL:GetDepressed()
  return self.Depressed
end

--- Sets whether the button is hovered.
-- @param hovered [Boolean `true` while the cursor is over it]
function PANEL:SetHovered(hovered)
  self.Hovered = hovered
end

--- Returns whether the button is hovered.
-- @return [Boolean Whether the button is hovered]
function PANEL:GetHovered()
  return self.Hovered
end

--- Marks the button as hovered unless it is disabled.
function PANEL:OnCursorEntered()
  if !self:GetDisabled() then
    self:SetHovered(true)
  end

  DImage.ApplySchemeSettings(self)
end

--- Clears the button's hovered state.
function PANEL:OnCursorExited()
  self:SetHovered(false)
  DImage.ApplySchemeSettings(self)
end

--- Captures the mouse and marks the button as held down.
function PANEL:OnMousePressed(code)
  self:MouseCapture(true)
  self:SetDepressed(true)
end

--- Releases the mouse and calls `DoClick` when the left button is released over an enabled button.
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

--- Fades the button out and hides it, playing the rollover sound.
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

--- Shows the button and fades it in, playing the click sound.
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

--- Runs the fade animation.
function PANEL:Think()
  if self.animation then
    self.animation:Run()
  end
end

--- Sets the function called when the button is clicked, playing the click sound first.
-- @param Callback [Function Called with the button]
function PANEL:SetCallback(Callback)
  self.DoClick = function(button)
    cw.option:PlaySound('click')
    Callback(button)
  end
end

vgui.Register('cwImageButton', PANEL, 'DImage')
