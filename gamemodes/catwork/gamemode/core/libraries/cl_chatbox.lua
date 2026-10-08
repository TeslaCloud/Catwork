--- Defines the client-side half of the global `chatbox` library and the `cwChatBox` and `cwChatTextEntry` panels that
-- replace the default chat box.
--
-- The last `chatbox.maxHistory` received messages are kept in `chatbox.history` and turned into wrapped lines by
-- `chatbox.ParseText`; filters (`chatbox.AddFilter`), message types (`chatbox.AddType`) and BB-codes
-- (`chatbox.AddBBCode`) decide how each one is drawn. `chat.AddText` is replaced to go through `chatbox.AddText`,
-- typed text is sent to the server over the `ChatboxTextEntered` Cable message, and the `cw_resetchat` console command
-- rebuilds the panels.

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

chatbox.history 	= history -- Chat history; the last `chatbox.maxHistory` messages.
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
chatbox.maxHistory = chatbox.maxHistory or 1000
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
    messageData.drawModel = messageData.drawModel or false
    messageData.isPlayerMessage = messageData.isPlayerMessage or false
    messageData.type = messageData.type or 'default'

    if messageData.drawTime == nil then messageData.drawTime = true end
    if messageData.rich == nil then messageData.rich = true end
    if messageData.translate == nil then messageData.translate = true end
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
    messageData.drawModel = false

    if messageData.drawTime == nil then messageData.drawTime = true end

    if messageData.icon == nil then
      messageData.icon = 'icon16/lightning.png'
    end

    messageData.rich = true

    if messageData.translate == nil then messageData.translate = true end

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
  codes[id].requireRich = (requireRich != false)
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
-- Changes `line` in place, splitting each string around its tags; tags that are not registered stay in
-- the text. The result of the last tag is stored in `chatbox.LastBBCode` and inserted at the start of
-- the next parsed line, so a color carries over wrapped lines.
-- @param line [List Strings and other objects making up a line]
-- @param rich [Boolean Whether tags that require rich messages are parsed]
function chatbox.ParseBBCodes(line, rich)
  if chatbox.LastBBCode then
    table.insert(line, 1, chatbox.LastBBCode)
  end

  local parsed = {}

  for k, v in ipairs(line) do
    if isstring(v) then
      -- The brackets are single bytes, so cutting the text at them never splits a UTF-8 character.
      local textStart = 1
      local searchStart = 1

      while true do
        local tagStart, tagEnd = v:find('%b[]', searchStart)

        if !tagStart then break end

        local tag = v:sub(tagStart + 1, tagEnd - 1)
        local eq = tag:find('=', 1, true)
        local codeTable = codes[eq and tag:sub(1, eq - 1) or tag]

        if codeTable and (!codeTable.requireRich or rich) then
          local nextTag = v:find('[', tagEnd + 1, true)
          local textEnd = nextTag and nextTag - 1 or #v
          local result, newText = codeTable.Callback(eq and tag:sub(eq + 1) or '', v:sub(tagEnd + 1, textEnd))

          if tagStart > textStart then
            parsed[#parsed + 1] = v:sub(textStart, tagStart - 1)
          end

          parsed[#parsed + 1] = result
          chatbox.LastBBCode = result

          if isstring(newText) then
            parsed[#parsed + 1] = newText
            textStart = textEnd + 1
          else
            textStart = tagEnd + 1
          end

          searchStart = textStart
        else
          -- Not a tag: look again from the next byte, as a real tag may be nested in the brackets.
          searchStart = tagStart + 1
        end
      end

      if textStart <= #v then
        parsed[#parsed + 1] = v:sub(textStart)
      end
    else
      parsed[#parsed + 1] = v
    end
  end

  for k = 1, math.max(#line, #parsed) do
    line[k] = parsed[k]
  end
end

do
  -- Turns one component of a `[color=r,g,b,a]` tag into a number from 0 to 255.
  local function ToColorComponent(value)
    value = tonumber(value)

    if !value or value != value then
      return 255
    end

    return math.Clamp(value, 0, 255)
  end

  chatbox.AddBBCode('color', function(code, text)
    local exploded = string.Explode(',', code:Replace(' ', ''))

    if !exploded[2] then
      local name = exploded[1]

      -- Players write these tags, so only well-formed hex colors reach the hex parser.
      if name:StartsWith('#') and !name:find('^#%x%x%x%x%x%x$') and !name:find('^#%x%x%x%x%x%x%x%x$') then
        return Color(255, 255, 255)
      end

      return Color(name)
    else
      return Color(
        ToColorComponent(exploded[1]),
        ToColorComponent(exploded[2]),
        ToColorComponent(exploded[3]),
        ToColorComponent(exploded[4])
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
        local w = util.GetTextSize(font, v)

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
            local curWord = ''
            local wordWide = 0

            -- Go through the word one UTF-8 character at a time, never byte by byte.
            for char in v:gmatch('[%z\1-\127\194-\244][\128-\191]*') do
              local charWide = util.GetTextSize(font, char)

              -- if we don't have enough characters to fill in the entire line
              if (wordWide + charWide + dashWidth) < (maxWidth - curWidth) then
                curWord = curWord..char
                wordWide = wordWide + charWide
              -- if we do
              else
                curWord = curWord..char..'-'
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
              curText = curText..curWord..' '
              curWidth = curWidth + wordWide + spaceWidth
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

  return wrapped
end

g_DisplayY = g_DisplayY or 0

-- Appends a marker string (send time, icon or avatar) to a parsed line and remembers its position in
-- `line.markers`. Only the strings added here are drawn as markers; message text that merely looks like
-- one, which a player can type, stays text.
local function AddMarker(line, marker)
  line[#line + 1] = marker
  line.markers = line.markers or {}
  line.markers[#line] = true
end

--- Turns a message into the lines drawn by the chat box.
--
-- Applies the message's filter (`'ooc'` when unset) and type, then builds the time,
-- icon, avatar, prefix and sender name parts and wraps the text. Runs the
-- `ChatboxPreProcess` and `PreChatboxParse` hooks with the message data and
-- `PostChatboxParse` with the result. A filter or type that is not registered falls
-- back to `'default'`.
-- @param messageData [Map The message data received from the server]
-- @return [List<List> The lines; each starts with its vertical offset, followed by the sender,
-- `Color`s, strings and marker strings such as `'[SenderAvatar]'`. The positions of the marker
-- strings are the keys of the line's `markers` field]
function chatbox.ParseText(messageData)
  local parsed = {}
  local msgWidth = 0

  messageData.filter = messageData.filter or 'ooc'

  hook.Run('ChatboxPreProcess', messageData)

  local filterCallback = chatbox.GetFilter(messageData.filter) or filters['default']
  filterCallback(messageData)

  local typeCallback = chatbox.GetType(messageData.type) or types['default']
  typeCallback(messageData)

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
    AddMarker(parsed[1], '[SendTime:'..(tonumber(messageData.time) or os.time())..']')
    table.insert(parsed[1], ' - ')
    msgWidth = msgWidth + 50
  end

  if isstring(messageData.icon) and messageData.icon != '' then
    AddMarker(parsed[1], '[icon:'..messageData.icon..']')
    msgWidth = msgWidth + 20
  end

  if messageData.drawAvatar and IsValid(messageData.sender) then
    -- The avatar itself is an engine AvatarImage painted by the chat box panel (see GetAvatarPanel).
    AddMarker(parsed[1], '[SenderAvatar]')
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
    local curLine = parsed[1]
    local curColor = messageData.textColor
    local bHasText = false

    table.insert(curLine, curColor)

    for k, v in ipairs(wrapped) do
      if v == 'std::endl' then
        -- A new line starts with its offset and the color the previous one ended in.
        curLine = { g_DisplayY, curColor }
        parsed[#parsed + 1] = curLine
        bHasText = false
      elseif v != '' then
        if isstring(v) then
          bHasText = true
        elseif istable(v) then
          curColor = v
        end

        table.insert(curLine, v)
      end
    end

    -- Drop the empty line left behind when the text ends exactly at a line break.
    if #parsed > 1 and !bHasText then
      parsed[#parsed] = nil
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
    -- The offset counts messages, so it stops at the oldest one however many lines they take.
    local maxOffset = math.Clamp(chatbox.GetLineCount() - 19, 0, math.max(#history - 1, 0))

    self.scrollOffset = math.Clamp(self.scrollOffset + delta, 0, maxOffset)
    chatbox.UpdateDisplay()
  end
end

--- Sets whether the chat box is open and starts its background fade.
-- @param bIsOpen [Boolean Whether the chat box is open]
function PANEL:SetChatOpen(bIsOpen)
  self.isOpen = bIsOpen
  self.startTime = CurTime()
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

local colorWhite = Color(255, 255, 255)

-- Builds the draw operations of a display line: what goes where, in which color. chatbox.UpdateDisplay
-- calls this once per line, so that painting the line every frame measures and translates nothing.
local function CompileLine(line)
  local meta = line._METADATA
  local fontSize = chatFontSize * ((meta.data and meta.data.sizeMultiplier) or 1)
  local font = cw.fonts:GetSize('cwChatBoxFont', fontSize)
  local GetTextSize = surface.OldGetTextSize or surface.GetTextSize
  local markers = line.markers
  local ops = {}
  local curColor = colorWhite
  local curSender = nil
  local offX = 4
  local offY = 0

  surface.SetFont(font)

  for k, v in ipairs(line) do
    if isstring(v) then
      if !markers or !markers[k] then
        -- Phrases are translated here; the text is then drawn as it is.
        local text = cw.lang:TranslateText(v)

        ops[#ops + 1] = { text = text, x = offX, y = math.ceil(offY), color = curColor }
        offX = offX + GetTextSize(text)
      elseif v == '[SenderAvatar]' then
        if IsValid(curSender) then
          ops[#ops + 1] = { avatar = curSender, x = offX, y = offY }
          offX = offX + 18
        end
      elseif v:StartsWith('[icon:') then
        ops[#ops + 1] = { material = cw.core:GetMaterial(v:sub(7, -2)), x = offX, y = offY }
        offX = offX + 18
      else
        local text = os.date('%H:%M', tonumber(v:match('^%[SendTime:(.-)%]$'))) or ''

        ops[#ops + 1] = { text = text, x = offX, y = math.ceil(offY), color = curColor }
        offX = offX + GetTextSize(text) + 2
      end
    elseif isnumber(v) then
      offY = v
      offX = 4
    elseif istable(v) then
      if v.r and v.g and v.b then
        curColor = v
      end
    elseif isentity(v) then
      curSender = v
    end
  end

  meta.font = font
  meta.ops = ops
end

-- Draws text in the current font with a one pixel outline, as draw.SimpleTextOutlined does, without
-- measuring the text or looking for phrases in it on every one of its ten passes.
local function DrawOutlinedText(text, x, y, color, alpha, outline)
  local DrawText = surface.OldDrawText or surface.DrawText

  surface.SetTextColor(outline, outline, outline, alpha)

  for offX = -1, 1 do
    for offY = -1, 1 do
      surface.SetTextPos(x + offX, y + offY)
      DrawText(text)
    end
  end

  surface.SetTextColor(color.r, color.g, color.b, alpha)
  surface.SetTextPos(x, y)
  DrawText(text)
end

-- Finds up to eight commands the local player may use that match the command being typed, and prepares
-- the texts of their hints. Returns nil when no hints are to be shown at all.
local function FindCommandHints(curText)
  local isSilentCmd = curText:StartsWith('/?')

  if isSilentCmd and !cw.client:IsAdmin() then return end

  local splitTable = string.Explode(' ', string.utf8sub(curText, (isSilentCmd and 3) or 2))
  local command = splitTable[1]

  if !command or command == '' then return end

  command = string.lower(command)

  local commandLen = string.utf8len(command)
  local commands = {}
  local found = {}

  for k, v in pairs(cw.command:GetAlias()) do
    if string.utf8sub(k, 1, commandLen) == command and (!splitTable[2] or command == k) then
      local cmdTable = cw.command:FindByAlias(v)

      -- It can so happen that multiple alias for the same command begin with the same string.
      -- We don't want to display the same command multiple times, so we check for that.
      if cmdTable and !found[cmdTable]
      and (cw.player:HasFlags(cw.client, cmdTable.access) or cw.client:HasPermission(cmdTable.uniqueID)) then
        found[cmdTable] = true
        commands[#commands + 1] = cmdTable
      end
    end

    if #commands == 8 then
      break
    end
  end

  local hints = {}

  for k, v in ipairs(commands) do
    local hint = {
      name = cw.lang:TranslateText('/'..v.name),
      tip = cw.lang:TranslateText(v.tip or '')
    }

    hint.nameWidth = util.GetTextSize('cwChatBoxSyntax', hint.name)

    -- A single match also shows its aliases and syntax.
    if #commands == 1 then
      if istable(v.alias) and v.alias[1] then
        local text = '#CMDDesc_Aliases '

        if #v.alias > 1 then
          for i, a in ipairs(v.alias) do
            text = text..tostring(a)..'; '
          end
        else
          text = text..tostring(v.alias[1])
        end

        hint.aliases = cw.lang:TranslateText(text)
      end

      hint.usage = cw.lang:TranslateText('#CMDDesc_Usage '..'/'..v.name..' '..v.text)
    end

    hints[k] = hint
  end

  return hints
end

local backColor = Color(38, 38, 38, 225)
local backDrawColor = Color(38, 38, 38, 0)
local hintNameColor = Color(240, 240, 240)
local hintTipColor = Color(206, 206, 206)

--- Draws the background, the visible messages and, while a command is typed, the matching commands.
--
-- Messages stay visible for 12 seconds while the chat box is closed. The
-- `PaintChatboxBackground` hook can return `true` to draw the background itself.
-- Draws nothing while the player is choosing a character.
function PANEL:Paint(w, h)
  if cw.core:IsChoosingCharacter() then return end

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

  if !hook.Run('PaintChatboxBackground', 0, 0, w, h, self.alpha) and self.alpha > 0 then
    backDrawColor.a = self.alpha
    draw.RoundedBox(2, 0, 0, w, h, backDrawColor)
  end

  local alpha = chatbox.curAlpha or 255
  local curTime = CurTime()
  local isOpen = self.isOpen
  local msgVisible = false

  for k, v in ipairs(display) do
    local meta = v._METADATA

    if isOpen or (curTime - meta.sendTime) < 12 then
      if !isOpen then
        msgVisible = true
      end

      for k2, op in ipairs(meta.ops) do
        if op.text then
          surface.SetFont(meta.font)
          DrawOutlinedText(op.text, op.x, op.y, op.color, alpha, 60)
        elseif op.material then
          surface.SetDrawColor(255, 255, 255, alpha)
          surface.SetMaterial(op.material)
          surface.DrawTexturedRect(op.x, op.y, 16, 16)
        elseif IsValid(op.avatar) then
          local avatar = GetAvatarPanel(self, op.avatar)

          avatar:SetPos(op.x, op.y)
          avatar:SetAlpha(alpha)
          avatar:PaintManual()
        end
      end
    end
  end

  self.drawTransparentBackground = msgVisible

  if !chatbox.IsTypingCommand() then
    self.hintText = nil
    chatbox.curAlpha = 255

    return
  end

  local curText = chatbox.GetCurrentText()

  -- The matching commands only change when the typed text does.
  if curText != self.hintText then
    self.hintText = curText
    self.hints = FindCommandHints(curText)
  end

  if !self.hints then
    chatbox.curAlpha = 255

    return
  end

  chatbox.curAlpha = 50

  local cY = math.ceil(chatbox.y / 4 + 38)

  for k, v in ipairs(self.hints) do
    surface.SetFont('cwChatBoxSyntax')
    DrawOutlinedText(v.name, 4, cY, hintNameColor, 255, 0)

    surface.SetFont('cwChatBoxFont')
    DrawOutlinedText(v.tip, 4 + v.nameWidth + 8, cY + 4, hintTipColor, 255, 0)

    local offsetY = 24

    if v.aliases then
      DrawOutlinedText(v.aliases, 4, cY + offsetY, hintNameColor, 255, 0)

      offsetY = offsetY + 20
    end

    if v.usage then
      DrawOutlinedText(v.usage, 4, cY + offsetY, hintNameColor, 255, 0)
    end

    cY = cY + 24
  end
end

PANEL.NextAdjust = CurTime()

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

local entryBackColor = Color(25, 25, 25)
local entryTextColor = Color(255, 255, 255, 255)
local entryHighlightColor = Color(255, 250, 200)

--- Draws the text entry.
--
-- The `ChatboxEntryPaint` hook can return `true` to draw it itself.
function PANEL:Paint(w, h)
  if !hook.Run('ChatboxEntryPaint', self, 0, 0, w, h) then
    draw.RoundedBox(2, 0, 0, w, h, entryBackColor)

    self:DrawTextEntryText(entryTextColor, entryHighlightColor, entryTextColor)
  end
end

--- Sends the typed text to the server, runs the `ChatBoxTextTyped` hook and closes the chat box.
function PANEL:OnEnter()
  local text = self:GetValue()

  cable.send('ChatboxTextEntered', text)

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

  local text = self:GetValue()

  -- The length only needs checking when the text has changed.
  if text == self.previousText then return end

  if text and text != '' then
    local maxChatLength = config.GetVal('max_chat_length') or 512

    if string.utf8len(text) > maxChatLength then
      self:SetValue(string.utf8sub(text, 0, maxChatLength))
      cw.option:PlaySound('tick')
    elseif chatbox.IsOpen() then
      hook.Run('ChatBoxTextChanged', self.previousText or '', text)
    end
  end

  self.previousText = text
end

--- Sets the text of the entry and moves the caret to its end.
-- @param text [String The new text]
function PANEL:SetValue(text)
  self:SetText(text)

  if text and text != '' then
    self:SetCaretPos(string.utf8len(text))
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
  if IsValid(chatbox.panel) then
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

  if IsValid(textEntry) and textEntry:IsVisible() and chatbox.IsOpen() then
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
  -- This also covers the silent command prefix, `/?`.
  return chatbox.GetCurrentText():StartsWith('/') and !chatbox.IsTypingOOC()
end

--- Creates the chat text entry inside the chat box, replacing the existing one.
function chatbox.CreateTextEntry()
  if IsValid(chatbox.textEntry) then
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
  if !IsValid(chatbox.panel) or !IsValid(chatbox.textEntry) then
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
  if !IsValid(chatbox.panel) or !IsValid(chatbox.textEntry) then
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

--- Removes the chat box panels and creates them again, closed.
--
-- Bound to the `cw_resetchat` console command.
function chatbox.RecreatePanel()
  if IsValid(chatbox.panel) then
    -- The text entry and the scroll overlay are children of the panel and go with it.
    chatbox.panel:SetVisible(false)
    chatbox.panel:Remove()
  end

  chatbox.panel = nil
  chatbox.textEntry = nil
  chatbox.CreateDerma()
  chatbox.Hide()

  -- The new panel is not scrolled, so show the newest messages again.
  chatbox.UpdateDisplay()
end

concommand.Add('cw_resetchat', chatbox.RecreatePanel)

--- Rebuilds the drawn lines from the chat history.
--
-- Parses up to 19 of the newest messages, skipping as many as the panel is
-- scrolled, lays them out from the bottom up and prepares them for drawing. Called
-- whenever a message arrives or the history is scrolled.
function chatbox.UpdateDisplay()
  if !IsValid(chatbox.panel) then
    chatbox.CreateDerma()
  end

  CleanAvatarPanels()

  local maxMessages = 20
  local newest = #history - math.floor(chatbox.panel.scrollOffset)

  g_DisplayY = (maxMessages - 2) * 20 + 20
  display = {}
  chatbox.display = display

  -- Newest first, starting below the messages scrolled past.
  for k = newest, math.max(newest - (maxMessages - 2), 1), -1 do
    local messageData = history[k]
    local parsed = chatbox.ParseText(messageData)
    local lineCount = #parsed

    messageData.lineCount = lineCount

    for _, line in ipairs(parsed) do
      line._METADATA = {
        time = messageData.time or os.time(),
        sendTime = messageData.sendTime or 0,
        index = k,
        data = messageData.data,
        multiLine = (lineCount > 1),
        lineCount = lineCount
      }

      table.insert(display, line)
    end
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

    CompileLine(v)
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
  cable.send('ChatboxAddText', ...)
end

--[[
  Hooks
--]]

hook.Add('PlayerBindPress', 'chatbox.PlayerBindPress', function(player, bind, bPress)
  -- This matches both `messagemode` and `messagemode2`.
  if bPress and string.find(bind, 'messagemode', 1, true) then
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

-- Adds a received message to the history, echoes it to the console and redraws the chat box.
local function AddMessage(messageData, sender)
  if !istable(messageData) then return end

  messageData.text = tostring(messageData.text or '')
  messageData.filter = tostring(messageData.filter or 'default')
  messageData.sendTime = tonumber(messageData.sendTime) or CurTime()

  chat.PlaySound()

  if sender then
    print('['..messageData.filter:upper()..'] '..cw.player:GetName(sender)..': '..messageData.text)
  else
    print('['..messageData.filter:upper()..'] '..messageData.text)
  end

  table.insert(history, messageData)

  -- Scrolled-past messages are counted from the newest, so dropping the oldest moves nothing.
  while #history > chatbox.maxHistory do
    table.remove(history, 1)
  end

  chatbox.UpdateDisplay()
end

cable.receive('ChatboxTextEnter', function(player, messageData)
  if IsValid(player) then
    AddMessage(messageData, player)
  end
end)

cable.receive('ChatboxAddText', function(messageData)
  AddMessage(messageData)
end)
