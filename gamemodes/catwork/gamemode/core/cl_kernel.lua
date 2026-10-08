--- Client-side kernel of the framework: the client half of `cw.core`, a few global helpers and the client `Player` meta
-- methods.
--
-- Derives the gamemode from Sandbox and defines the HUD and drawing helpers (`cw.core:DrawInfo`, `DrawBar`,
-- `DrawAdminESP`, `DrawDateTime`, hints, the cinematic intro, door text), text measuring and wrapping, the entity and
-- item menus (`HandleEntityMenu`, `HandleItemSpawnIconClick`), markup tooltips, background blurs and the client's
-- schema data files. It also adds `base64`, `surface.DrawScaledText` and `surface.DrawRotatedText`,
-- `Derma_NumRequest`, the `cwSay` and `cwLua` console commands, an `AddWorldTip` override and getters such as
-- `playerMeta:GetFaction` and `playerMeta:GetCharacterData`.

--[[
  Derive from Sandbox, because we want the spawn menu and such!
  We also want the base Sandbox entities and weapons.
--]]
DeriveGamemode('sandbox')

local CreateClientConVar = CreateClientConVar
local CloseDermaMenus = CloseDermaMenus
local ChangeTooltip = ChangeTooltip
local ScreenScale = ScreenScale
local FrameTime = FrameTime
local DermaMenu = DermaMenu
local ScrW = ScrW
local ScrH = ScrH
local surface = surface
local render = render
local draw = draw
local vgui = vgui
local cam = cam
local gui = gui

-- Matches one UTF-8 character; unlike `string.utf8sub` it never raises an error on malformed text.
local UTF8_CHARACTER = '[%z\1-\127\194-\244][\128-\191]*'

local scratchColor = Color(255, 255, 255, 255)

-- Returns a shared color for a draw call that reads it right away, so drawing every frame does not allocate one.
local function ScratchColor(r, g, b, a)
  scratchColor.r, scratchColor.g, scratchColor.b, scratchColor.a = r, g, b, a

  return scratchColor
end

do
  --[[
    This is a hack to display world tips correctly based on their owner.
  --]]

  local ClockworkAddWorldTip = cw.AddWorldTip or AddWorldTip
  cw.AddWorldTip = ClockworkAddWorldTip

  --- Shows a world tip only to the player who owns the entity, and only while they hold the toolgun.
  --
  -- Replaces the engine `AddWorldTip`, which is kept as `cw.AddWorldTip`. The entity must have a
  -- `GetPlayerName` method whose result matches the local player's name.
  -- @param entIndex [Number Index of the entity the tip belongs to]
  -- @param text [String Text of the tip]
  -- @param dieTime [Number Time the tip disappears]
  -- @param position [Vector Position of the tip]
  -- @param entity [Entity The entity the tip belongs to]
  function AddWorldTip(entIndex, text, dieTime, position, entity)
    local weapon = cw.client:GetActiveWeapon()

    if IsValid(weapon) and string.lower(weapon:GetClass()) == 'gmod_tool' then
      if IsValid(entity) and entity.GetPlayerName then
        if cw.client:Name() == entity:GetPlayerName() then
          ClockworkAddWorldTip(entIndex, text, dieTime, position, entity)
        end
      end
    end
  end
end

timer.Remove('HintSystem_OpeningMenu')
timer.Remove('HintSystem_Annoy1')
timer.Remove('HintSystem_Annoy2')

base64 = base64 or {}

--- Encodes data as base64.
--
-- A thin wrapper over `util.Base64Encode`; it is binary safe and the output is never line-wrapped.
-- @param data [String The data to encode; other values are converted with `tostring`]
-- @return [String The base64 text]
-- @see base64.decode
function base64.encode(data)
  return util.Base64Encode(tostring(data), true)
end

--- Decodes base64 text with `util.Base64Decode`.
-- @param data [String The base64 text]
-- @return [String The decoded data, or `nil` when the text is not valid base64]
-- @see base64.encode
function base64.decode(data)
  return util.Base64Decode(data)
end

do
  -- Kept on `cw` so that reloading this file does not wrap the wrapper again.
  local cwOldRunConsoleCommand = cw.RunConsoleCommand or RunConsoleCommand
  cw.RunConsoleCommand = cwOldRunConsoleCommand

  --- Runs a console command, ignoring calls without a command name.
  --
  -- Wraps the engine `RunConsoleCommand`, which is kept as `cw.RunConsoleCommand`, so that a `nil`
  -- command does nothing instead of raising an error.
  -- @param command [String The command name]
  -- @param ... [Any The command's arguments]
  function RunConsoleCommand(command, ...)
    if command == nil then
      return
    end

    cwOldRunConsoleCommand(command, ...)
  end
end

--- Draws text scaled around its top-left corner.
-- @param text [String The text]
-- @param font [String Font name]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param scale [Number Scale factor]
-- @param color [Color Text color]
-- @see surface.DrawScaled
function surface.DrawScaledText(text, font, x, y, scale, color)
  local matrix = Matrix()
  local pos = Vector(x, y)

  matrix:Translate(pos)
  matrix:Scale(Vector(1, 1, 1) * scale)
  matrix:Translate(-pos)

  cam.PushModelMatrix(matrix)
    surface.SetFont(font)
    surface.SetTextColor(color)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
  cam.PopModelMatrix()
end

--- Draws text rotated around its top-left corner.
-- @param text [String The text]
-- @param font [String Font name]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param angle [Number Rotation in degrees]
-- @param color [Color Text color]
-- @see surface.DrawRotated
function surface.DrawRotatedText(text, font, x, y, angle, color)
  local matrix = Matrix()
  local pos = Vector(x, y)

  matrix:Translate(pos)
  matrix:Rotate(Angle(0, angle, 0))
  matrix:Translate(-pos)

  cam.PushModelMatrix(matrix)
    surface.SetFont(font)
    surface.SetTextColor(color)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
  cam.PopModelMatrix()
end

-- Runs a drawing callback between a matrix push and pop; an error must not leave the matrix pushed.
local function RunDrawCallback(name, callback, ...)
  local bSuccess, message = pcall(callback, ...)

  if !bSuccess then
    ErrorNoHalt('['..name..'] '..tostring(message)..'\n')
  end
end

--- Runs a drawing callback with everything scaled around a point.
--
-- The callback is run in a `pcall`; its errors are printed rather than raised.
--
-- ```
-- surface.DrawScaled(x, y, 2, function(x, y, scale)
--   draw.SimpleText('Big', 'DermaDefault', x, y)
-- end)
-- ```
--
-- @param x [Number X position of the scaling origin]
-- @param y [Number Y position of the scaling origin]
-- @param scale [Number Scale factor]
-- @param callback [Function Called with `x`, `y` and `scale` while the scaling is active]
function surface.DrawScaled(x, y, scale, callback)
  local matrix = Matrix()
  local pos = Vector(x, y)

  matrix:Translate(pos)
  matrix:Scale(Vector(1, 1, 0) * scale)
  matrix:Rotate(Angle(0, 0, 0))
  matrix:Translate(-pos)

  cam.PushModelMatrix(matrix)

    if callback then
      RunDrawCallback('DrawScaled', callback, x, y, scale)
    end

  cam.PopModelMatrix()
end

--- Runs a drawing callback with everything rotated around a point.
--
-- The callback is run in a `pcall`; its errors are printed rather than raised.
-- @param x [Number X position of the rotation origin]
-- @param y [Number Y position of the rotation origin]
-- @param angle [Number Rotation in degrees]
-- @param callback [Function Called with `x`, `y` and `angle` while the rotation is active]
function surface.DrawRotated(x, y, angle, callback)
  local matrix = Matrix()
  local pos = Vector(x, y)

  matrix:Translate(pos)
  matrix:Rotate(Angle(0, angle, 0))
  matrix:Translate(-pos)

  cam.PushModelMatrix(matrix)

    if callback then
      RunDrawCallback('DrawRotated', callback, x, y, angle)
    end

  cam.PopModelMatrix()
end

concommand.Add('cwSay', function(player, command, arguments)
  return cable.send('PlayerSay', table.concat(arguments, ' '))
end)

-- Developer tool: runs Lua typed into the local console. Superadmins only; the 'RunCommand' net hook
-- refuses to relay it, so its arguments never come from network data.
concommand.Add('cwLua', function(player, command, arguments)
  if !IsValid(player) then return end

  if player:IsSuperAdmin() then
    RunString(table.concat(arguments, ' '), 'cwLua')
    return
  end

  print(L('#Commands_cwLua_accessDenied:'..player:Name()..';'))
end)

cw.BackgroundBlurs = cw.BackgroundBlurs or {}
cw.RecognisedNames = cw.RecognisedNames or {}
cw.NetworkProxies = cw.NetworkProxies or {}
cw.AccessoryData = cw.AccessoryData or {}
cw.InfoMenuOpen = cw.InfoMenuOpen or false
cw.ColorModify = cw.ColorModify or {}
cw.ClothesData = cw.ClothesData or {}
cw.Cinematics = cw.Cinematics or {}

cw.core.CenterHints = cw.core.CenterHints or {}
cw.core.ESPInfo = cw.core.ESPInfo or {}
cw.core.Hints = cw.core.Hints or {}

--- Registers a callback that runs when a networked variable of an entity changes.
--
-- The value is polled by the kernel; pass `game.GetWorld()` to watch a global networked variable.
-- Replaces any proxy already registered for the same entity and name.
--
-- ```
-- cw.core:RegisterNetworkProxy(cw.client, 'Cash', function(entity, name, oldValue, newValue)
--   print('Cash changed to '..newValue)
-- end)
-- ```
--
-- @param entity [Entity The entity to watch]
-- @param name [String Name of the networked variable]
-- @param Callback [Function Called with the entity, name, old value and new value]
function cw.core:RegisterNetworkProxy(entity, name, Callback)
  if !cw.NetworkProxies[entity] then
    cw.NetworkProxies[entity] = {}
  end

  cw.NetworkProxies[entity][name] = {
    Callback = Callback,
    oldValue = nil
  }
end

--- Returns whether the info menu is open.
-- @return [Boolean Whether the info menu is open]
function cw.core:IsInfoMenuOpen()
  return cw.InfoMenuOpen
end

--- Creates a client ConVar and watches it for changes.
--
-- Every change runs the `ClockworkConVarChanged` hook and then the optional callback.
-- @param name [String Name of the ConVar]
-- @param value [String Default value]
-- @param save [Boolean Save the value between sessions]
-- @param userData [Boolean Send the value to the server]
-- @param Callback=nil [Function Called with the ConVar name, old value and new value]
-- @return [ConVar The ConVar]
function cw.core:CreateClientConVar(name, value, save, userData, Callback)
  local conVar = CreateClientConVar(name, value, save, userData)

  cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
    hook.Run('ClockworkConVarChanged', conVar, previousValue, newValue)

    if Callback then
      Callback(conVar, previousValue, newValue)
    end
  end)

  return conVar
end

do
  local aspect = ScrW() / ScrH()

  --- Returns whether the screen has the given aspect ratio.
  --
  -- The aspect ratio is measured once when the file loads.
  -- @param w [Number Width part of the ratio, such as `16`]
  -- @param h [Number Height part of the ratio, such as `9`]
  -- @return [Boolean Whether the ratio matches exactly]
  function ScreenIsRatio(w, h)
    return (aspect == w / h)
  end
end

--- Scales a font size to the screen height, tripling it first.
--
-- The reference height is 1200 on 16:10 screens, 1024 on 4:3 screens and 1080 otherwise.
-- @param size [Number Font size]
-- @return [Number The scaled size]
-- @see cw.core:HDFontScreenScale
function cw.core:FontScreenScale(size)
  size = size * 3

  if ScreenIsRatio(16, 10) then
    return size * (ScrH() / 1200)
  elseif ScreenIsRatio(4, 3) then
    return size * (ScrH() / 1024)
  end

  return size * (ScrH() / 1080)
end

--- Scales a font size to the screen height without tripling it.
--
-- Uses the same reference heights as `cw.core:FontScreenScale`.
-- @param size [Number Font size]
-- @return [Number The scaled size]
function cw.core:HDFontScreenScale(size)
  if ScreenIsRatio(16, 10) then
    return size * (ScrH() / 1200)
  elseif ScreenIsRatio(4, 3) then
    return size * (ScrH() / 1024)
  end

  return size * (ScrH() / 1080)
end

--- Returns a material, creating and caching it on first use.
-- @param materialPath [String Material path; any other value is returned unchanged]
-- @param pngParameters=nil [String Parameters for `Material`, such as `'smooth'`]
-- @return [IMaterial The material]
function cw.core:GetMaterial(materialPath, pngParameters)
  if !isstring(materialPath) then
    return materialPath
  end

  local cachedMaterials = self.CachedMaterial

  if !cachedMaterials then
    cachedMaterials = {}
    self.CachedMaterial = cachedMaterials
  end

  local material = cachedMaterials[materialPath]

  if !material then
    material = Material(materialPath, pngParameters)
    cachedMaterials[materialPath] = material
  end

  return material
end

--- Returns the font size used for 3D2D text.
-- @return [Number Always `128`]
function cw.core:GetFontSize3D()
  return 128
end

--- Returns the size of a text, measured character by character.
--
-- Characters that measure zero width count as wide as `U`.
-- @param font [String Font name]
-- @param text [String The text]
-- @return [Number Width in pixels, Number Height in pixels]
-- @see cw.core:GetCachedTextSize
function cw.core:GetTextSize(font, text)
  local defaultWidth, defaultHeight = self:GetCachedTextSize(font, 'U')
  local height = defaultHeight
  local width = 0

  for character in string.gmatch(text, UTF8_CHARACTER) do
    local textWidth, textHeight = self:GetCachedTextSize(font, character)

    if textWidth == 0 then
      textWidth = defaultWidth
    end

    if textHeight > height then
      height = textHeight
    end

    width = width + textWidth
  end

  return width, height
end

--- Returns an alpha value that fades from 255 to 0 with distance.
-- @param maximum [Number Distance at which the alpha reaches 0]
-- @param start [Vector Start position; a player uses its shoot position, an entity its position]
-- @param finish [Vector End position; a player uses its shoot position, an entity its position]
-- @return [Number The alpha, 0 to 255]
function cw.core:CalculateAlphaFromDistance(maximum, start, finish)
  if type(start) == 'Player' then
    start = start:GetShootPos()
  elseif type(start) == 'Entity' then
    start = start:GetPos()
  end

  if type(finish) == 'Player' then
    finish = finish:GetShootPos()
  elseif type(finish) == 'Entity' then
    finish = finish:GetPos()
  end

  return math.Clamp(255 - ((255 / maximum) * (start:Distance(finish))), 0, 255)
end

--- Wraps text into lines that fit a width.
--
-- Lines are appended to `baseTable`. Breaks happen at any character, not only at spaces.
-- Does nothing when the width is not positive or the text is empty.
-- @param text [String The text to wrap]
-- @param font [String Font name]
-- @param maximumWidth [Number Maximum line width in pixels]
-- @param baseTable [List<String> Table the lines are added to]
function cw.core:WrapText(text, font, maximumWidth, baseTable)
  if maximumWidth <= 0 or !text or text == '' then
    return
  end

  local lines = self:GetWrappedLines(text, font, maximumWidth)

  for i = 1, #lines do
    baseTable[#baseTable + 1] = lines[i]
  end
end

do
  local MAX_CACHED_TEXTS = 256
  local wrapCache = {}
  local wrapCacheCount = 0

  local function BuildWrappedLines(text, font, maximumWidth)
    local defaultWidth = cw.core:GetCachedTextSize(font, 'U')
    local remainingWidth = cw.core:GetTextSize(font, text)
    local lines = {}
    local lineStart = 1
    local lineWidth = 0

    for position, character in string.gmatch(text, '()('..UTF8_CHARACTER..')') do
      local characterWidth = cw.core:GetCachedTextSize(font, character)

      if characterWidth == 0 then
        characterWidth = defaultWidth
      end

      -- A line always takes at least one character, or a width narrower than a character would never finish.
      if remainingWidth > maximumWidth and lineWidth + characterWidth >= maximumWidth and position > lineStart then
        lines[#lines + 1] = string.sub(text, lineStart, position - 1)
        remainingWidth = remainingWidth - lineWidth
        lineStart = position
        lineWidth = 0
      end

      lineWidth = lineWidth + characterWidth
    end

    lines[#lines + 1] = string.sub(text, lineStart)

    return lines
  end

  --- Returns a text wrapped into lines that fit a width, as `cw.core:WrapText` does.
  --
  -- The lines of the most recently wrapped texts are cached, so wrapping the same text every frame is cheap.
  -- @param text [String The text to wrap]
  -- @param font [String Font name]
  -- @param maximumWidth [Number Maximum line width in pixels]
  -- @return [List<String> The lines; the table is shared, do not change it]
  -- @see cw.core:WrapText
  function cw.core:GetWrappedLines(text, font, maximumWidth)
    local cached = wrapCache[text]

    if cached and cached.font == font and cached.maximumWidth == maximumWidth then
      return cached.lines
    end

    if !cached then
      if wrapCacheCount >= MAX_CACHED_TEXTS then
        wrapCache = {}
        wrapCacheCount = 0
      end

      wrapCacheCount = wrapCacheCount + 1
    end

    cached = {
      lines = BuildWrappedLines(text, font, maximumWidth),
      maximumWidth = maximumWidth,
      font = font
    }

    wrapCache[text] = cached

    return cached.lines
  end
end

--- Opens the context menu for an entity.
--
-- Options come from the `GetEntityMenuOptions` hook and, for `cw_item` entities, from the item's
-- `GetOptions`. Item options are handled by the item's `HandleOptions` and sent to the server
-- with the `MenuOption` Cable message; other options are sent with `cw.entity:ForceMenuOption`.
-- Option tables may set `isOrdered` (show first) and `toolTip`. Does nothing when there are no
-- options.
-- @param entity [Entity The entity the menu is for]
-- @return [Panel The menu, or `nil` when no menu was opened]
function cw.core:HandleEntityMenu(entity)
  local options = {}
  local itemTable = nil

  hook.Run('GetEntityMenuOptions', entity, options)

  if entity:GetClass() == 'cw_item' then
    itemTable = entity:GetItemTable()

    if itemTable and itemTable:IsInstance() and itemTable.GetOptions then
      local itemOptions = itemTable:GetOptions(entity)

      for k, v in pairs(itemOptions) do
        options[k] = {
          title = k,
          name = v,
          isOptionTable = true,
          isArgTable = true
        }
      end
    end
  end

  if table.Count(options) == 0 then return end

  if self:GetEntityMenuType() then
    local menuPanel = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
      if itemTable and type(arguments) == 'table' and arguments.isOptionTable then
        menuPanel:AddOption(arguments.title, function()
          if itemTable.HandleOptions then
            local transmit, data = itemTable:HandleOptions(arguments.name, nil, nil, entity)

            if transmit then
              cable.send('MenuOption', {
                option = arguments.name,
                data = data,
                item = itemTable.itemID,
                entity = entity
              })
            end
          end
        end)
      else
        menuPanel:AddOption(option, function()
          if type(arguments) == 'table' and arguments.isArgTable then
            if arguments.Callback then
              arguments.Callback(function(arguments)
                cw.entity:ForceMenuOption(
                  entity, option, arguments
                )
              end)
            else
              cw.entity:ForceMenuOption(
                entity, option, arguments.arguments
              )
            end
          else
            cw.entity:ForceMenuOption(
              entity, option, arguments
            )
          end

          timer.Simple(FrameTime(), function()
            self:RemoveActiveToolTip()
          end)
        end)
      end

      menuPanel.Items = menuPanel:GetChildren()
      local panel = menuPanel.Items[#menuPanel.Items]

      if IsValid(panel) then
        if type(arguments) == 'table' then
          if arguments.isOrdered then
            menuPanel.Items[#menuPanel.Items] = nil
            table.insert(menuPanel.Items, 1, panel)
          end

          if arguments.toolTip then
            self:CreateMarkupToolTip(panel)
            panel:SetMarkupToolTip(arguments.toolTip)
          end
        end
      end
    end)

    self:RegisterBackgroundBlur(menuPanel, SysTime())
    self:SetTitledMenu(menuPanel, '#EntityMenu_Title')
    menuPanel.entity = entity
    cw.client.openedEnt = entity

    return menuPanel
  end
end

--- Draws a textured rectangle.
--
-- Does nothing when no material is given.
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param w [Number Width]
-- @param h [Number Height]
-- @param material [IMaterial The material]
-- @param color=Color(255, 255, 255) [Color Draw color]
function draw.TexturedRect(x, y, w, h, material, color)
  if !material then return end

  if IsColor(color) then
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
  else
    surface.SetDrawColor(255, 255, 255, 255)
  end

  surface.SetMaterial(material)
  surface.DrawTexturedRect(x, y, w, h)
end

--- Returns whether entity menus are shown as a Derma menu.
--
-- `cw.core:HandleEntityMenu` only opens a menu when this is `true`.
-- @return [Boolean Always `true`]
function cw.core:GetEntityMenuType()
  return true
end

--- Returns the gradient texture.
-- @return [IMaterial The material stored in `cw.GradientTexture`, made from the `gradient` option]
function cw.core:GetGradientTexture()
  return cw.GradientTexture
end

--- Fills a Derma menu from a table of options.
--
-- Keys are option names, sorted alphabetically. A function value becomes an option that runs
-- it, a table becomes a submenu (unless it has `isArgTable` set), and anything else is passed to
-- the callback, which adds the option itself. When `menuPanel` is `nil` a new menu is created and
-- opened, or removed if it has no options.
--
-- ```
-- cw.core:AddMenuFromData(nil, {
--   ['Say hello'] = function() RunConsoleCommand('say', 'Hello') end,
--   ['More'] = { ['Wave'] = function() RunConsoleCommand('act', 'wave') end }
-- })
-- ```
--
-- @param menuPanel=nil [Panel Menu to add to; `nil` creates one]
-- @param data [Map Options keyed by name]
-- @param Callback=nil [Function Called with the menu, name and value for other values]
-- @param iMinimumWidth=nil [Number Minimum width of a new menu]
-- @param bManualOpen=false [Boolean Do not open a new menu automatically]
-- @return [Panel The new menu, or `nil` when an existing menu was passed]
function cw.core:AddMenuFromData(menuPanel, data, Callback, iMinimumWidth, bManualOpen)
  local bCreated = false
  local options = {}

  if !menuPanel then
    bCreated = true menuPanel = DermaMenu()

    if iMinimumWidth then
      menuPanel:SetMinimumWidth(iMinimumWidth)
    end
  end

  for k, v in pairs(data) do
    options[#options + 1] = { k, v }
  end

  table.sort(options, function(a, b)
    return a[1] < b[1]
  end)

  for k, v in pairs(options) do
    if type(v[2]) == 'table' and !v[2].isArgTable then
      if table.Count(v[2]) > 0 then
        self:AddMenuFromData(menuPanel:AddSubMenu(v[1]), v[2], Callback)
      end
    elseif type(v[2]) == 'function' then
      menuPanel:AddOption(v[1], v[2])
    elseif Callback then
      Callback(menuPanel, v[1], v[2])
    end
  end

  if !bCreated then return end

  if !bManualOpen then
    if #options > 0 then
      menuPanel:Open()
    else
      menuPanel:Remove()
    end
  end

  return menuPanel
end

--- Widens a width so that a text fits in it.
--
-- `&` characters are measured as `U`.
-- @param font [String Font name]
-- @param text [String The text]
-- @param width [Number Current width]
-- @param addition=0 [Number Padding added when the width has to grow]
-- @param extra=0 [Number Extra width added to the text measurement]
-- @return [Number The text width plus `addition` if it is wider, else `width`]
function cw.core:AdjustMaximumWidth(font, text, width, addition, extra)
  local textString = tostring(text)

  if string.find(textString, '&', 1, true) then
    textString = string.gsub(textString, '&', 'U')
  end

  local textWidth = self:GetCachedTextSize(font, textString) + (extra or 0)

  if textWidth > width then
    width = textWidth + (addition or 0)
  end

  return width
end

-- Adds a hint to the top or center list; `x` and `y` are where it slides in from.
local function AddHint(hints, text, delay, color, bNoSound, showDuplicated, x, y)
  if text == nil then return end

  text = tostring(text)

  if isstring(color) then
    color = cw.option:GetColor(color)
  end

  if !istable(color) then
    color = cw.option:GetColor('white')
  end

  if !showDuplicated then
    for k, v in ipairs(hints) do
      if v.text == text then
        return
      end
    end
  end

  if #hints >= 10 then
    table.remove(hints, 10)
  end

  if isstring(bNoSound) then
    surface.PlaySound(bNoSound)
  elseif bNoSound == nil then
    surface.PlaySound('hl1/fvox/blip.wav')
  end

  hints[#hints + 1] = {
    startTime = SysTime(),
    velocityX = -5,
    velocityY = 0,
    targetAlpha = 255,
    alphaSpeed = 64,
    color = color,
    delay = tonumber(delay) or 5,
    alpha = 0,
    text = text,
    y = y,
    x = x
  }
end

--- Shows a hint in the middle of the screen.
--
-- At most 10 center hints are shown; identical hints already on screen are skipped unless
-- `showDuplicated` is set. Does nothing when `text` is `nil`.
-- @param text [String The hint text]
-- @param delay=5 [Number Seconds the hint stays before fading]
-- @param color=nil [Color Text color, or the name of a color option; defaults to white]
-- @param bNoSound=nil [String Sound to play; `nil` plays a blip and `false` plays nothing]
-- @param showDuplicated=false [Boolean Show the hint even when the same text is on screen]
-- @see cw.core:AddTopHint
function cw.core:AddCenterHint(text, delay, color, bNoSound, showDuplicated)
  AddHint(self.CenterHints, text, delay, color, bNoSound, showDuplicated, ScrW() * 0.5, ScrH() * 0.6)
end

--- Shows a hint in the top right corner of the screen.
--
-- At most 10 top hints are shown; identical hints already on screen are skipped unless
-- `showDuplicated` is set. Does nothing when `text` is `nil`.
-- @param text [String The hint text]
-- @param delay=5 [Number Seconds the hint stays before fading]
-- @param color=nil [Color Text color, or the name of a color option; defaults to white]
-- @param bNoSound=nil [String Sound to play; `nil` plays a blip and `false` plays nothing]
-- @param showDuplicated=false [Boolean Show the hint even when the same text is on screen]
-- @see cw.core:AddCenterHint
function cw.core:AddTopHint(text, delay, color, bNoSound, showDuplicated)
  AddHint(self.Hints, text, delay, color, bNoSound, showDuplicated, ScrW(), ScrH() * 0.2)
end

-- Moves a hint towards its place in its list and returns whether it has expired.
local function UpdateHint(index, hintInfo, bCenter)
  local width, height = cw.core:GetCachedTextSize(cw.option:GetFont('hints_text'), hintInfo.text)
  local frameTime = FrameTime()
  local alpha = 255
  local idealX, idealY

  if bCenter then
    idealY = (ScrH() * 0.4) + (height * (index - 1))
    idealX = (ScrW() * 0.5) - (width * 0.5)
  else
    idealY = 24 + (height * (index - 1))
    idealX = ScrW() - width - 48
  end

  local timeLeft = (hintInfo.startTime - (SysTime() - hintInfo.delay) + 2)

  if timeLeft < 0.7 then
    idealX = idealX - 50
    alpha = 0
  end

  if timeLeft < 0.2 then
    idealX = idealX + width * 2
  end

  local fSpeed = frameTime * 15
  local y = hintInfo.y + hintInfo.velocityY * fSpeed
  local x = hintInfo.x + hintInfo.velocityX * fSpeed
  local distanceY = idealY - y
  local distanceX = idealX - x
  local distanceA = (alpha - hintInfo.alpha)

  hintInfo.velocityY = hintInfo.velocityY + distanceY * fSpeed
  hintInfo.velocityX = hintInfo.velocityX + distanceX * fSpeed

  if math.abs(distanceY) < 2 and math.abs(hintInfo.velocityY) < 0.1 then
    hintInfo.velocityY = 0
  end

  if math.abs(distanceX) < 2 and math.abs(hintInfo.velocityX) < 0.1 then
    hintInfo.velocityX = 0
  end

  hintInfo.velocityX = hintInfo.velocityX * (0.95 - frameTime * 8)
  hintInfo.velocityY = hintInfo.velocityY * (0.95 - frameTime * 8)
  hintInfo.alpha = hintInfo.alpha + distanceA * fSpeed * 0.1
  hintInfo.x = x
  hintInfo.y = y

  return (timeLeft < 0.1)
end

local function UpdateHints(hints, bCenter)
  -- Backwards, so that removing a hint does not skip the one after it.
  for i = #hints, 1, -1 do
    if UpdateHint(i, hints[i], bCenter) then
      table.remove(hints, i)
    end
  end
end

--- Animates the top and center hints and removes the ones that have expired.
-- @warning [Internal] Called every frame by the kernel.
function cw.core:CalculateHints()
  UpdateHints(self.Hints, false)
  UpdateHints(self.CenterHints, true)
end

-- A utility function to draw text within an info block.
local function Util_DrawText(info, text, color, bCentered, sFont)
  local realWidth = 0

  if sFont then cw.core:OverrideMainFont(sFont) end

  if !bCentered then
    info.y, realWidth = cw.core:DrawInfo(
      text, info.x - (info.width / 2), info.y, color, nil, true
    )
  else
    info.y, realWidth = cw.core:DrawInfo(
      text, info.x, info.y, color
    )
  end

  if realWidth > info.width then
    info.width = realWidth + 16
  end

  if sFont then
    cw.core:OverrideMainFont(false)
  end
end

do
  local texInfo = {
    shouldDisplay = true,
    textures = {},
    names = {}
  }

  local backgroundColor = Color(255, 255, 255)
  local mainTextFont = Color(255, 255, 255)
  local colorWhite = Color(255, 255, 255)
  local colorInfo = Color(255, 255, 255)

  --- Caches the limb textures and names and the colors and font used by the HUD.
  -- @warning [Internal] Called by the kernel once the options are available.
  function cw.core:CacheLimbs()
    texInfo = {
      shouldDisplay = true,
      textures = {
        [HITGROUP_RIGHTARM] = cw.limb:GetTexture(HITGROUP_RIGHTARM),
        [HITGROUP_RIGHTLEG] = cw.limb:GetTexture(HITGROUP_RIGHTLEG),
        [HITGROUP_LEFTARM] = cw.limb:GetTexture(HITGROUP_LEFTARM),
        [HITGROUP_LEFTLEG] = cw.limb:GetTexture(HITGROUP_LEFTLEG),
        [HITGROUP_STOMACH] = cw.limb:GetTexture(HITGROUP_STOMACH),
        [HITGROUP_CHEST] = cw.limb:GetTexture(HITGROUP_CHEST),
        [HITGROUP_HEAD] = cw.limb:GetTexture(HITGROUP_HEAD),
        ['body'] = cw.limb:GetTexture('body')
      },
      names = {
        [HITGROUP_RIGHTARM] = cw.limb:GetName(HITGROUP_RIGHTARM),
        [HITGROUP_RIGHTLEG] = cw.limb:GetName(HITGROUP_RIGHTLEG),
        [HITGROUP_LEFTARM] = cw.limb:GetName(HITGROUP_LEFTARM),
        [HITGROUP_LEFTLEG] = cw.limb:GetName(HITGROUP_LEFTLEG),
        [HITGROUP_STOMACH] = cw.limb:GetName(HITGROUP_STOMACH),
        [HITGROUP_CHEST] = cw.limb:GetName(HITGROUP_CHEST),
        [HITGROUP_HEAD] = cw.limb:GetName(HITGROUP_HEAD)
      }
    }

    backgroundColor = cw.option:GetColor('background')
    mainTextFont = cw.option:GetFont('main_text')
    colorWhite = cw.option:GetColor('white')
    colorInfo = cw.option:GetColor('information')
  end

  --- Draws the tab menu's date and time box, bars, player info and limb damage diagram.
  --
  -- While the info menu is open it also draws and positions the quick menu panel. Runs the
  -- `PlayerCanSeeDateTime`, `PaintInfoMenuExtras`, `PostDrawDateTimeBox` and
  -- `PlayerCanSeeLimbDamage` hooks and stores the box layout in `cw.LastDateTimeInfo`.
  -- @warning [Internal] Called by the kernel while the tab menu is drawn.
  function cw.core:DrawDateTime()
    local scrW = ScrW()
    local scrH = ScrH()
    local info = {
      DrawText = Util_DrawText,
      width = math.min(scrW * 0.35, 500),
      x = scrW / 2,
      y = scrH * 0.2
    }

    info.originalX = info.x
    info.originalY = info.y

    if cw.LastDateTimeInfo and cw.LastDateTimeInfo.y > info.y then
      local height = (cw.LastDateTimeInfo.y - info.y) + 8
      local width = cw.LastDateTimeInfo.width + 16
      local x = cw.LastDateTimeInfo.x - (cw.LastDateTimeInfo.width / 2) - 8
      local y = cw.LastDateTimeInfo.y - height - 8

      self:OverrideMainFont(cw.option:GetFont('menu_text_tiny'))
      self:DrawInfo('#InfoMenu_Title', x, y + 4, colorInfo, nil, true, function(x, y, width, height)
        return x, y - height
      end)

      cdraw.DrawBox(x, y + 8, width, height, backgroundColor)
      y = y + height + 16

      if self:CanCreateInfoMenuPanel() and self:IsInfoMenuOpen() then
        local menuPanelX = x
        local menuPanelY = y

        self:DrawInfo('#InfoMenu_SelectOption', x, y, colorInfo, nil, true, function(x, y, width, height)
          menuPanelY = menuPanelY + height + 8

          return x, y
        end)

        self:CreateInfoMenuPanel(menuPanelX, menuPanelY, width)

        local menuWide, menuTall = cw.InfoMenuPanel:GetWide(), cw.InfoMenuPanel:GetTall()

        cdraw.DrawBox(cw.InfoMenuPanel.x - 4, cw.InfoMenuPanel.y - 4, menuWide + 8, menuTall + 8, backgroundColor)

        --[[ Override the menu's width to fit nicely. --]]
        cw.InfoMenuPanel:SetSize(width, menuTall)
        cw.InfoMenuPanel:SetMinimumWidth(width)

        if !cw.InfoMenuPanel.VisibilitySet then
          cw.InfoMenuPanel.VisibilitySet = true

          timer.Simple(FrameTime() * 2, function()
            if IsValid(cw.InfoMenuPanel) then
              cw.InfoMenuPanel:SetVisible(true)
            end
          end)
        end

        local infoData = {
          x = menuPanelX,
          y = menuPanelY + menuTall + 16,
          width = width,
          height = height,
          Adjust = function(itable, n)
            itable.y = itable.y + n
            itable.height = itable.height + n
          end
        }

        hook.Run('PaintInfoMenuExtras', infoData)

        height = infoData.height
      end

      self:OverrideMainFont(false)
      cw.LastDateTimeInfo.height = height
    end

    if hook.Run('PlayerCanSeeDateTime') then
      local dateTimeFont = cw.option:GetFont('date_time_text')
      local dateString = os.date('%x')
      local timeString = cw.time:GetString()

      if dateString and timeString then
        local weekDay = tonumber(os.date('%w'))

        -- os.date counts the days from Sunday as 0, the day names start at Monday.
        if weekDay == 0 then
          weekDay = 7
        end

        local dayName = L(cw.option:GetKey('default_days')[weekDay])
        local text = string.upper(dateString..'. '..dayName..', '..timeString..'.')

        self:OverrideMainFont(dateTimeFont)
          info.y = self:DrawInfo(text, info.x, info.y, colorWhite, 255)
        self:OverrideMainFont(false)
      end
    end

    self:DrawBars(info, 'tab')
      cw.PlayerInfoBox = self:DrawPlayerInfo(info)
      hook.Run('PostDrawDateTimeBox', info)
    cw.LastDateTimeInfo = info

    if !hook.Run('PlayerCanSeeLimbDamage') then
      return
    end

    local tipHeight = 0
    local tipWidth = 0
    local limbInfo = {}
    local height = 240
    local width = 120
    local x = info.x + (info.width / 2) + 32
    local y = info.originalY + 8

    if texInfo.shouldDisplay then
      surface.SetDrawColor(255, 255, 255, 150)
      surface.SetMaterial(texInfo.textures['body'])
      surface.DrawTexturedRect(x, y, width, height)

      for k, v in pairs(cw.limb.hitGroups) do
        local limbHealth = cw.limb:GetHealth(k)
        local limbColor = cw.limb:GetColor(limbHealth)

        surface.SetDrawColor(limbColor.r, limbColor.g, limbColor.b, 150)
        surface.SetMaterial(texInfo.textures[k])
        surface.DrawTexturedRect(x, y, width, height)

        local limbText = L(texInfo.names[k])..': '..limbHealth..'%'
        local textWidth, textHeight = self:GetCachedTextSize(mainTextFont, limbText)

        tipHeight = tipHeight + textHeight + 4

        if textWidth > tipWidth then
          tipWidth = textWidth
        end

        limbInfo[#limbInfo + 1] = {
          textHeight = textHeight,
          color = limbColor,
          text = limbText
        }
      end

      local mouseX = gui.MouseX()
      local mouseY = gui.MouseY()

      if mouseX >= x and mouseX <= x + width
      and mouseY >= y and mouseY <= y + height then
        local tipX = mouseX + 16
        local tipY = mouseY + 16

        self:DrawSimpleGradientBox(
          2, tipX - 8, tipY - 8, tipWidth + 16, tipHeight + 12, backgroundColor
        )

        for k, v in pairs(limbInfo) do
          self:DrawInfo(v.text, tipX, tipY, v.color, 255, true)

          if k < #limbInfo then
            tipY = tipY + v.textHeight + 4
          else
            tipY = tipY + v.textHeight
          end
        end
      end
    end
  end
end

--- Draws the top and center hints.
--
-- Each kind is only drawn when `PlayerCanSeeHints` or `PlayerCanSeeCenterHints` returns `true`.
-- @warning [Internal] Called by the kernel while the HUD is drawn.
function cw.core:DrawHints()
  local bDrawTop = #self.Hints > 0 and hook.Run('PlayerCanSeeHints')
  local bDrawCenter = #self.CenterHints > 0 and hook.Run('PlayerCanSeeCenterHints')

  if !bDrawTop and !bDrawCenter then return end

  self:OverrideMainFont(cw.option:GetFont('hints_text'))

  if bDrawTop then
    for k, v in ipairs(self.Hints) do
      self:DrawInfo(v.text, v.x, v.y, v.color, v.alpha, true)
    end
  end

  if bDrawCenter then
    for k, v in ipairs(self.CenterHints) do
      self:DrawInfo(v.text, v.x, v.y, v.color, v.alpha, true)
    end
  end

  self:OverrideMainFont(false)
end

--- Draws every registered top bar from `cw.bars.stored` below a position.
--
-- Only draws when the `PlayerCanSeeBars` hook returns `true`. Moves `info.y` below the last bar.
-- @param info [Map Layout table with `x`, `y` and `width` fields; `y` is updated]
-- @param class [String Where the bars are drawn; `'tab'` centers them on `info.x`]
function cw.core:DrawBars(info, class)
  if hook.Run('PlayerCanSeeBars', class) then
    local barTextFont = cw.option:GetFont('bar_text')

    cw.bars.width = info.width
    cw.bars.height = cw.bars.height or 16
    cw.bars.padding = cw.bars.padding or 20
    cw.bars.y = info.y

    if class == 'tab' then
      cw.bars.x = info.x - (info.width / 2)
    else
      cw.bars.x = info.x
    end

    cw.option:SetFont('bar_text', cw.option:GetFont('auto_bar_text'))

      for k, v in ipairs(cw.bars.stored) do
        -- DrawBar writes the layout into the table it is given, so the stored bar is not passed directly.
        local barInfo = {}

        for key, value in pairs(v) do
          barInfo[key] = value
        end

        cw.bars.y = self:DrawBar(
          cw.bars.x,
          cw.bars.y,
          cw.bars.width,
          cw.bars.height,
          v.color,
          v.text,
          v.value,
          v.maximum,
          v.flash,
          barInfo
        ) + (cw.bars.padding + 2)
      end

    cw.option:SetFont('bar_text', barTextFont)

    info.y = cw.bars.y
  end
end

--- Returns the table admin ESP entries are collected in.
-- @return [List The ESP info table]
function cw.core:GetESPInfo()
  return self.ESPInfo
end

do
  local color_red = Color(255, 0, 0)
  local color_blue = Color(0, 0, 255)
  local color_grey = Color(100, 100, 100)
  local color_white = Color(255, 255, 255)
  local color_salesmen = Color(255, 150, 0)
  local color_items = Color(0, 255, 100)
  local color_props = Color(0, 150, 255)
  local color_lightred = Color(255, 100, 100)
  local color_lightblue = Color(200, 200, 255)
  local vector_salesman_offset = Vector(0, 0, 80)
  local espEntities = {}
  local espOptions = nil
  local nextESPScan = 0

  -- Lists the entities the entity ESP labels. Going through every entity is slow, so the list is only rebuilt
  -- every `cwESPTime` seconds, or when the ESP options change.
  local function GetESPEntities(drawSalesmen, drawItems, drawProps)
    local options = (drawSalesmen and 1 or 0) + (drawItems and 2 or 0) + (drawProps and 4 or 0)
    local realTime = RealTime()

    if options == espOptions and realTime < nextESPScan then
      return espEntities
    end

    espEntities = {}
    espOptions = options
    nextESPScan = realTime + CW_CONVAR_ESPTIME:GetFloat()

    for k, v in ipairs(ents.GetAll()) do
      if !IsValid(v) then continue end

      local entClass = v:GetClass()

      if (drawItems and entClass == 'cw_item') or (drawSalesmen and entClass == 'cw_salesman')
      or (drawProps and v:GetPersistent()) then
        espEntities[#espEntities + 1] = v
      end
    end

    return espEntities
  end

  --- Draws the admin ESP when the `CW_CONVAR_ADMINESP` ConVar is on.
  --
  -- Shows the name, Steam name, weapon, status and bounding box of every other player in front of the
  -- view, their health and armor bars when `cwESPBars` is on, plus persistent props, items and salesmen
  -- when their ESP ConVars are on. The entities are looked up again every `cwESPTime` seconds.
  -- @warning [Internal] Called by the kernel while the HUD is drawn.
  function cw.core:DrawAdminESP()
    if CW_CONVAR_ADMINESP:GetInt() != 1 or !IsValid(cw.client) or !cw.client:Alive() then
      return
    end

    local font = cw.option:GetFont('esp_text')
    local smallFont = cw.fonts:GetSize(font, 12)
    local noWeaponText = L('#AdminESPInfo_NoWeapon')
    local drawBars = (CW_CONVAR_ESPBARS:GetInt() == 1)
    local clientPos = cw.client:GetPos()
    local eyeVector = EyeVector()
    local eyePos = EyePos()

    for k, v in ipairs(_player.GetAll()) do
      if v == cw.client then continue end
      if !v:HasInitialized() then continue end

      local pos = v:GetPos()
      local head = Vector(pos.x, pos.y, pos.z + 60)

      -- A position behind the view projects onto the screen mirrored, so it is not drawn.
      if (head.x - eyePos.x) * eyeVector.x + (head.y - eyePos.y) * eyeVector.y
      + (head.z - eyePos.z) * eyeVector.z <= 0 then
        continue
      end

      local screenPos = pos:ToScreen()
      local headPos = head:ToScreen()
      local textPos = Vector(head.x, head.y, head.z + 30):ToScreen()
      local distance = clientPos:Distance(pos)
      local x, y = headPos.x, headPos.y
      local f = math.abs(350 / distance)
      local size = 52 * f
      local teamColor = team.GetColor(v:Team()) or color_white
      local offset = 0

      local name = v:Name()
      local nameWidth = self:GetCachedTextSize(font, name)

      draw.SimpleText(name, font, textPos.x - nameWidth / 2, textPos.y, teamColor)

      local icon = cw.player:GetChatIcon(v)

      if icon then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self:GetMaterial(icon))
        surface.DrawTexturedRect(textPos.x - nameWidth / 2 - 18, textPos.y, 16, 16)
      end

      offset = offset + 14

      local steamName = v:SteamName()
      local steamNameWidth = self:GetCachedTextSize(smallFont, steamName)

      draw.SimpleText(steamName, smallFont, textPos.x - steamNameWidth / 2, textPos.y + offset, color_lightblue)

      offset = offset + 12

      local activeWeapon = v:GetActiveWeapon()
      local weaponName = noWeaponText

      if IsValid(activeWeapon) then
        weaponName = '['..activeWeapon:GetClass()..']'
      end

      local weaponNameWidth = self:GetCachedTextSize(smallFont, weaponName)

      draw.SimpleText(weaponName, smallFont, textPos.x - weaponNameWidth / 2, textPos.y + offset, color_lightblue)

      offset = offset + 12

      local statusInfo = {}
      hook.Run('GetStatusInfo', v, statusInfo)
      local infoText = statusInfo[1]

      if v:Alive() then
        surface.SetDrawColor(teamColor)
        surface.DrawOutlinedRect(x - size / 2, y - size / 2, size, (screenPos.y - y) * 1.25)
      end

      if infoText then
        local infoWidth = self:GetCachedTextSize(smallFont, infoText)

        draw.SimpleText(infoText, smallFont, textPos.x - infoWidth / 2, textPos.y + offset, color_lightred)
      end

      if drawBars then
        local bx, by = x - size / 2, y - size / 2 + (screenPos.y - y) * 1.25
        local hpM = math.Clamp((v:Health() or 0) / v:GetMaxHealth(), 0, 1)

        if hpM > 0 then
          draw.RoundedBox(0, bx, by, size, 2, color_grey)
          draw.RoundedBox(0, bx, by, size * hpM, 2, color_red)
        end

        local arM = math.Clamp((v:Armor() or 0) / 100, 0, 1)

        if arM > 0 then
          draw.RoundedBox(0, bx, by + 3, size, 2, color_grey)
          draw.RoundedBox(0, bx, by + 3, size * arM, 2, color_blue)
        end
      end
    end

    local drawSalesmen = (CW_CONVAR_SALEESP:GetInt() == 1)
    local drawItems = (CW_CONVAR_ITEMESP:GetInt() == 1)
    local drawProps = (CW_CONVAR_PROPESP:GetInt() == 1)

    if !drawSalesmen and !drawItems and !drawProps then
      return
    end

    local salesmanLabel = drawSalesmen and L('#AdminESPInfo_SalesmanLabel')
    local itemLabel = drawItems and L('#AdminESPInfo_ItemLabel')
    local propLabel = drawProps and L('#AdminESPInfo_StaticEntLabel')

    for k, v in ipairs(GetESPEntities(drawSalesmen, drawItems, drawProps)) do
      if !IsValid(v) then continue end

      local pos = v:GetPos()
      local entClass = v:GetClass()

      if drawProps and v:GetPersistent() then
        local entText = propLabel..' ['..tostring(v:GetModel())..']'
        local position = pos:ToScreen()
        local textWidth = self:GetCachedTextSize(smallFont, entText)

        draw.SimpleText(entText, smallFont, position.x - textWidth / 2, position.y, color_props)
      elseif drawItems and entClass == 'cw_item' then
        local itemTable = cw.entity:FetchItemTable(v)

        if itemTable then
          local entText = itemLabel..' ['..itemTable.name..']'
          local position = pos:ToScreen()
          local textWidth = self:GetCachedTextSize(smallFont, entText)

          draw.SimpleText(entText, smallFont, position.x - textWidth / 2, position.y, color_items)
        end
      elseif drawSalesmen and entClass == 'cw_salesman' then
        pos = pos + vector_salesman_offset

        local entText = salesmanLabel..' ['..v:GetNWString('Name')..']'
        local position = pos:ToScreen()
        local textWidth = self:GetCachedTextSize(smallFont, entText)

        draw.SimpleText(entText, smallFont, position.x - textWidth / 2, position.y, color_salesmen)
      end
    end
  end
end

local colorBarLimit = Color(213, 173, 39, 255)
local colorBarLimitText = Color(255, 255, 255, 255)

--- Draws a progress bar with a value and a maximum.
--
-- The bar's fields are copied into `barInfo` where it has none, and that table is passed to the
-- `PreDrawBar`, `PostDrawBar` and `DrawBarLimit` hooks; return `true` from one to replace that
-- part of the drawing. When `barInfo.maxValue` is more than 5 below the maximum, the part above
-- it is shaded, with `barInfo.limitText` drawn on it.
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param width [Number Width]
-- @param height [Number Height]
-- @param color [Color Color of the filled part]
-- @param text [String Text drawn in the middle of the bar]
-- @param value [Number Current value]
-- @param maximum [Number Maximum value]
-- @param flash [Boolean Make the bar pulse]
-- @param barInfo=nil [Map Extra bar options, such as `maxValue`, `limitText` or `drawBackground`]
-- @return [Number The bar's y position]
function cw.core:DrawBar(x, y, width, height, color, text, value, maximum, flash, barInfo)
  local backgroundColor = cw.option:GetColor('background')
  local progressWidth = math.Clamp(((width - 4) / maximum) * value, 0, width - 4)
  local colorWhite = cw.option:GetColor('white')
  local newBarInfo = {
    progressWidth = progressWidth,
    drawBackground = true,
    drawProgress = true,
    cornerSize = 2,
    maximum = maximum,
    height = height,
    width = width,
    color = color,
    value = value,
    flash = flash,
    text = text,
    x = x,
    y = y,
    isBlocky = false,
    blocksAmt = 24
  }

  if barInfo then
    for k, v in pairs(newBarInfo) do
      if barInfo[k] == nil then
        barInfo[k] = v
      end
    end
  else
    barInfo = newBarInfo
  end

  if !hook.Run('PreDrawBar', barInfo) then
    if barInfo.drawBackground then
      cdraw.DrawBox(barInfo.x, barInfo.y, barInfo.width, barInfo.height, backgroundColor)
    end

    if barInfo.drawProgress then
      render.SetScissorRect(barInfo.x, barInfo.y, barInfo.x + barInfo.progressWidth, barInfo.y + barInfo.height, true)
        cdraw.DrawBox(barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4, barInfo.color)
      render.SetScissorRect(barInfo.x, barInfo.y, barInfo.x + barInfo.progressWidth, barInfo.height, false)
    end

    if barInfo.flash then
      local alpha = math.Clamp(math.abs(math.sin(UnPredictedCurTime()) * 50), 0, 50)

      if alpha > 0 then
        draw.RoundedBox(
          0, barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4,
          ScratchColor(colorWhite.r, colorWhite.g, colorWhite.b, alpha)
        )
      end
    end
  end

  if !hook.Run('PostDrawBar', barInfo) then
    if barInfo.text and barInfo.text != '' then
      self:OverrideMainFont(cw.option:GetFont('bar_text'))
        self:DrawSimpleText(
          barInfo.text, barInfo.x + (barInfo.width / 2), barInfo.y + (barInfo.height / 2),
          ScratchColor(colorWhite.r, colorWhite.g, colorWhite.b, 255), 1, 1
        )
      self:OverrideMainFont(false)
    end
  end

  if barInfo.maxValue and (barInfo.maximum - barInfo.maxValue) > 5 then
    if !hook.Run('DrawBarLimit', barInfo) then
      local width = barInfo.width
      local length = width * ((barInfo.maximum - barInfo.maxValue) / barInfo.maximum)

      draw.RoundedBox(2, barInfo.x + width - length, barInfo.y, length, barInfo.height, colorBarLimit)

      if barInfo.limitText then
        local limitText = cw.lang:TranslateText(barInfo.limitText)
        local limitFont = cw.fonts:GetSize('hl2_BarsFont', 15)
        local textWide = self:GetCachedTextSize(limitFont, limitText)

        render.SetScissorRect(
          barInfo.x + width - length,
          barInfo.y,
          barInfo.x + width,
          barInfo.y + barInfo.height,
          true
        )
          draw.SimpleText(
            limitText,
            limitFont,
            barInfo.x + barInfo.width - textWide - 8,
            barInfo.y - 1,
            colorBarLimitText
          )
        render.SetScissorRect(0, 0, 0, 0, false)
      end
    end
  end

  return barInfo.y
end

--- Stores the recognise menu and gives it its title.
-- @param menuPanel [Panel The menu]
-- @see cw.core:GetRecogniseMenu
function cw.core:SetRecogniseMenu(menuPanel)
  cw.RecogniseMenu = menuPanel
  self:SetTitledMenu(menuPanel, '#RecogniseMenu')
end

--- Returns the recognise menu.
-- @param menuPanel [Panel Unused]
-- @return [Panel The menu set with `cw.core:SetRecogniseMenu`, or `nil`]
function cw.core:GetRecogniseMenu(menuPanel)
  return cw.RecogniseMenu
end

--- Temporarily replaces the `main_text` font, or restores it.
--
-- Text drawn with `cw.core:DrawInfo` and `cw.core:DrawSimpleText` uses this font.
--
-- ```
-- cw.core:OverrideMainFont(cw.option:GetFont('hints_text'))
--   cw.core:DrawInfo('Hello', x, y, color)
-- cw.core:OverrideMainFont(false)
-- ```
--
-- @param font [String Font to use, or `false` to restore the original font]
function cw.core:OverrideMainFont(font)
  if font then
    if !cw.PreviousMainFont then
      cw.PreviousMainFont = cw.option:GetFont('main_text')
    end

    cw.option:SetFont('main_text', font)
  elseif cw.PreviousMainFont then
    cw.option:SetFont('main_text', cw.PreviousMainFont)
  end
end

--- Returns the point HUD elements are centered on, slightly below the middle of the screen.
-- @return [Number X position, Number Y position]
function cw.core:GetScreenCenter()
  return ScrW() / 2, (ScrH() / 2) + 32
end

--- Draws text in the `main_text` font with a dark outline.
-- @param text [String The text]
-- @param x [Number X position, rounded]
-- @param y [Number Y position, rounded]
-- @param color [Color Text color]
-- @param alignX=nil [Number A `TEXT_ALIGN_*` horizontal alignment]
-- @param alignY=nil [Number A `TEXT_ALIGN_*` vertical alignment]
-- @param shadowless=false [Boolean Skip the outline]
-- @param shadowDepth=1 [Number Thickness of the outline in pixels]
-- @return [Number Y position below the text, Number Width of the text]
-- @see cw.core:OverrideMainFont
function cw.core:DrawSimpleText(text, x, y, color, alignX, alignY, shadowless, shadowDepth)
  local mainTextFont = cw.option:GetFont('main_text')
  local realX = math.Round(x)
  local realY = math.Round(y)

  text = tostring(text)

  -- The text is drawn several times for the outline, so it is translated once here and then drawn as it is.
  if surface.bTranslating and string.find(text, '#', 1, true) then
    text = cw.lang:TranslateText(text)
  end

  local width, height = self:GetCachedTextSize(mainTextFont, text)
  local DrawText = surface.OldDrawText or surface.DrawText
  local textX = realX
  local textY = realY

  if alignX == TEXT_ALIGN_CENTER then
    textX = textX - width / 2
  elseif alignX == TEXT_ALIGN_RIGHT then
    textX = textX - width
  end

  if alignY == TEXT_ALIGN_CENTER then
    textY = textY - height / 2
  elseif alignY == TEXT_ALIGN_BOTTOM then
    textY = textY - height
  end

  textX = math.ceil(textX)
  textY = math.ceil(textY)

  surface.SetFont(mainTextFont)

  if !shadowless then
    surface.SetTextColor(25, 25, 25, math.min(225, color.a))

    for i = 1, (shadowDepth or 1) do
      surface.SetTextPos(textX - i, textY - i)
      DrawText(text)
      surface.SetTextPos(textX - i, textY + i)
      DrawText(text)
      surface.SetTextPos(textX + i, textY - i)
      DrawText(text)
      surface.SetTextPos(textX + i, textY + i)
      DrawText(text)
    end
  end

  surface.SetTextColor(color.r, color.g, color.b, color.a)
  surface.SetTextPos(textX, textY)
  DrawText(text)

  return realY + height + 2, width
end

--- Returns the alpha of the black screen fade.
-- @return [Number The alpha of the fade in or out, or `0` when there is none]
function cw.core:GetBlackFadeAlpha()
  return cw.BlackFadeIn or cw.BlackFadeOut or 0
end

--- Returns whether the screen has completely faded to black.
-- @return [Boolean Whether the black fade in is at full alpha]
function cw.core:IsScreenFadedBlack()
  return (cw.BlackFadeIn == 255)
end

--- Prints colored text to the chat and console with the engine `chat.AddText`.
--
-- A player argument adds their name in their team color; a color applies to the next argument;
-- other values without a color before them are white.
--
-- ```
-- cw.core:PrintColoredText(player, Color(255, 0, 0), ' was arrested.')
-- ```
--
-- @param ... [Any Players, colors and text]
function cw.core:PrintColoredText(...)
  local currentColor = nil
  local colorWhite = cw.option:GetColor('white')
  local text = {}

  for k, v in ipairs({ ... }) do
    if type(v) == 'Player' then
      text[#text + 1] = _team.GetColor(v:Team())
      text[#text + 1] = v:Name()
    elseif type(v) == 'table' then
      currentColor = v
    elseif currentColor then
      text[#text + 1] = currentColor
      text[#text + 1] = v
      currentColor = nil
    else
      text[#text + 1] = colorWhite
      text[#text + 1] = v
    end
  end

  chatbox.oldAddText(unpack(text))
end

--- Returns whether a custom crosshair is in use.
-- @return [Boolean The value of `cw.CustomCrosshair`]
function cw.core:UsingCustomCrosshair()
  return cw.CustomCrosshair
end

--- Returns the size of a text, caching it per font.
-- @param font [String Font name]
-- @param text [String The text]
-- @return [Number Width in pixels, Number Height in pixels]
function cw.core:GetCachedTextSize(font, text)
  local cachedTextSizes = cw.CachedTextSizes

  if !cachedTextSizes then
    cachedTextSizes = {}
    cw.CachedTextSizes = cachedTextSizes
  end

  local fontSizes = cachedTextSizes[font]

  if !fontSizes then
    fontSizes = {}
    cachedTextSizes[font] = fontSizes
  end

  local size = fontSizes[text]

  if !size then
    surface.SetFont(font)

    size = { surface.GetTextSize(text) }
    fontSizes[text] = size
  end

  return size[1], size[2]
end

--- Draws information text with the main font scaled; see `cw.core:DrawInfo`.
-- @param scale [Number Font size multiplier for `cwMainText`]
-- @param text [String The text, translated before drawing]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param color [Color Text color]
-- @param alpha=nil [Number Alpha; defaults to the color's alpha]
-- @param bAlignLeft=false [Boolean Draw from `x` instead of centering on it]
-- @param Callback=nil [Function Called with `x, y, width, height`; returns the new `x, y`]
-- @param shadowDepth=1 [Number Thickness of the outline in pixels]
-- @return [Number Y position below the text]
function cw.core:DrawInfoScaled(scale, text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)
  local newFont = cw.fonts:GetMultiplied('cwMainText', scale)
  local returnY = 0

  self:OverrideMainFont(newFont)

  returnY = self:DrawInfo(text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)

  self:OverrideMainFont(false)

  return returnY
end

--- Draws outlined information text in the `main_text` font.
--
-- The text is translated first and centered on `x` unless `bAlignLeft` is set. Nothing is drawn
-- when the text is `nil`.
--
-- ```
-- y = cw.core:DrawInfo('#Hint_Example', x, y, Color(255, 255, 255), 200, true, function(x, y, w, h)
--   return x, y - h
-- end)
-- ```
--
-- @param text [String The text, or a language phrase]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param color [Color Text color]
-- @param alpha=nil [Number Alpha; defaults to the color's alpha]
-- @param bAlignLeft=false [Boolean Draw from `x` instead of centering on it]
-- @param Callback=nil [Function Called with `x, y, width, height`; returns the new `x, y`]
-- @param shadowDepth=1 [Number Thickness of the outline in pixels]
-- @return [Number Y position below the text, Number Width of the text]
-- @see cw.core:OverrideMainFont
function cw.core:DrawInfo(text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)
  if text == nil then
    return y, 0
  end

  if string.find(text, '#', 1, true) then
    text = cw.lang:TranslateText(text)
  end

  local width, height = self:GetCachedTextSize(cw.option:GetFont('main_text'), text)

  if !bAlignLeft then
    x = x - (width / 2)
  end

  if Callback then
    x, y = Callback(x, y, width, height)
  end

  return self:DrawSimpleText(
    text,
    x,
    y,
    ScratchColor(color.r, color.g, color.b, alpha or color.a),
    nil,
    nil,
    nil,
    shadowDepth
  )
end

--- Returns the layout of the player info box from the last time it was drawn.
-- @return [Map The box info returned by `cw.core:DrawPlayerInfo`, or `nil`]
function cw.core:GetPlayerInfoBox()
  return cw.PlayerInfoBox
end

--- Draws the local player's information box from `cw.PlayerInfoText`.
--
-- Only draws when the `PlayerCanSeePlayerInfo` hook returns `true` and there is text to show.
-- The `PreDrawPlayerInfo` hook can return `true` to replace the drawing; `PostDrawPlayerInfo`
-- runs afterwards. Moves `info.y` below the box.
-- @param info [Map Layout table with `x`, `y` and `width` fields; `y` is updated]
-- @return [Map The box layout (`x`, `y`, `width`, `height`, `information`, `subInformation`...)]
function cw.core:DrawPlayerInfo(info)
  if !hook.Run('PlayerCanSeePlayerInfo') then
    return
  end

  local foregroundColor = cw.option:GetColor('foreground')
  local subInformation = cw.PlayerInfoText.subText
  local information = cw.PlayerInfoText.text
  local colorWhite = cw.option:GetColor('white')
  local textWidth, textHeight = self:GetCachedTextSize(
    cw.option:GetFont('player_info_text'), 'U'
  )
  local width = cw.PlayerInfoText.width

  if width < info.width then
    width = info.width
  elseif width > width then
    info.width = width
  end

  if #information == 0 and #subInformation == 0 then
    return
  end

  local height = (textHeight * #information) + ((textHeight + 12) * #subInformation)
  local scrW = ScrW()
  local scrH = ScrH()

  if #information > 0 then
    height = height + 8
  end

  local y = info.y + 8
  local x = info.x - (width / 2)

  local boxInfo = {
    subInformation = subInformation,
    drawBackground = true,
    information = information,
    textHeight = textHeight,
    cornerSize = 2,
    textWidth = textWidth,
    height = height,
    width = width,
    x = x,
    y = y
  }

  if !hook.Run('PreDrawPlayerInfo', boxInfo, information, subInformation) then
    self:OverrideMainFont(cw.option:GetFont('player_info_text'))

    for k, v in pairs(subInformation) do
      x, y = self:DrawPlayerInfoSubBox(v.text, x, y, width, boxInfo)
    end

    if #information > 0 and boxInfo.drawBackground then
      cdraw.DrawBox(x, y, width, height - ((textHeight + 12) * #subInformation), Color(200, 200, 200))
    end

    if #information > 0 then
      x = x + 8
      y = y + 4
    end

    for k, v in pairs(information) do
      self:DrawInfo(v.text, x, y - 1, colorWhite, 255, true)
      y = y + textHeight
    end

    self:OverrideMainFont(false)
  end

  hook.Run('PostDrawPlayerInfo', boxInfo, information, subInformation)
  info.y = info.y + boxInfo.height + 12

  return boxInfo
end

--- Returns whether there are quick menu entries to show in the info menu.
-- @return [Boolean Whether `cw.quickmenu` has any entries or categories]
function cw.core:CanCreateInfoMenuPanel()
  return (table.Count(cw.quickmenu.stored) > 0 or table.Count(cw.quickmenu.categories) > 0)
end

--- Creates the info menu panel from the quick menu entries.
--
-- Each entry's `GetInfo` returns its option table (`name`, `Callback`, `options`, `toolTip`).
-- The panel is stored in `cw.InfoMenuPanel` and starts hidden. Does nothing if it already exists.
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param iMinimumWidth [Number Width of the panel]
function cw.core:CreateInfoMenuPanel(x, y, iMinimumWidth)
  if IsValid(cw.InfoMenuPanel) then return end

  local options = {}

  for k, v in pairs(cw.quickmenu.categories) do
    options[k] = {}

    for k2, v2 in pairs(v) do
      local info = v2.GetInfo()

      if type(info) == 'table' then
        options[k][k2] = info
        options[k][k2].isArgTable = true
      end
    end
  end

  for k, v in pairs(cw.quickmenu.stored) do
    local info = v.GetInfo()

    if type(info) == 'table' then
      options[k] = info
      options[k].isArgTable = true
    end
  end

  cw.InfoMenuPanel = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
    if arguments.name then
      option = arguments.name
    end

    if arguments.options then
      local subMenu = menuPanel:AddSubMenu(option)

      for k, v in pairs(arguments.options) do
        local name = v

        if type(v) == 'table' then
          name = v[1]
        end

        subMenu:AddOption(name, function()
          if arguments.Callback then
            if type(v) == 'table' then
              arguments.Callback(v[2])
            else
              arguments.Callback(v)
            end
          end

          self:RemoveActiveToolTip()
          self:CloseActiveDermaMenus()
        end)
      end

      if IsValid(subMenu) then
        if arguments.toolTip then
          subMenu:SetTooltip(arguments.toolTip)
        end
      end
    else
      menuPanel:AddOption(option, function()
        if arguments.Callback then
          arguments.Callback()
        end

        self:RemoveActiveToolTip()
        self:CloseActiveDermaMenus()
      end)

      menuPanel.Items = menuPanel:GetChildren()
      local panel = menuPanel.Items[#menuPanel.Items]

      if IsValid(panel) and arguments.toolTip then
        panel:SetTooltip(arguments.toolTip)
      end
    end
  end, iMinimumWidth)

  if IsValid(cw.InfoMenuPanel) then
    cw.InfoMenuPanel:SetVisible(false)
    cw.InfoMenuPanel:SetSize(iMinimumWidth, cw.InfoMenuPanel:GetTall())
    cw.InfoMenuPanel:SetPos(x, y)
  end
end

--- Returns the eye angles used while the local player's view follows their ragdoll.
--
-- Creates the angle the first time it is needed.
-- @return [Angle The angle stored in `cw.RagdollEyeAngles`]
function cw.core:GetRagdollEyeAngles()
  if !cw.RagdollEyeAngles then
    cw.RagdollEyeAngles = Angle(0, 0, 0)
  end

  return cw.RagdollEyeAngles
end

--- Draws a gradient rectangle.
--
-- Does nothing when the gradient type has no texture in `cw.Gradients`.
-- @param gradientType [Number A `GRADIENT_*` constant, such as `GRADIENT_RIGHT`]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param width [Number Width]
-- @param height [Number Height]
-- @param color [Color Draw color]
function cw.core:DrawGradient(gradientType, x, y, width, height, color)
  if !cw.Gradients or !cw.Gradients[gradientType] then
    return
  end

  surface.SetDrawColor(color.r, color.g, color.b, color.a)
  surface.SetTexture(cw.Gradients[gradientType])
  surface.DrawTexturedRect(x, y, width, height)
end

--- Draws a rounded box at three quarters of the color's alpha.
--
-- Despite the name, no gradient is drawn on top.
-- @param cornerSize [Number Corner radius]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param width [Number Width]
-- @param height [Number Height]
-- @param color [Color Box color]
-- @param maxAlpha=100 [Number Unused]
-- @see cw.core:DrawTexturedGradientBox
function cw.core:DrawSimpleGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
  draw.RoundedBox(cornerSize, x, y, width, height, ScratchColor(color.r, color.g, color.b, color.a * 0.75))
end

--- Draws a rounded box at three quarters of the color's alpha with the gradient texture over it.
-- @param cornerSize [Number Corner radius; the gradient is inset by this much]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param width [Number Width]
-- @param height [Number Height]
-- @param color [Color Box color]
-- @param maxAlpha=100 [Number Maximum alpha of the gradient]
-- @see cw.core:GetGradientTexture
function cw.core:DrawTexturedGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
  local gradientAlpha = math.min(color.a, maxAlpha or 100)

  draw.RoundedBox(cornerSize, x, y, width, height, ScratchColor(color.r, color.g, color.b, color.a * 0.75))

  if x + cornerSize < x + width and y + cornerSize < y + height then
    surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha)
    surface.SetMaterial(self:GetGradientTexture())
    surface.DrawTexturedRect(x + cornerSize, y + cornerSize, width - (cornerSize * 2), height - (cornerSize * 2))
  end
end

--- Draws one sub box of the player info box.
-- @param text [String Text of the box]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param width [Number Width]
-- @param boxInfo [Map Layout from `cw.core:DrawPlayerInfo`; uses `textHeight` and `drawBackground`]
-- @return [Number X position, Number Y position for the next box]
function cw.core:DrawPlayerInfoSubBox(text, x, y, width, boxInfo)
  local foregroundColor = cw.option:GetColor('foreground')
  local colorInfo = cw.option:GetColor('information')
  local boxHeight = boxInfo.textHeight + 8

  if boxInfo.drawBackground then
    cdraw.DrawBox(x, y, width, boxHeight, foregroundColor)
  end

  self:DrawInfo(text, x + 8, y + (boxHeight / 2), colorInfo, 255, true,
    function(x, y, width, height)
      return x, y - (height / 2)
    end
  )

  return x, y + boxHeight + 4
end

--- Opens the action menu for an item's spawn icon.
--
-- Collects the item's use, drop and destroy actions, `customFunctions` and `GetOptions`, lets
-- the item (`OnEditFunctions`) and the `PlayerAdjustItemFunctions` and `PlayerAdjustItemMenu`
-- hooks change them, and runs the chosen action with the `InvAction` command. Does nothing when
-- the item has no actions and no callback is given.
-- @param itemTable [Item The item]
-- @param spawnIcon [Panel The clicked spawn icon; unused]
-- @param Callback=nil [Function Called with the menu before the actions are added]
-- @see cw.core:HandleItemSpawnIconRightClick
function cw.core:HandleItemSpawnIconClick(itemTable, spawnIcon, Callback)
  local customFunctions = itemTable.customFunctions
  local itemFunctions = {}
  local destroyName = cw.option:GetKey('name_destroy')
  local dropName = cw.option:GetKey('name_drop')
  local useName = cw.option:GetKey('name_use')

  if itemTable.OnUse then
    itemFunctions[#itemFunctions + 1] = (itemTable.useText or useName)
  end

  if itemTable.OnDrop then
    itemFunctions[#itemFunctions + 1] = (itemTable.dropText or dropName)
  end

  if itemTable.OnDestroy then
    itemFunctions[#itemFunctions + 1] = (itemTable.destroyText or destroyName)
  end

  if customFunctions then
    for k, v in pairs(customFunctions) do
      itemFunctions[#itemFunctions + 1] = v
    end
  end

  if itemTable.GetOptions then
    local options = itemTable:GetOptions(nil, nil)

    for k, v in pairs(options) do
      itemFunctions[#itemFunctions + 1] = { title = k, name = v }
    end
  end

  if itemTable.OnEditFunctions then
    itemTable:OnEditFunctions(itemFunctions)
  end

  hook.Run('PlayerAdjustItemFunctions', itemTable, itemFunctions)
  self:ValidateTableKeys(itemFunctions)

  table.sort(
    itemFunctions,
    function(a, b) return ((type(a) == 'table' and a.title) or a) < ((type(b) == 'table' and b.title) or b) end
  )
  if #itemFunctions == 0 and !Callback then return end

  local options = {}

  if itemTable.GetEntityMenuOptions then
    itemTable:GetEntityMenuOptions(nil, options)
  end

  local itemMenu = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
    menuPanel:AddOption(option, function()
      if type(arguments) == 'table' and arguments.isArgTable then
        if arguments.Callback then
          arguments.Callback()
        end
      end

      timer.Simple(FrameTime(), function()
        self:RemoveActiveToolTip()
      end)
    end)

    menuPanel.Items = menuPanel:GetChildren()
    local panel = menuPanel.Items[#menuPanel.Items]

    if IsValid(panel) then
      if type(arguments) == 'table' then
        if arguments.toolTip then
          self:CreateMarkupToolTip(panel)
          panel:SetMarkupToolTip(arguments.toolTip)
        end
      end
    end
  end, nil, true)

  if Callback then Callback(itemMenu) end

  itemMenu:SetMinimumWidth(100)
  hook.Run('PlayerAdjustItemMenu', itemTable, itemMenu, itemFunctions)

  for k, v in pairs(itemFunctions) do
    local useText = (itemTable.useText or useName)
    local dropText = (itemTable.dropText or dropName)
    local destroyText = (itemTable.destroyText or destroyName)

    if (!useText and v == 'Use') or (useText and v == useText) then
      itemMenu:AddOption(L(v), function()
        if itemTable then
          if itemTable.OnHandleUse then
            itemTable:OnHandleUse(function()
              self:RunCommand(
                'InvAction', 'use', itemTable.uniqueID, itemTable.itemID
              )
            end)
          else
            self:RunCommand(
              'InvAction', 'use', itemTable.uniqueID, itemTable.itemID
            )
          end
        end
      end)
    elseif (!dropText and v == 'Drop') or (dropText and v == dropText) then
      itemMenu:AddOption(L(v), function()
        if itemTable then
          self:RunCommand(
            'InvAction', 'drop', itemTable.uniqueID, itemTable.itemID
          )
        end
      end)
    elseif (!destroyText and v == 'Destroy') or (destroyText and v == destroyText) then
      local subMenu = itemMenu:AddSubMenu(L(v))

      subMenu:AddOption(L('Yes'), function()
        if itemTable then
          self:RunCommand(
            'InvAction', 'destroy', itemTable.uniqueID, itemTable.itemID
          )
        end
      end)

      subMenu:AddOption(L('No'), function() end)
    elseif type(v) == 'table' then
      itemMenu:AddOption(L(v.title), function()
        local defaultAction = true

        if itemTable.HandleOptions then
          local transmit, data = itemTable:HandleOptions(v.name)

          if transmit then
            cable.send('MenuOption', { option = v.name, data = data, item = itemTable.itemID })
            defaultAction = false
          end
        end

        if defaultAction then
          self:RunCommand(
            'InvAction', v.name, itemTable.uniqueID, itemTable.itemID
          )
        end
      end)
    else
      if itemTable.OnCustomFunction then
        itemTable:OnCustomFunction(v)
      end

      itemMenu:AddOption(L(v), function()
        if itemTable then
          self:RunCommand(
            'InvAction', v, itemTable.uniqueID, itemTable.itemID
          )
        end
      end)
    end
  end

  itemMenu:Open()
end

--- Runs an item's default action when its spawn icon is right-clicked.
--
-- If the item's `OnHandleRightClick` returns an action name other than `'Use'`, that action is
-- run; otherwise the item is used when it has `OnUse`. `OnHandleUse` can delay the use.
-- @param itemTable [Item The item]
-- @param spawnIcon [Panel The clicked spawn icon; unused]
function cw.core:HandleItemSpawnIconRightClick(itemTable, spawnIcon)
  if itemTable.OnHandleRightClick then
    local functionName = itemTable:OnHandleRightClick()

    if functionName and functionName != 'Use' then
      local customFunctions = itemTable.customFunctions

      if customFunctions and table.HasValue(customFunctions, functionName) then
        if itemTable.OnCustomFunction then
          itemTable:OnCustomFunction(functionName)
        end
      end

      self:RunCommand(
        'InvAction', string.lower(functionName), itemTable.uniqueID, itemTable.itemID
      )
      return
    end
  end

  if itemTable.OnUse then
    if itemTable.OnHandleUse then
      itemTable:OnHandleUse(function()
        self:RunCommand('InvAction', 'use', itemTable.uniqueID, itemTable.itemID)
      end)
    else
      self:RunCommand('InvAction', 'use', itemTable.uniqueID, itemTable.itemID)
    end
  end
end

--- Runs a callback after a panel's `PerformLayout`.
--
-- The original method is kept as `OldPerformLayout`. Does nothing when the panel has no
-- `PerformLayout`.
-- @param target [Panel The panel]
-- @param Callback [Function Called with the panel after each layout]
function cw.core:SetOnLayoutCallback(target, Callback)
  if target.PerformLayout then
    target.OldPerformLayout = target.PerformLayout

    -- Called when the panel's layout is performed.
    function target.PerformLayout()
      target:OldPerformLayout() Callback(target)
    end
  end
end

--- Sets the menu that gets a title drawn above it.
-- @param menuPanel [Panel The menu]
-- @param title [String The title, or a language phrase]
function cw.core:SetTitledMenu(menuPanel, title)
  cw.TitledMenu = {
    menuPanel = menuPanel,
    title = title
  }
end

--- Appends a colored line to markup text.
-- @param markupText [String Existing markup; a newline is added when it is not empty]
-- @param text [String Text of the new line]
-- @param color=nil [Color Color of the line]
-- @return [String The new markup]
-- @see cw.core:MarkupTextWithColor
function cw.core:AddMarkupLine(markupText, text, color)
  if markupText != '' then
    markupText = markupText..'\n'
  end

  return markupText..self:MarkupTextWithColor(text, color)
end

--- Draws a markup tool tip near a position, keeping it on the screen.
-- @param markupObject [Map A markup object from `markup.Parse`]
-- @param x [Number X position]
-- @param y [Number Y position]
-- @param alpha [Number Alpha of the tool tip]
function cw.core:DrawMarkupToolTip(markupObject, x, y, alpha)
  local height = markupObject:GetHeight()
  local width = markupObject:GetWidth()

  if x - (width / 2) > 0 then
    x = x - (width / 2)
  end

  if x + width > ScrW() then
    x = x - width - 8
  end

  if y + (height + 8) > ScrH() then
    y = y - height - 8
  end

  self:DrawSimpleGradientBox(2, x - 8, y - 8, width + 16, height + 16, Color(50, 50, 50, alpha))
  markupObject:Draw(x, y, nil, nil, alpha)
end

--- Replaces a markup object's `Draw` method so that it draws outlined text.
--
-- The new method takes an extra `alphaOverride` argument after the alignment arguments.
-- @param markupObject [Map A markup object from `markup.Parse`]
-- @param sCustomFont=nil [String Font for every block; defaults to each block's own font]
function cw.core:OverrideMarkupDraw(markupObject, sCustomFont)
  function markupObject:Draw(xOffset, yOffset, hAlign, vAlign, alphaOverride)
    for k, v in pairs(self.blocks) do
      if !v.colour then
        debug.Trace()
        return
      end

      local alpha = v.colour.a or 255
      local y = yOffset + (v.height - v.thisY) + v.offset.y
      local x = xOffset

      if hAlign == TEXT_ALIGN_CENTER then
        x = x - (self.totalWidth / 2)
      elseif hAlign == TEXT_ALIGN_RIGHT then
        x = x - self.totalWidth
      end

      x = x + v.offset.x

      if vAlign == TEXT_ALIGN_CENTER then
        y = y - (self.totalHeight / 2)
      elseif vAlign == TEXT_ALIGN_BOTTOM then
        y = y - self.totalHeight
      end

      if alphaOverride then
        alpha = alphaOverride
      end

      cw.core:OverrideMainFont(sCustomFont or v.font)
        cw.core:DrawSimpleText(
          v.text, x, y, ScratchColor(v.colour.r or 255, v.colour.g or 255, v.colour.b or 255, alpha)
        )
      cw.core:OverrideMainFont(false)
    end
  end
end

--- Returns the panel whose markup tool tip is shown.
-- @return [Panel The panel under the cursor, or `nil`]
function cw.core:GetActiveMarkupToolTip()
  return cw.MarkupToolTip
end

--- Returns an opening markup color tag for a color.
-- @param color [Color The color; alpha is ignored]
-- @return [String The tag, such as `'<color=255,0,0>'`]
function cw.core:ColorToMarkup(color)
  return '<color='..math.ceil(color.r)..','..math.ceil(color.g)..','..math.ceil(color.b)..'>'
end

--- Wraps text in markup font and color tags.
-- @param text [String The text]
-- @param color=nil [Color Color of the text]
-- @param scale=1 [Number Size multiplier for the `cwTooltip` font]
-- @return [String The markup]
function cw.core:MarkupTextWithColor(text, color, scale)
  local fontName = cw.fonts:GetMultiplied('cwTooltip', scale or 1)
  local finalText = text

  if color then
    finalText = self:ColorToMarkup(color)..text..'</color>'
  end

  finalText = '<font='..fontName..'>'..finalText..'</font>'

  return finalText
end

--- Gives a panel a markup tool tip.
--
-- Adds `SetMarkupToolTip`, `GetMarkupToolTip` and `SetToolTip` methods and wraps
-- `OnCursorEntered`/`OnCursorExited` so the tip shows while the cursor is over the panel.
--
-- ```
-- cw.core:CreateMarkupToolTip(button)
-- button:SetMarkupToolTip(cw.core:MarkupTextWithColor('Sells for ^50^', Color(0, 255, 0)))
-- ```
--
-- @param panel [Panel The panel]
-- @return [Panel The same panel]
function cw.core:CreateMarkupToolTip(panel)
  panel.OldCursorExited = panel.OnCursorExited
  panel.OldCursorEntered = panel.OnCursorEntered

  -- Called when the cursor enters the panel.
  function panel.OnCursorEntered(panel, ...)
    if panel.OldCursorEntered then
      panel:OldCursorEntered(...)
    end

    cw.MarkupToolTip = panel
  end

  -- Called when the cursor exits the panel.
  function panel.OnCursorExited(panel, ...)
    if panel.OldCursorExited then
      panel:OldCursorExited(...)
    end

    if cw.MarkupToolTip == panel then
      cw.MarkupToolTip = nil
    end
  end

  -- A function to set the panel's markup tool tip.
  function panel.SetMarkupToolTip(panel, text)
    if !text or text == '' then
      return
    end

    text = cw.lang:TranslateText(text)

    if !panel.MarkupToolTip or panel.MarkupToolTip.text != text then
      panel.MarkupToolTip = {
        object = markup.Parse(text, ScrW() * 0.25),
        text = text
      }

      self:OverrideMarkupDraw(panel.MarkupToolTip.object)
    end
  end

  -- A function to get the panel's markup tool tip.
  function panel.GetMarkupToolTip(panel)
    return panel.MarkupToolTip
  end

  -- A function to set the panel's tool tip.
  function panel.SetToolTip(panel, toolTip)
    panel:SetMarkupToolTip(toolTip)
  end

  return panel
end

--- Creates an expanded collapsible category in a panel.
--
-- The category is added to `parent.CategoryList`.
-- @param categoryName [String Label of the category]
-- @param parent [Panel The parent panel]
-- @return [Panel The `DCollapsibleCategory`]
function cw.core:CreateCustomCategoryPanel(categoryName, parent)
  if !parent.CategoryList then
    parent.CategoryList = {}
  end

  local collapsibleCategory = vgui.Create('DCollapsibleCategory', parent)
    collapsibleCategory:SetExpanded(true)
    collapsibleCategory:SetPadding(2)
    collapsibleCategory:SetLabel(categoryName)
  parent.CategoryList[#parent.CategoryList + 1] = collapsibleCategory

  return collapsibleCategory
end

--- Adds the local player's armor bar to the top bars when they have armor.
--
-- The displayed value moves towards the real one by one point per call.
-- @warning [Internal] Called by the kernel while the top bars are built.
function cw.core:DrawArmorBar()
  local armor = math.Clamp(cw.client:Armor(), 0, cw.client:GetMaxArmor())

  if !self.armor then
    self.armor = armor
  else
    self.armor = math.Approach(self.armor, armor, 1)
  end

  if armor > 0 then
    cw.bars:Add('#Bars_Armor', Color(139, 174, 179, 255), '', self.armor, cw.client:GetMaxArmor(), self.health < 10, 1)
  end
end

--- Adds the local player's health bar to the top bars while they are alive.
--
-- The displayed value moves towards the real one by one point per call, and the bar flashes
-- below 10 health.
-- @warning [Internal] Called by the kernel while the top bars are built.
function cw.core:DrawHealthBar()
  local health = math.Clamp(cw.client:Health(), 0, cw.client:GetMaxHealth())

  if !self.health then
    self.health = health
  else
    self.health = math.Approach(self.health, health, 1)
  end

  if health > 0 then
    cw.bars:Add('#Bars_Health', Color(179, 46, 49, 255), '', self.health, cw.client:GetMaxHealth(), self.health < 10, 2)
  end
end

--- Hides the active Derma tool tip.
function cw.core:RemoveActiveToolTip()
  ChangeTooltip()
end

--- Closes every open Derma menu.
function cw.core:CloseActiveDermaMenus()
  CloseDermaMenus()
end

--- Blurs the screen behind a panel while it is visible.
--
-- The blur fades in over one second from the creation time.
-- @param panel [Panel The panel, or a string key for a blur not tied to a panel]
-- @param fCreateTime=SysTime() [Number Time the blur starts fading in]
-- @see cw.core:RemoveBackgroundBlur
function cw.core:RegisterBackgroundBlur(panel, fCreateTime)
  cw.BackgroundBlurs[panel] = fCreateTime or SysTime()
end

--- Removes a background blur registered with `cw.core:RegisterBackgroundBlur`.
-- @param panel [Panel The panel or string key of the blur]
function cw.core:RemoveBackgroundBlur(panel)
  cw.BackgroundBlurs[panel] = nil
end

--- Draws the registered background blurs.
-- @warning [Internal] Called by the kernel while the HUD is drawn.
function cw.core:DrawBackgroundBlurs()
  local scrH, scrW = ScrH(), ScrW()
  local sysTime = SysTime()

  if !cw.ScreenBlur then
    cw.ScreenBlur = Material('pp/blurscreen')
  end

  for k, v in pairs(cw.BackgroundBlurs) do
    local bIsPanel = type(k) != 'string'

    if bIsPanel and !IsValid(k) then
      cw.BackgroundBlurs[k] = nil
    elseif !bIsPanel or k:IsVisible() then
      local fraction = math.Clamp((sysTime - v) / 1, 0, 1)
      local x, y = 0, 0

      surface.SetMaterial(cw.ScreenBlur)
      surface.SetDrawColor(255, 255, 255, 255)

      for i = 0.33, 1, 0.33 do
        cw.ScreenBlur:SetFloat('$blur', fraction * 5 * i)
        cw.ScreenBlur:Recompute()

        render.UpdateScreenEffectTexture()

        surface.DrawTexturedRect(x, y, scrW, scrH)
      end

      surface.SetDrawColor(10, 10, 10, 200 * fraction)
      surface.DrawRect(x, y, scrW, scrH)
    end
  end
end

--- Returns the notice panel when it is visible.
-- @return [Panel The panel, or `nil`]
function cw.core:GetNoticePanel()
  if IsValid(cw.NoticePanel) and cw.NoticePanel:IsVisible() then
    return cw.NoticePanel
  end
end

--- Sets the notice panel.
-- @param noticePanel [Panel The panel]
function cw.core:SetNoticePanel(noticePanel)
  cw.NoticePanel = noticePanel
end

--- Queues cinematic text, shown between black bars at the top and bottom of the screen.
-- @param text [String The text]
-- @param color=nil [Color Text color; defaults to white]
-- @param barLength=ScrH() * 8 [Number Height of the bars in pixels]
-- @param hangTime=3 [Number Seconds the text stays once the bars are in]
-- @param font=nil [String Font; defaults to the `cinematic_text` font]
-- @param bThisOnly=false [Boolean Replace the current cinematic instead of queueing]
function cw.core:AddCinematicText(text, color, barLength, hangTime, font, bThisOnly)
  local colorWhite = cw.option:GetColor('white')
  local cinematicTable = {
    barLength = barLength or (ScrH() * 8),
    hangTime = hangTime or 3,
    color = color or colorWhite,
    font = font,
    text = text,
    add = 0
  }

  if bThisOnly then
    cw.Cinematics[1] = cinematicTable
  else
    cw.Cinematics[#cw.Cinematics + 1] = cinematicTable
  end
end

--- Returns whether the local player is holding the toolgun.
-- @return [Boolean Whether the active weapon is `gmod_tool`]
function cw.core:IsUsingTool()
  local weapon = cw.client:GetActiveWeapon()

  return IsValid(weapon) and weapon:GetClass() == 'gmod_tool'
end

--- Returns whether the local player is holding the camera.
-- @return [Boolean Whether the active weapon is `gmod_camera`]
function cw.core:IsUsingCamera()
  local weapon = cw.client:GetActiveWeapon()

  return IsValid(weapon) and weapon:GetClass() == 'gmod_camera'
end

--- Returns the target ID data of the entity the local player is looking at.
-- @return [Map The value of `cw.TargetIDData`]
function cw.core:GetTargetIDData()
  return cw.TargetIDData
end

--- Fades the screen to black while the `ShouldPlayerScreenFadeBlack` hook returns `true`.
--
-- Fades back out afterwards; see `cw.core:GetBlackFadeAlpha`.
-- @warning [Internal] Called by the kernel while the HUD is drawn.
function cw.core:CalculateScreenFading()
  if hook.Run('ShouldPlayerScreenFadeBlack') then
    if !cw.BlackFadeIn then
      if cw.BlackFadeOut then
        cw.BlackFadeIn = cw.BlackFadeOut
      else
        cw.BlackFadeIn = 0
      end
    end

    cw.BlackFadeIn = math.Clamp(cw.BlackFadeIn + (FrameTime() * 20), 0, 255)
    cw.BlackFadeOut = nil
    self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), ScratchColor(0, 0, 0, cw.BlackFadeIn))
  else
    if cw.BlackFadeIn then
      cw.BlackFadeOut = cw.BlackFadeIn
    end

    cw.BlackFadeIn = nil

    if cw.BlackFadeOut then
      cw.BlackFadeOut = math.Clamp(cw.BlackFadeOut - (FrameTime() * 40), 0, 255)
      self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), ScratchColor(0, 0, 0, cw.BlackFadeOut))

      if cw.BlackFadeOut == 0 then
        cw.BlackFadeOut = nil
      end
    end
  end
end

--- Draws one frame of a cinematic text and advances its animation.
--
-- Removes the cinematic from `cw.Cinematics` once its bars have slid back out.
-- @param cinematicTable [Map The cinematic, as added by `cw.core:AddCinematicText`]
-- @param curTime [Number The current time]
-- @warning [Internal] Called by the kernel for the first queued cinematic.
function cw.core:DrawCinematic(cinematicTable, curTime)
  local maxBarLength = cinematicTable.barLength or (ScrH() / 13)
  local font = cinematicTable.font or cw.option:GetFont('cinematic_text')

  if cinematicTable.goBack and curTime > cinematicTable.goBack then
    cinematicTable.add = math.Clamp(cinematicTable.add - 2, 0, maxBarLength)

    if cinematicTable.add == 0 then
      table.remove(cw.Cinematics, 1)
      cinematicTable = nil
    end
  else
    cinematicTable.add = math.Clamp(cinematicTable.add + 1, 0, maxBarLength)

    if cinematicTable.add == maxBarLength and !cinematicTable.goBack then
      cinematicTable.goBack = curTime + cinematicTable.hangTime
    end
  end

  if cinematicTable then
    draw.RoundedBox(0, 0, -maxBarLength + cinematicTable.add, ScrW(), maxBarLength, Color(0, 0, 0, 255))
    draw.RoundedBox(0, 0, ScrH() - cinematicTable.add, ScrW(), maxBarLength, Color(0, 0, 0, 255))
    draw.SimpleText(
      cinematicTable.text,
      font,
      ScrW() / 2,
      (ScrH() - cinematicTable.add) + (maxBarLength / 2),
      cinematicTable.color,
      1,
      1
    )
  end
end

--- Draws the credits part of the character intro and fades it in and out.
--
-- Uses the table from the `GetCinematicIntroInfo` hook.
-- @param curTime [Number The current time]
-- @warning [Internal] Called by the kernel after a character is loaded.
function cw.core:DrawCinematicIntro(curTime)
  local cinematicInfo = hook.Run('GetCinematicIntroInfo')
  local colorWhite = cw.option:GetColor('white')

  if cinematicInfo then
    if cw.CinematicScreenAlpha and cw.CinematicScreenTarget then
      cw.CinematicScreenAlpha = math.Approach(cw.CinematicScreenAlpha, cw.CinematicScreenTarget, 1)

      if cw.CinematicScreenAlpha == cw.CinematicScreenTarget then
        if cw.CinematicScreenTarget == 255 then
          if !cw.CinematicScreenGoBack then
            cw.CinematicScreenGoBack = curTime + 2.5
            cw.option:PlaySound('rollover')
          end
        else
          cw.CinematicScreenDone = true
        end
      end

      if cw.CinematicScreenGoBack and curTime >= cw.CinematicScreenGoBack then
        cw.CinematicScreenGoBack = nil
        cw.CinematicScreenTarget = 0
        cw.option:PlaySound('rollover')
      end

      if !cw.CinematicScreenDone and cinematicInfo.credits then
        local alpha = math.Clamp(cw.CinematicScreenAlpha, 0, 255)

        self:OverrideMainFont(cw.option:GetFont('intro_text_tiny'))
          self:DrawSimpleText(
            cinematicInfo.credits,
            ScrW() / 8,
            ScrH() * 0.75,
            Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha)
          )
        self:OverrideMainFont(false)
      end
    else
      cw.CinematicScreenAlpha = 0
      cw.CinematicScreenTarget = 255
      cw.option:PlaySound('rollover')
    end
  end
end

--- Draws the black bars of the character intro when the `draw_intro_bars` config is on.
-- @warning [Internal] Called by the kernel after a character is loaded.
function cw.core:DrawCinematicIntroBars()
  if config.GetVal('draw_intro_bars') then
    local maxBarLength = ScrH() / 8

    if !cw.CinematicBarsTarget and !cw.CinematicBarsAlpha then
      cw.CinematicBarsAlpha = 0
      cw.CinematicBarsTarget = 255
      cw.option:PlaySound('rollover')
    end

    cw.CinematicBarsAlpha = math.Approach(cw.CinematicBarsAlpha, cw.CinematicBarsTarget, 1)

    if cw.CinematicScreenDone then
      if cw.CinematicScreenBarLength != 0 then
        cw.CinematicScreenBarLength = math.Clamp((maxBarLength / 255) * cw.CinematicBarsAlpha, 0, maxBarLength)
      end

      if cw.CinematicBarsTarget != 0 then
        cw.CinematicBarsTarget = 0
        cw.option:PlaySound('rollover')
      end

      if cw.CinematicBarsAlpha == 0 then
        cw.CinematicBarsDrawn = true
      end
    elseif cw.CinematicScreenBarLength != maxBarLength then
      if !cw.IntroBarsMultiplier then
        cw.IntroBarsMultiplier = 1
      else
        cw.IntroBarsMultiplier = math.Clamp(cw.IntroBarsMultiplier + (FrameTime() * 8), 1, 12)
      end

      cw.CinematicScreenBarLength = math.Clamp(
        (maxBarLength / 255) * math.Clamp(cw.CinematicBarsAlpha * cw.IntroBarsMultiplier, 0, 255),
        0,
        maxBarLength
      )
    end

    draw.RoundedBox(0, 0, 0, ScrW(), cw.CinematicScreenBarLength, Color(0, 0, 0, 255))
    draw.RoundedBox(0, 0, ScrH() - cw.CinematicScreenBarLength, ScrW(), maxBarLength, Color(0, 0, 0, 255))
  end
end

--- Draws the title and text of the character intro.
--
-- Uses the `title` and `text` from the `GetCinematicIntroInfo` hook and fades them out once the
-- intro screen starts.
-- @warning [Internal] Called by the kernel after a character is loaded.
function cw.core:DrawCinematicInfo()
  if !cw.CinematicInfoAlpha and !cw.CinematicInfoSlide then
    cw.CinematicInfoAlpha = 255
    cw.CinematicInfoSlide = 0
  end

  cw.CinematicInfoSlide = math.Approach(cw.CinematicInfoSlide, 255, 1)

  if cw.CinematicScreenAlpha and cw.CinematicScreenTarget then
    cw.CinematicInfoAlpha = math.Approach(cw.CinematicInfoAlpha, 0, 1)

    if cw.CinematicInfoAlpha == 0 then
      cw.CinematicInfoDrawn = true
    end
  end

  local cinematicInfo = hook.Run('GetCinematicIntroInfo')
  local colorWhite = cw.option:GetColor('white')
  local colorInfo = cw.option:GetColor('information')

  if cinematicInfo then
    local scrH = ScrH()
    local scrW = ScrW()
    local textPosScale = 1 - (cw.CinematicInfoAlpha / 255)
    local textPosY = (scrH * 0.35) - ((scrH * 0.15) * textPosScale)
    local textPosX = scrW * 0.3

    local cinematicIntroText = cinematicInfo.text and string.upper(cinematicInfo.text)
    local introTextSmallFont = cw.option:GetFont('intro_text_small')

    if cinematicInfo.title then
      local cinematicInfoTitle = string.upper(cinematicInfo.title)
      local introTextBigFont = cw.option:GetFont('intro_text_big')
      local textWidth, textHeight = self:GetCachedTextSize(introTextBigFont, cinematicInfoTitle)
      local boxAlpha = math.Clamp(cw.CinematicInfoAlpha, 0, 130)

      if cinematicInfo.text then
        local smallTextWidth, smallTextHeight = self:GetCachedTextSize(introTextSmallFont, cinematicIntroText)
        local tabY = textPosY + textHeight + smallTextHeight + 80
        local verts = {
          { x = 0, y = textPosY - 60 }, -- left upper
          { x = scrW, y = textPosY - 40 }, -- right upper
          { x = scrW, y = tabY }, -- right lower
          { x = 0, y = tabY + 20 } -- left lower
        }

        surface.SetDrawColor(0, 0, 0, boxAlpha)
        draw.NoTexture()
        surface.DrawPoly(verts)
      else
        self:DrawGradient(
          GRADIENT_RIGHT, 0, textPosY - 80, scrW, textHeight + 160, Color(100, 100, 100, boxAlpha)
        )
      end

      self:OverrideMainFont(introTextBigFont)
        self:DrawSimpleText(
          cinematicInfoTitle,
          textPosX,
          textPosY,
          Color(colorInfo.r, colorInfo.g, colorInfo.b, cw.CinematicInfoAlpha),
          nil,
          nil,
          true
        )
      self:OverrideMainFont(false)

      if cinematicInfo.text then
        self:OverrideMainFont(introTextSmallFont)
          self:DrawSimpleText(
            cinematicIntroText,
            textPosX,
            textPosY + textHeight + 8,
            Color(colorWhite.r, colorWhite.g, colorWhite.b, cw.CinematicInfoAlpha),
            nil,
            nil,
            true
          )
        self:OverrideMainFont(false)
      end
    elseif cinematicInfo.text then
      self:OverrideMainFont(introTextSmallFont)
        self:DrawSimpleText(
          cinematicIntroText,
          textPosX,
          textPosY,
          Color(colorWhite.r, colorWhite.g, colorWhite.b, cw.CinematicInfoAlpha),
          nil,
          nil,
          true
        )
      self:OverrideMainFont(false)
    end
  end
end

do
  local boxColor = Color(0, 0, 0, 0)
  local edgeColor = Color(220, 220, 220, 0)

  -- Working out where the text goes takes an entity search and a trace, so for a door that is not moving it is
  -- only done once a second.
  local function GetDoorTextData(entity)
    local position = entity:GetPos()
    local angles = entity:GetAngles()
    local realTime = RealTime()
    local cached = entity.cwDoorTextData

    if !cached or realTime >= cached.expireTime or cached.doorPosition != position or cached.doorAngles != angles then
      cached = cw.entity:CalculateDoorTextPosition(entity)
      cached.doorPosition = position
      cached.doorAngles = angles
      cached.expireTime = realTime + 1
      entity.cwDoorTextData = cached
    end

    return cached
  end

  --- Draws a door's name and text on both sides of the door.
  --
  -- The text comes from the `GetDoorInfo` hook. Nothing is drawn for invisible doors, doors whose
  -- text position hits the world, or when the door is more than 256 units away.
  -- @param entity [Entity The door]
  -- @param eyePos [Vector Position of the viewer's eyes]
  -- @param eyeAngles [Angle Angles of the viewer's eyes; unused]
  -- @param font [String Font of the text]
  -- @param nameColor [Color Color of the door name]
  -- @param textColor [Color Color of the door text]
  function cw.core:DrawDoorText(entity, eyePos, eyeAngles, font, nameColor, textColor)
    local entityColor = entity:GetColor()

    if entityColor.a <= 0 or entity:IsEffectActive(EF_NODRAW) then
      return
    end

    local alpha = self:CalculateAlphaFromDistance(256, eyePos, entity:GetPos())

    if alpha <= 0 then
      return
    end

    local name = hook.Run('GetDoorInfo', entity, DOOR_INFO_NAME)
    local text = hook.Run('GetDoorInfo', entity, DOOR_INFO_TEXT)

    if !name and !text then
      return
    end

    local doorData = GetDoorTextData(entity)

    if doorData.hitWorld then
      return
    end

    local frontY = -26
    local backY = -26
    local nameWidth, nameHeight = self:GetCachedTextSize(font, name or '')
    local textWidth, textHeight = self:GetCachedTextSize(font, text or '')
    local boxAlpha = math.min(alpha, 255)

    if textWidth > nameWidth then
      nameWidth = textWidth
    end

    local scale = math.abs((doorData.width * 0.75) / nameWidth)
    local nameScale = math.min(scale, 0.05)
    local textScale = math.min(scale, 0.03)
    local longHeight = (nameHeight + textHeight + 8)
    local backX = -nameWidth / 2 - 32
    local boxWidth = nameWidth + 64

    boxColor.a = math.Clamp(boxAlpha, 0, 130)
    edgeColor.a = boxAlpha

    cam.Start3D2D(doorData.position, doorData.angles, 0.03)
      draw.RoundedBox(0, backX, frontY - 5, boxWidth, longHeight + 14, boxColor)
      draw.RoundedBox(0, backX, frontY - 8, boxWidth, 3, edgeColor)
      draw.RoundedBox(0, backX, frontY + longHeight + 8, boxWidth, 3, edgeColor)
    cam.End3D2D()

    cam.Start3D2D(doorData.positionBack, doorData.anglesBack, 0.03)
      draw.RoundedBox(0, backX, frontY - 5, boxWidth, longHeight + 14, boxColor)
      draw.RoundedBox(0, backX, frontY - 8, boxWidth, 3, edgeColor)
      draw.RoundedBox(0, backX, frontY + longHeight + 8, boxWidth, 3, edgeColor)
    cam.End3D2D()

    self:OverrideMainFont(font)

    if name then
      if !text or text == '' then
        nameColor = textColor or nameColor
      end

      cam.Start3D2D(doorData.position, doorData.angles, nameScale)
        frontY = self:DrawInfo(name, 0, frontY, nameColor, alpha, nil, nil, 3)
      cam.End3D2D()

      cam.Start3D2D(doorData.positionBack, doorData.anglesBack, nameScale)
        backY = self:DrawInfo(name, 0, backY, nameColor, alpha, nil, nil, 3)
      cam.End3D2D()
    end

    if text then
      cam.Start3D2D(doorData.position, doorData.angles, textScale)
        self:DrawInfo(text, 0, frontY, textColor, alpha, nil, nil, 3)
      cam.End3D2D()

      cam.Start3D2D(doorData.positionBack, doorData.anglesBack, textScale)
        self:DrawInfo(text, 0, backY, textColor, alpha, nil, nil, 3)
      cam.End3D2D()
    end

    self:OverrideMainFont(false)
  end
end

--- Returns whether the character menu is open.
-- @param isVisible=false [Boolean Also require the panel to be visible]
-- @return [Boolean Whether the menu is open, or `nil` when it is not]
function cw.core:IsCharacterScreenOpen(isVisible)
  if cw.character:IsPanelOpen() then
    local panel = cw.character:GetPanel()

    if isVisible then
      if panel then
        return panel:IsVisible()
      end
    else
      return panel != nil
    end
  end
end

--- Saves a table to `data/clockwork/schemas/<schema>/<fileName>.txt`.
--
-- Prints an error and saves nothing when the data is not a table.
-- @param fileName [String File name without extension; may contain folders]
-- @param data [Map The data to save]
-- @see cw.core:RestoreSchemaData
function cw.core:SaveSchemaData(fileName, data)
  if type(data) != 'table' then
    MsgC(
      Color(255, 100, 0, 255),
      "[CW:Kernel] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..
        ', table required.\n'
    )

    return
  end

  local path = 'clockwork/schemas/'..self:GetSchemaFolder()..'/'..fileName..'.txt'

  -- file.Write does not create missing directories.
  _file.CreateDir(string.match(path, '^(.*)/'))
  _file.Write(path, self:Serialize(data))
end

--- Deletes a schema data file.
-- @param fileName [String File name without extension]
function cw.core:DeleteSchemaData(fileName)
  _file.Delete('clockwork/schemas/'..self:GetSchemaFolder()..'/'..fileName..'.txt')
end

--- Returns whether a schema data file exists.
-- @param fileName [String File name without extension]
-- @return [Boolean Whether the file exists]
function cw.core:SchemaDataExists(fileName)
  return _file.Exists('clockwork/schemas/'..self:GetSchemaFolder()..'/'..fileName..'.txt', 'DATA')
end

--- Finds files in the schema data folder.
-- @param directory [String Search pattern inside the schema data folder, such as `'logs/*'`]
-- @return [List<String> File names, List<String> Folder names]
function cw.core:FindSchemaDataInDir(directory)
  return _file.Find('clockwork/schemas/'..self:GetSchemaFolder()..'/'..directory, 'DATA', 'namedesc')
end

--- Loads a table saved with `cw.core:SaveSchemaData`.
--
-- A file that cannot be read is deleted.
-- @param fileName [String File name without extension]
-- @param failSafe=nil [Any Value returned when there is no data; defaults to an empty table]
-- @return [Map The data]
function cw.core:RestoreSchemaData(fileName, failSafe)
  if !fileName then return failSafe end

  if self:SchemaDataExists(fileName) then
    local data = _file.Read('clockwork/schemas/'..self:GetSchemaFolder()..'/'..fileName..'.txt', 'DATA')

    if data then
      local bSuccess, value = pcall(self.Deserialize, self, data)

      if bSuccess and value != nil then
        return value
      else
        if value then
          MsgC(
            Color(255, 100, 0, 255),
            "[CW:Kernel] '"..fileName.."' schema data has failed to restore.\n"..value..'\n'
          )
        end

        self:DeleteSchemaData(fileName)
      end
    end
  end

  if failSafe != nil then
    return failSafe
  else
    return {}
  end
end

--- Loads a table saved with `cw.core:SaveClockworkData`.
--
-- A file that cannot be read is deleted.
-- @param fileName [String File name without extension]
-- @param failSafe=nil [Any Value returned when there is no data; defaults to an empty table]
-- @return [Map The data]
function cw.core:RestoreClockworkData(fileName, failSafe)
  if self:ClockworkDataExists(fileName) then
    local data = _file.Read('clockwork/'..fileName..'.txt', 'DATA')

    if data then
      local bSuccess, value = pcall(self.Deserialize, self, data)

      if bSuccess and value != nil then
        return value
      else
        MsgC(
          Color(255, 100, 0, 255),
          "[CW:Kernel] '"..fileName.."' clockwork data has failed to restore.\n"..tostring(value)..'\n'
        )

        self:DeleteClockworkData(fileName)
      end
    end
  end

  if failSafe != nil then
    return failSafe
  else
    return {}
  end
end

--- Saves a table to `data/clockwork/<fileName>.txt`.
--
-- Prints an error and saves nothing when the data is not a table.
-- @param fileName [String File name without extension; may contain folders]
-- @param data [Map The data to save]
-- @see cw.core:RestoreClockworkData
function cw.core:SaveClockworkData(fileName, data)
  if type(data) != 'table' then
    MsgC(
      Color(255, 100, 0, 255),
      "[CW:Kernel] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..
        ', table required.\n'
    )

    return
  end

  local path = 'clockwork/'..fileName..'.txt'

  -- file.Write does not create missing directories.
  _file.CreateDir(string.match(path, '^(.*)/'))
  _file.Write(path, self:Serialize(data))
end

--- Returns whether a framework data file exists.
-- @param fileName [String File name without extension]
-- @return [Boolean Whether the file exists]
function cw.core:ClockworkDataExists(fileName)
  return _file.Exists('clockwork/'..fileName..'.txt', 'DATA')
end

--- Deletes a framework data file.
-- @param fileName [String File name without extension]
function cw.core:DeleteClockworkData(fileName)
  _file.Delete('clockwork/'..fileName..'.txt')
end

--- Runs a framework command through the `cwCmd` console command.
--
-- ```
-- cw.core:RunCommand('InvAction', 'use', itemTable.uniqueID, itemTable.itemID)
-- ```
--
-- @param command [String Name of the command]
-- @param ... [Any Arguments of the command]
function cw.core:RunCommand(command, ...)
  RunConsoleCommand('cwCmd', command, ...)
end

--- Returns whether the local player is in the character menu.
-- @return [Boolean `true` while the menu is open or has not been created yet]
function cw.core:IsChoosingCharacter()
  if cw.character:GetPanel() then
    return cw.character:IsPanelOpen()
  else
    return true
  end
end

--- Loads the schema with `cw.core:LoadSchema` when a schema folder is set.
-- @warning [Internal] Called by the kernel while the gamemode loads.
function cw.core:IncludeSchema()
  local schemaFolder = self:GetSchemaFolder()

  if schemaFolder and type(schemaFolder) == 'string' then
    self:LoadSchema()
  end
end

--- Opens a modal dialog that asks for a number with a slider.
--
-- ```
-- Derma_NumRequest('Volume', 'Choose a volume.', 50, 0, 100, 0, function(value)
--   RunConsoleCommand('volume', value / 100)
-- end)
-- ```
--
-- @param strTitle [String Window title]
-- @param strText [String Message above the slider]
-- @param nDefaultValue=0 [Number Initial value]
-- @param min=0 [Number Minimum value]
-- @param max=256 [Number Maximum value]
-- @param dec=0 [Number Number of decimals]
-- @param fnEnter [Function Called with the value when the player confirms]
-- @param fnCancel=nil [Function Called with the value when the player cancels]
-- @param strButtonText='#DermaRequest_OK' [String Text of the confirm button]
-- @param strButtonCancelText='#DermaRequest_confirmQuery_Cancel' [String Text of the cancel button]
-- @return [Panel The dialog window]
function Derma_NumRequest(
  strTitle,
  strText,
  nDefaultValue,
  min,
  max,
  dec,
  fnEnter,
  fnCancel,
  strButtonText,
  strButtonCancelText
)
  local Window = vgui.Create('DFrame')
  Window:SetTitle(strTitle or 'Message Title (First Parameter)')
  Window:SetDraggable(false)
  Window:ShowCloseButton(false)
  Window:SetBackgroundBlur(true)
  Window:SetDrawOnTop(true)

  local InnerPanel = vgui.Create('DPanel', Window)
  InnerPanel:SetPaintBackground(false)

  local Text = vgui.Create('DLabel', InnerPanel)
  Text:SetText(strText or 'Message Text (Second Parameter)')
  Text:SizeToContents()
  Text:SetContentAlignment(5)
  Text:SetTextColor(Color(255, 255, 255))

  local NumSlider = vgui.Create('DNumSlider', InnerPanel)
  NumSlider:SetValue(nDefaultValue or 0)
  NumSlider:SetMin(min or 0)
  NumSlider:SetMax(max or 256)
  NumSlider:SetDecimals(dec or 0)

  local ButtonPanel = vgui.Create('DPanel', Window)
  ButtonPanel:SetTall(30)
  ButtonPanel:SetPaintBackground(false)

  local Button = vgui.Create('DButton', ButtonPanel)
  Button:SetText(strButtonText or '#DermaRequest_OK')
  Button:SizeToContents()
  Button:SetTall(20)
  Button:SetWide(Button:GetWide() + 20)
  Button:SetPos(5, 5)
  Button.DoClick = function() Window:Close() fnEnter(NumSlider:GetValue()) end

  local ButtonCancel = vgui.Create('DButton', ButtonPanel)
  ButtonCancel:SetText(strButtonCancelText or '#DermaRequest_confirmQuery_Cancel')
  ButtonCancel:SizeToContents()
  ButtonCancel:SetTall(20)
  ButtonCancel:SetWide(Button:GetWide() + 20)
  ButtonCancel:SetPos(5, 5)
  ButtonCancel.DoClick = function() Window:Close() if fnCancel then fnCancel(NumSlider:GetValue()) end end
  ButtonCancel:MoveRightOf(Button, 5)

  ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10)

  local w, h = Text:GetSize()
  w = math.max(w, 400)

  Window:SetSize(w + 50, h + 25 + 75 + 10)
  Window:Center()

  InnerPanel:StretchToParent(5, 25, 5, 45)

  Text:StretchToParent(5, 5, 5, 35)

  NumSlider:StretchToParent(5, nil, 5, nil)
  NumSlider:AlignBottom(5)

  ButtonPanel:CenterHorizontal()
  ButtonPanel:AlignBottom(8)

  Window:MakePopup()
  Window:DoModal()

  return Window
end

local entityMeta = FindMetaTable('Entity')
local weaponMeta = FindMetaTable('Weapon')
local playerMeta = FindMetaTable('Player')

entityMeta.ClockworkFireBullets = entityMeta.ClockworkFireBullets or entityMeta.FireBullets
weaponMeta.OldGetPrintName = weaponMeta.OldGetPrintName or weaponMeta.GetPrintName
playerMeta.SteamName = playerMeta.SteamName or playerMeta.Name

--- Fires bullets from the entity after letting hooks adjust them.
--
-- Runs `PlayerAdjustBulletInfo` for players and `EntityFireBullets` for every entity, then calls
-- the engine method, kept as `Entity:ClockworkFireBullets`.
-- @param bulletInfo [Map The bullet table, which hooks may change]
-- @param ... [Any Extra arguments for the engine method]
function entityMeta:FireBullets(bulletInfo, ...)
  if self:IsPlayer() then
    hook.Run('PlayerAdjustBulletInfo', self, bulletInfo)
  end

  hook.Run('EntityFireBullets', self, bulletInfo)
  return self:ClockworkFireBullets(bulletInfo, ...)
end

--- Returns the weapon's print name, using its item's name when it belongs to an item.
--
-- Weapons without an item use the engine method, kept as `Weapon:OldGetPrintName`.
-- @return [String The print name]
function weaponMeta:GetPrintName()
  local itemTable = item.GetByWeapon(self)

  if itemTable then
    return cw.lang:TranslateText(itemTable.PrintName or itemTable.name)
  else
    return self:OldGetPrintName()
  end
end

--- Returns the player's character name.
--
-- Uses the `NameOverride` net variable unless `bRealName` is set, then the character name, and
-- falls back to the Steam name (`Player:SteamName`) when there is no character.
-- @param bRealName=false [Boolean Ignore the name override]
-- @return [String The name]
-- @alias [Player.GetName]
-- @alias [Player.Nick]
function playerMeta:Name(bRealName)
  local name = (!bRealName and self:GetNetVar('NameOverride', nil)) or self:GetDTString(STRING_NAME)

  if !name or name == '' then
    return self:SteamName()
  else
    return name
  end
end

--- Returns the player's animation playback rate.
-- @return [Number The rate, `1` by default]
function playerMeta:GetPlaybackRate()
  return self.cwPlaybackRate or 1
end

--- Returns whether the player is in noclip outside a vehicle.
-- @return [Boolean Whether the player is noclipping]
function playerMeta:IsNoClipping()
  return cw.player:IsNoClipping(self)
end

--- Returns whether the player is running.
--
-- The player must be alive, standing, out of a vehicle, not ragdolled, and flagged as running
-- by the server.
-- @param bNoWalkSpeed=false [Boolean Do not require moving at least at walk speed]
-- @return [Boolean Whether the player is running]
function playerMeta:IsRunning(bNoWalkSpeed)
  if self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching()
  and self:GetDTBool(BOOL_ISRUNNING) then
    if self:GetVelocity():Length() >= self:GetWalkSpeed()
    or bNoWalkSpeed then
      return true
    end
  end

  return false
end

--- Returns the player's forced animation.
-- @return [Map Table with the `animation` field, or `nil` when no animation is forced]
function playerMeta:GetForcedAnimation()
  local forcedAnimation = self:GetNetVar('ForceAnim')

  -- The variable is not set until the server has spawned the player.
  if forcedAnimation and forcedAnimation != 0 then
    return {
      animation = forcedAnimation
    }
  end
end

--- Returns whether the player is ragdolled; see `cw.player:IsRagdolled`.
-- @param exception=nil [Number A `RAGDOLL_*` state that does not count]
-- @param entityless=false [Boolean Check the state even when there is no ragdoll entity]
-- @return [Boolean Whether the player is ragdolled]
function playerMeta:IsRagdolled(exception, entityless)
  return cw.player:IsRagdolled(self, exception, entityless)
end

--- Does nothing; shared variables can only be set on the server.
-- @param key [String Name of the variable]
-- @param value [Any The value]
function playerMeta:SetSharedVar(key, value) end

--- Returns a networked variable of the player.
-- @param key [String Name of the variable]
-- @param default=nil [Any Value returned when the variable is not set]
-- @return [Any The value]
function playerMeta:GetSharedVar(key, default)
  return self:GetNetVar(key, default)
end

--- Returns whether the player has fully loaded and has a character.
-- @return [Boolean The `Initialized` net variable, or `nil` for invalid players]
function playerMeta:HasInitialized()
  if IsValid(self) then
    return self:GetNetVar('Initialized')
  end
end

--- Returns the gender of the player's character.
-- @return [String `GENDER_FEMALE` or `GENDER_MALE`]
function playerMeta:GetGender()
  if self:GetNetVar('Gender') == 1 then
    return GENDER_FEMALE
  else
    return GENDER_MALE
  end
end

--- Returns the name of the player's faction.
-- @return [String The faction name, or `'Unknown'`]
function playerMeta:GetFaction()
  local factionTable = faction.FindByID(self:GetNetVar('Faction'))

  if factionTable then
    return factionTable.name
  else
    return 'Unknown'
  end
end

--- Returns what the player's class calls its wages.
-- @return [String The wages name]
function playerMeta:GetWagesName()
  return cw.player:GetWagesName(self)
end

--- Returns a networked player data value.
--
-- The default is returned when the value is not set, the key is not registered player data, or it
-- is player-only and the player is not the local player.
-- @param key [String The data key]
-- @param default=nil [Any Fallback value]
-- @return [Any The value]
-- @see Player:GetCharacterData
function playerMeta:GetData(key, default)
  local playerData = cw.player:GetPlayerData(key)

  if playerData and (!playerData.playerOnly or self == cw.client) then
    return self:GetNetVar(key, default)
  end

  return default
end

--- Returns a networked character data value.
--
-- The default is returned when the value is not set, the key is not registered character data
-- (see `cw.player:AddCharacterData`), or it is player-only and the player is not the local player.
-- @param key [String The data key]
-- @param default=nil [Any Fallback value]
-- @return [Any The value]
function playerMeta:GetCharacterData(key, default)
  local characterData = cw.player:GetCharacterData(key)

  if characterData and (!characterData.playerOnly or self == cw.client) then
    return self:GetNetVar(key, default)
  end

  return default
end

--- Returns the player's maximum armor.
-- @param armor [Number Unused]
-- @return [Number The `MaxAP` net variable, or `100` when it is not positive]
function playerMeta:GetMaxArmor(armor)
  local maxArmor = self:GetNetVar('MaxAP') or 100

  if maxArmor > 0 then
    return maxArmor
  else
    return 100
  end
end

--- Returns the player's maximum health.
-- @param health [Number Unused]
-- @return [Number The `MaxHP` net variable, or `100` when it is not positive]
function playerMeta:GetMaxHealth(health)
  local maxHealth = self:GetNetVar('MaxHP') or 100

  if maxHealth > 0 then
    return maxHealth
  else
    return 100
  end
end

--- Returns the player's ragdoll state.
-- @return [Number A `RAGDOLL_*` constant]
function playerMeta:GetRagdollState()
  return self:GetDTInt(INT_RAGDOLLSTATE)
end

--- Returns the player's ragdoll entity.
-- @return [Entity The ragdoll, or `nil` when the player is not ragdolled]
function playerMeta:GetRagdollEntity()
  return cw.player:GetRagdollEntity(self)
end

--- Returns the player's rank within their faction; see `cw.player:GetFactionRank`.
-- @param character=nil [Character Character to check instead of the current one]
-- @return [String The rank name, or `nil` when the faction has no ranks, Map The rank table]
function playerMeta:GetFactionRank(character)
  return cw.player:GetFactionRank(self, character)
end

--- Returns the icon shown next to the player in chat.
-- @return [String Path of the icon material]
function playerMeta:GetChatIcon()
  return cw.player:GetChatIcon(self)
end

playerMeta.GetName = playerMeta.Name
playerMeta.Nick = playerMeta.Name
