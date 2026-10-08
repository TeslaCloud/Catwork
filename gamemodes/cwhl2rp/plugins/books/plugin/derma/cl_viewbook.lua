--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

--- Sets up the book window with a blurred background and a close button.
function PANEL:Init()
  self:SetBackgroundBlur(true)
  self:SetDeleteOnClose(false)

  -- Called when the button is clicked.
  function self.btnClose.DoClick(button)
    self:Close() self:Remove()

    gui.EnableScreenClicker(false)
  end
end

--- Keeps the window centred and closes it when the book is removed or more than 192 units away.
function PANEL:Think()
  local scrW = ScrW()
  local scrH = ScrH()

  self:SetSize(512, 512)
  self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2))

  if !IsValid(self.entity) or self.entity:GetPos():Distance(cw.client:GetPos()) > 192 then
    self:Close() self:Remove()

    gui.EnableScreenClicker(false)
  end
end

--- Sets the book entity the window shows.
--
-- @param entity [Entity The `cw_book` entity]
function PANEL:SetEntity(entity)
  self.entity = entity
end

--- Shows the book's HTML text and a Take button that picks the book up.
--
-- The button closes the window and sends the `TakeBook` netstream.
--
-- @param itemTable [Item The book's item, with its `bookInformation` HTML]
function PANEL:Populate(itemTable)
  self:SetTitle(cw.lang:TranslateText(itemTable.PrintName))

  self.htmlPanel = vgui.Create('HTML', self)
  self.htmlPanel:SetHTML(itemTable.bookInformation)
  self.htmlPanel:SetWrap(true)

  self.button = vgui.Create('DButton', self)
  self.button:SetText('#EntityMenuOptions_Take')
  self.button:SetWide(504)
  self.button:SetPos(4, 486)

  -- Called when the button is clicked.
  function self.button.DoClick(button)
    self:Close() self:Remove()

    gui.EnableScreenClicker(false)

    if IsValid(self.entity) then
      netstream.Start('TakeBook', self.entity)
    end
  end

  gui.EnableScreenClicker(true)
end

--- Stretches the HTML text to fill the window above the Take button.
function PANEL:PerformLayout()
  self.htmlPanel:StretchToParent(4, 28, 4, 30)

  DFrame.PerformLayout(self)
end

vgui.Register('cwViewBook', PANEL, 'DFrame')
