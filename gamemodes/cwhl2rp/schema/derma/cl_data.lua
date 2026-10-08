--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

--- Sets up the blurred frame, a close button that also hides the cursor, and the list holding the editor.
function PANEL:Init()
  self:SetBackgroundBlur(true)
  self:SetDeleteOnClose(false)

  -- Called when the button is clicked.
  function self.btnClose.DoClick(button)
    self:Close() self:Remove()

    gui.EnableScreenClicker(false)
  end

  self.panelList = vgui.Create('DPanelList', self)
  self.panelList:SetPadding(2)
  self.panelList:SetSpacing(3)
  self.panelList:SizeToContents()
  self.panelList:EnableVerticalScrollbar()
end

--- Keeps the frame at 256 by 318 pixels in the middle of the screen.
function PANEL:Think()
  local scrW = ScrW()
  local scrH = ScrH()

  self:SetSize(256, 318)
  self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2))
end

--- Fills the panel with an editor for a player's Combine data.
--
-- The text is limited to 500 characters. Pressing Okay sends it to the server with the `EditData`
-- netstream message, which saves it as the player's `combinedata` character data.
-- @param player [Player The player whose data is edited]
-- @param data [String The current data]
function PANEL:Populate(player, data)
  self:SetTitle(player:Name())

  self.panelList:Clear()

  local textEntry = vgui.Create('DTextEntry')
  local button = vgui.Create('DButton')

  textEntry:SetMultiline(true)
  textEntry:SetHeight(256)
  textEntry:SetText(data)

  button:SetText('#Button_Okay')

  -- A function to set the text entry's real value.
  function textEntry:SetRealValue(text)
    self:SetValue(text)
    self:SetCaretPos(string.len(text))
  end

  -- Called each frame.
  function textEntry:Think()
    local text = self:GetValue()

    if string.len(text) > 500 then
      self:SetRealValue(string.sub(text, 0, 500))

      surface.PlaySound('common/talk.wav')
    end
  end

  -- Called when the button is clicked.
  function button.DoClick(button)
    self:Close() self:Remove()

    if IsValid(player) then
      netstream.Start('EditData', { player, string.sub(textEntry:GetValue(), 0, 500) })
    end

    gui.EnableScreenClicker(false)
  end

  self.panelList:AddItem(textEntry)
  self.panelList:AddItem(button)
end

--- Stretches the editor list to fill the frame below the title bar.
function PANEL:PerformLayout()
  self.panelList:StretchToParent(4, 28, 4, 4)

  DFrame.PerformLayout(self)
end

vgui.Register('cwData', PANEL, 'DFrame')
