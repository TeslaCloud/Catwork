--- Defines the `cw.lang` library and the global `L` function, which translate `#Phrase` identifiers into the player's
-- language.
--
-- Language files fill the table returned by `cw.lang:GetTable`. On the client `L` translates directly, and
-- `surface.DrawText`, `surface.GetTextSize` and `Panel:SetText` are wrapped to translate phrases automatically; on the
-- server `L` only builds a `#Identifier:arg1,arg2;` string for the client to translate. The language follows the
-- `cwLanguage` console variable, or the game's language when it is empty.

library.New('lang', cw)

local stored = cw.lang.stored or {}
cw.lang.stored = stored

local fileList = cw.lang.fileList or {}
cw.lang.fileList = fileList

CW_LANGUAGE_CLASS = { __index = CW_LANGUAGE_CLASS }

--- Adds a phrase to the language table.
--
-- Same as assigning `lang[identifier] = value`.
--
-- @param identifier [String Phrase identifier, including the leading `#`]
-- @param value [String Translated text; `#1`, `#2`... are replaced with arguments]
function CW_LANGUAGE_CLASS:Add(identifier, value)
  self[identifier] = value
end

--- Returns the phrase table of a language, creating it if it does not exist.
--
-- Language files fill this table with phrases.
--
-- ```
-- local lang = cw.lang:GetTable('en')
--
-- lang.name = 'English'
-- lang['#Gender_Female'] = 'Female'
-- lang['#RequestFrom'] = 'Request from #1: #2'
-- ```
--
-- @param name [String Language code, such as `'en'` or `'ru'`]
-- @return [Map The language's phrase table]
function cw.lang:GetTable(name)
  if !stored[name] then
    stored[name] = cw.core:NewMetaTable(
      CW_LANGUAGE_CLASS
    )
  end

  return stored[name]
end

--- Returns every language's phrase table.
--
-- @return [Map<Map> Phrase tables keyed by language code]
function cw.lang:GetAll()
  return stored
end

--- Records a language file name for a language in `cw.lang.fileList`.
--
-- The file is not loaded.
--
-- @param language [String Language code]
-- @param fileName [String Path of the language file]
function cw.lang:Add(language, fileName)
  if !fileList[language] then
    fileList[language] = {}
  end

  table.insert(fileList[language], fileName)
end

--- Does nothing; kept so existing calls do not error.
--
-- @param language [String Language code, ignored]
function cw.lang:Set(language) end

--- Returns the translation of a phrase in a language.
--
-- Falls back to English, then to the identifier itself. Each argument replaces the first `#key`
-- in the text (`#1` for the first argument), and every `;` is removed from the result.
--
-- @param language [String Language code]
-- @param identifier [String Phrase identifier, including the leading `#`]
-- @param arguments=nil [List Values that replace `#1`, `#2`...; converted with `tostring`]
-- @return [String The translated text]
function cw.lang:GetString(language, identifier, arguments)
  local langTable = stored[language]
  local langString = langTable and langTable[identifier]

  if !langString then
    local english = stored['en']

    langString = (english and english[identifier]) or identifier
  end

  if arguments then
    for k, v in pairs(arguments) do
      -- Arguments are often player-written text, and a '%' is special in a gsub replacement.
      langString = string.gsub(langString, '#'..k, (string.gsub(tostring(v), '%%', '%%%%')), 1)
    end
  end

  if string.find(langString, ';', 1, true) then
    langString = string.gsub(langString, ';', '')
  end

  return langString
end

if CLIENT then
  -- gmod_language is blocked from Lua, so the settings menu writes this instead. Empty means "follow the game".
  local cwLanguage = CreateClientConVar('cwLanguage', '', true, false, 'Interface language, empty to follow the game.')
  local gmodLanguage

  --- Returns the language the interface is shown in.
  --
  -- Uses the `cwLanguage` client setting, or the game's `gmod_language` when it is empty.
  --
  -- @return [String The language code]
  function cw.lang:GetLanguage()
    local lang = cwLanguage:GetString()

    if lang == '' then
      gmodLanguage = gmodLanguage or GetConVar('gmod_language')
      lang = gmodLanguage:GetString()
    end

    return lang
  end

  --- Translates a phrase for the local player.
  --
  -- The identifier can carry arguments in the networked form built by the server's `L`:
  -- `#Identifier:arg1,arg2;`.
  --
  -- ```
  -- L('#Attribute_MaximumReached')
  -- L('#Scoreboard_Ping:'..self.player:Ping()..';')
  -- ```
  --
  -- @param identifier [String Phrase identifier, with optional arguments]
  -- @return [String The translated text, or an empty string when `identifier` is `nil`]
  -- @see cw.lang:GetString
  function L(identifier)
    if !identifier then return '' end

    local args

    -- Get all the arguments.
    if string.find(identifier, ';', 1, true) then
      args = string.Explode(',', identifier)

      local colon = string.find(args[1], ':', 1, true)

      if colon then
        -- The first result will always be the base identifier.
        identifier = string.sub(args[1], 1, colon - 1)
        args[1] = string.sub(args[1], colon + 1)
      end
    end

    return cw.lang:GetString(cw.lang:GetLanguage(), identifier, args)
  end

  if surface.bTranslating == nil then
    surface.bTranslating = true
  end

  --- Turns automatic translation of drawn text and panel text on or off.
  --
  -- Used to keep text such as the chatbox untranslated.
  --
  -- @param bValue [Boolean `true` to stop translating, `false` to translate again]
  function surface.NoTranslate(bValue)
    surface.bTranslating = !bValue
  end

  surface.OldGetTextSize = surface.OldGetTextSize or surface.GetTextSize

  --- Returns the size of a text, translating its phrases first.
  --
  -- Overrides `surface.GetTextSize` so measured text matches the drawn translation. The original is
  -- kept as `surface.OldGetTextSize`.
  --
  -- @param sText [String Text to measure; phrases are translated unless `surface.NoTranslate` is on]
  -- @return [Number The width, Number The height]
  function surface.GetTextSize(sText)
    if surface.bTranslating then
      sText = cw.lang:TranslateText(sText)
    end

    return surface.OldGetTextSize(sText)
  end

  --- Translates every phrase in a text.
  --
  -- Phrases are `#` followed by letters, digits, `_` or `.`. A phrase followed by `:` takes its
  -- arguments up to the next `;`; otherwise it ends at the next space. This always translates, even
  -- while `surface.NoTranslate` is on.
  --
  -- @param sText [String Text containing phrases]
  -- @return [String The text with every phrase translated]
  function cw.lang:TranslateText(sText)
    -- This runs for every text that is drawn or measured, and most of it has no phrases.
    if !string.find(sText, '#', 1, true) then
      return sText
    end

    -- A lone phrase without arguments needs no searching either.
    if string.find(sText, '^#[%w_.]+$') then
      return L(sText)
    end

    local phrases = string.FindAll(sText, '#[%w_.]+')
    local translations = {}

    for k, v in ipairs(phrases) do
      local phraseEnd = nil
      local colonDetected = false

      if sText:sub(v[3] + 1, v[3] + 1) == ':' then
        phraseEnd = sText:find(';', v[2])
        colonDetected = true
      end

      if !phraseEnd and !colonDetected then
        phraseEnd = sText:find(' ', v[2])

        if !phraseEnd then
          phraseEnd = v[3]
        else
          phraseEnd = phraseEnd - 1
        end
      elseif !phraseEnd and colonDetected then
        phraseEnd = v[3]
      end

      translations[#translations + 1] = L(sText:sub(v[2], phraseEnd))
      phrases[k] = sText:sub(v[2], phraseEnd)
    end

    for k, v in ipairs(translations) do
      sText = sText:Replace(phrases[k], v)
    end

    return sText
  end

  surface.OldDrawText = surface.OldDrawText or surface.DrawText

  --- Draws text, translating its phrases first.
  --
  -- Overrides `surface.DrawText` so everything drawn with it, such as `draw.SimpleText`, is
  -- translated. The original is kept as `surface.OldDrawText`.
  --
  -- @param sText [String Text to draw; phrases are translated unless `surface.NoTranslate` is on]
  function surface.DrawText(sText)
    if surface.bTranslating then
      sText = cw.lang:TranslateText(sText)
    end

    return surface.OldDrawText(sText)
  end

  local PANEL_META = FindMetaTable('Panel')

  PANEL_META.OldSetText = PANEL_META.OldSetText or PANEL_META.SetText

  --- Sets a panel's text, translating it when it is a phrase.
  --
  -- Overrides `Panel:SetText`. Text starting with `#` is translated, except on panels with
  -- `AllowInput` set, where the `#` characters are removed instead. The original is kept as
  -- `Panel:OldSetText`.
  --
  -- @param sText [String Text or phrase identifier]
  function PANEL_META:SetText(sText)
    if string.sub(sText, 1, 1) == '#' and surface.bTranslating then
      if self.AllowInput then
        sText = string.gsub(sText, '#', '')
      else
        sText = L(sText)
      end

      self.__PhraseName = sText
    end

    return self:OldSetText(sText)
  end
else
  --[[
    We do this to provide backcompat for the
    few translations that were actually done serverside.

    This is also a way nicer way to do things, but
    you need to remember this is ONLY available serverside.

    Clientside needs to manually concat arguments.
  --]]
  local function BuildPhrase(identifier, ...)
    local arguments = { ... }

    for i = 1, select('#', ...) do
      local value = arguments[i]

      arguments[i] = (value == nil and '') or tostring(value)
    end

    return '#'..identifier..':'..table.concat(arguments, ',')..';'
  end

  --- Builds a phrase string to send to clients, which translate it themselves.
  --
  -- Returns `#Identifier:arg1,arg2;`, which the client's `L` and `cw.lang:TranslateText`
  -- understand. Can also be called without the player, as `L(identifier, ...)`.
  --
  -- ```
  -- cw.player:Notify(player, L('CashSetTarget', '#CashSet_Cash', amount, playerName))
  -- ```
  --
  -- @param player [Player The player the text is for (unused), or the identifier when called without one]
  -- @param identifier [String Phrase identifier without the leading `#`]
  -- @param ... [Any Arguments for `#1`, `#2`... in the phrase; converted with `tostring`]
  -- @return [String The phrase string, or `nil` when there is no identifier]
  function L(player, identifier, ...)
    -- In case the format L(identifier, ...) is used.
    if isstring(player) then
      if identifier then
        return BuildPhrase(player, identifier, ...)
      end

      return BuildPhrase(player, ...)
    elseif identifier then
      return BuildPhrase(identifier, ...)
    end
  end
end

util.IncludeDirectory('language/', true)
