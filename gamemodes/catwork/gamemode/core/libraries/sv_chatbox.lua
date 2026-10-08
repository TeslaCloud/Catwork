--- Defines the server-side half of the global `chatbox` library, which processes what players type and decides who
-- receives each chat message.
--
-- Prefixes registered with `chatbox.AddPrefix` (`//`, `.//`, `[[`, `/`, `/?`, `@` and `<sys>` are built in; `/?` and
-- `<sys>` only work for admins) classify typed text as OOC, local OOC, a command and so on, and filters registered
-- with `chatbox.AddFilter` pick the listeners. `chatbox.AddText` builds and sends a message from code and
-- `chatbox.SayAsPlayer` speaks for a player. The `ChatboxTextEntered` receiver runs commands, applies the
-- `ooc_interval` and `looc_interval` configs, and kicks players who type one of a hard-coded list of insults about
-- the server.

library.New('chatbox', _G)
// Chatbox prefixes for serverside processing. Will be networked to clients for message styling.
chatbox.prefixes = chatbox.prefixes or {}
chatbox.filters = chatbox.filters or {}

--- Registers a chat prefix that is checked against messages players type.
--
-- The callback receives the message table and inspects `msgData.text`. When it
-- returns a truthy value, the prefix is stripped from the text afterwards (for
-- `/?` only the first character is stripped). The callback usually sets
-- `msgData.filter` and `msgData.radius`. Does nothing if the prefix is empty.
--
-- ```
-- chatbox.AddPrefix('!', function(msgData)
--   if msgData.text:StartsWith('!') then
--     msgData.filter = 'looc'
--     msgData.radius = config.GetVal('talk_radius')
--
--     return true
--   end
-- end)
-- ```
--
-- @param prefix [String The text messages must start with, such as `'//'`]
-- @param callback [Function Called as `callback(msgData)`; return `true` once the message has been handled]
-- @see chatbox.GetPrefix
function chatbox.AddPrefix(prefix, callback)
  if !prefix or prefix == '' then return end

  local oldCB = callback

  function callback(msgData)
    local result = oldCB(msgData)

    if result then
      msgData.text = msgData.text:utf8sub((prefix == '/?' and 2) or (prefix:utf8len() + 1), msgData.text:utf8len())
    end

    return result
  end

  chatbox.prefixes[prefix] = {}
  chatbox.prefixes[prefix].Callback = callback
  chatbox.prefixes[prefix].length = prefix:utf8len()
end

--- Returns the data registered for a chat prefix.
-- @param prefix [String The prefix as passed to `chatbox.AddPrefix`]
-- @return [Map The prefix data with `Callback` and `length` keys, or `nil` if it is not registered]
function chatbox.GetPrefix(prefix)
  if chatbox.prefixes[prefix] then
    return chatbox.prefixes[prefix]
  end
end

--- Registers a chat filter that decides who receives messages of a type.
--
-- Messages pick their filter through `msgData.filter` (`'ic'`, `'ooc'`,
-- `'looc'`, `'admin'`, `'command'` and so on). Registering an existing ID
-- replaces it. Does nothing if the ID is empty.
--
-- ```
-- chatbox.AddFilter('radio', function(listener, msgData)
--   return listener:HasItemByID('handheld_radio')
-- end)
-- ```
--
-- @param id [String Name of the filter]
-- @param callback [Function Called as `callback(listener, msgData)`; return `true` to send the message to `listener`]
-- @see chatbox.GetFilter
function chatbox.AddFilter(id, callback)
  if !id or id == '' then return end

  chatbox.filters[id] = callback
end

--- Returns the callback of a chat filter.
-- @param id [String Name of the filter, as passed to `chatbox.AddFilter`]
-- @return [Function The filter callback, or `nil` if no filter has that name]
function chatbox.GetFilter(id)
  if chatbox.filters[id] then
    return chatbox.filters[id]
  end
end

--- Returns whether a player is within hearing range of a position.
--
-- The player hears it when the position is within `radius` of them, or within
-- half the radius of the point they are looking at. Players that have not
-- initialized never hear anything.
-- @param listener [Player The player who would hear the message]
-- @param position [Vector Where the message comes from; without one only a radius of `0` is heard]
-- @param radius [Number Hearing radius; `0` means everyone hears it, a negative value or a non-number means
-- nobody does]
-- @return [Boolean Whether the listener can hear the message]
function chatbox.CanHear(listener, position, radius)
  if listener:HasInitialized() then
    if !isnumber(radius) then return false end
    if radius == 0 then return true end
    if radius < 0 or !position then return false end

    -- The distance is checked first, as the trace is only needed for listeners out of range.
    if position:Distance(listener:GetPos()) <= radius
    or cw.player:GetRealTrace(listener).HitPos:Distance(position) <= (radius / 2) then
      return true
    end
  end

  return false
end

do
  chatbox.AddFilter('ooc', function(listener, msgData)
    return true -- todo chat types blocking
  end)

  chatbox.AddFilter('pm', function(listener, msgData)
    return true
  end)

  -- variables in these 2 filters are locals because we may wanna use them a bit later.
  chatbox.AddFilter('looc', function(listener, msgData)
    local pos = msgData.position
    local rad = msgData.radius or config.GetVal('talk_radius')

    return chatbox.CanHear(listener, pos, rad)
  end)

  chatbox.AddFilter('ic', function(listener, msgData)
    local pos = msgData.position

    if !pos and IsValid(msgData.sender) then
      pos = msgData.sender:GetPos()
    end

    local rad = msgData.radius or config.GetVal('talk_radius')

    return chatbox.CanHear(listener, pos, rad)
  end)

  chatbox.AddFilter('player_events', function(listener, msgData)
    local pos = msgData.position
    local rad = msgData.radius or config.GetVal('talk_radius')

    return chatbox.CanHear(listener, pos, rad)
  end)

  chatbox.AddFilter('events', function(listener, msgData)
    return true
  end)

  chatbox.AddFilter('admin', function(listener, msgData)
    return (listener:IsAdmin() or listener:IsUserGroup('operator'))
  end)

  chatbox.AddFilter('default', function(listener, msgData)
    return true
  end)

  -- prevent commands from appearing in chatbox.
  chatbox.AddFilter('command', function(listener, msgData)
    return false
  end)

  chatbox.AddFilter('command_no_announcement', function(listener, msgData)
    return false
  end)

  chatbox.AddFilter('player_as_system', function(listener, msgData)
    return true
  end)
end

do
  chatbox.AddPrefix('//', function(msgData)
    local text = msgData.text

    if text:StartsWith('//') then
      msgData.filter = 'ooc'
      msgData.radius = 0

      msgData.text = string.gsub(text, '^// +', '//')

      return true -- tell the system that we set everything!
    end
  end)

  chatbox.AddPrefix('.//', function(msgData)
    local text = msgData.text

    if text:StartsWith('.//') then
      msgData.filter = 'looc'
      msgData.radius = config.GetVal('talk_radius') -- todo

      msgData.text = string.gsub(text, '^%.// +', './/')

      return true
    end
  end)

  -- who even does [[ anyway
  chatbox.AddPrefix('[[', function(msgData)
    local text = msgData.text

    if text:StartsWith('[[') then
      msgData.filter = 'looc'
      msgData.radius = config.GetVal('talk_radius') -- todo

      msgData.text = string.gsub(text, '^%[%[ +', '[[')

      return true
    end
  end)

  chatbox.AddPrefix('/', function(msgData)
    local text = msgData.text

    if text:StartsWith('/') and !text:StartsWith('//') and !text:StartsWith('/?') then
      msgData.filter = 'command'
      msgData.isCommand = true
      msgData.radius = -1

      return true
    end
  end)

  chatbox.AddPrefix('/?', function(msgData)
    local text = msgData.text

    if IsValid(msgData.sender) and msgData.sender:IsAdmin() and text:StartsWith('/?') then
      msgData.filter = 'command_no_announcement'
      msgData.isCommand = true
      msgData.isCommandSilent = true
      msgData.radius = -1

      return true
    end
  end)

  chatbox.AddPrefix('@', function(msgData)
    local text = msgData.text

    if text:StartsWith('@') then
      msgData.filter = 'admin'
      msgData.radius = 0

      return true
    end
  end)

  -- Admins only: the message is shown to everyone without a name, like one from the server itself.
  chatbox.AddPrefix('<sys>', function(msgData)
    local text = msgData.text

    if IsValid(msgData.sender) and msgData.sender:IsAdmin() and text:StartsWith('<sys>') then
      msgData.filter = 'player_as_system'
      msgData.radius = 0

      return true
    end
  end)
end

--- Returns whether a listener receives a message, according to the message's filter.
--
-- An invalid listener (such as the server console) receives everything except
-- in-character messages.
-- @param listener [Player The player to check]
-- @param messageData [Map The message table; `messageData.filter` names the filter and defaults to `'default'`]
-- @return [Boolean Whether the listener receives the message]
-- @see chatbox.AddFilter
function chatbox.PlayerCanHear(listener, messageData)
  if !IsValid(listener) then
    return messageData.filter != 'ic'
  end

  return chatbox.GetFilter(messageData.filter or 'default')(listener, messageData)
end

--- Builds a chat message from its arguments and sends it to the listeners that pass its filter.
--
-- Strings are appended to the text, `Color`s wrap the following text in
-- `[color=r,g,b,a]` tags, players append their name and become the message's
-- position and `players` entry, and tables are merged into the message to set
-- fields such as `filter`, `icon`, `radius`, `sender` or `textColor`. The
-- message defaults to the `'default'` filter and the information icon.
--
-- Fires `ChatAddText(listeners, message)`, then `ChatboxAdjustMessageInfo(message,
-- listeners)` (returning `false` there cancels the message), sends the message
-- over the `ChatboxAddText` netstream to the listeners that pass its filter (an
-- unknown filter counts as `'default'`) and finally fires
-- `ChatboxMessageSent(message)`.
--
-- ```
-- chatbox.AddText(nil, Color(255, 100, 100), 'The server restarts in five minutes.', {
--   filter = 'events',
--   icon = 'icon16/error.png'
-- })
-- ```
--
-- @param listeners=nil [Player A player or a list of players to send to; `nil` sends to everyone]
-- @param ... [Any Strings, colors, players and option tables making up the message]
-- @return [Map The message table with a `listeners` key added (the list of players it was sent to), or `nil` if
-- a hook cancelled it or the only listener is no longer valid]
-- @see chatbox.SayAsPlayer
function chatbox.AddText(listeners, ...)
  local args = { ... }
  local message = {
    text = '',
    filter = 'default',
    icon = 'icon16/information.png',
    time = os.time(),
    sendTime = CurTime(),
    drawAvatar = false,
    drawTime = true,
    drawModel = false,
    isPlayerMessage = false,
    rich = true,
    translate = true,
    players = {},
    data = {}
  }

  if listeners == nil then
    listeners = _player.GetAll()
  elseif !istable(listeners) and !IsValid(listeners) then
    -- A player who has left since the caller got hold of them.
    return
  end

  local colored = false
  local curColor = Color(255, 255, 255)

  for k, v in pairs(args) do
    if isstring(v) then
      if colored then
        message.text = message.text..'[color='..curColor.r..','..curColor.g..','..curColor.b..','..curColor.a..']'
      end

      message.text = message.text..v

      if colored and v:lower():find('[/color]') then
        colored = false
      end
    elseif IsColor(v) then
      if colored then
        message.text = message.text..'[/color]'
      end

      message.text = message.text..'[color='..v.r..','..v.g..','..v.b..','..v.a..']'

      colored = true
      curColor = v
    elseif typeof(v) == 'player' then
      message.text = message.text..v:Name()
      message.position = v:GetPos()
      table.insert(message.players, v)
    elseif istable(v) then
      table.Merge(message, v)
    end
  end

  if colored then
    message.text = message.text..'[/color]'
  end

  if IsValid(listeners) then
    message.position = message.position or listeners:GetPos()
  else
    if IsValid(message.players[1]) then
      message.position = message.position or message.players[1]:GetPos()
    end
  end

  hook.Run('ChatAddText', listeners, message)

  if hook.Run('ChatboxAdjustMessageInfo', message, listeners) == false then
    return
  end

  if cw.DeveloperVersion then
    print('[Chat::'..message.filter:upper()..'] '..message.text)
  end

  local filterCallback = chatbox.GetFilter(message.filter) or chatbox.GetFilter('default')
  local recipients = {}

  for k, v in ipairs(IsValid(listeners) and { listeners } or listeners) do
    if filterCallback(v, message) then
      recipients[#recipients + 1] = v
    end
  end

  -- Sent in one go, so that the message is only encoded once.
  netstream.Start(recipients, 'ChatboxAddText', message)

  message.listeners = recipients

  hook.Run('ChatboxMessageSent', message)

  return message
end

--- Makes a player say something in character, as if they had typed it.
--
-- The text is quoted and sent through `chatbox.AddText` with the `'ic'`
-- filter, so only players within the radius receive it.
-- @param player [Player The player who speaks]
-- @param radius=nil [Number Hearing radius; `nil` uses the `talk_radius` config]
-- @param text [String What the player says]
-- @see chatbox.AddText
function chatbox.SayAsPlayer(player, radius, text)
  chatbox.AddText(nil, '"'..text..'"', {
    sender = player,
    isPlayerMessage = true,
    filter = 'ic',
    radius = radius,
    textColor = Color(255, 255, 200, 255)
  })
end

--- Sets `chatbox.clientMode`, which marks that the message being built was requested by a client.
--
-- The `ChatboxAddText` netstream receiver turns it on around its call to
-- `chatbox.AddText`.
-- @param isclient [Boolean Whether client mode is on]
function chatbox.SetClientMode(isclient)
  chatbox.clientMode = isclient
end

-- Message fields that server code acts on. A client asking for a message in its own chat box may not set them.
local clientBlockedFields = { 'voice', 'listeners', 'players', 'position' }

netstream.Hook('ChatboxAddText', function(player, ...)
  local args = {}

  for i = 1, math.min(select('#', ...), 64) do
    local v = select(i, ...)

    if istable(v) then
      for k2, v2 in ipairs(clientBlockedFields) do
        v[v2] = nil
      end

      if v.sender != player then v.sender = nil end
      if !isstring(v.filter) then v.filter = nil end
      if !isstring(v.text) then v.text = nil end
      if !istable(v.data) then v.data = nil end

      args[#args + 1] = v
    elseif isstring(v) or type(v) == 'Player' then
      args[#args + 1] = v
    end
  end

  -- Players named in the message would otherwise set its position, and so reveal where they are.
  args[#args + 1] = { position = player:GetPos() }

  chatbox.SetClientMode(true)
  chatbox.AddText(player, unpack(args))
  chatbox.SetClientMode(false)
end)

local adminNames = {
  'Console', 'kurozael', 'alexgrist',
  'John Smith', 'John Doe', 'Jane Doe',
  'Ivan', 'Admin', 'An Admin', 'Administrator',
  'Gabe Newell', 'Tim Cook', 'Vladimir Putin',
  'Bill Gates', 'Donald Trump', 'Barack Obama',
  'Russian Hackers', 'Ukrainians', 'Ponis', 'A',
  'Wheatley', 'GLaDOS', 'Chell', 'Mel', 'Gordon Freeman',
  'Wallace Breen', 'Robots', 'Machines', 'Heavy', 'Scout',
  'Spy', 'Medic', 'Pyro', 'Soldier', 'Eye of Harmony',
  'Eye of Chaos', 'Garry Newman', 'Robotboy665', 'D}|{et',
  'NightAngel', 'Mr. Meow', 'Zig', 'DarkMind187', 'Matew',
  'Fixxer', 'RJ', 'duck', 'Gurrazor', '$30', 'CloudAuthX',
  'CloudAuth', "kuro's backdoors", "kurozael's backdoors",
  'Microsoft', 'Apple', 'John Cena', 'BOT Gabe', 'BOT Ivan',
  'You', 'Schwarz Kruppzo', 'The Combine', 'Universal Union',
  'OTA', 'Rebels'
}

local slanderPhrases = {
  ['сервер говно'] = true, ['сервер гавно'] = true, ['сирвир говно'] = true,
  ['сирвир гавно'] = true, ['этот сервер говно'] = true, ['ваш сервер говно'] = true,
  ['блоубек говно'] = true, ['мяу лох'] = true, ['этот сервер гавно'] = true,
  ['ваш сервер гавно'] = true, ['блоубек гавно'] = true, ['blowback говно'] = true,
  ['сервер параша'] = true, ['ваш сервер параша'] = true, ['этот сервер параша'] = true,
  ['сервер дерьмо'] = true, ['этот сервер дерьмо'] = true, ['ваш сервер дерьмо'] = true,
  ['пони для девочек'] = true, ['пони для долбоебов'] = true
}

netstream.Hook('ChatboxTextEntered', function(player, msgText)
  if !isstring(msgText) or msgText == '' then return end

  if !IsValid(player) then
    print('[Catwork Debug] Player is not valid. This should never happen.')

    return
  end

  local curTime = CurTime()

  -- Nobody types this fast; without it a client could flood everyone in range as fast as it can send.
  if player.cwNextChatText and curTime < player.cwNextChatText then return end

  player.cwNextChatText = curTime + 0.2

  local maxChatLength = config.GetVal('max_chat_length')
  local maxBytes = (maxChatLength + 8) * 4

  -- The text is cut to the maximum length further down; do not process more of it than can survive that.
  -- The pattern drops the last multi-byte character, which the cut may have split.
  if #msgText > maxBytes then
    msgText = string.gsub(string.sub(msgText, 1, maxBytes), '[\192-\255][\128-\191]*$', '')
  end

  local lowerText = msgText:utf8lower()
  lowerText = lowerText:Replace('.//', '')
  lowerText = lowerText:Replace('//', '')
  lowerText = lowerText:Replace('[[', '')
  lowerText = lowerText:Replace('/y', '')
  lowerText = lowerText:Replace('/w', '')

  if slanderPhrases[lowerText] then
    cw.player:NotifyAll(L('Chat_SlanderKick', player:Name()))

    if lowerText:find('пони для девочек') then
      player:Kick('Сам ты для девочек.')
    elseif lowerText:find('пони для долбоебов') then
      player:Kick('Сам ты для долбоебов.')
    elseif lowerText:find('лох') then
      player:Kick('Сам ты лох.')
    else
      player:Kick('Сам ты говно.')
    end

    return
  end

  local message = {
    text = msgText, -- text of the message
    playerName = player:Name(), -- name of the player who sent this message
    sender = player, -- player object
    filter = 'ic', -- filter id
    time = os.time(),
    sendTime = curTime,
    position = player:GetPos(),
    steamID = player:SteamID(),
    steamID64 = player:SteamID64(),
    data = {}
  }

  if msgText:StartsWith('/?') and !player:IsAdmin() then
    cw.player:Notify(player, L('Chat_NotValidCommand'))

    return
  end

  if msgText:StartsWith('//') then
    chatbox.GetPrefix('//').Callback(message)
  else
    for k, v in pairs(chatbox.prefixes) do
      if k == '//' then continue end

      if msgText:StartsWith(k) then
        if v.Callback(message) then
          break
        end
      end
    end
  end

  if string.utf8len(message.text) >= maxChatLength then
    message.text = string.utf8sub(message.text, 0, maxChatLength)
    message.text = message.text..'...'
  end

  hook.Run('ChatboxPlayerSay', player, message)

  if hook.Run('ChatboxAdjustMessageInfo', message) == false then
    return
  end

  if message.isCommand then
    local arguments = cw.core:ExplodeByTags(message.text, ' ', '"', '"', true)

    if message.isCommandSilent then
      player:OverrideName(table.Random(adminNames))

      -- The fake name must not outlive the command, even if the command errors.
      local bSuccess, errorText = pcall(cw.command.ConsoleCommand, cw.command, player, 'cwCmd', arguments)

      player:OverrideName(nil)

      if !bSuccess then
        ErrorNoHalt(tostring(errorText)..'\n')
      end
    else
      cw.command:ConsoleCommand(player, 'cwCmd', arguments)
    end

    return
  elseif message.data.anon then
    message.playerName = '#Chat_Someone'
  end

  local shouldSend = true

  if message.filter == 'ooc' then
    if !hook.Run('PlayerCanSayOOC', player, message.text) then return end

    if !player.cwNextTalkOOC or curTime > player.cwNextTalkOOC or player:IsAdmin() then
      player.cwNextTalkOOC = curTime + config.Get('ooc_interval'):Get()
    else
      cw.player:Notify(
        player, L('Chat_OOCWait', math.ceil(player.cwNextTalkOOC - curTime))
      )

      return
    end
  elseif message.filter == 'looc' then
    if message.text != '' then
      if !hook.Run('PlayerCanSayLOOC', player, message.text) then return end

      if !player.cwNextTalkLOOC or curTime > player.cwNextTalkLOOC or player:IsAdmin() then
        player.cwNextTalkLOOC = curTime + config.Get('looc_interval'):Get()
      else
        cw.player:Notify(
          player, L('Chat_LOOCWait', math.ceil(player.cwNextTalkLOOC - curTime))
        )

        return
      end
    end
  elseif message.filter == 'ic' then
    if hook.Run('PlayerCanSayIC', player, message.text) == false then
      shouldSend = false
    else
      if cw.player:GetDeathCode(player, true) then
        cw.player:UseDeathCode(player, nil, { message.text })
      end

      message.text = '"'..message.text..'"'
    end
  end

  if cw.player:GetDeathCode(player) then
    cw.player:TakeDeathCode(player)
  end

  if !shouldSend then return end
  if message.text == '' or message.text == ' ' then return end

  print('['..message.filter:upper()..'] '..player:Name()..': '..message.text)

  local filterCallback = chatbox.GetFilter(message.filter) or chatbox.GetFilter('default')
  local listeners = {}

  for k, v in ipairs(_player.GetAll()) do
    if filterCallback(v, message) then
      listeners[#listeners + 1] = v
    end
  end

  -- Sent in one go, so that the message is only encoded once.
  netstream.Start(listeners, 'ChatboxTextEnter', player, message)

  message.listeners = listeners

  hook.Run('ChatboxMessageSent', message)
end)
