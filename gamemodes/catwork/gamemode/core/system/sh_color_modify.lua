--- Registers the `Color Modify` system, which lets admins with the `a` flag tune a screen color modification applied to
-- every player.
--
-- The client page has an enable checkbox and sliders for brightness, contrast, color and the add and multiply
-- channels. Changes go to the server over the `SystemColSet` netstream, are validated and stored in
-- `cw.OverrideColorMod`, saved to the `color` schema data file (which the server loads again when it starts) and
-- broadcast back to all clients.

local ACCESS_FLAG = 'a'

-- The slider settings of each value. The server clamps what it is sent to the same range.
local KEY_INFO = {
  brightness = { name = '#System_ColorModify_Brightness', minimum = -2, maximum = 2, decimals = 2 },
  contrast = { name = '#System_ColorModify_Contrast', minimum = 0, maximum = 10, decimals = 2 },
  color = { name = '#System_ColorModify_Color', minimum = 0, maximum = 5, decimals = 2 },
  addr = { name = '#System_ColorModify_AddRed', minimum = 0, maximum = 255, decimals = 0 },
  addg = { name = '#System_ColorModify_AddGreen', minimum = 0, maximum = 255, decimals = 0 },
  addb = { name = '#System_ColorModify_AddBlue', minimum = 0, maximum = 255, decimals = 0 },
  mulr = { name = '#System_ColorModify_MulRed', minimum = 0, maximum = 255, decimals = 0 },
  mulg = { name = '#System_ColorModify_MulGreen', minimum = 0, maximum = 255, decimals = 0 },
  mulb = { name = '#System_ColorModify_MulBlue', minimum = 0, maximum = 255, decimals = 0 }
}

local SLIDER_KEYS = { 'brightness', 'contrast', 'color', 'addr', 'addg', 'addb', 'mulr', 'mulg', 'mulb' }

local DEFAULT_COLOR_MOD = {
  brightness = 0,
  contrast = 1,
  enabled = false,
  color = 1,
  mulr = 0,
  mulg = 0,
  mulb = 0,
  addr = 0,
  addg = 0,
  addb = 0
}

--- Checks a color modification value and clamps numbers to their slider range.
-- @param key [Any The key the value is for]
-- @param value [Any The value to check]
-- @return [Any The value to store: a boolean for `enabled`, a clamped number for the other keys, or `nil` when the
-- key is unknown or the value has the wrong type]
local function GetValidValue(key, value)
  if key == 'enabled' then
    if isbool(value) then
      return value
    end

    return
  end

  local info = KEY_INFO[key]

  if info and isnumber(value) and value == value then
    return math.Clamp(value, info.minimum, info.maximum)
  end
end

--- Builds a complete color modification table from stored or networked data.
-- @param data [Any The data to read; anything but a table gives the defaults]
-- @return [Map The defaults, overridden by every valid value of `data`]
local function SanitizeColorMod(data)
  local colorMod = table.Copy(DEFAULT_COLOR_MOD)

  if istable(data) then
    for k in pairs(DEFAULT_COLOR_MOD) do
      local value = GetValidValue(k, data[k])

      if value != nil then
        colorMod[k] = value
      end
    end
  end

  return colorMod
end

if CLIENT then
  local SYSTEM = cw.system:New('Color Modify')
  SYSTEM.access = ACCESS_FLAG
  SYSTEM.toolTip = '#System_ColorModify_ToolTip'
  SYSTEM.doesCreateForm = false
  cw.OverrideColorMod = SanitizeColorMod(cw.core:RestoreSchemaData('color', false))

  --- Returns the current color modification values.
  -- @return [Map The `cw.OverrideColorMod` table: `enabled` plus the brightness, contrast, color and add/mul channels]
  function SYSTEM:GetModifyTable()
    return cw.OverrideColorMod
  end

  --- Returns the slider settings for a color modification key.
  -- @param key [String One of `brightness`, `contrast`, `color`, `addr`, `addg`, `addb`, `mulr`, `mulg` or `mulb`]
  -- @return [Map `name` (language key), `minimum`, `maximum` and `decimals` for the slider, or `nil`
  -- for an unknown key]
  function SYSTEM:GetKeyInfo(key)
    return KEY_INFO[key]
  end

  --- Builds the enable checkbox and one slider per color modification value.
  --
  -- Changes are sent to the server with the `SystemColSet` netstream once the mouse button is released.
  -- @param systemPanel [Panel The system panel to add the form to]
  -- @param systemForm [Panel The system's form (unused, the system does not create one)]
  function SYSTEM:OnDisplay(systemPanel, systemForm)
    local infoText = vgui.Create('cwInfoText', systemPanel)
      infoText:SetText('#System_ColorModify_Info')
      infoText:SetInfoColor('blue')
      infoText:DockMargin(0, 0, 0, 8)
    systemPanel.panelList:AddItem(infoText)

    local infoText = vgui.Create('cwInfoText', systemPanel)
      infoText:SetText('#System_ColorModify_Warning')
      infoText:SetInfoColor('orange')
      infoText:DockMargin(0, 0, 0, 8)
    systemPanel.panelList:AddItem(infoText)

    self.colorModForm = vgui.Create('DForm', systemPanel)
      self.colorModForm:SetName('#System_ColorModify_Color')
      self.colorModForm:SetPadding(4)
    systemPanel.panelList:AddItem(self.colorModForm)

    local checkBox = self.colorModForm:CheckBox('#System_Enabled')
    checkBox.OnChange = function(checkBox, value)
      if value != cw.OverrideColorMod.enabled then
        netstream.Start('SystemColSet', { key = 'enabled', value = value })
      end
    end

    checkBox:SetValue(cw.OverrideColorMod.enabled)

    for _, k in ipairs(SLIDER_KEYS) do
      local info = self:GetKeyInfo(k)
      local numSlider = self.colorModForm:NumSlider(info.name, nil, info.minimum, info.maximum, info.decimals)
      numSlider.OnValueChanged = function(numSlider, value)
        if value != cw.OverrideColorMod[k] then
          local timerName = 'ColorModifySet: '..k
          timer.Create(timerName, 1, 0, function()
            if !input.IsMouseDown(MOUSE_LEFT) then
              netstream.Start('SystemColSet', { key = k, value = value })
              timer.Remove(timerName)
            end
          end)
        end
      end

      numSlider:SetValue(cw.OverrideColorMod[k])
    end
  end

  SYSTEM:Register()

  netstream.Hook('SystemColSet', function(data)
    local value = GetValidValue(data.key, data.value)

    if value == nil then
      return
    end

    cw.OverrideColorMod[data.key] = value
      cw.core:SaveSchemaData('color', cw.OverrideColorMod)
    local systemTable = cw.system:FindByID('Color Modify')

    if systemTable then
      systemTable:Rebuild()
    end
  end)

  netstream.Hook('SystemColGet', function(data)
    cw.OverrideColorMod = SanitizeColorMod(data)
    cw.core:SaveSchemaData('color', cw.OverrideColorMod)
  end)
else
  cw.OverrideColorMod = SanitizeColorMod(cw.OverrideColorMod or cw.core:RestoreSchemaData('color', false))

  netstream.Hook('SystemColSet', function(player, data)
    if !istable(data) or !cw.player:HasFlags(player, ACCESS_FLAG) then
      return
    end

    local key = data.key
    local value = GetValidValue(key, data.value)

    if value == nil or cw.OverrideColorMod[key] == value then
      return
    end

    cw.OverrideColorMod[key] = value
    cw.core:SaveSchemaData('color', cw.OverrideColorMod)
    netstream.Start(nil, 'SystemColSet', { key = key, value = value })
  end)
end
