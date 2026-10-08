--- Defines the `cwStorage` window, which shows an open storage next to the player's inventory, and handles the storage
-- netstreams.
--
-- `cwStorageItem` is an item icon that moves the item with the `StorageGiveItem` and `StorageTakeItem` commands, and
-- `cwStorageWeight` and `cwStorageSpace` are the weight and space bars. The `StorageStart`, `StorageCash`,
-- `StorageWeight`, `StorageSpace`, `StorageTake`, `StorageGive` and `StorageClose` hooks keep `cw.storage` and the
-- window in sync with the server.

local barBackgroundColor = Color(75, 75, 75, 255)
local barUsedColor = Color(139, 215, 113, 255)

local PANEL = {}

--- Builds the storage window with a container list and, unless the storage is one-sided, the player's
-- inventory list next to it.
--
-- Closing the window runs the `StorageClose` command.
function PANEL:Init()
  self:SetTitle(cw.storage:GetName())
  self:SetDeleteOnClose(false)

  -- Called when the button is clicked.
  function self.btnClose.DoClick(button)
    CloseDermaMenus()
      self:Close() self:Remove()
      gui.EnableScreenClicker(false)
    cw.core:RunCommand('StorageClose')
  end

  self.containerPanel = vgui.Create('cwPanelList', self)
  self.containerPanel:SetPadding(2)
  self.containerPanel:SetSpacing(3)
  self.containerPanel:SizeToContents()
  self.containerPanel:EnableVerticalScrollbar()

  if !cw.storage:GetIsOneSided() then
    self.inventoryPanel = vgui.Create('cwPanelList', self)
    self.inventoryPanel:SetPadding(2)
    self.inventoryPanel:SetSpacing(3)
    self.inventoryPanel:SizeToContents()
    self.inventoryPanel:EnableVerticalScrollbar()
  end

  cw.core:SetNoticePanel(self)
end

--- Rebuilds one side of the storage window: a model preview, the weight and space bars, a cash transfer
-- form and the items that can be moved, grouped by category.
--
-- Only items the storage lets the player take (container side) or give (inventory side) are listed,
-- each as a `cwStorageItem`. The cash form appears when cash is enabled and the side holds cash; it runs
-- the `StorageTakeCash` or `StorageGiveCash` command. Runs the `PlayerPreRebuildStorage` hook with the
-- panel before building it and `PlayerStorageRebuilt` with the panel and the category list after
-- sorting the items.
--
-- @param storagePanel [Panel The `cwPanelList` to fill]
-- @param storageType [String `'Container'` or `'Inventory'`]
-- @param usedWeight [Number Weight already used, stored on the panel; when `nil`, the weight of the cash and
-- listed items is stored instead]
-- @param weight [Number Maximum weight of the side]
-- @param usedSpace [Number Space already used, stored on the panel; when `nil`, the space of the cash and
-- listed items is stored instead]
-- @param space [Number Maximum space of the side]
-- @param cash [Number Cash held by the side]
-- @param inventory [Inventory Items held by the side]
function PANEL:RebuildPanel(storagePanel, storageType, usedWeight, weight, usedSpace, space, cash, inventory)
  storagePanel:Clear(true)
    storagePanel.cash = cash
    storagePanel.weight = weight
    storagePanel.usedWeight = usedWeight
    storagePanel.space = space
    storagePanel.usedSpace = usedSpace
    storagePanel.inventory = inventory
    storagePanel.storageType = storageType
  hook.Run('PlayerPreRebuildStorage', storagePanel)

  local modelIcon = vgui.Create('DModelPanel', storagePanel)
  modelIcon:SetSize(100, 250)

  local modelSource = cw.client

  if storageType == 'Container' then
    modelSource = cw.storage:GetEntity()
  end

  if IsValid(modelSource) then
    modelIcon:SetModel(modelSource:GetModel())
  end

  local modelEntity = modelIcon:GetEntity()

  if IsValid(modelEntity) then
    local bone = modelEntity:LookupBone('ValveBiped.Bip01_Head1')
    local position = Vector(0, 0, 10)

    if bone then
      position = modelEntity:GetBonePosition(bone)
    end

    modelIcon:SetLookAt(position - Vector(0, 0, 15))
    modelEntity:SetSequence(modelSource:GetSequence())
  end

  function modelIcon:LayoutEntity(entity) return self:RunAnimation() end

  storagePanel:AddItem(modelIcon)

  local categories = {}
  local usedWeight = (cash * config.GetVal('cash_weight'))
  local usedSpace = (cash * config.GetVal('cash_space'))
  local itemsList = {}

  if cw.storage:GetNoCashWeight() then
    usedWeight = 0
  end

  if cw.storage:GetNoCashSpace() then
    usedSpace = 0
  end

  for k, v in pairs(storagePanel.inventory) do
    for k2, v2 in pairs(v) do
      if (storageType == 'Container' and cw.storage:CanTakeFrom(v2))
      or (storageType == 'Inventory' and cw.storage:CanGiveTo(v2)) then
        local itemCategory = v2.category

        if itemCategory then
          itemsList[itemCategory] = itemsList[itemCategory] or {}
          itemsList[itemCategory][#itemsList[itemCategory] + 1] = v2
          usedWeight = usedWeight + math.max((v2.storageWeight or v2.weight), 0)
          usedSpace = usedSpace + math.max((v2.storageSpace or v2.space), 0)
        end
      end
    end
  end

  for k, v in pairs(itemsList) do
    categories[#categories + 1] = {
      itemsList = v,
      category = k
    }
  end

  table.sort(categories, function(a, b)
    return a.category < b.category
  end)

  if !storagePanel.usedWeight then
    storagePanel.usedWeight = usedWeight
  end

  if !storagePanel.usedSpace then
    storagePanel.usedSpace = usedSpace
  end

  hook.Run(
    'PlayerStorageRebuilt', storagePanel, categories
  )

  local numberWang = nil
  local cashForm = nil
  local button = nil

  if config.GetVal('cash_enabled') and storagePanel.cash > 0 then
    numberWang = vgui.Create('DNumberWang', storagePanel)
    cashForm = vgui.Create('DForm', storagePanel)
    button = vgui.Create('DButton', storagePanel)

    button:SetText('#Storage_TransferCash')
    button.Stretch = true

    -- Called when the button is clicked.
    function button.DoClick(button)
      local amount = math.min(math.floor(tonumber(numberWang:GetValue()) or 0), storagePanel.cash)

      if amount < 1 then
        return
      end

      if storageType == 'Inventory' then
        cw.core:RunCommand('StorageGiveCash', amount)
      else
        cw.core:RunCommand('StorageTakeCash', amount)
      end
    end

    numberWang.Stretch = true
    numberWang:SetDecimals(0)
    numberWang:SetMinMax(1, storagePanel.cash)
    numberWang:SetValue(storagePanel.cash)
    numberWang:SizeToContents()

    cashForm:SetPadding(5)
    cashForm:SetName(cw.option:GetKey('name_cash'))
    cashForm:AddItem(numberWang)
    cashForm:AddItem(button)
  end

  local informationForm = vgui.Create('DForm', storagePanel)
    informationForm:SetPadding(5)
    informationForm:SetName(L'Weight')

    local storageWeight = vgui.Create('cwStorageWeight', storagePanel)
    storageWeight:SetWeight(storagePanel.weight)
    storageWeight:SetUsedWeight(storagePanel.usedWeight)

    informationForm:AddItem(storageWeight)
  storagePanel:AddItem(informationForm)

  if cw.inventory:UseSpaceSystem() and storagePanel.usedSpace > 0 then
    local informationForm = vgui.Create('DForm', storagePanel)
      informationForm:SetPadding(5)
      informationForm:SetName(L'#Space')

      local storageSpace = vgui.Create('cwStorageSpace', storagePanel)
      storageSpace:SetSpace(storagePanel.space)
      storageSpace:SetUsedSpace(storagePanel.usedSpace)

      informationForm:AddItem(storageSpace)
    storagePanel:AddItem(informationForm)
  end

  if cashForm then
    storagePanel:AddItem(cashForm)
  end

  if #categories > 0 then
    for k, v in pairs(categories) do
      local collapsibleCategory = cw.core:CreateCustomCategoryPanel(L(v.category), storagePanel)
        collapsibleCategory:SetCookieName(storageType..v.category)
      storagePanel:AddItem(collapsibleCategory)

      local categoryList = vgui.Create('DPanelList', collapsibleCategory)
        categoryList:EnableHorizontal(true)
        categoryList:SetAutoSize(true)
        categoryList:SetPadding(4)
        categoryList:SetSpacing(4)
      collapsibleCategory:SetContents(categoryList)

      table.sort(v.itemsList, function(a, b)
        return a.itemID < b.itemID
      end)

      for k2, v2 in pairs(v.itemsList) do
        CURRENT_ITEM_DATA = {
          itemTable = v2,
          storageType = storagePanel.storageType
        }

        categoryList:AddItem(
          vgui.Create('cwStorageItem', categoryList)
        )
      end
    end
  end
end

--- Rebuilds the container side from `cw.storage` and, unless the storage is one-sided, the player's
-- inventory side.
function PANEL:Rebuild()
  self.bRebuildQueued = nil

  self:RebuildPanel(self.containerPanel, 'Container', nil,
    cw.storage:GetWeight(),
    nil, cw.storage:GetSpace(),
    cw.storage:GetCash(),
    cw.storage:GetInventory()
  )

  if !cw.storage:GetIsOneSided() then
    local inventory = cw.inventory:GetClient()
    local maxWeight = cw.player:GetMaxWeight()
    local weight = cw.inventory:CalculateWeight(inventory)
    local maxSpace = cw.player:GetMaxSpace()
    local space = cw.inventory:CalculateSpace(inventory)
    local cash = cw.player:GetCash()

    self:RebuildPanel(self.inventoryPanel, 'Inventory',
      weight, maxWeight, space, maxSpace, cash, inventory
    )
  end
end

--- Rebuilds the window on the next frame.
--
-- The server sends an update for the cash, the limits and each item type when a storage is opened, so
-- queueing them rebuilds the window once instead of once per message.
function PANEL:QueueRebuild()
  self.bRebuildQueued = true
end

--- Keeps the window centred and rebuilds it when a rebuild is queued or the player's cash changes.
function PANEL:Think()
  self:SetSize(ScrW() * 0.5, ScrH() * 0.75)
  self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))

  if self.bRebuildQueued
  or (IsValid(self.inventoryPanel) and cw.player:GetCash() != self.inventoryPanel.cash) then
    self:Rebuild()
  end
end

--- Removes the window's background blur along with it.
function PANEL:OnRemove()
  cw.core:RemoveBackgroundBlur(self)
end

--- Lays out the frame with the container list on the left half and the inventory list on the right.
function PANEL:PerformLayout(w, h)
  DFrame.PerformLayout(self)

  if !cw.storage:GetIsOneSided() then
    self.inventoryPanel:StretchToParent(nil, 28, nil, 4)
    self.inventoryPanel:AlignRight(0)
    self.inventoryPanel:SetWide(self:GetWide() / 2)
  end

  self.containerPanel:SetWide(self:GetWide() / 2)
  self.containerPanel:StretchToParent(nil, 28, nil, 4)
  self.containerPanel:AlignLeft(0)
end

vgui.Register('cwStorage', PANEL, 'DFrame')

local PANEL = {}

--- Builds a storage item icon (`cwStorageItem`) from the parent's `itemData` or the global
-- `CURRENT_ITEM_DATA`.
--
-- Clicking the icon moves the item with the `StorageGiveItem` or `StorageTakeItem` command, at most once
-- a second.
function PANEL:Init()
  local itemData = self:GetParent().itemData or CURRENT_ITEM_DATA

  self:SetSize(48, 48)
  self.itemTable = itemData.itemTable
  self.storageType = itemData.storageType
  self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create('cwSpawnIcon', self))

  -- Called when the spawn icon is clicked.
  function self.spawnIcon.DoClick(spawnIcon)
    if !self.nextCanClick or CurTime() >= self.nextCanClick then
      if self.storageType == 'Inventory' then
        cw.core:RunCommand('StorageGiveItem', self.itemTable.uniqueID, self.itemTable.itemID)
      else
        cw.core:RunCommand('StorageTakeItem', self.itemTable.uniqueID, self.itemTable.itemID)
      end

      self.nextCanClick = CurTime() + 1
    end
  end

  local model, skin = item.GetIconInfo(self.itemTable)
    self.spawnIcon:SetModel(model, skin)
    self.spawnIcon:SetTooltip('')
    self.spawnIcon:SetSize(48, 48)
  self.cachedInfo = { model = model, skin = skin }
end

--- Refreshes the storage item's color, its model when the item's icon changes, and its tooltip while it is
-- hovered.
function PANEL:Think()
  local spawnIcon = self.spawnIcon

  -- The tooltip is only drawn for the hovered panel, so the others keep the one they were built with.
  if cw.core:GetActiveMarkupToolTip() == spawnIcon or !spawnIcon:GetMarkupToolTip() then
    spawnIcon:SetMarkupToolTip(item.GetMarkupToolTip(self.itemTable))
  end

  spawnIcon:SetColor(self.itemTable.color)

  --[[ Check if the model or skin has changed and update the spawn icon. --]]
  local model, skin = item.GetIconInfo(self.itemTable)

  if model != self.cachedInfo.model or skin != self.cachedInfo.skin then
    self.spawnIcon:SetModel(model, skin)
    self.cachedInfo.model = model
    self.cachedInfo.skin = skin
  end
end

vgui.Register('cwStorageItem', PANEL, 'DPanel')

local PANEL = {}

--- Sets the maximum weight shown by the weight bar.
-- @param weight [Number Maximum weight]
function PANEL:SetWeight(weight)
  self.weight = weight
end

--- Returns the maximum weight shown by the weight bar.
-- @return [Number Maximum weight, or 0 when unset]
function PANEL:GetWeight()
  return self.weight or 0
end

--- Sets the used weight shown by the weight bar.
-- @param usedWeight [Number Weight in use]
function PANEL:SetUsedWeight(usedWeight)
  self.usedWeight = usedWeight
end

--- Returns the used weight shown by the weight bar.
-- @return [Number Weight in use, or 0 when unset]
function PANEL:GetUsedWeight()
  return self.usedWeight or 0
end

--- Creates the storage weight bar (`cwStorageWeight`) and its label.
function PANEL:Init()
  local colorWhite = cw.option:GetColor('white')

  self.spaceUsed = vgui.Create('DPanel', self)
  self.spaceUsed:SetPos(1, 1)
  self.panel = self:GetParent()

  self.weightLabel = vgui.Create('DLabel', self)
  self.weightLabel:SetText('N/A')
  self.weightLabel:SetTextColor(colorWhite)
  self.weightLabel:SizeToContents()
  self.weightLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))

  -- Called when the panel should be painted.
  function self.spaceUsed.Paint(spaceUsed)
    local maximumWeight = math.floor(self:GetWeight())
    local usedWeight = math.floor(self:GetUsedWeight())
    local width = math.Clamp((spaceUsed:GetWide() / maximumWeight) * usedWeight, 0, spaceUsed:GetWide())

    cw.core:DrawSimpleGradientBox(0, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), barBackgroundColor)
    cw.core:DrawSimpleGradientBox(0, 0, 0, width, spaceUsed:GetTall(), barUsedColor)
  end
end

--- Lays out the weight bar and updates its label when the used or maximum weight changes.
function PANEL:Think()
  local usedWeight = math.floor(self:GetUsedWeight())
  local maximumWeight = math.floor(self:GetWeight())

  if usedWeight != self.shownUsedWeight or maximumWeight != self.shownWeight then
    self.shownUsedWeight = usedWeight
    self.shownWeight = maximumWeight

    self.weightLabel:SetText(usedWeight..'/'..maximumWeight..L('#Unit_Kilograms'))
    self.weightLabel:SizeToContents()
  end

  self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2)
  self.weightLabel:SetPos(
    self:GetWide() / 2 - self.weightLabel:GetWide() / 2,
    self:GetTall() / 2 - self.weightLabel:GetTall() / 2
  )
end

vgui.Register('cwStorageWeight', PANEL, 'DPanel')

local PANEL = {}

--- Sets the maximum space shown by the space bar.
-- @param space [Number Maximum space]
function PANEL:SetSpace(space)
  self.maxSpace = space
end

--- Returns the maximum space shown by the space bar.
-- @return [Number Maximum space, or 0 when unset]
function PANEL:GetSpace()
  return self.maxSpace or 0
end

--- Sets the used space shown by the space bar.
-- @param usedSpace [Number Space in use]
function PANEL:SetUsedSpace(usedSpace)
  self.usedSpace = usedSpace
end

--- Returns the used space shown by the space bar.
-- @return [Number Space in use, or 0 when unset]
function PANEL:GetUsedSpace()
  return self.usedSpace or 0
end

--- Creates the storage space bar (`cwStorageSpace`) and its label.
function PANEL:Init()
  local colorWhite = cw.option:GetColor('white')

  self.spaceUsed = vgui.Create('DPanel', self)
  self.spaceUsed:SetPos(1, 1)
  self.panel = self:GetParent()

  self.space = vgui.Create('DLabel', self)
  self.space:SetText('N/A')
  self.space:SetTextColor(colorWhite)
  self.space:SizeToContents()
  self.space:SetExpensiveShadow(1, Color(0, 0, 0, 150))

  -- Called when the panel should be painted.
  function self.spaceUsed.Paint(spaceUsed)
    local maximumSpace = math.floor(self:GetSpace())
    local usedSpace = math.floor(self:GetUsedSpace())
    local width = math.Clamp((spaceUsed:GetWide() / maximumSpace) * usedSpace, 0, spaceUsed:GetWide())

    cw.core:DrawSimpleGradientBox(0, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), barBackgroundColor)
    cw.core:DrawSimpleGradientBox(0, 0, 0, width, spaceUsed:GetTall(), barUsedColor)
  end
end

--- Lays out the space bar and updates its label when the used or maximum space changes.
function PANEL:Think()
  local usedSpace = math.floor(self:GetUsedSpace())
  local maximumSpace = math.floor(self:GetSpace())

  if usedSpace != self.shownUsedSpace or maximumSpace != self.shownSpace then
    self.shownUsedSpace = usedSpace
    self.shownSpace = maximumSpace

    self.space:SetText(usedSpace..'/'..maximumSpace..L('#Unit_Litres'))
    self.space:SizeToContents()
  end

  self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2)
  self.space:SetPos(self:GetWide() / 2 - self.space:GetWide() / 2, self:GetTall() / 2 - self.space:GetTall() / 2)
end

vgui.Register('cwStorageSpace', PANEL, 'DPanel')

netstream.Hook('StorageStart', function(data)
  if cw.storage:IsStorageOpen() then
    CloseDermaMenus()
    cw.storage.panel:Close()
    cw.storage.panel:Remove()
  end

  gui.EnableScreenClicker(true)

  cw.storage.noCashWeight = data.noCashWeight
  cw.storage.noCashSpace = data.noCashSpace
  cw.storage.isOneSided = data.isOneSided
  cw.storage.inventory = {}
  cw.storage.weight = config.GetVal('default_inv_weight')
  cw.storage.space = config.GetVal('default_inv_space')
  cw.storage.entity = data.entity
  cw.storage.name = data.name
  cw.storage.cash = 0

  cw.storage.panel = vgui.Create('cwStorage')
  cw.storage.panel:Rebuild()
  cw.storage.panel:MakePopup()

  cw.core:RegisterBackgroundBlur(cw.storage:GetPanel(), SysTime())
end)

netstream.Hook('StorageCash', function(data)
  if cw.storage:IsStorageOpen() then
    cw.storage.cash = data
    cw.storage:GetPanel():QueueRebuild()
  end
end)

netstream.Hook('StorageWeight', function(data)
  if cw.storage:IsStorageOpen() then
    cw.storage.weight = data
    cw.storage:GetPanel():QueueRebuild()
  end
end)

netstream.Hook('StorageSpace', function(data)
  if cw.storage:IsStorageOpen() then
    cw.storage.space = data
    cw.storage:GetPanel():QueueRebuild()
  end
end)

netstream.Hook('StorageClose', function(data)
  if cw.storage:IsStorageOpen() then
    cw.core:RemoveBackgroundBlur(cw.storage:GetPanel())

    CloseDermaMenus()

    cw.storage:GetPanel():Close()
    cw.storage:GetPanel():Remove()

    gui.EnableScreenClicker(false)

    cw.storage.inventory = nil
    cw.storage.weight = nil
    cw.storage.space = nil
    cw.storage.entity = nil
    cw.storage.name = nil
  end
end)

netstream.Hook('StorageTake', function(data)
  if cw.storage:IsStorageOpen() then
    cw.inventory:RemoveUniqueID(
      cw.storage.inventory, data.uniqueID, data.itemID
    )

    cw.storage:GetPanel():QueueRebuild()
  end
end)

netstream.Hook('StorageGive', function(data)
  if cw.storage:IsStorageOpen() then
    local itemTable = item.FindByID(data.index)

    if itemTable then
      for k, v in pairs(data.itemList) do
        cw.inventory:AddInstance(
          cw.storage.inventory,
          item.CreateInstance(data.index, v.itemID, v.data)
        )
      end

      cw.storage:GetPanel():QueueRebuild()
    end
  end
end)
