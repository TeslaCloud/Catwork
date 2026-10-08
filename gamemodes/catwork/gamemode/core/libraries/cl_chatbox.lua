--[[
  © 2016 TeslaCloud Studios LLC.
  For internal use only.
--]]

if chatbox then return end

local chatFontSize = 19
local chatMessagePadding = chatFontSize * 1.17

if !plugin then
  include('catwork/gamemode/core/libraries/sh_plugin.lua')
end

if !cw.fonts then
  include('catwork/gamemode/core/libraries/cl_fonts.lua')
end

if !cdraw then
  include('catwork/gamemode/core/libraries/cl_clouddraw.lua')
end

cw.fonts:Add('cwChatBoxFont', {
  font		= 'Roboto',
  size		= chatFontSize,
  weight = 500,
  extended = true
})

cw.fonts:Add('cwChatBoxFontBold', {
  font		= 'Roboto',
  size		= chatFontSize,
  weight = 1000,
  extended = true
})

cw.fonts:Add('cwChatBoxSyntax', {
  font		= 'Roboto',
  size		= 20,
  weight = 500,
  extended = true
})

library.New('chatbox', _G)

local history = chatbox.history or {}
local display = chatbox.display or {}
local filters = chatbox.filters or {}
local types = chatbox.types or {}
local emotes = chatbox.emotes or {}
local codes = chatbox.codes or {}

chatbox.history 	= history -- Entire chat history. Last X meesages, configurable.
chatbox.display		= display -- Pre-parsed lines that are currently being drawn.
chatbox.filters 	= filters -- Table that stores filter data.
chatbox.types = types -- Table that stores message types data.
chatbox.emotes = emotes -- Table that stores emotes data.
chatbox.codes = codes -- Table that stores BB-Codes data.

chatbox.oldAddText = chatbox.oldAddText or chat.AddText

--- Adds a message to the local player's chat box, replacing the engine's `chat.AddText`.
--
-- Runs the `ChatAddText` hook with the arguments, then passes them to `chatbox.AddText`.
-- The original function is kept as `chatbox.oldAddText`.
-- @param ... [Any Strings, `Color`s, players and message option tables, as accepted by `chatbox.AddText`]
function chat.AddText(...)
  hook.Run('ChatAddText', ...)

  chatbox.AddText(...)
end

--- Returns the number of lines in the chat history, counting wrapped lines.
-- @return [Number Total line count of the stored messages]
function chatbox.GetLineCount()
  local lines = 0

  for k, v in ipairs(history) do
    lines = lines + (v.lineCount or 1)
  end

  return lines
end

--[[
  Sizes and Configuration
--]]
chatbox.width = chatbox.width or math.min(ScrW() / 2.8, 550)
chatbox.height = chatbox.height or 430
chatbox.x = chatbox.x or 4
chatbox.y = ScrH() - chatbox.height - 36
chatbox.maxLength = chatbox.maxLength or 512
chatbox.curAlpha = chatbox.curAlpha or 255
chatbox.moveDuration = chatbox.moveDuration or 0.25

--- Moves the chat box to a position on the screen.
--
-- The panel slides to the new position when it exists; otherwise the position is
-- used when it is created.
-- @param x [Number Horizontal position]
-- @param y [Number Vertical position]
-- @param duration=0.25 [Number Length of the move animation in seconds; defaults to `chatbox.moveDuration`]
-- @see chatbox.ResetCustomPos
function chatbox.SetCustomPos(x, y, duration)
  chatbox.x = x
  chatbox.y = y

  if chatbox.panel then
    chatbox.panel:MoveTo(x, y, duration or chatbox.moveDuration)
  end
end

--- Resizes the chat box.
--
-- The panel animates to the new size when it exists; otherwise the size is used
-- when it is created.
-- @param w [Number New width]
-- @param h [Number New height]
-- @param duration=0.25 [Number Length of the resize animation in seconds; defaults to `chatbox.moveDuration`]
function chatbox.SetCustomSize(w, h, duration)
  chatbox.width = w
  chatbox.height = h

  if chatbox.panel then
    chatbox.panel:SizeTo(w, h, duration or chatbox.moveDuration)
  end
end

--- Moves the chat box back to its default position in the bottom left corner.
-- @see chatbox.SetCustomPos
function chatbox.ResetCustomPos()
  chatbox.SetCustomPos(4, ScrH() - chatbox.height - 36)
end

--[[
  Filters and Types
--]]

--- Registers a chat filter.
--
-- A filter is called with the message data before it is parsed and sets the
-- message's display options (`drawAvatar`, `drawTime`, `icon`, `rich`, `translate`,
-- `type`...). Does nothing when `id` is empty.
--
-- ```
-- chatbox.AddFilter('radio', function(messageData)
--   messageData.isPlayerMessage = true
--   messageData.type = 'radio'
-- end)
-- ```
--
-- @param id [String Unique ID of the filter, set as `filter` on messages]
-- @param callback [Function Called with the message data `Map` to change]
-- @see chatbox.AddType
function chatbox.AddFilter(id, callback)
  if !id or id == '' then return end

  filters[id] = callback
end

--- Registers a chat message type.
--
-- A type is called with the message data after its filter and sets its colors
-- and prefix (`textColor`, `prefix`, `prefixColor`, `nameColorOverride`...).
-- Does nothing when `id` is empty.
-- @param id [String Unique ID of the type, set as `type` on messages]
-- @param callback [Function Called with the message data `Map` to change]
-- @see chatbox.AddFilter
function chatbox.AddType(id, callback)
  if !id or id == '' then return end

  types[id] = callback
end

--- Returns the callback of a chat filter.
-- @param id [String Unique ID of the filter]
-- @return [Function The filter, the `default` filter if `id` is unknown, or `nil` if `id` is empty]
function chatbox.GetFilter(id)
  if !id or id == '' then return end

  if filters[id] then
    return filters[id]
  else
    return filters['default']
  end
end

--- Returns the callback of a chat message type.
-- @param id [String Unique ID of the type]
-- @return [Function The type, or `nil` if it is unknown or `id` is empty]
function chatbox.GetType(id)
  if !id or id == '' then return end

  if types[id] then
    return types[id]
  end
end

--[[
  Message table prototype:
  {
    text = string, -- text of the message
    playerName = string, -- name of the player who sent this message
    sender = plyObject, -- player object
    filter = string, -- filter id
    type = string, -- message type id
    icon = string, -- path to icon material. "" = no icon
    time = uint, -- time when the message has been added
    drawAvatar = bool, -- draw avatar or not
    drawTime = bool, -- draw time or not
    drawModel = bool, -- draw player model panel
    isPlayerMessage = bool, -- was this message sent by a valid player?
    sizeOverride = int, -- font size override
    rich = bool, -- force the bbcode parser on/off
    translate = bool -- whether or not to translate the message using #phrases system
  }

  display table prototype:
chatbox.display[1] = {
  [1] = { 0, LocalPlayer(), Color(255, 255, 255), "[SendTime:"..os.time().."]", "[icon:icon16/shield.png]",
  Color(255, 0, 0), "[SenderAvatar]", "[OOC] ", Color(255, 255, 255), "Mr. Meow: ", "Test message Test Message"},
  [2] = { 20, Color(255, 255, 255), "It is hardcoded btw. Render testing." }
}
--]]

do
  chatbox.AddFilter('default', function(messageData)
    messageData.drawAvatar = messageData.drawAvatar or false
    messageData.drawTime = messageData.drawTime or true
    messageData.drawModel = messageData.drawModel or false
    messageData.isPlayerMessage = messageData.isPlayerMessage or false
    messageData.rich = messageData.rich or true
    messageData.translate = messageData.translate or true
    messageData.type = messageData.type or 'default'
  end)

  chatbox.AddFilter('system', function(messageData)
    -- system messages define this table themselves
    messageData.type = messageData.type or 'system'
  end)

  chatbox.AddFilter('ooc', function(messageData)
    messageData.drawAvatar = true
    messageData.drawTime = true
    messageData.drawModel = false
    messageData.isPlayerMessage = true
    messageData.icon = cw.player:GetChatIcon(messageData.sender)
    messageData.rich = true
    messageData.translate = false
    messageData.type = 'ooc'
  end)

  chatbox.AddFilter('admin', function(messageData)
    messageData.drawAvatar = true
    messageData.drawTime = true
    messageData.drawModel = false
    messageData.isPlayerMessage = true
    messageData.icon = false
    messageData.rich = true
    messageData.translate = false
    messageData.type = 'admin'
  end)

  chatbox.AddFilter('ic', function(messageData)
    messageData.drawAvatar = false
    messageData.drawTime = true
    messageData.drawModel = true
    messageData.isPlayerMessage = true
    messageData.icon = ''
    messageData.rich = false
    messageData.translate = false
    messageData.type = 'ic'
  end)

  chatbox.AddFilter('looc', function(messageData)
    messageData.drawAvatar = false
    messageData.drawTime = true
    messageData.drawModel = false
    messageData.isPlayerMessage = true
    messageData.icon = cw.player:GetChatIcon(messageData.sender)
    messageData.rich = true
    messageData.translate = false
    messageData.type = 'looc'
  end)

  chatbox.AddFilter('player_events', function(messageData)
    messageData.drawAvatar = false
    messageData.drawTime = messageData.drawTime or true
    messageData.drawModel = false

    if messageData.icon == nil then
      messageData.icon = 'icon16/lightning.png'
    end

    messageData.rich = true
    messageData.translate = messageData.translate or true
    messageData.type = 'player_events'
  end)
end

do
  chatbox.AddType('default', function(messageData)
    messageData.textColor = messageData.textColor or Color(255, 255, 255)
  end)

  chatbox.AddType('system', function(messageData)
    messageData.textColor = messageData.textColor or Color(255, 255, 255)
  end)

  chatbox.AddType('ooc', function(messageData)
    messageData.textColor = Color(255, 255, 255)
    messageData.prefix = '[OOC] '
    messageData.prefixColor = Color(255, 20, 20)
  end)

  chatbox.AddType('admin', function(messageData)
    messageData.textColor = messageData.textColor or Color('#F0AAAA')
    messageData.prefix = messageData.prefix or '#Chatbox_AdminPrefix '
    messageData.prefixColor = Color(255, 20, 20)
  end)

  chatbox.AddType('pm', function(messageData)
    messageData.prefix = '[PM] '
    messageData.prefixColor = Color('#65DBAC')
  end)

  chatbox.AddType('ic', function(messageData)
    messageData.textColor = messageData.textColor or Color(255, 255, 200)
  end)

  chatbox.AddType('player_events', function(messageData)
    messageData.textColor = messageData.textColor or Color('#EE4343')
    messageData.prefix = messageData.prefix or nil
    messageData.prefixColor = messageData.prefixColor or Color(255, 20, 20)
  end)

  chatbox.AddType('looc', function(messageData)
    messageData.textColor = Color(255, 255, 200)
    messageData.nameColorOverride = Color(255, 255, 200)
    messageData.prefix = '[LOOC] '
    messageData.prefixColor = Color(255, 20, 75)
  end)
end

--[[
  Emotes and BB-Codes
--]]

--- Registers a BB-code tag that can be used in chat messages.
--
-- The callback receives the value after `=` in the opening tag and the text up to
-- the next tag, and returns the object inserted into the parsed line in place of
-- the tag (usually a `Color`). It may return a replacement for the text as a second value.
--
-- ```
-- chatbox.AddBBCode('red', function(value, text)
--   return Color(255, 0, 0)
-- end)
-- ```
--
-- @param id [String Name of the tag, such as `'color'` for `[color=...]`]
-- @param callback [Function Called with the tag value and the following text]
-- @param requireRich=true [Boolean Whether the tag is only parsed in rich messages]
function chatbox.AddBBCode(id, callback, requireRich)
  if !id or id == '' then return end

  codes[id] = codes[id] or {}
  codes[id].Callback = callback
  codes[id].requireRich = requireRich or true
end

--- Returns the callback of a BB-code tag.
-- @param id [String Name of the tag]
-- @return [Function The tag's callback, or `nil` if it is not registered]
function chatbox.GetBBCode(id)
  if codes[id] then
    return codes[id].Callback
  end
end

chatbox.LastBBCode = chatbox.LastBBCode or nil

--- Replaces the BB-code tags in a line of text with the objects their callbacks return.
--
-- Changes `line` in place, splitting each string around its tags. The result of the
-- last tag is stored in `chatbox.LastBBCode` and inserted at the start of the next
-- parsed line, so a color carries over wrapped lines.
-- @param line [List Strings and other objects making up a line]
-- @param rich [Boolean Whether tags that require rich messages are parsed]
function chatbox.ParseBBCodes(line, rich)
  if chatbox.LastBBCode then
    table.insert(line, 1, chatbox.LastBBCode)
  end

  for k, v in ipairs(line) do
    if isstring(v) then
      local whole = v
      local length = whole:utf8len()
      local hits = string.FindAll(v, '%b[]')
      local rm = false
      local nextInsert = 0
      local prevOffset = 0

      if #hits > 0 then
        for i, hit in ipairs(hits) do
          local text = hit[1]
          local wS, wE = hit[2], hit[3]
          local eq = text:find('=')
          local code = ''
          local eqWhat = ''
          local textValue = ''

          wS = wS - prevOffset
          wE = wE - prevOffset

          if eq then
            code = text:utf8sub(2, eq - 1)
            eqWhat = text:utf8sub(eq + 1, text:utf8len() - 1)
          else
            code = text:utf8sub(2, text:utf8len() - 1)
          end

          if codes[code] then
            if !codes[code].requireRich or rich then
              if !rm then
                table.remove(line, k)
                nextInsert = k
                rm = true
              end

              local closure = { whole:find('%[', wE + 1) }
              local closurePos = closure[1]
              local oldTextLength = 0

              if closurePos then
                textValue = whole:utf8sub(wE + 1, closure[1] - 1)
              else
                textValue = whole:utf8sub(wE + 1, length)
                closurePos = length
              end

              oldTextLength = textValue:utf8len()

              local result, newTextValue = chatbox.GetBBCode(code)(eqWhat, textValue)

              if isstring(newTextValue) then
                textValue = newTextValue
              end

              chatbox.LastBBCode = result

              if !whole:StartsWith('[') then
                table.insert(line, nextInsert, whole:utf8sub(1, wS - 1))
                nextInsert = nextInsert + 1
              end

              if newTextValue then
                length = length + (textValue:utf8len() - oldTextLength)
                wS = wS + (textValue:utf8len() - oldTextLength)
                wE = wE + (textValue:utf8len() - oldTextLength)
              end

              if closurePos != length then
                whole = textValue..whole:utf8sub(closurePos, length)
              else
                whole = textValue
              end

              table.insert(line, nextInsert, result)
              nextInsert = nextInsert + 1

              if i == #hits then
                table.insert(line, nextInsert, whole)
                nextInsert = nextInsert + 1
                break
              end
            end
          end

          prevOffset = wE
        end
      end
    end
  end
end

do
  chatbox.AddBBCode('color', function(code, text)
    local exploded = string.Explode(',', code)

    for k, v in ipairs(exploded) do
      exploded[k] = v:Replace(' ', '')
    end

    if !exploded[2] then
      local code = exploded[1]

      return Color(code)
    else
      return Color(
        (tonumber(exploded[1]) or 255),
        (tonumber(exploded[2]) or 255),
        (tonumber(exploded[3]) or 255),
        (tonumber(exploded[4]) or 255)
      )
    end
  end)

  chatbox.AddBBCode('/color', function(code, text)
    return Color(255, 255, 255)
  end)
end

--[[
  Text parser and renderer
--]]

--- Splits a message's text into pieces that fit the width of the chat box.
--
-- Translates the text first when the message has `translate` set and parses its
-- BB-codes. Words longer than a line are broken with a dash.
-- @param msgData [Map The message data; reads `text`, `translate`, `rich` and `data.sizeMultiplier`]
-- @param maxWidth [Number Width of a line in pixels]
-- @param initWidth=0 [Number Width already taken on the first line by the time, icon and name]
-- @return [List Strings and BB-code objects, with `'std::endl'` marking each line break]
function chatbox.WrapText(msgData, maxWidth, initWidth)
  local text = msgData.text
  local wrapped = {}

  if msgData.translate then
    -- Attempt to translate the text before parsing.
    -- System messages often contain phrases, and line wrapping won't work unless we translate the
    -- phrases, duh.
    text = cw.lang:TranslateText(text)
  end

  local parsed = { text }
  chatbox.ParseBBCodes(parsed, msgData.rich)

  local fontSize = chatFontSize * ((msgData.data and msgData.data.sizeMultiplier) or 1)
  local font = cw.fonts:GetSize('cwChatBoxFont', fontSize)
  local curWidth = initWidth or 0
  local curText = ''
  local spaceWidth = util.GetTextSize(font, ' ')
  local dashWidth = util.GetTextSize(font, '-')

  for key, val in ipairs(parsed) do
    if isstring(val) then
      local exploded = string.Explode(' ', val)

      for k, v in ipairs(exploded) do
        local w, h = util.GetTextSize(font, v)

        -- if word's width is less than the remaining width
        if (w + spaceWidth) < (maxWidth - curWidth) then
          curText = curText..v..' '
          curWidth = curWidth + w + spaceWidth
        -- if it's exactly the width that's left
        elseif (w + spaceWidth) == (maxWidth - curWidth) or w == (maxWidth - curWidth) then
          curText = curText..v
          table.insert(wrapped, curText)
          table.insert(wrapped, 'std::endl')
          curText = ''
          curWidth = 0
        -- if it's more
        else
          -- if the word doesn't fit in a single line
          if w > maxWidth then
            local characters = string.Explode('', v)
            local curWord = ''
            local wordWide = 0

            for k2, v2 in ipairs(characters) do
              local w, h = util.GetTextSize(font, v2)

              -- if we don't have enough characters to fill in the entire line
              if (wordWide + w + dashWidth) < (maxWidth - curWidth) then
                curWord = curWord..v2
                wordWide = wordWide + w
              -- if we do
              else
                curWord = curWord..v2..'-'
                curText = curText..curWord
                table.insert(wrapped, curText)
                table.insert(wrapped, 'std::endl')
                wordWide = 0
                curWidth = 0
                curText = ''
                curWord = ''
              end
            end

            if curWord != '' then
              curText = curWord..' '
            end

          -- if it does
          else
            table.insert(wrapped, curText)
            table.insert(wrapped, 'std::endl')
            curText = v..' '
            curWidth = w + spaceWidth
          end
        end
      end

      table.insert(wrapped, curText)
      curText = ''
    else
      table.insert(wrapped, val)
    end
  end

  -- insert the leftover text.
  if curText != '' then
    table.insert(wrapped, 'std::endl')
    table.insert(wrapped, curText)
  end

  return wrapped
end

g_DisplayY = g_DisplayY or 0

--- Turns a message into the lines drawn by the chat box.
--
-- Applies the message's filter (`'ooc'` when unset) and type, then builds the time,
-- icon, avatar, prefix and sender name parts and wraps the text. Runs the
-- `ChatboxPreProcess` and `PreChatboxParse` hooks with the message data and
-- `PostChatboxParse` with the result. The message type must be registered with
-- `chatbox.AddType`, or the call errors.
-- @param messageData [Map The message data received from the server]
-- @return [List<List> The lines; each starts with its vertical offset, followed by the sender,
-- `Color`s, strings and marker strings such as `'[SenderAvatar]'`]
function chatbox.ParseText(messageData)
  local parsed = {}
  local msgWidth = 0

  messageData.filter = messageData.filter or 'ooc'

  hook.Run('ChatboxPreProcess', messageData)

  chatbox.GetFilter(messageData.filter)(messageData)
  chatbox.GetType(messageData.type)(messageData)

  hook.Run('PreChatboxParse', messageData)

  parsed[1] = parsed[1] or {}
  table.insert(parsed[1], g_DisplayY)

  if messageData.isPlayerMessage and IsValid(messageData.sender) then
    table.insert(parsed[1], messageData.sender)
  end

  if messageData.drawTime then
    -- I know this is STUPID as heck, but for some reason
    -- if we don't store the value beforehand Lua will throw
    -- the following error:
    -- [ERROR] gamemodes/clockwork/framework/libraries/client/cl_chatbox.lua:474: wrong number of arguments to 'insert'
    local color = Color(255, 255, 255)
    table.insert(parsed[1], color) -- this was line 474 from the error btw.
    table.insert(parsed[1], '[SendTime:'..messageData.time..']')
    table.insert(parsed[1], ' - ')
    msgWidth = msgWidth + 50
  end

  if messageData.icon and messageData.icon != '' then
    table.insert(parsed[1], '[icon:'..messageData.icon..']')
    msgWidth = msgWidth + 20
  end

  if messageData.drawAvatar and IsValid(messageData.sender) then
    -- The avatar itself is an engine AvatarImage painted by the chat box panel (see GetAvatarPanel).
    table.insert(parsed[1], '[SenderAvatar]')
    msgWidth = msgWidth + 20
  end

  local fontSize = chatFontSize * ((messageData.data and messageData.data.sizeMultiplier) or 1)
  local font = cw.fonts:GetSize('cwChatBoxFont', fontSize)

  if messageData.prefix then
    -- Prefix may contain phrases!
    messageData.prefix = cw.lang:TranslateText(messageData.prefix)

    table.insert(parsed[1], messageData.prefixColor)
    table.insert(parsed[1], messageData.prefix)

    local wide = util.GetTextSize(font, messageData.prefix)
    msgWidth = msgWidth + wide
  end

  if messageData.isPlayerMessage then
    if IsValid(messageData.sender) then
      messageData.playerTeam = messageData.sender:Team()

      if (messageData.filter == 'ic' or messageData.fakeName) and !messageData.forceName then
        local plyName = cw.player:GetName(messageData.sender)

        if plyName:utf8len() >= 32 then
          messageData.playerName = '['..plyName:utf8sub(1, 32)..'...]'
        else
          messageData.playerName = plyName
        end
      end
    end

    if !isstring(messageData.playerName) then
      messageData.playerName =
        (IsValid(messageData.sender) and messageData.sender:Name()) or L('#Chatbox_UnknownPlayer')
    end

    if messageData.filter != 'ic' and messageData.playerTeam and !messageData.noStyling then
      if messageData.nameColorOverride then
        table.insert(parsed[1], messageData.nameColorOverride)
      else
        table.insert(parsed[1], _team.GetColor(messageData.playerTeam))
      end
    else
      table.insert(parsed[1], messageData.textColor)
    end

    if messageData.suffix then
      -- Suffix too!
      messageData.suffix = cw.lang:TranslateText(messageData.suffix)
    end

    local styledName = messageData.playerName

    if !messageData.noStyling then
      styledName = messageData.playerName..(messageData.suffix or ': ')
    elseif messageData.noStyling == true then
      styledName = styledName..' '
    end

    table.insert(parsed[1], styledName)

    local wide = util.GetTextSize(font, styledName)
    msgWidth = msgWidth + wide
  end

  if messageData.text then
    local wrapped = chatbox.WrapText(messageData, chatbox.width - 8, msgWidth)
    local curLine = 1
    local bIsNew = true

    for k, v in ipairs(wrapped) do
      parsed[curLine] = parsed[curLine] or {}

      if curLine > 1 then
        table.insert(parsed[curLine], g_DisplayY)
      end

      if bIsNew then
        table.insert(parsed[curLine], messageData.textColor)
        bIsNew = false
      end

      if isstring(v) then
        if v == 'std::endl' then
          curLine = curLine + 1

          parsed[curLine] = parsed[curLine] or {}

          bIsNew = true
          v = ''
        end
      end

      if v != '' then
        table.insert(parsed[curLine], v)
      end
    end
  end

  chatbox.LastBBCode = nil

  hook.Run('PostChatboxParse', parsed)

  return parsed
end

--[[
  Panels
--]]

local PANEL = {}
PANEL.isOpen = false
PANEL.scrollOffset = 0

local fadeDuration = 0.2

--- Sizes and places the chat box and adds the overlay that scrolls the history with the mouse wheel.
function PANEL:Init()
  self.alpha = 0

  self:SetSize(chatbox.width, chatbox.height)
  self:SetPos(chatbox.x, chatbox.y)

  self.scrollBar = vgui.Create('Panel', self)
  self.scrollBar:SetMouseInputEnabled(true)

  self.scrollBar.Think = function(sb)
    sb:SetSize(self:GetWide(), self:GetTall())
    sb:SetPos(0, 0)
  end

  self.scrollBar.OnMouseWheeled = function(sb, delta)
    -- prettiest code contest 2k16 lmao
    self.scrollOffset =
      math.Clamp(self.scrollOffset + delta, 0, math.Clamp(chatbox.GetLineCount() - 19, 0, chatbox.GetLineCount()))
    chatbox.UpdateDisplay()
  end
end

--- Sets whether the chat box is open and starts its background fade.
-- @param bIsOpen [Boolean Whether the chat box is open]
function PANEL:SetChatOpen(bIsOpen)
  self.isOpen = bIsOpen
  self.startTime = CurTime()
end

local function IsIcon(text)
  return (text:StartsWith('[icon:') and text:EndsWith('.png]'))
end

local function IsAvatar(text)
  return (text == '[SenderAvatar]')
end

local function IsTime(text)
  return (text:StartsWith('[SendTime:'))
end

local function SendTime(text)
  if IsTime(text) then
    return tonumber(text:utf8sub(11, text:find(']') - 1))
  end
end

local function ToIcon(text)
  if IsIcon(text) then
    return text:utf8sub(7, text:find(']') - 1)
  end
end

-- Sender avatars are engine AvatarImage panels, one per player, painted manually from PANEL:Paint.
local avatarPanels = {}

local function GetAvatarPanel(parent, player)
  local avatar = avatarPanels[player]

  if !IsValid(avatar) then
    avatar = vgui.Create('AvatarImage', parent)
    avatar:SetSize(16, 16)
    avatar:SetPlayer(player, 32)
    avatar:SetMouseInputEnabled(false)
    avatar:SetPaintedManually(true)

    avatarPanels[player] = avatar
  end

  return avatar
end

-- A function to remove the avatar panels of players who have left.
local function CleanAvatarPanels()
  for k, v in pairs(avatarPanels) do
    if !IsValid(k) or !IsValid(v) then
      if IsValid(v) then v:Remove() end

      avatarPanels[k] = nil
    end
  end
end

--- Draws the background, the visible messages and, while a command is typed, the matching commands.
--
-- Messages stay visible for 12 seconds while the chat box is closed. The
-- `PaintChatboxBackground` hook can return `true` to draw the background itself.
-- Draws nothing while the player is choosing a character.
function PANEL:Paint(w, h)
  if cw.core:IsChoosingCharacter() then return end

  local backColor = Color(38, 38, 38, 225)

  if self.startTime then
    local fraction = (CurTime() - self.startTime) / fadeDuration

    if self.isOpen then
      self.alpha = Lerp(fraction, 0, backColor.a)
    elseif self.drawTransparentBackground then
      self.alpha = Lerp(fraction, 0, 50)
    else
      self.alpha = Lerp(fraction, backColor.a, 0)
    end
  end

  if !hook.Run('PaintChatboxBackground', 0, 0, w, h, self.alpha) then
    draw.RoundedBox(2, 0, 0, w, h, ColorAlpha(backColor, self.alpha))
  end

  local curColor = Color(255, 255, 255)
  local offX = 4
  local offY = 0
  local curSender = nil
  local msgVisible = false

  for k, v in ipairs(display) do
    local fontSize = chatFontSize * ((v._METADATA.data and v._METADATA.data.sizeMultiplier) or 1)
    local font = cw.fonts:GetSize('cwChatBoxFont', fontSize)

    if (CurTime() - v._METADATA.sendTime) < 12 or self.isOpen then
      if !self.isOpen then
        msgVisible = true
      end

      for k2, v2 in pairs(v) do
        if istable(v2) then
          if k2 != '_METADATA' then
            v2.a = chatbox.curAlpha or v2.a or 255
            curColor = v2
          end
        elseif isstring(v2) then
          if IsTime(v2) then
            local time = os.date('%H:%M', SendTime(v2))

            draw.SimpleTextOutlined(
              time,
              font,
              offX,
              offY,
              curColor,
              TEXT_ALIGN_LEFT,
              TEXT_ALIGN_TOP,
              1,
              Color(60, 60, 60, chatbox.curAlpha)
            )

            local width = util.GetTextSize(font, time)
            offX = offX + width + 2
          elseif IsIcon(v2) then
            local matPath = ToIcon(v2)
            local material = cw.core:GetMaterial(matPath)

            surface.SetDrawColor(255, 255, 255, chatbox.curAlpha)
            surface.SetMaterial(material)
            surface.DrawTexturedRect(offX, offY, 16, 16)

            offX = offX + 18
          elseif IsAvatar(v2) then
            if IsValid(curSender) then
              local avatar = GetAvatarPanel(self, curSender)

              avatar:SetPos(offX, offY)
              avatar:SetAlpha(chatbox.curAlpha or 255)
              avatar:PaintManual()

              offX = offX + 18
            end
          else
            draw.SimpleTextOutlined(
              v2,
              font,
              offX,
              offY,
              curColor,
              TEXT_ALIGN_LEFT,
              TEXT_ALIGN_TOP,
              1,
              Color(60, 60, 60, chatbox.curAlpha)
            )

            local width = util.GetTextSize(font, v2)
            offX = offX + width
          end
        elseif isnumber(v2) then
          offY = v2
          offX = 4
        elseif typeof(v2) == 'player' then
          curSender = v2
        else
          print(v2)
        end
      end
    end

    self.drawTransparentBackground = msgVisible
  end

  if chatbox.IsTypingCommand() then
    local curText = chatbox.GetCurrentText()
    local isSilentCmd = curText:StartsWith('/?')

    if isSilentCmd and !cw.client:IsAdmin() then
      return
    end

    local splitTable = string.Explode(' ', string.utf8sub(curText, (isSilentCmd and 3) or 2))
    local commands = {}
    local command = splitTable[1]
    local cX, cY = 4, chatbox.y / 4 + 38

    if command and command != '' then
      chatbox.curAlpha = 50

      for k, v in pairs(cw.command:GetAlias()) do
        local commandLen = string.utf8len(command)

        if commandLen == 0 then
          commandLen = 1
        end

        if string.utf8sub(k, 1, commandLen) == string.lower(command)
        and (!splitTable[2] or string.lower(command) == k) then
          local cmdTable = cw.command:FindByAlias(v)

          if cmdTable
          and (cw.player:HasFlags(cw.client, cmdTable.access) or cw.client:HasPermission(cmdTable.uniqueID)) then
            local bShouldAdd = true

            -- It can so happen that multiple alias for the same command begin with the same string.
            -- We don't want to display the same command multiple times, so we check for that.
            for k, v in pairs(commands) do
              if v == cmdTable then
                bShouldAdd = false
              end
            end

            if bShouldAdd then
              commands[#commands + 1] = cmdTable
            end
          end
        end

        if #commands == 8 then
          break
        end
      end

      for k, v in ipairs(commands) do
        cX = 4
        draw.SimpleTextOutlined(
          '/'..v.name,
          'cwChatBoxSyntax',
          cX,
          cY,
          Color(240, 240, 240),
          TEXT_ALIGN_LEFT,
          TEXT_ALIGN_TOP,
          1,
          Color(0, 0, 0)
        )
        local w = util.GetTextSize('cwChatBoxSyntax', '/'..v.name)
        cX = cX + w + 8
        draw.SimpleTextOutlined(
          (v.tip or ''),
          'cwChatBoxFont',
          cX,
          cY + 4,
          Color(206, 206, 206),
          TEXT_ALIGN_LEFT,
          TEXT_ALIGN_TOP,
          1,
          Color(0, 0, 0)
        )

        if #commands == 1 then
          local offsetX = 24

          if v.alias then
            local text = '#CMDDesc_Aliases '

            if #v.alias > 1 then
              for i, a in ipairs(v.alias) do
                text = text..a..'; '
              end
            else
              text = text..v.alias[1]
            end

            draw.SimpleTextOutlined(
              text,
              'cwChatBoxFont',
              4,
              cY + offsetX,
              Color(240, 240, 240),
              TEXT_ALIGN_LEFT,
              TEXT_ALIGN_TOP,
              1,
              Color(0, 0, 0)
            )

            offsetX = offsetX + 20
          end

          draw.SimpleTextOutlined(
            '#CMDDesc_Usage '..'/'..v.name..' '..v.text,
            'cwChatBoxFont',
            4,
            cY + offsetX,
            Color(240, 240, 240),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_TOP,
            1,
            Color(0, 0, 0)
          )
        end

        cY = cY + 24
      end
    else
      chatbox.curAlpha = 255
    end
  else
    chatbox.curAlpha = 255
  end
end

PANEL.NextAdjust = CurTime()

local lerpDuration = 0.15

--- Runs the `AdjustChatboxInfo` hook eight times a second and closes the chat box when Escape is held.
function PANEL:Think()
  local curTime = CurTime()

  if curTime > self.NextAdjust then
    hook.Run('AdjustChatboxInfo', chatbox)

    self.NextAdjust = curTime + (1 / 8)
  end

  if self.isOpen and input.IsKeyDown(KEY_ESCAPE) then
    chatbox.Hide()
  end
end

vgui.Register('cwChatBox', PANEL, 'EditablePanel')

local PANEL = {}

--- Clears the text of the chat text entry.
function PANEL:Init()
  self:SetText('')
end

local entryBack = Color(0, 0, 0, 170)

--- Draws the text entry.
--
-- The `ChatboxEntryPaint` hook can return `true` to draw it itself.
function PANEL:Paint(w, h)
  if !hook.Run('ChatboxEntryPaint', self, 0, 0, w, h) then
    draw.RoundedBox(2, 0, 0, w, h, Color(25, 25, 25))

    self:DrawTextEntryText(Color(255, 255, 255, 255), Color(255, 250, 200), Color(255, 255, 255, 255))
  end
end

--- Sends the typed text to the server, runs the `ChatBoxTextTyped` hook and closes the chat box.
function PANEL:OnEnter()
  local text = self:GetValue()

  netstream.Start('ChatboxTextEntered', text)

  hook.Run('ChatBoxTextTyped', text)

  self:SetText('')
  chatbox.Hide()
end

--- Keeps the entry at the bottom of the chat box and cuts the text to the `max_chat_length` config.
--
-- Runs the `ChatBoxTextChanged` hook with the old and new text when the text changes.
function PANEL:Think()
  self:SetSize(chatbox.width, 24)
  self:SetPos(0, chatbox.height - 24)

  local maxChatLength = config.GetVal('max_chat_length') or 512
  local text = self:GetValue()

  if text and text != '' then
    if string.utf8len(text) > maxChatLength then
      self:SetValue(string.utf8sub(text, 0, maxChatLength))
      cw.option:PlaySound('tick')
    elseif chatbox.IsOpen() then
      if text != self.previousText then
        hook.Run('ChatBoxTextChanged', self.previousText or '', text)
      end
    end
  end

  self.previousText = text
end

--- Sets the text of the entry and moves the caret to its end.
-- @param text [String The new text]
function PANEL:SetValue(text)
  self:SetText(text)

  if text and text != '' then
    if limit then
      if self:GetCaretPos() > string.utf8len(text) then
        self:SetCaretPos(string.utf8len(text))
      end
    else
      self:SetCaretPos(string.utf8len(text))
    end
  end
end

--- Submits the text on Enter, otherwise runs the `ChatBoxKeyCodeTyped` hook.
--
-- A string returned by the hook replaces the text in the entry.
-- @param code [Number The `KEY_*` enum of the key]
function PANEL:OnKeyCodeTyped(code)
  if code == KEY_ENTER and !self:IsMultiline() and self:GetEnterAllowed() then
    self:FocusNext()
    self:OnEnter()
  else
    local text = hook.Run('ChatBoxKeyCodeTyped', code, self:GetValue())

    if text and type(text) == 'string' then
      self:SetValue(text)
    end
  end
end

vgui.Register('cwChatTextEntry', PANEL, 'DTextEntry')

--- Creates the chat box panel, replacing the existing one.
function chatbox.CreateChatBox()
  if chatbox.panel then
    chatbox.panel:Remove()
  end

  chatbox.panel = vgui.Create('cwChatBox')
end

--- Returns whether the chat box is open.
-- @return [Boolean Whether the chat box is open, or `nil` if it has not been created]
function chatbox.IsOpen()
  if IsValid(chatbox.panel) then
    return chatbox.panel.isOpen
  end
end

--- Returns the text the local player is typing.
-- @return [String The text in the entry, or `''` if the chat box is closed]
function chatbox.GetCurrentText()
  local textEntry = chatbox.textEntry

  if textEntry and textEntry:IsVisible() and chatbox.IsOpen() then
    return textEntry:GetValue()
  else
    return ''
  end
end

--- Returns whether the typed text starts with an OOC prefix (`//`, `.//` or `[[`).
-- @return [Boolean Whether the player is typing an OOC message]
function chatbox.IsTypingOOC()
  local text = chatbox.GetCurrentText()

  return (text:StartsWith('//') or text:StartsWith('.//') or text:StartsWith('[['))
end

--- Returns whether the typed text is a command (starts with `/` or `/?` and is not OOC).
-- @return [Boolean Whether the player is typing a command]
function chatbox.IsTypingCommand()
  local text = chatbox.GetCurrentText()
  local prefix = { '/', '/?' }

  for k, v in pairs(prefix) do
    if text:StartsWith(v) and !chatbox.IsTypingOOC() then
      return true
    end
  end

  return false
end

--- Creates the chat text entry inside the chat box, replacing the existing one.
function chatbox.CreateTextEntry()
  if chatbox.textEntry then
    chatbox.textEntry:Remove()
  end

  chatbox.textEntry = vgui.Create('cwChatTextEntry', chatbox.panel)
  chatbox.textEntry:SetFont('cwChatBoxFont')
  chatbox.textEntry:SetTextColor(Color(255, 255, 255))
end

--- Creates the chat box panel and its text entry.
function chatbox.CreateDerma()
  chatbox.CreateChatBox()
  chatbox.CreateTextEntry()
end

--- Opens the chat box and focuses its text entry.
--
-- Creates the panels first if needed.
-- @param panel=nil [Panel Panel to parent the chat box to; when `nil` the chat box becomes a popup]
-- @see chatbox.Hide
function chatbox.Show(panel)
  if !chatbox.panel then
    chatbox.CreateDerma()
  end

  chatbox.panel:SetChatOpen(true)

  if panel then
    chatbox.panel:SetParent(panel)
  else
    chatbox.panel:MakePopup()
  end

  chatbox.textEntry:AlphaTo(255, fadeDuration)
  chatbox.panel.scrollBar:AlphaTo(255, fadeDuration)
  chatbox.textEntry:RequestFocus()
  chatbox.lerpStart = CurTime()
end

--- Closes the chat box.
--
-- Runs the `ChatBoxClosed` hook with the typed text and then `FinishChat`. When
-- Escape closed it, keeps the pause menu from opening.
-- @see chatbox.Show
function chatbox.Hide()
  if !chatbox.textEntry or !chatbox.panel then
    chatbox.CreateDerma()
  end

  hook.Run('ChatBoxClosed', chatbox.GetCurrentText())

  local wasOpen = chatbox.IsOpen()

  chatbox.textEntry:AlphaTo(0, fadeDuration)
  chatbox.panel.scrollBar:AlphaTo(0, fadeDuration)

  chatbox.panel:SetChatOpen(false)
  chatbox.panel:SetMouseInputEnabled(false)
  chatbox.panel:SetKeyboardInputEnabled(false)

  hook.Run('FinishChat')

  -- 'cancelselect' is blocked for RunConsoleCommand nowadays. When ESC closed the chat box, keep the
  -- pause menu from opening (OnPauseMenuShow below) or close it again if it already has.
  if wasOpen and input.IsKeyDown(KEY_ESCAPE) and !input.IsShiftDown() then
    chatbox.escapeFrame = FrameNumber()

    timer.Simple(FrameTime() * 0.5, function()
      if gui.IsGameUIVisible() then
        gui.HideGameUI()
      end
    end)
  end
end

--- Removes the chat box panels and creates them again.
--
-- Bound to the `cw_resetchat` console command.
function chatbox.RecreatePanel()
  chatbox.panel:SetVisible(false)
  chatbox.textEntry:SetVisible(false)
  chatbox.textEntry:Remove()
  chatbox.panel.scrollBar:SetVisible(false)
  chatbox.panel.scrollBar:Remove()
  chatbox.panel:Remove()
  chatbox.panel = nil
  chatbox.textEntry = nil
  chatbox.CreateDerma()
end

concommand.Add('cw_resetchat', chatbox.RecreatePanel)

--- Rebuilds the drawn lines from the chat history.
--
-- Parses up to 19 of the newest messages, skipping as many as the panel is
-- scrolled, and lays them out from the bottom up. Called whenever a message
-- arrives or the history is scrolled.
function chatbox.UpdateDisplay()
  if !chatbox.panel then
    chatbox.CreateDerma()
  end

  CleanAvatarPanels()

  local i = 1
  local maxMessages = 20

  g_DisplayY = (maxMessages - 2) * 20 + 20
  display = {}
  local curMsg = 0

  for k, v in SortedPairs(history, true) do
    if curMsg < chatbox.panel.scrollOffset then
      -- nothing
    else
      if i < maxMessages then
        local parsed = chatbox.ParseText(history[k])

        for _, line in ipairs(parsed) do
          line._METADATA = {}
          line._METADATA.time = v.time or os.time()
          line._METADATA.sendTime = v.sendTime
          line._METADATA.index = k
          line._METADATA.data = v.data

          if #parsed > 1 then
            line._METADATA.multiLine = true
          end

          line._METADATA.lineCount = #parsed
          history[k].lineCount = #parsed

          table.insert(display, line)
        end

        i = i + 1
      else
        break
      end
    end

    curMsg = curMsg + 1
  end

  local lastIdx = 0
  local multiLineOffset = 0
  local curLine = 1

  for k, v in ipairs(display) do
    local next = display[k + 1]
    local multiplier = next and next._METADATA.data and next._METADATA.data.sizeMultiplier or 1
    local padding = chatMessagePadding * multiplier

    if v._METADATA.index == lastIdx then
      curLine = curLine + 1

      v[1] = g_DisplayY + (curLine * padding)
    else
      multiLineOffset = 0
      curLine = 1

      if v._METADATA.multiLine then
        multiLineOffset = v._METADATA.lineCount * padding - padding

        v[1] = g_DisplayY - multiLineOffset
        g_DisplayY = g_DisplayY - multiLineOffset - padding

        lastIdx = v._METADATA.index
      else
        v[1] = g_DisplayY
        g_DisplayY = g_DisplayY - padding
        lastIdx = v._METADATA.index
      end
    end
  end
end

--- Asks the server to add a message to the local player's chat box.
--
-- The arguments are sent to the server, which builds the message with its own
-- `chatbox.AddText` and sends it back to this player only.
--
-- ```
-- chatbox.AddText(Color(255, 100, 100), 'You cannot do that.')
-- ```
--
-- @param ... [Any Strings, `Color`s, players and message option tables]
function chatbox.AddText(...)
  netstream.Start('ChatboxAddText', ...)
end

--[[
  Hooks
--]]

hook.Add('PlayerBindPress', 'chatbox.PlayerBindPress', function(player, bind, bPress)
  if (string.find(bind, 'messagemode') or string.find(bind, 'messagemode2')) and bPress then
    if cw.client:HasInitialized() then
      chatbox.Show()
    end

    return true
  end
end)

-- Called when the pause menu is about to open. ESC closes the chat box first.
hook.Add('OnPauseMenuShow', 'chatbox.OnPauseMenuShow', function()
  if chatbox.IsOpen() then
    chatbox.Hide()

    return false
  elseif chatbox.escapeFrame == FrameNumber() then
    return false
  end
end)

netstream.Hook('ChatboxTextEnter', function(player, messageData)
  if IsValid(player) then
    chat.PlaySound()

    print('['..messageData.filter:upper()..'] '..cw.player:GetName(player)..': '..messageData.text)

    table.insert(history, messageData)

    chatbox.UpdateDisplay()
  end
end)

netstream.Hook('ChatboxAddText', function(messageData)
  chat.PlaySound()

  print('['..messageData.filter:upper()..'] '..messageData.text)

  table.insert(history, messageData)

  chatbox.UpdateDisplay()
end)
