--- Defines the `cwSalesman` panel, the editor used to set up a salesman, and the `cwSalesmanItem` icon it shows for
-- each item.
--
-- The editor has sells, buys, items and settings tabs backed by `cw.salesman`; the settings cover prices, stock, cash,
-- model, responses and the factions and classes allowed to trade. Closing it sends the result to the server in the
-- `SalesmanAdd` netstream message.

local PANEL = {}
local colorSettings = Color(200, 200, 200)

--- Builds the salesman editor: the sells, buys, items and settings tabs, filled from `cw.salesman`.
--
-- Closing the frame sends the edited salesman to the server with the `SalesmanAdd` netstream message.
function PANEL:Init()
  local salesmanName = cw.salesman:GetName()

  self:SetTitle(salesmanName)
  self:SetBackgroundBlur(true)
  self:SetDeleteOnClose(false)

  -- Called when the button is clicked.
  function self.btnClose.DoClick(button)
    CloseDermaMenus()
    self:Close() self:Remove()

    netstream.Start('SalesmanAdd', {
      showChatBubble = cw.salesman.showChatBubble,
      buyInShipments = cw.salesman.buyInShipments,
      priceScale = cw.salesman.priceScale,
      factions = cw.salesman.factions,
      physDesc = cw.salesman.physDesc,
      buyRate = cw.salesman.buyRate,
      classes = cw.salesman.classes,
      stock = cw.salesman.stock,
      model = cw.salesman.model,
      sells = cw.salesman.sells,
      cash = cw.salesman.cash,
      text = cw.salesman.text,
      buys = cw.salesman.buys,
      name = cw.salesman.name,
      flags = cw.salesman.flags
    })

    cw.salesman.priceScale = nil
    cw.salesman.factions = nil
    cw.salesman.classes = nil
    cw.salesman.physDesc = nil
    cw.salesman.buyRate = nil
    cw.salesman.stock = nil
    cw.salesman.model = nil
    cw.salesman.sells = nil
    cw.salesman.buys = nil
    cw.salesman.items = nil
    cw.salesman.text = nil
    cw.salesman.cash = nil
    cw.salesman.name = nil
    cw.salesman.flags = nil

    gui.EnableScreenClicker(false)
  end

  self.sellsPanel = vgui.Create('cwPanelList')
  self.sellsPanel:SetPadding(2)
  self.sellsPanel:SetSpacing(3)
  self.sellsPanel:SizeToContents()
  self.sellsPanel:EnableVerticalScrollbar()

  self.buysPanel = vgui.Create('cwPanelList')
  self.buysPanel:SetPadding(2)
  self.buysPanel:SetSpacing(3)
  self.buysPanel:SizeToContents()
  self.buysPanel:EnableVerticalScrollbar()

  self.itemsPanel = vgui.Create('cwPanelList')
  self.itemsPanel:SetPadding(2)
  self.itemsPanel:SetSpacing(3)
  self.itemsPanel:SizeToContents()
  self.itemsPanel:EnableVerticalScrollbar()

  self.settingsPanel = vgui.Create('cwPanelList')
  self.settingsPanel:SetPadding(2)
  self.settingsPanel:SetSpacing(3)
  self.settingsPanel:SizeToContents()
  self.settingsPanel:EnableVerticalScrollbar()
  self.settingsPanel.Paint = function(sp, w, h)
    draw.RoundedBox(0, 0, 0, w, h, colorSettings)
  end

  self.settingsForm = vgui.Create('cwForm')
  self.settingsForm:SetPadding(4)
  self.settingsForm:SetName(L'Settings')

  self.settingsPanel:AddItem(self.settingsForm)

  self.showChatBubble = self.settingsForm:CheckBox(L('#Salesman_ShowChatBubble'))
  self.buyInShipments = self.settingsForm:CheckBox(L('#Salesman_BuyInShipments'))
  self.priceScale = self.settingsForm:TextEntry(L('#Salesman_PriceScale'))
  self.flagsEntry = self.settingsForm:TextEntry(L('#Salesman_Flags'))
  self.physDesc = self.settingsForm:TextEntry(L('#Salesman_PhysDesc'))
  self.buyRate = self.settingsForm:NumSlider(L('#Salesman_BuyRate'), nil, 1, 100, 0)
  self.stock = self.settingsForm:NumSlider(L('#Salesman_Stock'), nil, -1, 100, 0)
  self.model = self.settingsForm:TextEntry(L('#Salesman_Model'))
  self.cash = self.settingsForm:NumSlider(L('#Salesman_Cash'), nil, -1, 1000000, 0)

  self.buyRate:SetTooltip(L('#Salesman_BuyRateTip'))
  self.stock:SetTooltip(L('#Salesman_StockTip'))
  self.cash:SetTooltip(L('#Salesman_CashTip'))

  self.showChatBubble:SetValue(cw.salesman.showChatBubble == true)
  self.buyInShipments:SetValue(cw.salesman.buyInShipments == true)
  self.priceScale:SetValue(cw.salesman.priceScale)
  self.flagsEntry:SetValue(cw.salesman.flags or '')
  self.physDesc:SetValue(cw.salesman.physDesc)
  self.buyRate:SetValue(cw.salesman.buyRate)
  self.stock:SetValue(cw.salesman.stock)
  self.model:SetValue(cw.salesman.model)
  self.cash:SetValue(cw.salesman.cash)

  self.responsesForm = vgui.Create('cwForm')
  self.responsesForm:SetPadding(4)
  self.responsesForm:SetName(L('#Salesman_Responses'))
  self.settingsForm:AddItem(self.responsesForm)

  self.startText = self.responsesForm:TextEntry(L('#Salesman_Response_Start'))
  self.startSound = self.responsesForm:TextEntry(L('#Salesman_Response_Sound'))
  self.startHideName = self.responsesForm:CheckBox(L('#Salesman_Response_HideName'))

  self.noSaleText = self.responsesForm:TextEntry(L('#Salesman_Response_NoSale'))
  self.noSaleSound = self.responsesForm:TextEntry(L('#Salesman_Response_Sound'))
  self.noSaleHideName = self.responsesForm:CheckBox(L('#Salesman_Response_HideName'))

  self.noStockText = self.responsesForm:TextEntry(L('#Salesman_Response_NoStock'))
  self.noStockSound = self.responsesForm:TextEntry(L('#Salesman_Response_Sound'))
  self.noStockHideName = self.responsesForm:CheckBox(L('#Salesman_Response_HideName'))

  self.needMoreText = self.responsesForm:TextEntry(L('#Salesman_Response_NeedMore'))
  self.needMoreSound = self.responsesForm:TextEntry(L('#Salesman_Response_Sound'))
  self.needMoreHideName = self.responsesForm:CheckBox(L('#Salesman_Response_HideName'))

  self.cannotAffordText = self.responsesForm:TextEntry(L('#Salesman_Response_CannotAfford'))
  self.cannotAffordSound = self.responsesForm:TextEntry(L('#Salesman_Response_Sound'))
  self.cannotAffordHideName = self.responsesForm:CheckBox(L('#Salesman_Response_HideName'))

  self.doneBusinessText = self.responsesForm:TextEntry(L('#Salesman_Response_DoneBusiness'))
  self.doneBusinessSound = self.responsesForm:TextEntry(L('#Salesman_Response_Sound'))
  self.doneBusinessHideName = self.responsesForm:CheckBox(L('#Salesman_Response_HideName'))

  cw.salesman.text.start = cw.salesman.text.start or {}

  self.startText:SetValue(cw.salesman.text.start.text or L('#Salesman_Default_Start'))
  self.startSound:SetValue(cw.salesman.text.start.sound or '')

  self.startHideName:SetValue(cw.salesman.text.start.bHideName == true)

  self.noSaleText:SetValue(cw.salesman.text.noSale.text or L('#Salesman_Default_NoSale'))
  self.noSaleSound:SetValue(cw.salesman.text.noSale.sound or '')

  self.noSaleHideName:SetValue(cw.salesman.text.noSale.bHideName == true)

  self.noStockText:SetValue(cw.salesman.text.noStock.text or L('#Salesman_Prefill_NoStock'))
  self.noStockSound:SetValue(cw.salesman.text.noStock.sound or '')

  self.noStockHideName:SetValue(cw.salesman.text.noStock.bHideName == true)

  self.needMoreText:SetValue(cw.salesman.text.needMore.text or L('#Salesman_Prefill_NeedMore'))
  self.needMoreSound:SetValue(cw.salesman.text.needMore.sound or '')

  self.needMoreHideName:SetValue(cw.salesman.text.needMore.bHideName == true)

  self.cannotAffordText:SetValue(cw.salesman.text.cannotAfford.text or L('#Salesman_Prefill_CannotAfford'))
  self.cannotAffordSound:SetValue(cw.salesman.text.cannotAfford.sound or '')

  self.cannotAffordHideName:SetValue(cw.salesman.text.cannotAfford.bHideName == true)

  self.doneBusinessText:SetValue(cw.salesman.text.doneBusiness.text or L('#Salesman_Prefill_DoneBusiness'))
  self.doneBusinessSound:SetValue(cw.salesman.text.doneBusiness.sound or '')

  self.doneBusinessHideName:SetValue(cw.salesman.text.doneBusiness.bHideName == true)

  self.factionsForm = vgui.Create('DForm')
  self.factionsForm:SetPadding(4)
  self.factionsForm:SetName(L('#Salesman_Factions'))
  self.settingsForm:AddItem(self.factionsForm)
  self.factionsForm:Help(L('#Salesman_FactionsHelp'))

  self.classesForm = vgui.Create('DForm')
  self.classesForm:SetPadding(4)
  self.classesForm:SetName(L('#Classes'))
  self.settingsForm:AddItem(self.classesForm)
  self.classesForm:Help(L('#Salesman_ClassesHelp'))

  self.classBoxes = {}
  self.factionBoxes = {}

  for k, v in pairs(faction.GetStored()) do
    self.factionBoxes[k] = self.factionsForm:CheckBox(v.name)
    self.factionBoxes[k].OnChange = function(checkBox)
      if checkBox:GetChecked() then
        cw.salesman.factions[k] = true
      else
        cw.salesman.factions[k] = nil
      end
    end

    if cw.salesman.factions[k] then
      self.factionBoxes[k]:SetValue(true)
    end
  end

  for k, v in pairs(cw.class:GetStored()) do
    self.classBoxes[k] = self.classesForm:CheckBox(v.name)
    self.classBoxes[k].OnChange = function(checkBox)
      if checkBox:GetChecked() then
        cw.salesman.classes[k] = true
      else
        cw.salesman.classes[k] = nil
      end
    end

    if cw.salesman.classes[k] then
      self.classBoxes[k]:SetValue(true)
    end
  end

  self.propertySheet = vgui.Create('DPropertySheet', self)
    self.propertySheet:SetPadding(4)
    self.propertySheet:AddSheet(
      L'Sells',
      self.sellsPanel,
      'icon16/box.png',
      nil,
      nil,
      string.Replace(L('#Salesman_SellsTip'), '#1', salesmanName)
    )
    self.propertySheet:AddSheet(
      L'Buys',
      self.buysPanel,
      'icon16/add.png',
      nil,
      nil,
      string.Replace(L('#Salesman_BuysTip'), '#1', salesmanName)
    )
    self.propertySheet:AddSheet(
      L'Items',
      self.itemsPanel,
      'icon16/application_view_tile.png',
      nil,
      nil,
      L('#Salesman_ItemsTip')
    )
    self.propertySheet:AddSheet(
      L'Settings',
      self.settingsPanel,
      'icon16/tick.png',
      nil,
      nil,
      L('#Salesman_SettingsTip')
    )
  cw.core:SetNoticePanel(self)
end

--- Refills one tab of the editor with item icons grouped by category and sorted by cost.
-- @param panelList [Panel The `cwPanelList` of the tab]
-- @param typeName [String Which tab this is: `'Sells'`, `'Buys'` or `'Items'`]
-- @param inventory [Map The items to show, keyed by item unique ID]
function PANEL:RebuildPanel(panelList, typeName, inventory)
  panelList:Clear(true)
  panelList.typeName = typeName
  panelList.inventory = inventory

  local categories = {}
  local items = {}

  for k, v in pairs(panelList.inventory) do
    local itemTable = item.FindByID(k)

    if itemTable then
      local category = itemTable.category

      if category then
        items[category] = items[category] or {}
        items[category][#items[category] + 1] = { k, v }
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
        collapsibleCategory:SetCookieName('Salesman'..typeName..v.category)
      panelList:AddItem(collapsibleCategory)

      local categoryList = vgui.Create('DPanelList', collapsibleCategory)
        categoryList:EnableHorizontal(true)
        categoryList:SetAutoSize(true)
        categoryList:SetPadding(4)
        categoryList:SetSpacing(4)
      collapsibleCategory:SetContents(categoryList)

      table.sort(v.items, function(a, b)
        local itemTableA = item.FindByID(a[1])
        local itemTableB = item.FindByID(b[1])

        return itemTableA.cost < itemTableB.cost
      end)

      for k2, v2 in pairs(v.items) do
        CURRENT_ITEM_DATA = {
          itemTable = item.FindByID(v2[1]),
          typeName = typeName
        }

        categoryList:AddItem(
          vgui.Create('cwSalesmanItem', categoryList)
        )
      end
    end
  end
end

--- Refills the sells, buys and items tabs from `cw.salesman`.
function PANEL:Rebuild()
  self:RebuildPanel(self.sellsPanel, 'Sells',
    cw.salesman:GetSells()
  )

  self:RebuildPanel(self.buysPanel, 'Buys',
    cw.salesman:GetBuys()
  )

  self:RebuildPanel(self.itemsPanel, 'Items',
    cw.salesman:GetItems()
  )
end

--- Keeps the editor centred and copies the settings and response fields back into `cw.salesman`.
function PANEL:Think()
  self:SetSize(ScrW() * 0.5, ScrH() * 0.75)
  self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))

  cw.salesman.text.doneBusiness = {
    text = self.doneBusinessText:GetValue(),
    bHideName = (self.doneBusinessHideName:GetChecked() == true),
    sound = self.doneBusinessSound:GetValue()
  }
  cw.salesman.text.cannotAfford = {
    text = self.cannotAffordText:GetValue(),
    bHideName = (self.cannotAffordHideName:GetChecked() == true),
    sound = self.cannotAffordSound:GetValue()
  }
  cw.salesman.text.needMore = {
    text = self.needMoreText:GetValue(),
    bHideName = (self.needMoreHideName:GetChecked() == true),
    sound = self.needMoreSound:GetValue()
  }
  cw.salesman.text.noStock = {
    text = self.noStockText:GetValue(),
    bHideName = (self.noStockHideName:GetChecked() == true),
    sound = self.noStockSound:GetValue()
  }
  cw.salesman.text.noSale = {
    text = self.noSaleText:GetValue(),
    bHideName = (self.noSaleHideName:GetChecked() == true),
    sound = self.noSaleSound:GetValue()
  }
  cw.salesman.text.start = {
    text = self.startText:GetValue(),
    bHideName = (self.startHideName:GetChecked() == true),
    sound = self.startSound:GetValue()
  }
  cw.salesman.showChatBubble = (self.showChatBubble:GetChecked() == true)
  cw.salesman.buyInShipments = (self.buyInShipments:GetChecked() == true)
  cw.salesman.physDesc = self.physDesc:GetValue()
  cw.salesman.buyRate = math.Round(self.buyRate:GetValue())
  cw.salesman.stock = math.Round(self.stock:GetValue())
  cw.salesman.model = self.model:GetValue()
  cw.salesman.cash = math.Round(self.cash:GetValue())

  local priceScale = self.priceScale:GetValue()
  cw.salesman.priceScale = tonumber(priceScale) or 1

  cw.salesman.flags = self.flagsEntry:GetValue() or ''
end

--- Stretches the property sheet to fill the frame.
function PANEL:PerformLayout(w, h)
  DFrame.PerformLayout(self)

  if self.propertySheet then
    self.propertySheet:StretchToParent(4, 28, 4, 4)
  end
end

vgui.Register('cwSalesman', PANEL, 'DFrame')

local PANEL = {}

--- Creates the item's spawn icon; clicking it adds the item to the sells or buys list (asking for a
-- price when cash is enabled), or removes it from the list it is shown in.
function PANEL:Init()
  local itemData = self:GetParent().itemData or CURRENT_ITEM_DATA
  self:SetSize(40, 40)
  self.itemTable = itemData.itemTable
  self.typeName = itemData.typeName
  self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create('cwSpawnIcon', self))
  self.spawnIcon:SetColor(self.itemTable.color)

  -- Called when the spawn icon is clicked.
  function self.spawnIcon.DoClick(spawnIcon)
    if self.typeName == 'Items' then
      if config.Get('cash_enabled'):Get() then
        local cashName = cw.option:GetKey('name_cash')

        cw.core:AddMenuFromData(nil, {
          [L'Buys'] = function()
            Derma_StringRequest(cashName, '#Salesman_BuyPriceRequest', '', function(text)
              cw.salesman.buys[self.itemTable.uniqueID] = tonumber(text) or true
              cw.salesman:GetPanel():Rebuild()
            end)
          end,
          [L'Sells'] = function()
            Derma_StringRequest(cashName, '#Salesman_SellPriceRequest', '', function(text)
              cw.salesman.sells[self.itemTable.uniqueID] = tonumber(text) or true
              cw.salesman:GetPanel():Rebuild()
            end)
          end,
          [L'Both'] = function()
            Derma_StringRequest(cashName, '#Salesman_SellPriceRequest', '', function(sellPrice)
              Derma_StringRequest(cashName, '#Salesman_BuyPriceRequest', '', function(buyPrice)
                cw.salesman.sells[self.itemTable.uniqueID] = tonumber(sellPrice) or true
                cw.salesman.buys[self.itemTable.uniqueID] = tonumber(buyPrice) or true
                cw.salesman:GetPanel():Rebuild()
              end)
            end)
          end
        })
      else
        cw.core:AddMenuFromData(nil, {
          [L'Buys'] = function()
            cw.salesman.buys[self.itemTable.uniqueID] = true
            cw.salesman:GetPanel():Rebuild()
          end,
          [L'Sells'] = function()
            cw.salesman.sells[self.itemTable.uniqueID] = true
            cw.salesman:GetPanel():Rebuild()
          end,
          [L'Both'] = function()
            cw.salesman.sells[self.itemTable.uniqueID] = true
            cw.salesman.buys[self.itemTable.uniqueID] = true
            cw.salesman:GetPanel():Rebuild()
          end
        })
      end
    elseif self.typeName == 'Sells' then
      cw.salesman.sells[self.itemTable.uniqueID] = nil
      cw.salesman:GetPanel():Rebuild()
    elseif self.typeName == 'Buys' then
      cw.salesman.buys[self.itemTable.uniqueID] = nil
      cw.salesman:GetPanel():Rebuild()
    end
  end

  local model, skin = item.GetIconInfo(self.itemTable)
  self.spawnIcon:SetModel(model, skin)
  self.spawnIcon:SetTooltip('')
  self.spawnIcon:SetSize(40, 40)
end

--- Updates the icon's tooltip with the item's price, shipment size and stock.
function PANEL:UpdateToolTip()
  local function DisplayCallback(displayInfo)
    local priceScale = 1
    local amount = 0

    if cw.salesman:BuyInShipments() then
      amount = self.itemTable.batch
    else
      amount = 1
    end

    if self.typeName == 'Sells' then
      priceScale = cw.salesman:GetPriceScale()
    elseif self.typeName == 'Buys' then
      priceScale = cw.salesman:GetBuyRate() / 100
    end

    if config.Get('cash_enabled'):Get() then
      if self.itemTable.cost != 0 then
        displayInfo.weight = cw.core:FormatCash(
          (self.itemTable.cost * priceScale) * math.max(amount, 1)
        )
      else
        displayInfo.weight = L'Free'
      end

      local overrideCash = cw.salesman.sells[self.itemTable.uniqueID]

      if self.typeName == 'Buys' then
        overrideCash = cw.salesman.buys[self.itemTable.uniqueID]
      end

      if type(overrideCash) == 'number' then
        displayInfo.weight = cw.core:FormatCash(overrideCash * math.max(amount, 1))
      end
    end

    if amount > 1 then
      displayInfo.name = amount..' x '..self.itemTable.PrintName
    else
      displayInfo.name = self.itemTable.PrintName
    end

    if self.typeName == 'Sells' and cw.salesman.stock != -1 then
      displayInfo.itemTitle = '['..cw.salesman.stock..'] ['..displayInfo.name..', '..displayInfo.weight..']'
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

vgui.Register('cwSalesmanItem', PANEL, 'DPanel')
