--- Defines the `cwDoor` door management window and handles the door Cable messages sent by the server.
--
-- The window has a Players tab for granting basic or complete access and a Settings tab with the door text, parent
-- sharing options and a Sell or Unown button; every change is sent with the `DoorManagement` Cable message. The
-- `PurchaseDoor`, `DoorManagement`, `DoorAccess`, `SetSharedAccess` and `SetSharedText` hooks open the purchase query
-- or the window and keep `cw.door` up to date.

local PANEL = {}

--- Builds the door management window: a Players tab and a Settings tab with the door text entry and,
-- for the owner, parent sharing options and a Sell or Unown button.
--
-- Changes are sent to the server with the `DoorManagement` Cable message. Door text containing "this door
-- can be purchased" is not sent.
function PANEL:Init()
  self:SetTitle(cw.door:GetName())
  self:SetSizable(false)
  self:SetDeleteOnClose(false)
  self:SetBackgroundBlur(true)

  -- Called when the button is clicked.
  function self.btnClose.DoClick(button)
    self:Close() self:Remove()
    gui.EnableScreenClicker(false)
  end

  self.settingsPanel = vgui.Create('cwPanelList')
  self.settingsPanel:SetPadding(2)
  self.settingsPanel:SetSpacing(3)
  self.settingsPanel:SizeToContents()
  self.settingsPanel:EnableVerticalScrollbar()

  self.playersPanel = vgui.Create('cwPanelList')
  self.playersPanel:SetPadding(2)
  self.playersPanel:SetSpacing(3)
  self.playersPanel:SizeToContents()
  self.playersPanel:EnableVerticalScrollbar()

  self.settingsForm = vgui.Create('DForm')
  self.settingsForm:SetPadding(4)
  self.settingsForm:SetName('#Settings')

  if cw.door:IsParent() then
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#DoorMenu_ParentInfo')
      label:SetInfoColor('blue')
    self.settingsPanel:AddItem(label)
  end

  self.settingsPanel:AddItem(self.settingsForm)
  self.textEntry = self.settingsForm:TextEntry('#DoorMenu_DoorText')
  self.textEntry:SetAllowNonAsciiCharacters(true)

  -- Called when enter has been pressed.
  function self.textEntry.OnEnter(textEntry)
    local text = textEntry:GetValue()

    if !string.find(string.gsub(string.lower(text), '%s', ''), 'thisdoorcanbepurchased') then
      cable.send('DoorManagement', { cw.door:GetEntity(), 'Text', textEntry:GetValue() })
    end
  end

  if cw.door:GetOwner() == cw.client then
    if cw.door:IsParent() then
      self.comboBox = self.settingsForm:ComboBox('#DoorMenu_ParentAccess')
      self.comboBox:AddChoice(L('#DoorMenu_ShareAccess'))
      self.comboBox:AddChoice(L('#DoorMenu_SeparateAccess'))

      if cw.door:HasSharedAccess() then
        self.comboBox:SetText(L('#DoorMenu_ShareAccess'))
      else
        self.comboBox:SetText(L('#DoorMenu_SeparateAccess'))
      end

      -- Called when an option is selected.
      self.comboBox.OnSelect = function(multiChoice, index, value, data)
        if value == L('#DoorMenu_ShareAccess') then
          cable.send('DoorManagement', { cw.door:GetEntity(), 'Share' })
        else
          cable.send('DoorManagement', { cw.door:GetEntity(), 'Unshare' })
        end
      end

      self.parentText = self.settingsForm:ComboBox('#DoorMenu_ParentText')
      self.parentText:AddChoice(L('#DoorMenu_ShareText'))
      self.parentText:AddChoice(L('#DoorMenu_SeparateText'))

      if cw.door:HasSharedText() then
        self.parentText:SetText(L('#DoorMenu_ShareText'))
      else
        self.parentText:SetText(L('#DoorMenu_SeparateText'))
      end

      -- Called when an option is selected.
      self.parentText.OnSelect = function(multiChoice, index, value, data)
        if value == L('#DoorMenu_ShareText') then
          cable.send('DoorManagement', { cw.door:GetEntity(), 'Share', 'Text' })
        else
          cable.send('DoorManagement', { cw.door:GetEntity(), 'Unshare', 'Text' })
        end
      end
    end

    if !cw.door:IsUnsellable() then
      local doorCost = config.GetVal('door_cost')
      local button = nil

      if doorCost > 0 then
        button = self.settingsForm:Button('#DoorMenu_Sell')
      else
        button = self.settingsForm:Button('#DoorMenu_Unown')
      end

      -- Called when the button is clicked.
      function button.DoClick(button)
        local query, title = '#DoorMenu_UnownQuery', '#DoorMenu_UnownTitle'

        if doorCost > 0 then
          query, title = '#DoorMenu_SellQuery', '#DoorMenu_SellTitle'
        end

        Derma_Query(L(query), L(title), L('Yes'), function()
          gui.EnableScreenClicker(false)

          -- The window closes itself when the player walks away from the door while the query is open.
          if IsValid(self) then
            cable.send('DoorManagement', { cw.door:GetEntity(), 'Sell' })

            self:Close() self:Remove()
          end
        end, L('No'), function()
          gui.EnableScreenClicker(false)
        end)

        gui.EnableScreenClicker(true)
      end
    end
  end

  self.propertySheet = vgui.Create('DPropertySheet', self)
  self.propertySheet:SetPadding(4)
  self.propertySheet:AddSheet(
    L('#DoorMenu_Players'),
    self.playersPanel,
    'icon16/user.png',
    nil,
    nil,
    L('#DoorMenu_PlayersTip')
  )
  self.propertySheet:AddSheet(
    L('#Settings'),
    self.settingsPanel,
    'icon16/wrench.png',
    nil,
    nil,
    L('#DoorMenu_SettingsTip')
  )

  cw.core:SetNoticePanel(self)
end

--- Rebuilds the Players tab, grouping players into complete, basic and no access lists.
--
-- Each player opens a menu to give or take access when clicked. Players are listed when the
-- `PlayerShouldShowOnDoorAccessList` hook allows it, under the name from `GetPlayerDoorAccessName`.
function PANEL:Rebuild()
  self.playersPanel:Clear(true)

  local accessList = cw.door:GetAccessList()
  local categories = {}
  local owner = cw.door:GetOwner()
  local door = cw.door:GetEntity()

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if cw.client != v and owner != v then
        local access = accessList[v] or false

        if hook.Run('PlayerShouldShowOnDoorAccessList', v, door, owner) then
          local name = hook.Run('GetPlayerDoorAccessName', v, door, owner)
          local index

          if access == DOOR_ACCESS_COMPLETE then
            index = 1
          elseif access == DOOR_ACCESS_BASIC then
            index = 2
          else
            index = 3
          end

          if !categories[index] then
            categories[index] = {}
          end

          categories[index][#categories[index] + 1] = { v, name }
        end
      end
    end
  end

  -- In order: complete access, basic access, no access.
  for k = 1, 3 do
    local v = categories[k]

    if v then
      local collapsibleCategory = vgui.Create('DCollapsibleCategory', self.playersPanel)
      local panelList = vgui.Create('DPanelList', self.playersPanel)

      self.playersPanel:AddItem(collapsibleCategory)

      table.sort(v, function(a, b)
        return a[2] < b[2]
      end)

      for k2, v2 in pairs(v) do
        local button = vgui.Create('DButton', self.playersPanel)
        local access = false
        local player = v2[1]

        if k == 1 then
          access = DOOR_ACCESS_COMPLETE
        elseif k == 2 then
          access = DOOR_ACCESS_BASIC
        end

        -- Called when the button is clicked.
        function button.DoClick(button)
          local options

          if access == DOOR_ACCESS_COMPLETE then
            options = {
              [L('#DoorMenu_TakeCompleteAccess')] = function()
                cable.send('DoorManagement', { door, 'Access', player, access })
              end
            }
          elseif access == DOOR_ACCESS_BASIC then
            options = {
              [L('#DoorMenu_TakeBasicAccess')] = function()
                cable.send('DoorManagement', { door, 'Access', player, access })
              end,
              [L('#DoorMenu_GiveCompleteAccess')] = function()
                cable.send('DoorManagement', { door, 'Access', player, DOOR_ACCESS_COMPLETE })
              end
            }
          else
            options = {
              [L('#DoorMenu_GiveBasicAccess')] = function()
                cable.send('DoorManagement', { door, 'Access', player, DOOR_ACCESS_BASIC })
              end,
              [L('#DoorMenu_GiveCompleteAccess')] = function()
                cable.send('DoorManagement', { door, 'Access', player, DOOR_ACCESS_COMPLETE })
              end
            }
          end

          if options then
            cw.core:AddMenuFromData(nil, options)
          end
        end

        button:SetText(v2[2])

        panelList:AddItem(button)
      end

      panelList:SetAutoSize(true)
      panelList:SetPadding(4)
      panelList:SetSpacing(4)

      collapsibleCategory:SetPadding(4)
      collapsibleCategory:SetContents(panelList)

      if k == 1 then
        collapsibleCategory:SetLabel(L('#DoorMenu_CompleteAccessList'))
        collapsibleCategory:SetCookieName('cwDoorComplete')
      elseif k == 2 then
        collapsibleCategory:SetLabel(L('#DoorMenu_BasicAccessList'))
        collapsibleCategory:SetCookieName('cwDoorBasic')
      else
        collapsibleCategory:SetLabel(L('#DoorMenu_NoAccessList'))
        collapsibleCategory:SetCookieName('cwDoorZero')
      end
    end
  end
end

--- Keeps the window centred and closes it when the door is gone or more than 192 units away.
function PANEL:Think()
  local entity = cw.door:GetEntity()
  local scrW = ScrW()
  local scrH = ScrH()

  self:SetSize(scrW * 0.5, scrH * 0.75)
  self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2))

  if !IsValid(entity) or entity:GetPos():Distance(cw.client:GetPos()) > 192 then
    self:Close() self:Remove()

    gui.EnableScreenClicker(false)
  end
end

--- Lays out the frame and stretches the tabs to fill it.
function PANEL:PerformLayout(w, h)
  DFrame.PerformLayout(self)

  self.propertySheet:StretchToParent(4, 28, 4, 4)
end

vgui.Register('cwDoor', PANEL, 'DFrame')

cable.receive('PurchaseDoor', function(data)
  local doorCost = config.GetVal('door_cost')
  local query, title = '#DoorMenu_OwnQuery', '#DoorMenu_OwnTitle'

  if doorCost > 0 then
    query = '#DoorMenu_PurchaseQuery:'..cw.core:FormatCash(doorCost, nil, true)..';'
    title = '#DoorMenu_PurchaseTitle'
  end

  Derma_Query(L(query), L(title), L('Yes'), function()
    cable.send('DoorManagement', { data, 'Purchase' })

    gui.EnableScreenClicker(false)
  end, L('No'), function()
    gui.EnableScreenClicker(false)
  end)

  gui.EnableScreenClicker(true)
end)

cable.receive('SetSharedAccess', function(data)
  if cw.door:GetPanel() then
    cw.door.cwDoorSharedAxs = data

    cw.door:GetPanel():Rebuild()
  end
end)

cable.receive('SetSharedText', function(data)
  if cw.door:GetPanel() then
    cw.door.cwDoorSharedTxt = data

    cw.door:GetPanel():Rebuild()
  end
end)

cable.receive('DoorAccess', function(data)
  if cw.door:GetPanel() then
    local accessList = cw.door:GetAccessList()

    if IsValid(data[1]) then
      if data[2] then
        accessList[data[1]] = data[2]
      else
        accessList[data[1]] = nil
      end

      cw.door:GetPanel():Rebuild()
    end
  end
end)

cable.receive('DoorManagement', function(data)
  if cw.door:GetPanel() then
    cw.door:GetPanel():Remove()
  end

  gui.EnableScreenClicker(true)

  cw.door.cwDoorSharedAxs = data.cwDoorSharedAxs
  cw.door.cwDoorSharedTxt = data.cwDoorSharedTxt
  cw.door.unsellable = data.unsellable
  cw.door.accessList = data.accessList
  cw.door.isParent = data.isParent
  cw.door.entity = data.entity
  cw.door.owner = data.owner
  cw.door.name = cw.entity:GetDoorName(data.entity)

  if cw.door.name == '' then
    cw.door.name = L('#Doors_Name')
  end

  cw.door.panel = vgui.Create('cwDoor')
  cw.door.panel:MakePopup()
  cw.door.panel:Rebuild()

  if !cw.entity:HasOwner(data.entity) or IsValid(data.owner) then
    cw.door.panel.textEntry:SetValue(cw.entity:GetDoorText(data.entity))
  end
end)
