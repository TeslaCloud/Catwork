--- Defines the `cwSalesmenu` panel, the menu in which a player trades with a salesman, and the `cwSalesmenuItem` icon
-- it shows for each item.
--
-- Lists the items the salesman sells and buys from `cw.salesmenu`, grouped by category. Clicking an icon sends a
-- `Salesmenu` Cable message to buy or sell the item, and closing the menu sends `SalesmanDone`.

local PANEL = {}

--- Builds the trade menu with a sells tab and a buys tab for whichever lists the salesman has.
--
-- Closing the frame sends `SalesmanDone` to the server and clears `cw.salesmenu`.
function PANEL:Init()
  local salesmenuName = cw.salesmenu:GetName()

  self:SetTitle(salesmenuName)
  self:SetBackgroundBlur(true)
  self:SetDeleteOnClose(false)

  -- Called when the button is clicked.
  function self.btnClose.DoClick(button)
    CloseDermaMenus()
    self:Close() self:Remove()

    cable.send('SalesmanDone', cw.salesmenu.entity)
      cw.salesmenu.buyInShipments = nil
      cw.salesmenu.priceScale = nil
      cw.salesmenu.factions = nil
      cw.salesmenu.buyRate = nil
      cw.salesmenu.classes = nil
      cw.salesmenu.entity = nil
      cw.salesmenu.stock = nil
      cw.salesmenu.sells = nil
      cw.salesmenu.cash = nil
      cw.salesmenu.text = nil
      cw.salesmenu.buys = nil
      cw.salesmenu.name = nil
      cw.salesmenu.flags = nil
    gui.EnableScreenClicker(false)
  end

  self.propertySheet = vgui.Create('DPropertySheet', self)
  self.propertySheet:SetPadding(4)

  if table.Count(cw.salesmenu:GetSells()) > 0 then
    self.sellsPanel = vgui.Create('cwPanelList')
    self.sellsPanel:SetPadding(2)
    self.sellsPanel:SetSpacing(3)
    self.sellsPanel:SizeToContents()
    self.sellsPanel:EnableVerticalScrollbar()

    self.propertySheet:AddSheet(
      L'Sells',
      self.sellsPanel,
      'icon16/box.png',
      nil,
      nil,
      string.Replace(L('#Salesman_SellsTip'), '#1', salesmenuName)
    )
  end

  if table.Count(cw.salesmenu:GetBuys()) > 0 then
    self.buysPanel = vgui.Create('cwPanelList')
    self.buysPanel:SetPadding(2)
    self.buysPanel:SetSpacing(3)
    self.buysPanel:SizeToContents()
    self.buysPanel:EnableVerticalScrollbar()

    self.propertySheet:AddSheet(
      L'Buys',
      self.buysPanel,
      'icon16/add.png',
      nil,
      nil,
      string.Replace(L('#Salesman_BuysTip'), '#1', salesmenuName)
    )
  end

  cw.core:SetNoticePanel(self)
end

--- Refills one tab of the trade menu with item icons grouped by category.
--
-- The sells tab lists the salesman's items; the buys tab lists the matching items in the local
-- player's inventory. Both are sorted by cost, most expensive first, and the salesman's cash is shown
-- when it is limited.
-- @param typeName [String Which tab this is: `'Sells'` or `'Buys'`]
-- @param panelList [Panel The `cwPanelList` of the tab]
-- @param inventory [Map The salesman's sells or buys list, keyed by item unique ID]
function PANEL:RebuildPanel(typeName, panelList, inventory)
  panelList:Clear(true)
  panelList.inventory = inventory

  if config.Get('cash_enabled'):Get() then
    local totalCash = cw.salesmenu:GetCash()

    if totalCash > -1 then
      local cashForm = vgui.Create('DForm', panelList)
        cashForm:SetName(cw.option:GetKey('name_cash'))
        cashForm:SetPadding(4)
      panelList:AddItem(cashForm)

      cashForm:Help(
        string.Replace(
          string.Replace(L('#Salesman_CashInfo'), '#2', cw.core:FormatCash(totalCash, nil, true)),
          '#1',
          cw.salesmenu:GetName()
        )
      )
    end
  end

  local categories = {}
  local items = {}

  for k, v in pairs(panelList.inventory) do
    if typeName == 'Sells' then
      local itemTable = item.FindByID(k)

      if itemTable then
        local itemCategory = itemTable.category

        if itemCategory then
          items[itemCategory] = items[itemCategory] or {}
          items[itemCategory][#items[itemCategory] + 1] = { k, v }
        end
      end
    else
      local itemsList = cw.inventory:GetItemsByID(
        cw.inventory:GetClient(), k
      )

      if itemsList then
        for k2, v2 in pairs(itemsList) do
          local itemCategory = v2.category

          if itemCategory then
            items[itemCategory] = items[itemCategory] or {}
            items[itemCategory][#items[itemCategory] + 1] = v2
          end
        end
      end
    end
  end

  for k, v in pairs(items) do
    categories[#categories + 1] = {
      category = k,
      items = v
    }
  end

  if table.Count(categories) > 0 then
    for k, v in pairs(categories) do
      local collapsibleCategory = cw.core:CreateCustomCategoryPanel(L(v.category), panelList)
        collapsibleCategory:SetCookieName('Salesmenu'..typeName..v.category)
      panelList:AddItem(collapsibleCategory)

      local categoryList = vgui.Create('DPanelList', collapsibleCategory)
        categoryList:EnableHorizontal(true)
        categoryList:SetAutoSize(true)
        categoryList:SetPadding(4)
        categoryList:SetSpacing(4)
      collapsibleCategory:SetContents(categoryList)

      if typeName == 'Sells' then
        table.sort(v.items, function(a, b)
          local itemTableA = item.FindByID(a[1])
          local itemTableB = item.FindByID(b[1])

          if itemTableA.cost == itemTableB.cost then
            return itemTableA.name < itemTableB.name
          else
            return itemTableA.cost > itemTableB.cost
          end
        end)

        for k2, v2 in pairs(v.items) do
          CURRENT_ITEM_DATA = {
            itemTable = item.FindByID(v2[1]),
            typeName = typeName
          }

          categoryList:AddItem(
            vgui.Create('cwSalesmenuItem', categoryList)
          )
        end
      else
        table.sort(v.items, function(a, b)
          if a.cost == b.cost then
            return a.name < b.name
          else
            return a.cost > b.cost
          end
        end)

        for k2, v2 in pairs(v.items) do
          CURRENT_ITEM_DATA = {
            itemTable = v2,
            typeName = typeName
          }

          categoryList:AddItem(
            vgui.Create('cwSalesmenuItem', categoryList)
          )
        end
      end
    end
  end
end

--- Refills the sells and buys tabs from `cw.salesmenu`.
function PANEL:Rebuild()
  if IsValid(self.sellsPanel) then
    self:RebuildPanel('Sells', self.sellsPanel, cw.salesmenu:GetSells())
  end

  if IsValid(self.buysPanel) then
    self:RebuildPanel('Buys', self.buysPanel, cw.salesmenu:GetBuys())
  end
end

--- Keeps the trade menu centred at half the screen width and three quarters of its height.
function PANEL:Think()
  local scrW = ScrW()
  local scrH = ScrH()

  self:SetSize(scrW * 0.5, scrH * 0.75)
  self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2))
end

--- Stretches the property sheet to fill the frame.
function PANEL:PerformLayout(w, h)
  DFrame.PerformLayout(self)

  self.propertySheet:StretchToParent(4, 28, 4, 4)
end

vgui.Register('cwSalesmenu', PANEL, 'DFrame')

local PANEL = {}

--- Creates the item's spawn icon; clicking it asks the server to buy or sell the item.
function PANEL:Init()
  local itemData = self:GetParent().itemData or CURRENT_ITEM_DATA

  self:SetSize(40, 40)
  self.itemTable = itemData.itemTable
  self.typeName = itemData.typeName
  self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create('cwSpawnIcon', self))
  self.spawnIcon:SetColor(self.itemTable.color)

  -- Called when the spawn icon is clicked.
  function self.spawnIcon.DoClick(spawnIcon)
    local entity = cw.salesmenu:GetEntity()

    if IsValid(entity) then
      cable.send('Salesmenu', {
        tradeType = self.typeName,
        uniqueID = self.itemTable.uniqueID,
        itemID = self.itemTable.itemID,
        entity = entity
      })
    end
  end

  local model, skin = item.GetIconInfo(self.itemTable)
  self.spawnIcon:SetModel(model, skin)
  self.spawnIcon:SetTooltip('')
  self.spawnIcon:SetSize(40, 40)
end

--- Updates the icon's tooltip with the item's price, shipment size and remaining stock.
function PANEL:UpdateToolTip()
  local function DisplayCallback(displayInfo)
    local priceScale = 1
    local amount = 0

    if cw.salesmenu:BuyInShipments() then
      amount = self.itemTable.batch
    else
      amount = 1
    end

    if self.typeName == 'Sells' then
      priceScale = cw.salesmenu:GetPriceScale()
    elseif self.typeName == 'Buys' then
      priceScale = cw.salesmenu:GetBuyRate() / 100
    end

    if config.Get('cash_enabled'):Get() then
      if self.itemTable.cost != 0 then
        displayInfo.weight = cw.core:FormatCash(
          (self.itemTable.cost * priceScale) * math.max(amount, 1)
        )
      else
        displayInfo.weight = L'Free'
      end

      local overrideCash = cw.salesmenu.sells[self.itemTable.uniqueID]

      if self.typeName == 'Buys' then
        overrideCash = cw.salesmenu.buys[self.itemTable.uniqueID]
      end

      if type(overrideCash) == 'number' then
        displayInfo.weight = cw.core:FormatCash(overrideCash * math.max(amount, 1))
      end
    end

    local name = cw.lang:TranslateText(self.itemTable.PrintName)

    if amount > 1 then
      displayInfo.name = amount..' '..cw.core:Pluralize(name)
    else
      displayInfo.name = name
    end

    if cw.salesmenu.stock then
      local iStockLeft = cw.salesmenu.stock[self.itemTable.uniqueID]

      if self.typeName == 'Sells' and iStockLeft then
        displayInfo.itemTitle = '['..iStockLeft..'] ['..displayInfo.name..', '..displayInfo.weight..']'
      end
    end
  end

  self.spawnIcon:SetMarkupToolTip(
    item.GetMarkupToolTip(self.itemTable, true, DisplayCallback)
  )
end

--- Refreshes the icon's color, and its tooltip while it is hovered.
function PANEL:Think()
  local spawnIcon = self.spawnIcon

  -- The tooltip is only drawn for the hovered panel, so the others keep the one they were built with.
  if cw.core:GetActiveMarkupToolTip() == spawnIcon or !spawnIcon:GetMarkupToolTip() then
    self:UpdateToolTip()
  end

  spawnIcon:SetColor(self.itemTable.color)
end

vgui.Register('cwSalesmenuItem', PANEL, 'DPanel')
