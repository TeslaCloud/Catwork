--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--[[
  @codebase Client
  @details Provides an interface to the Menu Items.
  @field stored A table containing a list of stored menu items.
--]]
library.New('menuitems', cw)
cw.menuitems.stored = cw.menuitems.stored or {}

--- Returns a main menu tab by its text.
-- @param text [String Text of the tab, as passed to `cw.menuitems:Add`]
-- @return [Map The menu item (`text`, `panel`, `tip`, `iconData`), or `nil` if there is none]
function cw.menuitems:Get(text)
  for k, v in pairs(self.stored) do
    if v.text == text then
      return v
    end
  end
end

--- Adds a tab to the main menu.
--
-- The list is rebuilt whenever the menu is created, so call this from the
-- `MenuItemsAdd` hook. Tabs are sorted by text.
--
-- ```
-- function PLUGIN:MenuItemsAdd(menuItems)
--   menuItems:Add('#Combine_PDA', 'cwCombinePDA', '#Combine_PDA_Desc', { path = 'fa-mobile', size = 10 })
-- end
-- ```
--
-- @param text [String Text of the tab button, or a language phrase]
-- @param panel [String VGUI class name of the panel the tab opens]
-- @param tip [String Tooltip of the button, or a language phrase]
-- @param iconData [Map Icon of the button: `path` (a Font Awesome icon name) and optional `size`]
-- @see cw.menuitems:Destroy
function cw.menuitems:Add(text, panel, tip, iconData)
  self.stored[#self.stored + 1] = { text = text, panel = panel, tip = tip, iconData = iconData }
end

--- Removes a main menu tab by its text.
--
-- Call this from the `MenuItemsDestroy` hook.
-- @param text [String Text of the tab]
function cw.menuitems:Destroy(text)
  for k, v in pairs(self.stored) do
    if v.text == text then
      table.remove(self.stored, k)
    end
  end
end
