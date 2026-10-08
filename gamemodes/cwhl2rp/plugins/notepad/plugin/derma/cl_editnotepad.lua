--[[
  © 2012 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {}

--- Sets up the notepad editor window and its scrolling list.
function PANEL:Init()
  self:SetBackgroundBlur(true)
  self:SetDeleteOnClose(false)
  self:SetTitle('#Notepad_Title')

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

--- Keeps the window centred and closes it when the notepad is removed or more than 192 units away.
function PANEL:Think()
  local scrW = ScrW()
  local scrH = ScrH()

  self:SetSize(scrW * 0.45, scrH * 0.6)
  self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2))

  if !IsValid(self.entity) or self.entity:GetPos():Distance(cw.client:GetPos()) > 192 then
    self:Close()
    self:Remove()

    gui.EnableScreenClicker(false)
  end
end

--- Sets the notepad entity the editor writes to.
--
-- @param entity [Entity The `cw_notepad` entity]
function PANEL:SetEntity(entity)
  self.entity = entity
end

--- Adds the text box and the button that sends the text to the server.
--
-- The text box is capped at 64000 characters. Pressing the button closes the window and
-- sends the text with the `EditNotepad` netstream.
--
-- @param notepad [String The notepad's current text]
function PANEL:Populate(notepad)
  -- self.panelList:Clear();

  local textEntry = vgui.Create('DTextEntry')
  local button = vgui.Create('DButton')

  textEntry:SetMultiline(true)
  textEntry:SetHeight(ScrH() * 0.6 - 64)
  textEntry:SetText(notepad)

  button:SetText('#Notepad_Okay')

  -- A function to set the text entry's real value.
  function textEntry:SetRealValue(text)
    self:SetValue(text)
    self:SetCaretPos(string.len(text))
  end

  -- Called each frame.
  function textEntry:Think()
    local text = self:GetValue()

    if string.utf8len(text) > 64000 then
      self:SetRealValue(string.utf8sub(text, 0, 64000))

      surface.PlaySound('common/talk.wav')
    end
  end

  -- Called when the button is clicked.
  function button.DoClick(button)
    self:Close()
    self:Remove()

    gui.EnableScreenClicker(false)

    if IsValid(self.entity) then
      netstream.Heavy('EditNotepad', self.entity, string.utf8sub(textEntry:GetValue(), 0, 64000))
    end
  end

  self.panelList:AddItem(textEntry)
  self.panelList:AddItem(button)
end

--- Stretches the list to fill the window below the title bar.
function PANEL:PerformLayout()
  self.panelList:StretchToParent(4, 28, 4, 4)

  DFrame.PerformLayout(self)
end

vgui.Register('cwEditNotepad', PANEL, 'DFrame')
