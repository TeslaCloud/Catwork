--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('setting', cw)

cw.setting.stored = cw.setting.stored or {}

--- Adds a slider to the settings menu that changes a number console variable.
--
-- A setting is keyed by its console variable, so adding another setting for the
-- same variable replaces it.
--
-- ```
-- cw.setting:AddNumberSlider('#Framework', '#HeadbobAmount', 'cwHeadbobScale', 0, 1, 1, '#HeadbobAmountDesc')
-- ```
--
-- @param category [String Category of the settings menu, or a language phrase]
-- @param text [String Label of the setting, or a language phrase]
-- @param conVar [String Name of the console variable]
-- @param minimum [Number Lowest value]
-- @param maximum [Number Highest value]
-- @param decimals [Number Number of decimal places]
-- @param toolTip=nil [String Tooltip of the setting, or a language phrase]
-- @param Condition=nil [Function Returns whether the setting is shown; shown always when `nil`]
-- @return [String Index of the setting, which is `conVar`]
function cw.setting:AddNumberSlider(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
  local index = conVar

  self.stored[index] = {
    Condition = Condition,
    category = category,
    decimals = decimals,
    toolTip = toolTip,
    maximum = maximum,
    minimum = minimum,
    conVar = conVar,
    class = 'numberSlider',
    text = text
  }

  return index
end

--- Adds a drop-down list to the settings menu that sets a console variable.
-- @param category [String Category of the settings menu, or a language phrase]
-- @param text [String Label of the setting, or a language phrase]
-- @param conVar [String Name of the console variable]
-- @param options=nil [Map Values the variable is set to, keyed by the text shown for them]
-- @param toolTip=nil [String Tooltip of the setting, or a language phrase]
-- @param Condition=nil [Function Returns whether the setting is shown; shown always when `nil`]
-- @return [String Index of the setting, which is `conVar`]
function cw.setting:AddMultiChoice(category, text, conVar, options, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
  local index = conVar

  if options then
    table.sort(options, function(a, b) return a < b end)
  else
    options = {}
  end

  self.stored[index] = {
    Condition = Condition,
    category = category,
    toolTip = toolTip,
    options = options,
    conVar = conVar,
    class = 'multiChoice',
    text = text
  }

  return index
end

--- Adds a number box to the settings menu that changes a number console variable.
-- @param category [String Category of the settings menu, or a language phrase]
-- @param text [String Label of the setting, or a language phrase]
-- @param conVar [String Name of the console variable]
-- @param minimum [Number Lowest value]
-- @param maximum [Number Highest value]
-- @param decimals [Number Number of decimal places]
-- @param toolTip=nil [String Tooltip of the setting, or a language phrase]
-- @param Condition=nil [Function Returns whether the setting is shown; shown always when `nil`]
-- @return [String Index of the setting, which is `conVar`]
function cw.setting:AddNumberWang(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
  local index = conVar

  self.stored[index] = {
    Condition = Condition,
    category = category,
    decimals = decimals,
    toolTip = toolTip,
    maximum = maximum,
    minimum = minimum,
    conVar = conVar,
    class = 'numberWang',
    text = text
  }

  return index
end

--- Adds a text box to the settings menu that sets a string console variable.
-- @param category [String Category of the settings menu, or a language phrase]
-- @param text [String Label of the setting, or a language phrase]
-- @param conVar [String Name of the console variable]
-- @param toolTip=nil [String Tooltip of the setting, or a language phrase]
-- @param Condition=nil [Function Returns whether the setting is shown; shown always when `nil`]
-- @return [String Index of the setting, which is `conVar`]
function cw.setting:AddTextEntry(category, text, conVar, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
  local index = conVar

  self.stored[index] = {
    Condition = Condition,
    category = category,
    toolTip = toolTip,
    conVar = conVar,
    class = 'textEntry',
    text = text
  }

  return index
end

--- Adds a check box to the settings menu that toggles a console variable.
--
-- ```
-- cw.setting:AddCheckBox('#AdminESP', '#EnableAdminESP', 'cwAdminESP', '#EnableAdminESPDesc', function()
--   return cw.player:IsAdmin(cw.client)
-- end)
-- ```
--
-- @param category [String Category of the settings menu, or a language phrase]
-- @param text [String Label of the setting, or a language phrase]
-- @param conVar [String Name of the console variable]
-- @param toolTip=nil [String Tooltip of the setting, or a language phrase]
-- @param Condition=nil [Function Returns whether the setting is shown; shown always when `nil`]
-- @return [String Index of the setting, which is `conVar`]
function cw.setting:AddCheckBox(category, text, conVar, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
  local index = conVar

  self.stored[index] = {
    Condition = Condition,
    category = category,
    toolTip = toolTip,
    conVar = conVar,
    class = 'checkBox',
    text = text
  }

  return index
end

--- Adds a color picker to the settings menu.
--
-- The color is stored in four console variables named after `conVar` with `R`,
-- `G`, `B` and `A` appended.
-- @param category [String Category of the settings menu, or a language phrase]
-- @param text [String Label of the setting, or a language phrase]
-- @param conVar [String Prefix of the console variable names]
-- @param toolTip=nil [String Tooltip of the setting, or a language phrase]
-- @param Condition=nil [Function Returns whether the setting is shown; shown always when `nil`]
-- @return [String Index of the setting, which is `conVar`]
function cw.setting:AddColorMixer(category, text, conVar, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
  local index = conVar

  self.stored[index] = {
    Condition = Condition,
    category = category,
    toolTip = toolTip,
    conVar = conVar,
    class = 'colorMixer',
    text = text
  }

  return index
end

--- Removes a setting by its index.
-- @param index [String Index returned when the setting was added]
function cw.setting:RemoveByIndex(index)
  self.stored[index] = nil
end

--- Removes every setting bound to a console variable.
-- @param conVar [String Name of the console variable]
function cw.setting:RemoveByConVar(conVar)
  for k, v in pairs(self.stored) do
    if v.conVar == conVar then
      self.stored[k] = nil
    end
  end
end

--- Removes every setting that matches all of the given fields.
--
-- A `nil` field matches anything, so `cw.setting:Remove('#AdminESP')` removes a whole category.
-- @param category=nil [String Category of the setting]
-- @param text=nil [String Label of the setting]
-- @param class=nil [String Kind of setting: `'numberSlider'`, `'multiChoice'`, `'numberWang'`,
-- `'textEntry'`, `'checkBox'` or `'colorMixer'`]
-- @param conVar=nil [String Name of the console variable]
function cw.setting:Remove(category, text, class, conVar)
  for k, v in pairs(self.stored) do
    if (!category or v.category == category)
    and (!conVar or v.conVar == conVar)
    and (!class or v.class == class)
    and (!text or v.text == text) then
      self.stored[k] = nil
    end
  end
end

--- Adds Catwork's own settings: framework options, language, theme and admin ESP.
--
-- Called from the `ClockworkInitialized` hook. Theme choice is only shown when
-- the `modify_themes` config is on, and the ESP settings only to admins.
function cw.setting:AddSettings()
  local langTable = {}

  for k, v in pairs(cw.lang:GetAll()) do
    langTable[v.name] = k
  end

  local themeTable = {}

  for k, v in pairs(cw.theme:GetAll()) do
    themeTable[k] = k
  end

  local frameworkStr = '#Framework'
  local chatBoxStr = '#ChatBox'
  local themeStr = '#Theme'
  local adminESP = '#AdminESP'

  cw.setting:AddNumberSlider(frameworkStr, '#HeadbobAmount', 'cwHeadbobScale', 0, 1, 1, '#HeadbobAmountDesc')
  cw.setting:AddNumberSlider(frameworkStr, '#MusicVolume', 'nombat_volume', 0, 100, 1, '#MusicVolumeDesc')

  cw.setting:AddCheckBox(frameworkStr, '#EnableConsoleLog', 'cwShowLog', '#EnableConsoleLogDesc', function()
    return cw.player:IsAdmin(cw.client)
  end)

  cw.setting:AddCheckBox(frameworkStr, '#TwelveHourClock', 'cwTwelveHourClock', '#TwelveHourClockDesc')
  cw.setting:AddCheckBox(frameworkStr, '#ShowBars', 'cwTopBars', '#ShowBarsDesc')
  cw.setting:AddCheckBox(frameworkStr, '#EnableHints', 'cwShowHints', '#EnableHintsDesc')
  cw.setting:AddMultiChoice(frameworkStr, '#Language', 'cwLanguage', langTable, '#LangDesc')
  cw.setting:AddCheckBox(frameworkStr, '#EnableVignette', 'cwShowVignette', '#EnableVignetteDesc')

  cw.setting:AddMultiChoice(themeStr, themeStr, 'cwActiveTheme', themeTable, '#ThemeDesc', function ()
    return (config.Get('modify_themes'):GetBoolean())
  end)

  // Schemas can re-add the stuff that was here.

  cw.setting:AddCheckBox(adminESP, '#EnableAdminESP', 'cwAdminESP', '#EnableAdminESPDesc', function()
    return cw.player:IsAdmin(cw.client)
  end)

  cw.setting:AddCheckBox(adminESP, '#DrawESPBars', 'cwESPBars', '#DrawESPBarsDesc', function()
    return cw.player:IsAdmin(cw.client)
  end)

  cw.setting:AddCheckBox(adminESP, '#ShowItemEntities', 'cwItemESP', '#ShowItemEntitiesDesc', function()
    return cw.player:IsAdmin(cw.client)
  end)

  cw.setting:AddCheckBox(adminESP, '#ShowSalesmenEntities', 'cwSaleESP', '#ShowSalesmenEntitiesDesc', function()
    return cw.player:IsAdmin(cw.client)
  end)

  cw.setting:AddCheckBox(adminESP, '#ShowStaticProps', 'cwPropESP', '#ShowStaticPropsDesc', function()
    return cw.player:IsAdmin(cw.client)
  end)

  cw.setting:AddNumberSlider(adminESP, '#ESPInterval', 'cwESPTime', 0, 2, 0, '#ESPIntervalDesc', function()
    return cw.player:IsAdmin(cw.client)
  end)
end
