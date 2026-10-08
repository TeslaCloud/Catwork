--- Registers the `Manage Config` system, which lists the config keys and lets admins edit their values in-game.
--
-- The page is shown to players with access to `/CfgSetVar`. Keys and values are requested over the `SystemCfgKeys` and
-- `SystemCfgValue` Cable messages, with private values masked, and `SystemCfgSet` applies a change on the server,
-- optionally for a single map. The server answers all three only for players with that access.

if CLIENT then
  local SYSTEM = cw.system:New('Manage Config')
  SYSTEM.toolTip = '#System_ManageConfig_ToolTip'
  SYSTEM.doesCreateForm = false

  --- Shows the Manage Config system to players who may use the `CfgSetVar` command.
  -- @return [Boolean Whether the player has the command's access flags]
  function SYSTEM:HasAccess()
    local commandTable = cw.command:FindByID('CfgSetVar')

    if commandTable and cw.player:HasFlags(cw.client, commandTable.access) then
      return true
    else
      return false
    end
  end

  --- Builds the config key list and the (hidden) edit form, requesting the key list from the server if needed.
  --
  -- Selecting a row requests that key's value with the `SystemCfgValue` Cable message.
  -- @param systemPanel [Panel The system panel to add the forms to]
  -- @param systemForm [Panel The system's form (unused, the system does not create one)]
  function SYSTEM:OnDisplay(systemPanel, systemForm)
    self.adminValues = nil

    self.infoText = vgui.Create('cwInfoText', systemPanel)
      self.infoText:SetText('#System_ManageConfig_Info')
      self.infoText:SetInfoColor('blue')
      self.infoText:SetTextColor(Color('white'))
      self.infoText:DockMargin(0, 0, 0, 8)
    systemPanel.panelList:AddItem(self.infoText)

    self.configForm = vgui.Create('DForm', systemPanel)
      self.configForm:SetName('#System_ManageConfig_Config')
      self.configForm:SetPadding(4)
    systemPanel.panelList:AddItem(self.configForm)

    self.editForm = vgui.Create('DForm', systemPanel)
      self.editForm:SetName('')
      self.editForm:SetPadding(4)
      self.editForm:SetVisible(false)
    systemPanel.panelList:AddItem(self.editForm)

    if !self.activeKey then
      cable.send('SystemCfgKeys', true)
    end

    self.listView = vgui.Create('DListView')
      self.listView:AddColumn('#System_ManageConfig_Name')
      self.listView:AddColumn('#System_ManageConfig_Key')
      self.listView:AddColumn('#System_ManageConfig_AddedBy')
      self.listView:SetMultiSelect(false)
      self.listView:SetTall(256)
    self:PopulateComboBox()

    function self.listView.OnRowSelected(parent, lineID, line)
      cable.send('SystemCfgValue', line.key)
    end

    self.configForm:AddItem(self.listView)
  end

  --- Fills the edit form for the selected config key (`self.activeKey`).
  --
  -- Shows the key's help text, a map entry and a text entry, slider or checkbox depending on the value's type;
  -- the okay button sends the new value to the server with the `SystemCfgSet` Cable message.
  function SYSTEM:PopulateConfigBox()
    if !IsValid(self.editForm) then
      return
    end

    self.editForm:Clear(true)

    if self.activeKey then
      self.adminValues = config.GetFromSystem(self.activeKey.name)

      self.infoText:SetText('#System_ManageConfig_InfoEditing')
    end

    if !self.editForm:IsVisible() then
      self.editForm:SetVisible(true)
    end

    if self.adminValues then
      for k, v in pairs(string.Explode('\n', self.adminValues.help)) do
        self.editForm:Help(v):SetTextColor(Color('white'))
      end

      self.editForm:SetName(self.activeKey.name)

      if self.activeKey.value != nil then
        local mapEntry, mapLabel = self.editForm:TextEntry('#System_ManageConfig_Map')
        mapLabel:SetTextColor(Color('white'))

        local valueType = type(self.activeKey.value)

        if valueType == 'string' then
          local textEntry, textLabel = self.editForm:TextEntry('#System_ManageConfig_Value')
            textLabel:SetTextColor(Color('white'))
            textEntry:SetValue(self.activeKey.value)
          local okayButton = self.editForm:Button('#System_ManageConfig_Okay')

          -- Called when the button is clicked.
          function okayButton.DoClick(okayButton)
            cable.send('SystemCfgSet', {
              key = self.activeKey.name,
              value = textEntry:GetValue(),
              useMap = mapEntry:GetValue()
            })
          end
        elseif valueType == 'number' then
          local numSlider = self.editForm:NumSlider('#System_ManageConfig_Value', nil, self.adminValues.minimum,
          self.adminValues.maximum, self.adminValues.decimals)
            numSlider.Label:SetTextColor(Color('white'))
            numSlider:SetValue(self.activeKey.value)
          local okayButton = self.editForm:Button('#System_ManageConfig_Okay')

          -- Called when the button is clicked.
          function okayButton.DoClick(okayButton)
            cable.send('SystemCfgSet', {
              key = self.activeKey.name,
              value = numSlider:GetValue(),
              useMap = mapEntry:GetValue()
            })
          end
        elseif valueType == 'boolean' then
          local checkBox = self.editForm:CheckBox('#System_ManageConfig_On')
            checkBox:SetValue(self.activeKey.value)
            checkBox:SetTextColor(Color('white'))
          local okayButton = self.editForm:Button('#System_ManageConfig_Okay')

          -- Called when the button is clicked.
          function okayButton.DoClick(okayButton)
            cable.send('SystemCfgSet', {
              key = self.activeKey.name,
              value = checkBox:GetChecked(),
              useMap = mapEntry:GetValue()
            })
          end
        end
      end
    end
  end

  --- Fills the config list with the keys in `self.configKeys` and reselects the active key, if any.
  --
  -- Keys without system data in `config.GetFromSystem` are skipped.
  function SYSTEM:PopulateComboBox()
    if !IsValid(self.listView) then
      return
    end

    self.listView:Clear(true)

    if self.configKeys then
      local defaultConfigItem = nil

      for k, v in pairs(self.configKeys) do
        local adminValues = config.GetFromSystem(v)

        if adminValues then
          local comboBoxItem = self.listView:AddLine(adminValues.name, v, adminValues.category)
            comboBoxItem:SetTooltip(adminValues.help)
            comboBoxItem.key = v

          if self.activeKey and self.activeKey.name == v then
            defaultConfigItem = comboBoxItem
          end
        end
      end

      if defaultConfigItem then
        self.listView:SelectItem(defaultConfigItem, true)
      end

      self.listView:SortByColumn(1)
    end
  end

  SYSTEM:Register()

  cable.receive('SystemCfgKeys', function(data)
    local systemTable = cw.system:FindByID('Manage Config')

    if systemTable then
      systemTable.configKeys = data
      systemTable:PopulateComboBox()
    end
  end)

  cable.receive('SystemCfgValue', function(data)
    local systemTable = cw.system:FindByID('Manage Config')

    if systemTable then
      systemTable.activeKey = { name = data[1], value = data[2] }
      systemTable:PopulateConfigBox()
    end
  end)
else
  --- Returns whether a player may read and change config values through the Manage Config system.
  -- @param player [Player The player who sent the request]
  -- @return [Boolean Whether the player has the `CfgSetVar` command's access flags]
  local function CanManageConfig(player)
    local commandTable = cw.command:FindByID('CfgSetVar')

    if commandTable and cw.player:HasFlags(player, commandTable.access) then
      return true
    end

    return false
  end

  --- Sends a config key's pending or current value to a player, masking private strings.
  -- @param player [Player The player to send the value to]
  -- @param key [String The config key]
  -- @param configObject [Config The key's config object]
  local function SendConfigValue(player, key, configObject)
    local value = configObject:GetNext(configObject:Get())

    if isstring(value) and configObject('isPrivate') then
      value = '****'
    end

    cable.send(player, 'SystemCfgValue', { key, value })
  end

  cable.receive('SystemCfgSet', function(player, data)
    if !istable(data) or !isstring(data.key) or !CanManageConfig(player) then
      return
    end

    local key = data.key
    local value = data.value
    local configObject = config.Get(key)

    if !configObject:IsValid() then
      cw.player:Notify(player, L('ConfigKeyNotValid', key))

      return
    end

    local keyPrefix = ''
    local useMap = data.useMap

    if !isstring(useMap) or useMap == '' then
      useMap = nil
    end

    if useMap then
      useMap = string.lower(cw.core:Replace(useMap, '.bsp', ''))
      keyPrefix = '('..useMap..') '

      -- The map name becomes part of a data file path, so it must not be able to leave its folder.
      if string.find(useMap, '[/\\:]') or string.find(useMap, '..', 1, true)
      or !file.Exists('maps/'..useMap..'.bsp', 'GAME') then
        cw.player:Notify(player, L('NotValidMap', useMap))

        return
      end
    end

    if configObject('isStatic') then
      cw.player:Notify(player, L('ConfigIsStaticKey', key))

      return
    end

    -- NaN and infinity would be saved and networked as they are, and '****' is only the mask the
    -- client was sent for a private value.
    if (isnumber(value) and (value != value or math.abs(value) == math.huge))
    or (value == '****' and configObject('isPrivate')) then
      cw.player:Notify(player, L('ConfigUnableToSet', key))

      return
    end

    value = configObject:Set(value, useMap)

    if value == nil then
      cw.player:Notify(player, L('ConfigUnableToSet', key))

      return
    end

    local printValue = tostring(value)
    local phrase = 'Config_ValueSet'

    if configObject('isPrivate') then
      printValue = string.rep('*', string.utf8len(printValue))
    end

    if configObject('needsRestart') then
      phrase = 'Config_ValueSetRestart'
    end

    cw.player:NotifyAll(L(phrase, player:Name(), keyPrefix..key).." '"..printValue.."'")

    SendConfigValue(player, key, configObject)
  end)

  cable.receive('SystemCfgKeys', function(player, data)
    if !CanManageConfig(player) then
      return
    end

    local configKeys = {}

    for k, v in pairs(config.GetStored()) do
      if !v.isStatic then
        configKeys[#configKeys + 1] = k
      end
    end

    table.sort(configKeys)

    cable.send(player, 'SystemCfgKeys', configKeys)
  end)

  cable.receive('SystemCfgValue', function(player, data)
    if !isstring(data) or !CanManageConfig(player) then
      return
    end

    local configObject = config.Get(data)

    if configObject:IsValid() then
      SendConfigValue(player, data, configObject)
    end
  end)
end
