--- Defines `cwPanelList`, a `DCategoryList` with an outlined background that docks added items to the top, used as the
-- list in most framework menus.
--
-- Keeps `DPanelList` methods such as `SetSpacing` and `EnableVerticalScrollbar` so older code keeps working.

local PANEL = {}

--- Sets the list's default dark background and black outline.
function PANEL:Init()
  self.backgroundColor = Color(50, 50, 50, 255)
  self.backgroundColorOutline = Color(0, 0, 0, 255)
end

--- Sets the list's background and outline colors.
-- @param color [Color Background color]
-- @param col2=nil [Color Outline color; black when not given]
function PANEL:SetBackgroundColor(color, col2)
  self.backgroundColor = color
  self.backgroundColorOutline = col2 or Color(0, 0, 0)
end

--- Stops the list from drawing its background.
function PANEL:HideBackground()
  self.backgroundHidden = true
end

--- Sets the space left below each item added afterwards.
-- @param spacing [Number Space in pixels]
function PANEL:SetSpacing(spacing)
  self.defaultSpacing = spacing
end

--- Does nothing; kept so code written for `DPanelList` keeps working.
function PANEL:EnableVerticalScrollbar() end

--- Docks an item to the top of the list with the list's padding around it.
-- @param item [Panel Panel to add]
-- @param bottomMargin=nil [Number Space below the item; defaults to the `SetSpacing` value, or 8]
function PANEL:AddItem(item, bottomMargin)
  bottomMargin = bottomMargin or self.defaultSpacing or 8

  local padding = self:GetPadding()

  item:Dock(TOP)
  item:DockMargin(padding, padding, padding, bottomMargin)

  DCategoryList.AddItem(self, item)

  -- TODO: Maybe not have this.
  self:InvalidateLayout(true)
end

--- Draws the outlined background unless it is hidden.
function PANEL:Paint(width, height)
  if !self.backgroundHidden then
    draw.RoundedBox(0, 0, 0, width, height, self.backgroundColorOutline)
    draw.RoundedBox(0, 1, 1, width - 2, height - 2, self.backgroundColor)
  end

  return true
end

vgui.Register('cwPanelList', PANEL, 'DCategoryList')
