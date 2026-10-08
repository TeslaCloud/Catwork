--- Defines `cwForm`, a `DForm` whose `TextEntry` adds a dark label with a text entry on the row below it.

local PANEL = {}

--- Adds a dark label followed by a text entry below it.
-- @param strLabel [String Label text]
-- @return [Panel The `DTextEntry`, Panel The label]
function PANEL:TextEntry(strLabel)
  local labelPanel = vgui.Create('DLabel', self)

  self:AddItem(labelPanel)

  labelPanel:SetText(strLabel)
  labelPanel:SetDark(true)

  local textEntryPanel = vgui.Create('DTextEntry', self)

  self:AddItem(textEntryPanel)

  return textEntryPanel, labelPanel
end

vgui.Register('cwForm', PANEL, 'DForm')
