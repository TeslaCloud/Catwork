--- Defines the server-side `cw.hint` library, which sends hint text to players and keeps the list of gameplay hints
-- shown at random.
--
-- `cw.hint:Send` and `cw.hint:SendCenter` show a hint to one player, and `cw.hint:Distribute` sends a random
-- registered hint to every player who wants hints. The file adds the framework's default hints.

library.New('hint', cw)

local stored = cw.hint.stored or {}
cw.hint.stored = stored

--- Adds a hint to the list that `cw.hint:Distribute` picks from.
--
-- Adding a hint under an existing name replaces it.
--
-- ```
-- cw.hint:Add('Recognise', '#Hints_Recognise', function(player)
--   return config.Get('recognise_system'):Get()
-- end)
-- ```
--
-- @param name [String Unique identifier of the hint]
-- @param text [String The hint text; may be a `#Phrase` language key]
-- @param Callback=nil [Function Called as `Callback(player)`; return `false` to hide the hint. `cw.hint:Get` calls
-- it without a player]
-- @see cw.hint:Remove
function cw.hint:Add(name, text, Callback)
  stored[name] = {
    Callback = Callback,
    text = text
  }
end

--- Removes a hint from the list.
-- @param name [String Identifier the hint was added under]
function cw.hint:Remove(name)
  stored[name] = nil
end

--- Returns a hint by its identifier.
-- @param name [String Identifier the hint was added under]
-- @return [Map The hint with `text` and `Callback` keys, or `nil` if there is none]
function cw.hint:Find(name)
  return stored[name]
end

--- Sends a random hint to every player who wants to see hints.
--
-- Players must have initialized, have the `cwShowHints` client convar set to
-- `1`, not be viewing the starter hints, and pass the hint's callback. The
-- hint is shown for 6 seconds. Does nothing if no hint is available.
-- @see cw.hint:Get
function cw.hint:Distribute()
  local hintText, Callback = self:Get()

  if !hintText then return end

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() and v:GetInfoNum('cwShowHints', 1) == 1
    and !v:IsViewingStarterHints() then
      if !Callback or Callback(v) != false then
        self:Send(v, hintText, 6, nil, true)
      end
    end
  end
end

--- Sends a hint to be shown in the center of the screen.
--
-- The text is parsed with `cw.core:ParseData` and translated on the client.
-- @param player [Player The recipient, a list of players, or `nil` for everyone]
-- @param text [String The hint text; may be a `#Phrase` language key]
-- @param delay [Number Seconds the hint stays on screen]
-- @param color=nil [Color Text color, or the name of a `cw.option` color; defaults to white]
-- @param bNoSound=nil [Any `nil` plays the default blip, a string plays that sound file, anything else plays
-- no sound]
-- @param showDuplicated=nil [Boolean Show the hint even if the same text is already on screen]
-- @see cw.hint:SendCenterAll
function cw.hint:SendCenter(player, text, delay, color, bNoSound, showDuplicated)
  cable.send(player, 'Hint', {
    text = cw.core:ParseData(text),
    delay = delay,
    color = color,
    center = true,
    noSound = bNoSound,
    showDuplicates = showDuplicated
  })
end

--- Sends a centered hint to every player who has initialized.
-- @param text [String The hint text; may be a `#Phrase` language key]
-- @param delay [Number Seconds the hint stays on screen]
-- @param color=nil [Color Text color, or the name of a `cw.option` color; defaults to white]
-- @see cw.hint:SendCenter
function cw.hint:SendCenterAll(text, delay, color)
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      self:SendCenter(v, text, delay, color)
    end
  end
end

--- Sends a hint to be shown at the top right of the screen.
--
-- The text is parsed with `cw.core:ParseData` and translated on the client.
-- @param player [Player The recipient, a list of players, or `nil` for everyone]
-- @param text [String The hint text; may be a `#Phrase` language key]
-- @param delay [Number Seconds the hint stays on screen]
-- @param color=nil [Color Text color, or the name of a `cw.option` color; defaults to white]
-- @param bNoSound=nil [Any `nil` plays the default blip, a string plays that sound file, anything else plays
-- no sound]
-- @param showDuplicated=nil [Boolean Show the hint even if the same text is already on screen]
-- @see cw.hint:SendAll
function cw.hint:Send(player, text, delay, color, bNoSound, showDuplicated)
  cable.send(player, 'Hint', {
    text = cw.core:ParseData(text), delay = delay, color = color, noSound = bNoSound, showDuplicates = showDuplicated
  })
end

--- Sends a hint to every player who has initialized.
-- @param text [String The hint text; may be a `#Phrase` language key]
-- @param delay [Number Seconds the hint stays on screen]
-- @param color=nil [Color Text color, or the name of a `cw.option` color; defaults to white]
-- @see cw.hint:Send
function cw.hint:SendAll(text, delay, color)
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      self:Send(v, text, delay, color)
    end
  end
end

--- Picks a random hint whose callback does not return `false`.
--
-- The callbacks are called without a player here. Returns nothing if no hint
-- is available.
-- @return [String The hint text, Function The hint's callback, or `nil` if it has none]
function cw.hint:Get()
  local hints = {}

  for k, v in pairs(stored) do
    if !v.Callback or v.Callback() != false then
      hints[#hints + 1] = v
    end
  end

  if #hints > 0 then
    local hint = hints[math.random(1, #hints)]

    if hint then
      return hint.text, hint.Callback
    end
  end
end

cw.hint:Add('OOC', '#Hints_OOC')
cw.hint:Add('LOOC', '#Hints_LOOC')
cw.hint:Add('Ducking', '#Hints_Ducking')
cw.hint:Add('Directory', '#Hints_Directory')
cw.hint:Add('F1 Hotkey', '#Hints_F1_Hotkey')
cw.hint:Add('F2 Hotkey', '#Hints_F2_Hotkey')
cw.hint:Add('Tab Hotkey', '#Hints_Tab_Hotkey')

cw.hint:Add('Context Menu', '#Hints_Context_Menu', function(player)
  return !config.Get('use_opens_entity_menus'):Get()
end)

cw.hint:Add('Entity Menu', '#Hints_Entity_Menu', function(player)
  return config.Get('use_opens_entity_menus'):Get()
end)

cw.hint:Add('Phys Desc', '#Hints_Phys_Desc', function(player)
  return cw.command:FindByID('CharPhysDesc') != nil
end)

cw.hint:Add('Give Name', '#Hints_Give_Name', function(player)
  return config.Get('recognise_system'):Get()
end)

cw.hint:Add('Raise Weapon', '#Hint_Raise_Weapon', function(player)
  return config.Get('raised_weapon_system'):Get()
end)

cw.hint:Add('Target Recognises', '#Hint_Target_Recognises', function(player)
  return config.Get('recognise_system'):Get()
end)
