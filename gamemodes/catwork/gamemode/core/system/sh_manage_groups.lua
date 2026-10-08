--- Registers the `Manage Groups` system, which lists the members of the superadmin, admin and operator user groups and
-- lets them be demoted.
--
-- The page is shown to players with access to `/PlySetGroup` unless the `use_own_group_system` config is on. Members
-- are read from the players database table and sent eight per page over the `SystemGroupGet` Cable message;
-- `SystemGroupDemote` demotes through the `PlyDemote` command.

local GROUP_SUPER = 1
local GROUP_ADMIN = 2
local GROUP_OPER = 3
local GROUP_USER = 4

if CLIENT then
  local SYSTEM = cw.system:New('Manage Groups')
  SYSTEM.toolTip = '#System_ManageGroups_ToolTip'
  SYSTEM.groupType = GROUP_USER
  SYSTEM.groupPage = 1
  SYSTEM.groupPlayers = nil
  SYSTEM.doesCreateForm = false

  --- Shows the Manage Groups system to players who may use `PlySetGroup`, unless `use_own_group_system` is enabled.
  -- @return [Boolean `true` when the player has access, otherwise `nil`]
  function SYSTEM:HasAccess()
    if !config.Get('use_own_group_system'):Get() then
      local commandTable = cw.command:FindByID('PlySetGroup')

      if commandTable and cw.player:HasFlags(cw.client, commandTable.access) then
        return true
      end
    end
  end

  --- Shows the user group buttons, or the paged member list of the selected group with demote buttons.
  --
  -- Members are requested with the `SystemGroupGet` Cable message unless `noRefresh` is set; demoting asks for
  -- confirmation, requires the `PlyDemote` command's access and sends `SystemGroupDemote`.
  -- @param systemPanel [Panel The system panel to add the group buttons or member list to]
  -- @param systemForm [Panel The system's form (unused, the system does not create one)]
  function SYSTEM:OnDisplay(systemPanel, systemForm)
    if self.groupType == GROUP_USER then
      local label = vgui.Create('cwInfoText', systemPanel)
        label:SetText('#System_ManageGroups_Info')
        label:SetInfoColor('blue')
        label:DockMargin(0, 0, 0, 8)
      systemPanel.panelList:AddItem(label)

      local userGroupsForm = vgui.Create('DForm', systemPanel)
        userGroupsForm:SetName('#System_ManageGroups_UserGroups')
        userGroupsForm:SetPadding(4)
      systemPanel.panelList:AddItem(userGroupsForm)

      local userGroups =
        { '#System_ManageGroups_SuperAdmins', '#System_ManageGroups_Administrators', '#System_ManageGroups_Operators' }

      for k, v in pairs(userGroups) do
        local groupButton = vgui.Create('DButton', systemPanel)
          groupButton:SetTooltip(L('#System_ManageGroups_GroupTip:'..L(v)..';'))
          groupButton:SetText(v)
          groupButton:SetWide(systemPanel:GetParent():GetWide())

          -- Called when the button is clicked.
          function groupButton.DoClick(button)
            self.groupPlayers = nil
            self.groupType = k
            self.groupPage = 1
            self:Rebuild()
          end

        userGroupsForm:AddItem(groupButton)
      end
    else
      local backButton = vgui.Create('DButton', systemPanel)
        backButton:SetText('#System_ManageGroups_Back')
        backButton:SetWide(systemPanel:GetParent():GetWide())

        -- Called when the button is clicked.
        function backButton.DoClick(button)
          self.groupType = GROUP_USER
          self:Rebuild()
        end

      systemPanel.navigationForm:AddItem(backButton)

      if !self.noRefresh then
        cable.send('SystemGroupGet', { self.groupType, self.groupPage })
      else
        self.noRefresh = nil
      end

      if self.groupPlayers then
        if #self.groupPlayers > 0 then
          for k, v in pairs(self.groupPlayers) do
            local label = vgui.Create('cwInfoText', systemPanel)
              label:SetText(v.steamName)
              label:SetButton(true)
              label:SetTooltip(L('#Scoreboard_SteamIDIs')..' '..v.steamID..'.')
              label:SetInfoColor('blue')
            systemPanel.panelList:AddItem(label)

            -- Called when the button is clicked.
            function label.DoClick(button)
              local commandTable = cw.command:FindByID('PlyDemote')

              if commandTable and cw.player:HasFlags(cw.client, commandTable.access) then
                Derma_Query(L('#System_ManageGroups_DemoteConfirm'), v.steamName, L('Yes'), function()
                  cable.send('SystemGroupDemote', { v.steamID, v.steamName, self.groupType })
                end, L('No'), function() end)
              end
            end
          end

          if self.pageCount > 1 then
            local pageForm = vgui.Create('DForm', systemPanel)
              pageForm:SetName(L('#System_Page:'..self.groupPage..','..self.pageCount..';'))
              pageForm:SetPadding(4)
            systemPanel.panelList:AddItem(pageForm)

            if self.isNext then
              local nextButton = pageForm:Button('#System_Next')

              -- Called when the button is clicked.
              function nextButton.DoClick(button)
                cable.send('SystemGroupGet', { self.groupType, self.groupPage + 1 })
              end
            end

            if self.isBack then
              local backButton = pageForm:Button('#System_Back')

              -- Called when the button is clicked.
              function backButton.DoClick(button)
                cable.send('SystemGroupGet', { self.groupType, self.groupPage - 1 })
              end
            end
          end
        else
          local label = vgui.Create('cwInfoText', systemPanel)
            label:SetText('#System_ManageGroups_Empty')
            label:SetInfoColor('orange')
          systemPanel.panelList:AddItem(label)
        end
      else
        local label = vgui.Create('cwInfoText', systemPanel)
          label:SetText('#System_ManageGroups_Loading')
          label:SetInfoColor('blue')
        systemPanel.panelList:AddItem(label)
      end
    end
  end

  SYSTEM:Register()

  cable.receive('SystemGroupRebuild', function(data)
    local systemTable = cw.system:FindByID('Manage Groups')

    if systemTable and systemTable:IsActive() then
      systemTable:Rebuild()
    end
  end)

  cable.receive('SystemGroupGet', function(data)
    if type(data) == 'table' then
      local systemTable = cw.system:FindByID('Manage Groups')

      if systemTable then
        systemTable.groupPlayers = data.players
        systemTable.groupPage = data.page
        systemTable.pageCount = data.pageCount
        systemTable.noRefresh = true
        systemTable.isBack = data.isBack
        systemTable.isNext = data.isNext
        systemTable:Rebuild()
      end
    else
      local systemTable = cw.system:FindByID('Manage Groups')

      if systemTable then
        systemTable.groupPlayers = {}
        systemTable.groupPage = 1
        systemTable.noRefresh = true

        if systemTable:IsActive() then
          systemTable:Rebuild()
        end
      end
    end
  end)
else
  local GROUP_NAMES = {
    [GROUP_SUPER] = 'superadmin',
    [GROUP_ADMIN] = 'admin',
    [GROUP_OPER] = 'operator'
  }

  --- Returns whether a Steam ID is listed in the `owner_steamid` config, also when its player is offline.
  -- @param steamID [String The Steam ID to check]
  -- @return [Boolean Whether the Steam ID belongs to an owner]
  local function IsOwnerSteamID(steamID)
    local ownerSteamID = string.gsub(config.Get('owner_steamid'):GetString(), ' ', '')

    for k, v in ipairs(string.Split(ownerSteamID, ',')) do
      if v == steamID then
        return true
      end
    end

    return false
  end

  cable.receive('SystemGroupDemote', function(player, data)
    local commandTable = cw.command:FindByID('PlyDemote')

    if !commandTable or !istable(data) or !isstring(data[1])
    or !cw.player:HasFlags(player, commandTable.access) then
      return
    end

    local steamID = string.upper(data[1])

    if !string.find(steamID, '^STEAM_%d:%d:%d+$') then
      return
    end

    if _player.Find(steamID) then
      cw.player:RunClockworkCommand(player, 'PlyDemote', steamID)

      timer.Simple(1, function()
        if IsValid(player) then
          cable.send(player, 'SystemGroupRebuild', true)
        end
      end)

      return
    end

    local steamName = steamID

    -- The name is only used for the announcement; utf8sub raises an error on invalid UTF-8.
    if isstring(data[2]) then
      local bSuccess, name = pcall(string.utf8sub, data[2], 1, 64)

      if bSuccess and name != '' then
        steamName = name
      end
    end

    if IsOwnerSteamID(steamID) then
      cw.player:Notify(player, L('Command_PlayerProtected', steamName))

      return
    end

    local queryObj = cw.database:Update(config.Get('mysql_players_table'):Get())
      queryObj:Update('_UserGroup', 'user')
      queryObj:Where('_Schema', cw.core:GetSchemaFolder())
      queryObj:Where('_SteamID', steamID)
      queryObj:Callback(function(result)
        if IsValid(player) then
          cable.send(player, 'SystemGroupRebuild', true)
        end
      end)
    queryObj:Execute()

    cw.player:NotifyAll(
      L('Command_Plydemote_Demoted', player:Name(), steamName, GROUP_NAMES[data[3]] or 'user')
    )
  end)

  cable.receive('SystemGroupGet', function(player, data)
    local commandTable = cw.command:FindByID('PlySetGroup')

    if !commandTable or !istable(data) or !cw.player:HasFlags(player, commandTable.access) then
      return
    end

    local groupName = GROUP_NAMES[tonumber(data[1])]
    local groupPage = tonumber(data[2])

    -- Only the three staff groups can be listed; 'user' would return every player in the database.
    if !groupName or !groupPage or groupPage != groupPage then
      return
    end

    groupPage = math.max(math.floor(groupPage), 1)

    local finishIndex = groupPage * 8
    local startIndex = finishIndex - 7

    local queryObj = cw.database:Select(config.Get('mysql_players_table'):Get())
      queryObj:Select('_SteamName')
      queryObj:Select('_SteamID')
      queryObj:Where('_Schema', cw.core:GetSchemaFolder())
      queryObj:Where('_UserGroup', groupName)
      queryObj:Callback(function(result)
        if !IsValid(player) then
          return
        end

        local groupPlayers = {}
        local sendPlayers = {}

        if cw.database:IsResult(result) then
          for k, v in pairs(result) do
            groupPlayers[#groupPlayers + 1] = {
              steamName = v._SteamName or v._SteamID,
              steamID = v._SteamID
            }
          end
        end

        table.sort(groupPlayers, function(a, b)
          return a.steamName < b.steamName
        end)

        for i = startIndex, math.min(finishIndex, #groupPlayers) do
          sendPlayers[#sendPlayers + 1] = groupPlayers[i]
        end

        if #sendPlayers > 0 then
          cable.send(player, 'SystemGroupGet', {
            pageCount = math.ceil(#groupPlayers / 8),
            players = sendPlayers,
            isNext = (groupPlayers[finishIndex + 1] != nil),
            isBack = (groupPlayers[startIndex - 1] != nil),
            page = groupPage
          })
        else
          cable.send(player, 'SystemGroupGet', false)
        end
      end)
    queryObj:Execute()
  end)
end
