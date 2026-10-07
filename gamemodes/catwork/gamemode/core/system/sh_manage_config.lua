--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

if CLIENT then
  local SYSTEM = cw.system:New('Manage Config')
  SYSTEM.toolTip = '#System_ManageConfig_ToolTip'
  SYSTEM.doesCreateForm = false

  -- Called to get whether the local player has access to the system.
  function SYSTEM:HasAccess()
    local commandTable = cw.command:FindByID('CfgSetVar')

    if commandTable and cw.player:HasFlags(cw.client, commandTable.access) then
      return true
    else
      return false
    end
  end

  -- Called when the system should be displayed.
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
      netstream.Start('SystemCfgKeys', true)
    end

    self.listView = vgui.Create('DListView')
      self.listView:AddColumn('#System_ManageConfig_Name')
      self.listView:AddColumn('#System_ManageConfig_Key')
      self.listView:AddColumn('#System_ManageConfig_AddedBy')
      self.listView:SetMultiSelect(false)
      self.listView:SetTall(256)
    self:PopulateComboBox()

    function self.listView.OnRowSelected(parent, lineID, line)
      netstream.Start('SystemCfgValue', line.key)
    end

    self.configForm:AddItem(self.listView)
  end

  function SYSTEM:PopulateConfigBox()
    self.editForm:Clear(true)

    if self.activeKey then
      self.adminValues = config.GetFromSystem(self.activeKey.name)

      self.infoText:SetText('#System_ManageConfig_InfoEditing')
    end

    if self.editForm and !self.editForm:IsVisible() then
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
            netstream.Start('SystemCfgSet', {
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
            netstream.Start('SystemCfgSet', {
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
            netstream.Start('SystemCfgSet', {
              key = self.activeKey.name,
              value = checkBox:GetChecked(),
              useMap = mapEntry:GetValue()
            })
          end
        end
      end
    end
  end

  -- A function to populate the system's combo box.
  function SYSTEM:PopulateComboBox()
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

  netstream.Hook('SystemCfgKeys', function(data)
    local systemTable = cw.system:FindByID('Manage Config')

    if systemTable then
      systemTable.configKeys = data
      systemTable:PopulateComboBox()
    end
  end)

  netstream.Hook('SystemCfgValue', function(data)
    local systemTable = cw.system:FindByID('Manage Config')

    if systemTable then
      systemTable.activeKey = { name = data[1], value = data[2] }
      systemTable:PopulateConfigBox()
    end
  end)
else
  netstream.Hook('SystemCfgSet', function(player, data)
    local commandTable = cw.command:FindByID('CfgSetVar')

    if commandTable and cw.player:HasFlags(player, commandTable.access) then
      local configObject = config.Get(data.key)

      if configObject:IsValid() then
        local keyPrefix = ''
        local useMap = data.useMap

        if useMap == '' then
          useMap = nil
        end

        if useMap then
          useMap = string.lower(cw.core:Replace(useMap, '.bsp', ''))
          keyPrefix = '('..useMap..') '

          if !file.Exists('maps/'..useMap..'.bsp', 'GAME') then
            cw.player:Notify(player, L('NotValidMap', useMap))

            return
          end
        end

        if !configObject('isStatic') then
          value = configObject:Set(data.value, useMap)

          if value != nil then
            local printValue = tostring(value)

            if configObject('isPrivate') then
              if configObject('needsRestart') then
                cw.player:NotifyAll(
                  L('Config_ValueSetRestart', player:Name(), keyPrefix..data.key).." '"..string.rep('*', string.utf8len(
                    printValue
                  )).."'"
                )
              else
                cw.player:NotifyAll(
                  L('Config_ValueSet', player:Name(), keyPrefix..data.key).." '"..string.rep('*', string.utf8len(
                    printValue
                  ))..
                    "'"
                )
              end
            elseif configObject('needsRestart') then
              cw.player:NotifyAll(
                L('Config_ValueSetRestart', player:Name(), keyPrefix..data.key).." '"..printValue.."'"
              )
            else
              cw.player:NotifyAll(L('Config_ValueSet', player:Name(), keyPrefix..data.key).." '"..printValue.."'")
            end

            netstream.Start(player, 'SystemCfgValue', { data.key, configObject:Get() })
          else
            cw.player:Notify(player, L('ConfigUnableToSet', data.key))
          end
        else
          cw.player:Notify(player, L('ConfigIsStaticKey', data.key))
        end
      else
        cw.player:Notify(player, L('ConfigKeyNotValid', data.key))
      end
    end
  end)

  netstream.Hook('SystemCfgKeys', function(player, data)
    local configKeys = {}

    for k, v in pairs(config.GetStored()) do
      if !v.isStatic then
        configKeys[#configKeys + 1] = k
      end
    end

    table.sort(configKeys, function(a, b)
      return a < b
    end)

    netstream.Start(player, 'SystemCfgKeys', configKeys)
  end)

  netstream.Hook('SystemCfgValue', function(player, data)
    local configObject = config.Get(data)

    if configObject:IsValid() then
      if type(configObject:Get()) == 'string' and configObject('isPrivate') then
        netstream.Start(player, 'SystemCfgValue', { data, '****' })
      else
        netstream.Start(player, 'SystemCfgValue', {
          data, configObject:GetNext(configObject:Get())
        })
      end
    end
  end)
end
