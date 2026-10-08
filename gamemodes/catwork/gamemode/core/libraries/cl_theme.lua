--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('theme', cw)

cw.theme.stored = cw.theme.stored or {}

--[[ Use a debug hack to get the panel factory. --]]
local sTabName, tPanelFactory = debug.getupvalue(vgui.Create, 1)

if sTabName == 'PanelFactory' and type(tPanelFactory) == 'table' then
  cw.theme.factory = tPanelFactory
  cw.theme.backupFactory = cw.theme.backupFactory or table.Copy(tPanelFactory)
else
  cw.theme.factory = cw.theme.factory or {}
  cw.theme.backupFactory = cw.theme.backupFactory or {}
end

--[[
  Make new derma panels get saved to the backup factory so that panels
  made after the backup is made can be freely changed and switched from.

  This method will also revert any changes made by overwriting vgui tables with
  vgui.Register in a theme file when a theme is changed.
--]]
local oldRegister = vgui.Register

--- Registers a VGUI panel class, replacing the engine's `vgui.Register`.
--
-- Also saves wrappers of the panel's methods (merged with its base class) to
-- `cw.theme.backupFactory`, or to the theme being built when the class is
-- re-registered inside a theme file, so theme changes can be reverted when the
-- theme is unloaded.
-- @param className [String Name of the panel class]
-- @param panelTable [Map The panel's methods]
-- @param baseName=nil [String Name of the base class]
-- @return [Map The registered panel table, as returned by the engine function]
function vgui.Register(className, panelTable, baseName)
  local backup = cw.theme.backupFactory

  if backup[className] and cwTHEME then
    backup = cwTHEME.factory
  end

  backup[className] = {}

  local base = backup[baseName]

  if base then
    table.Merge(base, panelTable)

    for k, v in pairs(base) do
      backup[className][k] = function(vguiObject, ...)
        v(vguiObject, ...)
      end
    end
  else
    for k, v in pairs(panelTable) do
      backup[className][k] = function(vguiObject, ...)
        v(vguiObject, ...)
      end
    end
  end

  return oldRegister(className, panelTable, baseName)
end

--- Replaces a method of a Derma panel class in the theme being built.
--
-- Must be called between `cw.theme:New` and `cw.theme:Register`; does nothing
-- otherwise or if the panel class does not exist.
--
-- ```
-- cw.theme:HookReplace('cwStorage', 'Paint', function(panel, w, h)
--   draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20))
-- end)
-- ```
--
-- @param vguiName [String Name of the panel class]
-- @param functionName [String Name of the method to replace]
-- @param callback [Function The new method, called with the panel and the method's arguments]
-- @see cw.theme:HookBefore
-- @see cw.theme:HookAfter
function cw.theme:HookReplace(vguiName, functionName, callback)
  if !self.factory[vguiName] then
    return
  end

  if cwTHEME then
    local factory = cwTHEME.factory

    factory[vguiName] = factory[vguiName] or {}
    factory[vguiName][functionName] = function(vguiObject, ...)
      callback(vguiObject, ...)
    end
  end
end

--- Adds a function that runs before a method of a Derma panel class, in the theme being built.
--
-- Must be called between `cw.theme:New` and `cw.theme:Register`; does nothing
-- otherwise or if the panel class or method does not exist.
-- @param vguiName [String Name of the panel class]
-- @param functionName [String Name of the method]
-- @param callback [Function Called with the panel and the method's arguments before the method]
-- @see cw.theme:HookAfter
function cw.theme:HookBefore(vguiName, functionName, callback)
  if !self.factory[vguiName] then
    return
  end

  local oldFunction = self.factory[vguiName][functionName]

  if oldFunction == nil then
    return
  end

  if cwTHEME then
    local factory = cwTHEME.factory

    factory[vguiName] = factory[vguiName] or {}
    factory[vguiName][functionName] = function(vguiObject, ...)
      callback(vguiObject, ...)
      oldFunction(vguiObject, ...)
    end
  end
end

--- Adds a function that runs after a method of a Derma panel class, in the theme being built.
--
-- Must be called between `cw.theme:New` and `cw.theme:Register`; does nothing
-- otherwise or if the panel class or method does not exist.
-- @param vguiName [String Name of the panel class]
-- @param functionName [String Name of the method]
-- @param callback [Function Called with the panel and the method's arguments after the method]
-- @see cw.theme:HookBefore
function cw.theme:HookAfter(vguiName, functionName, callback)
  if !self.factory[vguiName] then
    return
  end

  local oldFunction = self.factory[vguiName][functionName]

  if oldFunction == nil then
    return
  end

  if cwTHEME then
    local factory = cwTHEME.factory

    factory[vguiName] = factory[vguiName] or {}
    factory[vguiName][functionName] = function(vguiObject, ...)
      oldFunction(vguiObject, ...)
      callback(vguiObject, ...)
    end
  end
end

--- Returns every registered theme.
-- @return [Map<Map> Theme tables keyed by name]
function cw.theme:GetAll()
  return cw.theme.stored
end

--- Returns a registered theme by name.
-- @param id [String Name of the theme]
-- @return [Map The theme table, or `nil` if it does not exist]
function cw.theme:FindByID(id)
  return cw.theme.stored[id]
end

--- Returns whether a theme is registered.
--
-- Uses `IsValid` on the theme table, which is only true for tables with an
-- `IsValid` method, so this returns `false` for ordinary themes.
-- @param id [String Name of the theme]
-- @return [Boolean Whether the theme exists]
function cw.theme:Exists(id)
  return (IsValid(cw.theme.stored[id]))
end

--- Starts building a new theme with the arguments in the old order.
-- @param isFixed=nil [Boolean Whether players cannot change the information color]
-- @param name='Schema' [String Name of the theme]
-- @param baseName=nil [String Name of the theme to derive from]
-- @return [Map The new theme table]
-- @deprecation [Use `cw.theme:New`, which takes the arguments as `(name, baseName, isFixed)`.]
function cw.theme:Begin(isFixed, name, baseName)
  return self:New(name, baseName, isFixed)
end

--- Starts building a new theme and stores it in the global `cwTHEME`.
--
-- The theme starts as a copy of its base theme, or of the `Clockwork` theme when
-- no base is given. Fill in its `hooks` (theme hooks run by `cw.theme:Call`),
-- `module` (plugin hooks), `skin` and `factory` tables and its `CreateFonts`,
-- `Initialize`, `PostInitialize` and `OnUnloaded` methods, then call
-- `cw.theme:Register`.
--
-- ```
-- local THEME = cw.theme:New('Combine', 'Clockwork')
--
-- function THEME.hooks:PostMainMenuPaint(panel)
--   draw.RoundedBox(0, 0, 0, panel:GetWide(), 4, Color(0, 120, 255))
-- end
--
-- cw.theme:Register()
-- ```
--
-- @param themeName='Schema' [String Name of the theme]
-- @param baseName=nil [String Name of the theme to derive from]
-- @param isFixed=nil [Boolean Whether players cannot change the information color]
-- @return [Map The new theme table]
function cw.theme:New(themeName, baseName, isFixed)
  if baseName then
    local base = self:FindByID(baseName)

    if base then
      cwTHEME = table.Copy(base)
    end

    cwTHEME.base = baseName
  elseif themeName != 'Clockwork' then
    local base = self:FindByID('Clockwork')

    if base then
      cwTHEME = table.Copy(base)
    end

    cwTHEME.base = 'Clockwork'
  end

  if !cwTHEME then
    cwTHEME = {
      factory = {},
      module = {},
      hooks = {},
      skin = {}
    }
  end

  cwTHEME.name = themeName or 'Schema'
  cwTHEME.isFixed = isFixed

  return cwTHEME
end

--- Returns the active theme.
-- @return [Map The active theme table, or `nil` if none is loaded]
function cw.theme:Get()
  return self.active
end

--- Returns whether the active theme stops players from changing the information color.
-- @return [Boolean Whether the color is fixed; `nil` if no theme is active]
function cw.theme:IsFixed()
  return (self.active and self.active.isFixed)
end

--- Copies the active theme's `skin` table into the `Clockwork` Derma skin and refreshes the skins.
function cw.theme:CopySkin()
  local skinTable = derma.GetNamedSkin('Clockwork')

  if self.active and skinTable then
    for k, v in pairs(self.active.skin) do
      skinTable[k] = v
    end
  end

  derma.RefreshSkins()
end

--- Loads the starting theme when Catwork initializes.
--
-- Uses the `default_theme` config, or the player's `cwActiveTheme` console
-- variable when the `modify_themes` config is on, falling back to `Clockwork`.
-- @warning [Internal] Called from `GM:Initialize`.
function cw.theme:Initialize()
  local theme = self:Get()
  local defaultTheme = config.Get('default_theme'):Get()

  if defaultTheme then
    theme = defaultTheme
  end

  if config.Get('modify_themes'):GetBoolean() then
    local convarTheme = self:FindByID(GetConVar('cwActiveTheme'):GetString())

    if convarTheme then
      theme = convarTheme
    end
  end

  if !theme then
    theme = 'Clockwork'
  end

  cw.theme:SetActive(theme, true)
end

--- Saves the theme being built in `cwTHEME` with `cw.theme:Finish`.
-- @param bSwitchTo=nil [Boolean Whether to switch to the theme right away]
-- @return [String Name of the theme, or `nil` if no theme was being built]
function cw.theme:Register(bSwitchTo)
  if cwTHEME then
    local name = cwTHEME.name

    cw.theme:Finish(cwTHEME, !bSwitchTo)

    return name
  end
end

--- Saves a theme to the theme library and clears `cwTHEME`.
-- @param themeTable [Map The theme table]
-- @param bNoSwitch=nil [Boolean Whether to keep the current theme instead of switching to this one]
-- @see cw.theme:Register
function cw.theme:Finish(themeTable, bNoSwitch)
  cw.theme.stored[themeTable.name] = themeTable

  if !bNoSwitch then
    self:SetActive(themeTable)
  end

  cwTHEME = nil
end

--- Switches to a theme, unloading the active one first.
--
-- Loads the theme with its bases and copies its skin. Does nothing if a theme
-- name is given and no such theme exists.
-- @param theme [String Name of the theme, or the theme table itself]
-- @param firstLoad=nil [Boolean Whether this is the first theme loaded, which skips unloading; only
-- set by Catwork when it initializes]
function cw.theme:SetActive(theme, firstLoad)
  if istable(theme) then
    if self:Get() and !firstLoad then
      self:UnloadTheme()
    end

    self.active = theme

    if !bNoLoad then
      self:LoadTheme(theme)
    end
  else
    local themeTable = self:FindByID(theme)

    if themeTable then
      self:SetActive(themeTable, firstLoad)
    end
  end

  cw.theme:CopySkin()
end

--- Loads a theme and its base themes.
--
-- Calls the theme's `CreateFonts`, `Initialize` and `PostInitialize` methods,
-- registers its `module` as the `Theme` plugin module and merges its panel
-- changes into the VGUI factory. Does not unload the previous theme; use
-- `cw.theme:SetActive`.
-- @param themeTable [Map The theme table]
-- @param isBase=nil [Boolean Whether the theme is loaded as the base of another, which skips the
-- module and panel changes]
-- @warning [Internal] Called by `cw.theme:SetActive`.
function cw.theme:LoadTheme(themeTable, isBase)
  local baseName = themeTable.base

  if baseName then
    local base = self:FindByID(baseName)

    if base then
      self:LoadTheme(base, true)
    end
  end

  if themeTable.CreateFonts then
    themeTable:CreateFonts()
  end

  if themeTable.Initialize then
    themeTable:Initialize()
  end

  if themeTable.PostInitialize then
    themeTable:PostInitialize()
  end

  if !isBase then
    plugin.Add('Theme', themeTable.module)

    local factory = themeTable.factory

    if factory != {} then
      table.Merge(self.factory, factory)
    end
  end
end

--- Unloads a theme and its base themes.
--
-- Calls the theme's `OnUnloaded` method, removes the `Theme` plugin module and
-- restores the panel methods it changed from the backup factory. Does not load
-- another theme; use `cw.theme:SetActive`.
-- @param theme=nil [Map The theme table; the active theme when `nil`]
-- @param isBase=nil [Boolean Whether the theme is unloaded as the base of another]
-- @warning [Internal] Called by `cw.theme:SetActive`.
function cw.theme:UnloadTheme(theme, isBase)
  local themeTable = theme or self.active
  local baseName = themeTable.base

  if baseName then
    local base = self:FindByID(baseName)

    if base then
      self:UnloadTheme(base, true)
    end
  end

  if themeTable.OnUnloaded then
    themeTable:OnUnloaded()
  end

  if !isBase then
    plugin.Remove('Theme')

    local factory = themeTable.factory

    if factory != {} then
      for k, v in pairs(factory) do
        for k2, v2 in pairs(factory[k]) do
          if isfunction(v2) then
            self.factory[k][k2] = function(vguiObject, ...)
              self.backupFactory[k][k2](vguiObject, ...)
            end
          else
            self.factory[k][k2] = self.backupFactory[k][k2]
          end
        end
      end
    end

    self.active = nil
  end
end

--- Calls a hook of the active theme.
--
-- Theme hooks such as `PreMainMenuPaint` live in the theme's `hooks` table. The
-- `Pre` hooks can return `true` to replace the default drawing or behaviour.
-- @param hookName [String Name of the hook]
-- @param ... [Any Arguments passed to the hook]
-- @return [Any Whatever the hook returns, or `nil` if the active theme does not define it]
function cw.theme:Call(hookName, ...)
  if self.active and self.active.hooks[hookName] then
    return self.active.hooks[hookName](self.active.hooks, ...)
  end
end

local MARKUP_OBJECT = { __index = MARKUP_OBJECT, text = '' }

--- Adds a line of colored text to the markup object.
--
-- The text is parsed with `config.Parse` first, so config placeholders work.
-- @param text [String Text to add]
-- @param color=nil [Color Color of the text]
-- @param scale=nil [Number Text scale]
-- @param noNewLine=nil [Boolean Whether to append to the last line instead of starting a new one]
function MARKUP_OBJECT:Add(text, color, scale, noNewLine)
  if self.text != '' and !noNewLine then
    self.text = self.text..'\n'
  end

  self.text = self.text..cw.core:MarkupTextWithColor(
    config.Parse(text), color, scale
  )
end

--- Adds a title line to the markup object.
-- @param title [String Text of the title]
-- @param color=nil [Color Color of the title; the `information` option color when `nil`]
-- @param scale=1.2 [Number Text scale]
function MARKUP_OBJECT:Title(title, color, scale)
  self:Add(title, color or cw.option:GetColor('information'), scale or 1.2)
end

--- Returns the markup text built so far.
-- @return [String The markup text]
function MARKUP_OBJECT:GetText()
  return self.text
end

--- Returns a new markup object for building tooltip and info text.
--
-- ```
-- local markup = cw.theme:GetMarkupObject()
-- markup:Title(itemTable.name)
-- markup:Add(itemTable.description)
-- local toolTip = markup:GetText()
-- ```
--
-- @return [Map The markup object, with `Add`, `Title` and `GetText` methods]
function cw.theme:GetMarkupObject()
  return cw.core:NewMetaTable(MARKUP_OBJECT)
end

--[[
  The following are available hooks for cw.theme library:

  Hooks with a [/] after them mean that returning true
  overrides the default action.

  PreCharacterMenuInit(panel) [/]
  PostCharacterMenuInit(panel)

  PreCharacterMenuThink(panel) [/]
  PostCharacterMenuThink(panel)

  PreCharacterMenuPaint(panel) [/]
  PostCharacterMenuPaint(panel)

  PreCharacterMenuOpenPanel(panel, vguiName, childData, Callback) [/]
  PostCharacterMenuOpenPanel(panel)

  PreMainMenuInit(panel) [/]
  PostMainMenuInit(panel)

  PreMainMenuRebuild(panel) [/]
  PostMainMenuRebuild(panel)

  PreMainMenuOpenPanel(panel, panelToOpen) [/]
  PostMainMenuOpenPanel(panel, panelToOpen)

  PreMainMenuPaint(panel) [/]
  PostMainMenuPaint(panel)

  PreMainMenuThink(panel) [/]
  PostMainMenuThink(panel)
--]]
