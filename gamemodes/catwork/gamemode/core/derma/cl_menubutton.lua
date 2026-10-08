--- Defines `cw.menuButton`, the `cwFAButton` used for a tab in the main menu, and adds the `cwMenuButtonSmall` font.
--
-- `SetupLabel` gives it the menu item's translated text, icon and tooltip and a callback that opens the item's panel
-- through `cw.menu`.

local PANEL = {}

cw.fonts:Add('cwMenuButtonSmall', {
  font		= 'Roboto Condensed',
  size		= 24,
  weight = 600,
  antialiase = true,
  additive = false,
  extended = true
})

--- Sets the button up for a menu item: translated upper-case text, icon, tooltip and a click callback that
-- opens the item's tab.
--
-- A `#` is added to the item's `text` when it lacks one, so it is looked up as a language phrase. The
-- icon comes from `iconData.path` (`bars` when empty), offset by `iconData.size` when set.
--
-- @param menuItem [Map Menu item with `text`, `tip` and `iconData` (`path` and `size`), as stored in
-- `cw.menuitems.stored`]
-- @param panel [Panel The tab panel the button opens]
function PANEL:SetupLabel(menuItem, panel)
  self:SetFont('cwMenuButtonSmall')

  if !menuItem.text:StartsWith('#') then
    menuItem.text = '#'..menuItem.text
  end

  local text = cw.lang:GetString(cw.lang:GetLanguage(), menuItem.text)

  self:SetText(text:utf8upper())

  if menuItem.iconData.path != '' then
    self:SetIcon(menuItem.iconData.path)
  else
    self:SetIcon('bars')
  end

  local offsetX = 4

  if menuItem.iconData.size then
    offsetX = menuItem.iconData.size
  end

  self:SetIconSize(24, 24, offsetX, 4)
  self:SetTextOffset(34, 4)

  self:FadeIn(0.5)

  self:SetTooltip(menuItem.tip)

  self:SetCallback(function(button)
    if cw.menu:GetActivePanel() != panel then
      cw.menu:GetPanel():OpenPanel(panel)
    end
  end)

  self:SizeToContents()
  self:SetMouseInputEnabled(true)

  self.ContentPanel = panel
  self:UpdatePositioning()
end

--- Sets the button to its fixed size of 200 by 32 pixels.
function PANEL:UpdatePositioning()
  self:SetSize(200, 32)
end

vgui.Register('cw.menuButton', PANEL, 'cwFAButton')
