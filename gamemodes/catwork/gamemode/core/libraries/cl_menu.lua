--- Defines the client-side `cw.menu` library, which creates, opens and closes the main menu and gives access to its tab
-- panels.
--
-- The tabs themselves are registered with `cw.menuitems`.

library.New('menu', cw)
cw.menu.width = math.min(ScrW() * 0.7, 768)
cw.menu.height = ScrH() * 0.75
cw.menu.stored = cw.menu.stored or {}

--- Returns the tab panel shown in the main menu.
-- @return [Panel The active tab panel, or `nil` if there is none or the menu does not exist]
function cw.menu:GetActivePanel()
  local panel = self:GetPanel()

  if panel then
    return panel.activePanel
  end
end

--- Returns whether the main menu is open on a tab panel.
-- @param panel [Panel The tab panel to check]
-- @return [Boolean Whether the menu is open and `panel` is its active tab]
function cw.menu:IsPanelActive(panel)
  return (cw.menu:GetOpen() and self:GetActivePanel() == panel)
end

--- Returns the time until which releasing the scoreboard key keeps the main menu open.
--
-- Set to half a second after the menu is opened with the scoreboard key, so a short
-- press leaves it open.
-- @return [Number An `UnPredictedCurTime` value, or `nil` if the menu was never opened that way]
function cw.menu:GetHoldTime()
  return self.holdTime
end

--- Returns the tab buttons and panels created by the main menu.
-- @return [Map<Map> Tables with `button` and `panel` keyed by the VGUI class name of the tab]
function cw.menu:GetItems()
  return self.stored
end

--- Returns the width of the main menu's tab panels.
-- @return [Number Width in pixels]
function cw.menu:GetWidth()
  return self.width
end

--- Returns the height of the main menu.
-- @return [Number Height in pixels]
function cw.menu:GetHeight()
  return self.height
end

--- Opens the main menu if it is closed, and closes it otherwise.
--
-- Does nothing if the menu does not exist.
function cw.menu:ToggleOpen()
  local panel = self:GetPanel()

  if panel then
    if self:GetOpen() then
      panel:SetOpen(false)
    else
      panel:SetOpen(true)
    end
  end
end

--- Opens or closes the main menu.
--
-- Does nothing if the menu does not exist.
-- @param bIsOpen [Boolean Whether to open the menu]
-- @see cw.menu:Create
function cw.menu:SetOpen(bIsOpen)
  local panel = self:GetPanel()

  if panel then
    panel:SetOpen(bIsOpen)
  end
end

--- Returns whether the main menu is open.
-- @return [Boolean Whether the menu is open]
function cw.menu:GetOpen()
  return self.bIsOpen
end

--- Returns the main menu panel.
-- @return [Panel The menu, or `nil` if it has not been created or was removed]
function cw.menu:GetPanel()
  if IsValid(self.panel) then
    return self.panel
  end
end

--- Creates the main menu if it does not exist yet.
-- @param setOpen=nil [Boolean Whether the new menu starts open]
function cw.menu:Create(setOpen)
  local panel = self:GetPanel()

  if !panel then
    self.panel = vgui.Create('cw.menu')

    if IsValid(self.panel) then
      self.panel:SetOpen(setOpen)
      self.panel:MakePopup()
    end
  end
end
