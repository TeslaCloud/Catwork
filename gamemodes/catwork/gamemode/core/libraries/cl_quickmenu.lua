--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('quickmenu', cw)
cw.quickmenu.stored = cw.quickmenu.stored or {}
cw.quickmenu.categories = cw.quickmenu.categories or {}

--- Adds an option to the quick menu opened from the player information box.
--
-- `GetInfo` is called when the menu is built and returns the option table:
-- `Callback` (called with the chosen sub option), and optionally `toolTip`,
-- `name` and `options` (a `List` of sub options, each a string or a
-- `{ name, value }` pair). Returning anything other than a table hides the option.
--
-- ```
-- cw.quickmenu:AddCallback('#QuickMenu_FallOver', nil, function()
--   return {
--     toolTip = 'Fall over.',
--     Callback = function(option)
--       cw.core:RunCommand('CharFallOver')
--     end
--   }
-- end)
-- ```
--
-- @param name [String Text of the option, or a language phrase]
-- @param category=nil [String Category submenu to put the option in; top level when `nil`]
-- @param GetInfo [Function Returns the option table]
-- @param OnCreateMenu=nil [Function Stored with the option; not called by Catwork]
-- @return [String The option name]
-- @see cw.quickmenu:AddCommand
function cw.quickmenu:AddCallback(name, category, GetInfo, OnCreateMenu)
  if category then
    if !self.categories[category] then
      self.categories[category] = {}
    end

    self.categories[category][name] = {
      OnCreateMenu = OnCreateMenu,
      GetInfo = GetInfo,
      name = name
    }
  else
    self.stored[name] = {
      OnCreateMenu = OnCreateMenu,
      GetInfo = GetInfo,
      name = name
    }
  end

  return name
end

--- Adds a quick menu option that runs a command.
--
-- The option shows the command's tip and is hidden when the command does not exist.
-- @param name [String Text of the option, or a language phrase]
-- @param category=nil [String Category submenu to put the option in; top level when `nil`]
-- @param command [String Unique ID of the command]
-- @param options=nil [List Sub options; the chosen one is passed to the command as its argument]
-- @return [String The option name]
function cw.quickmenu:AddCommand(name, category, command, options)
  return self:AddCallback(name, category, function()
    local commandTable = cw.command:FindByID(command)

    if commandTable then
      return {
        toolTip = commandTable.tip,
        Callback = function(option)
          cw.core:RunCommand(command, option)
        end,
        options = options
      }
    else
      return false
    end
  end)
end

cw.quickmenu:AddCallback('#QuickMenu_FallOver', nil, function()
  local commandTable = cw.command:FindByID('CharFallOver')

  if commandTable then
    return {
      toolTip = commandTable.tip,
      Callback = function(option)
        cw.core:RunCommand('CharFallOver')
      end
    }
  else
    return false
  end
end)

cw.quickmenu:AddCallback('#QuickMenu_Description', nil, function()
  local commandTable = cw.command:FindByID('CharPhysDesc')

  if commandTable then
    return {
      toolTip = commandTable.tip,
      Callback = function(option)
        cw.core:RunCommand('CharPhysDesc')
      end
    }
  else
    return false
  end
end)
