--- Registers the `Manage Plugins` system, which lists every plugin by author and lets admins load or unload them.
--
-- The page is shown to players with access to `/PluginLoad` or `/PluginUnload`. The unloaded plugins are requested
-- over the `SystemPluginGet` netstream, and `SystemPluginSet` toggles a plugin with `plugin.SetUnloaded` on the server
-- and updates the page for every admin.

if CLIENT then
  local SYSTEM = cw.system:New('Manage Plugins')
  SYSTEM.toolTip = '#System_ManagePlugins_ToolTip'
  SYSTEM.doesCreateForm = false

  --- Shows the Manage Plugins system to players who may use `PluginLoad` or `PluginUnload`.
  -- @return [Boolean Whether the player has either command's access flags]
  function SYSTEM:HasAccess()
    local unloadTable = cw.command:FindByID('PluginUnload')
    local loadTable = cw.command:FindByID('PluginLoad')

    if loadTable and unloadTable then
      if cw.player:HasFlags(cw.client, loadTable.access)
      or cw.player:HasFlags(cw.client, unloadTable.access) then
        return true
      end
    end

    return false
  end

  --- Lists every plugin except the schema, grouped by author, colored by state, as buttons that toggle loading.
  --
  -- Asks the server for the unloaded plugins with the `SystemPluginGet` netstream; clicking a plugin that is not
  -- disabled sends `SystemPluginSet` to load or unload it.
  -- @param systemPanel [Panel The system panel to add the plugin lists to]
  -- @param systemForm [Panel The system's form (unused, the system does not create one)]
  function SYSTEM:OnDisplay(systemPanel, systemForm)
    pluginButtons = {}

    local donePlugins = {}
    local categories = {}
    local mainPlugins = {}

    for k, v in pairs(plugin.GetStored()) do
      if v != Schema then
        categories[v.author] = categories[v.author] or {}
        categories[v.author][#categories[v.author] + 1] = v
      end
    end

    for k, v in pairs(categories) do
      table.sort(v, function(a, b)
        return a.name < b.name
      end)

      mainPlugins[#mainPlugins + 1] = {
        category = k,
        plugins = v
      }
    end

    table.sort(mainPlugins, function(a, b)
      return a.category < b.category
    end)

    netstream.Start('SystemPluginGet', true)

    if #mainPlugins > 0 then
      local label = vgui.Create('cwInfoText', systemPanel)
        label:SetText('#System_ManagePlugins_Info')
        label:SetInfoColor('blue')
        label:DockMargin(0, 0, 0, 8)
      systemPanel.panelList:AddItem(label)

      for k, v in pairs(mainPlugins) do
        local pluginForm = vgui.Create('DForm', systemPanel)
        local panelList = vgui.Create('DPanelList', systemPanel)

        for k2, v2 in pairs(v.plugins) do
          pluginButtons[v2.name] = vgui.Create('cwInfoText', systemPanel)
            pluginButtons[v2.name]:SetText(v2.name)
            pluginButtons[v2.name]:SetButton(true)
            pluginButtons[v2.name]:SetTooltip(v2.description)
          panelList:AddItem(pluginButtons[v2.name])

          if plugin.IsDisabled(v2.name) then
            pluginButtons[v2.name]:SetInfoColor('orange')
            pluginButtons[v2.name]:SetButton(false)
          elseif plugin.IsUnloaded(v2.name) then
            pluginButtons[v2.name]:SetInfoColor('red')
          else
            pluginButtons[v2.name]:SetInfoColor('green')
          end

          -- Called when the button is clicked.
          pluginButtons[v2.name].DoClick = function(button)
            if !plugin.IsDisabled(v2.name) then
              if plugin.IsUnloaded(v2.name) then
                netstream.Start('SystemPluginSet', { v2.name, false })
              else
                netstream.Start('SystemPluginSet', { v2.name, true })
              end
            end
          end
        end

        systemPanel.panelList:AddItem(pluginForm)

        panelList:SetAutoSize(true)
        panelList:SetPadding(4)
        panelList:SetSpacing(4)

        pluginForm:SetName(v.category)
        pluginForm:AddItem(panelList)
        pluginForm:SetPadding(4)
      end
    else
      local label = vgui.Create('cwInfoText', systemPanel)
        label:SetText('#System_ManagePlugins_Empty')
        label:SetInfoColor('red')
      systemPanel.panelList:AddItem(label)
    end
  end

  --- Recolors the plugin buttons to match each plugin's current state.
  --
  -- Disabled plugins turn orange and stop being clickable, unloaded ones red and loaded ones green.
  function SYSTEM:UpdatePluginButtons()
    for k, v in pairs(pluginButtons) do
      if plugin.IsDisabled(k) then
        v:SetInfoColor('orange')
        v:SetButton(false)
      elseif plugin.IsUnloaded(k) then
        v:SetInfoColor('red')
        v:SetButton(true)
      else
        v:SetInfoColor('green')
        v:SetButton(true)
      end
    end
  end

  SYSTEM:Register()

  netstream.Hook('SystemPluginGet', function(data)
    local systemTable = cw.system:FindByID('Manage Plugins')
    local unloaded = data

    for k, v in pairs(plugin.GetStored()) do
      if unloaded[v.folderName] then
        plugin.SetUnloaded(v.name, true)
      else
        plugin.SetUnloaded(v.name, false)
      end
    end

    if systemTable and systemTable:IsActive() then
      systemTable:UpdatePluginButtons()
    end
  end)

  netstream.Hook('SystemPluginSet', function(data)
    local systemTable = cw.system:FindByID('Manage Plugins')
    local pluginTable = plugin.FindByID(data[1])

    if pluginTable then
      plugin.SetUnloaded(pluginTable.name, (data[2] == true))
    end

    if systemTable and systemTable:IsActive() then
      systemTable:UpdatePluginButtons()
    end
  end)
else
  netstream.Hook('SystemPluginGet', function(player, data)
    netstream.Start(player, 'SystemPluginGet', plugin.GetUnloaded())
  end)

  netstream.Hook('SystemPluginSet', function(player, data)
    local unloadTable = cw.command:FindByID('PluginLoad')
    local loadTable = cw.command:FindByID('PluginLoad')

    if data[2] == true and (!loadTable or !cw.player:HasFlags(player, loadTable.access)) then
      return
    elseif data[2] == false and (!unloadTable or !cw.player:HasFlags(player, unloadTable.access)) then
      return
    elseif type(data[2]) != 'boolean' then
      return
    end

    local pluginTable = plugin.FindByID(data[1])

    if !pluginTable then
      cw.player:Notify(player, L('PluginManage_NotValid'))
      return
    end

    if !plugin.IsDisabled(pluginTable.name) then
      local bSuccess = plugin.SetUnloaded(pluginTable.name, data[2])
      local recipients = {}

      if bSuccess then
        if data[2] then
          cw.player:NotifyAll(L('PluginManage_Unloaded', player:Name(), pluginTable.name))
        else
          cw.player:NotifyAll(L('PluginManage_Loaded', player:Name(), pluginTable.name))
        end

        for k, v in ipairs(_player.GetAll()) do
          if v:HasInitialized() then
            if cw.player:HasFlags(v, loadTable.access)
            or cw.player:HasFlags(v, unloadTable.access) then
              recipients[#recipients + 1] = v
            end
          end
        end

        if #recipients > 0 then
          netstream.Start(recipients, 'SystemPluginSet', { pluginTable.name, data[2] })
        end
      elseif data[2] then
        cw.player:Notify(player, L('PluginManage_CouldNotUnload'))
      else
        cw.player:Notify(player, L('PluginManage_CouldNotLoad'))
      end
    else
      cw.player:Notify(player, L('PluginManage_Depends'))
    end
  end)
end
