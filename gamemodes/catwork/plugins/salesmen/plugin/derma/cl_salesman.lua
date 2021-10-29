--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	local salesmanName = cw.salesman:GetName()

	self:SetTitle(salesmanName)
	self:SetBackgroundBlur(true)
	self:SetDeleteOnClose(false)

	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus()
		self:Close(); self:Remove()

		netstream.Start("SalesmanAdd", {
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

	self.sellsPanel = vgui.Create("cwPanelList")
 	self.sellsPanel:SetPadding(2)
 	self.sellsPanel:SetSpacing(3)
 	self.sellsPanel:SizeToContents()
	self.sellsPanel:EnableVerticalScrollbar()

	self.buysPanel = vgui.Create("cwPanelList")
 	self.buysPanel:SetPadding(2)
 	self.buysPanel:SetSpacing(3)
 	self.buysPanel:SizeToContents()
	self.buysPanel:EnableVerticalScrollbar()

	self.itemsPanel = vgui.Create("cwPanelList")
 	self.itemsPanel:SetPadding(2)
 	self.itemsPanel:SetSpacing(3)
 	self.itemsPanel:SizeToContents()
	self.itemsPanel:EnableVerticalScrollbar()

	self.settingsPanel = vgui.Create("cwPanelList")
 	self.settingsPanel:SetPadding(2)
 	self.settingsPanel:SetSpacing(3)
 	self.settingsPanel:SizeToContents()
	self.settingsPanel:EnableVerticalScrollbar()
	self.settingsPanel.Paint = function(sp, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200))
	end

	self.settingsForm = vgui.Create("cwForm")
	self.settingsForm:SetPadding(4)
	self.settingsForm:SetName(L"Settings")

	self.settingsPanel:AddItem(self.settingsForm)

	self.showChatBubble = self.settingsForm:CheckBox("Отображать символ чата над головой.")
	self.buyInShipments = self.settingsForm:CheckBox("Покупать / продавать предметы оптом (5 шт.).")
	self.priceScale = self.settingsForm:TextEntry("Множитель цен.")
	self.flagsEntry = self.settingsForm:TextEntry("Флаги для доступа (введите '-' перед флагами чтобы проверялись ТОЛЬКО они).")
	self.physDesc = self.settingsForm:TextEntry("Описание торговца.")
	self.buyRate = self.settingsForm:NumSlider("Множитель продажи", nil, 1, 100, 0)
	self.stock = self.settingsForm:NumSlider("Кол-во предметов по умолчанию", nil, -1, 100, 0)
	self.model = self.settingsForm:TextEntry("Модель торговца.")
	self.cash = self.settingsForm:NumSlider("Стартовый капитал", nil, -1, 1000000, 0)

	self.buyRate:SetTooltip("На какое число будут умножаться цены при продаже.")
	self.stock:SetTooltip("Количество предметов в запасе (-1 - бесконечно).")
	self.cash:SetTooltip("Количество денег торговца (-1 - бесконечно).")

	self.showChatBubble:SetValue(cw.salesman.showChatBubble == true)
	self.buyInShipments:SetValue(cw.salesman.buyInShipments == true)
	self.priceScale:SetValue(cw.salesman.priceScale)
	self.flagsEntry:SetValue(cw.salesman.flags or "")
	self.physDesc:SetValue(cw.salesman.physDesc)
	self.buyRate:SetValue(cw.salesman.buyRate)
	self.stock:SetValue(cw.salesman.stock)
	self.model:SetValue(cw.salesman.model)
	self.cash:SetValue(cw.salesman.cash)

	self.responsesForm = vgui.Create("cwForm")
	self.responsesForm:SetPadding(4)
	self.responsesForm:SetName("Ответы")
	self.settingsForm:AddItem(self.responsesForm)

	self.startText = self.responsesForm:TextEntry("При начале торговли.")
	self.startSound = self.responsesForm:TextEntry("Звук.")
	self.startHideName = self.responsesForm:CheckBox("Спрятать имя торговца.")

	self.noSaleText = self.responsesForm:TextEntry("Если игрок не может торговать с торговцем.")
	self.noSaleSound = self.responsesForm:TextEntry("Звук.")
	self.noSaleHideName = self.responsesForm:CheckBox("Спрятать имя торговца.")

	self.noStockText = self.responsesForm:TextEntry("Если кончились предметы в запасе.")
	self.noStockSound = self.responsesForm:TextEntry("Звук.")
	self.noStockHideName = self.responsesForm:CheckBox("Спрятать имя торговца.")

	self.needMoreText = self.responsesForm:TextEntry("При покупке предмета.")
	self.needMoreSound = self.responsesForm:TextEntry("Звук.")
	self.needMoreHideName = self.responsesForm:CheckBox("Спрятать имя торговца.")

	self.cannotAffordText = self.responsesForm:TextEntry("Если торговец не может приобрести предмет.")
	self.cannotAffordSound = self.responsesForm:TextEntry("Звук.")
	self.cannotAffordHideName = self.responsesForm:CheckBox("Спрятать имя торговца.")

	self.doneBusinessText = self.responsesForm:TextEntry("При успешном обмене.")
	self.doneBusinessSound = self.responsesForm:TextEntry("Звук.")
	self.doneBusinessHideName = self.responsesForm:CheckBox("Спрятать имя торговца.")

	cw.salesman.text.start = cw.salesman.text.start or {}

	self.startText:SetValue(cw.salesman.text.start.text or "Чем могу помочь?")
	self.startSound:SetValue(cw.salesman.text.start.sound or "")

	self.startHideName:SetValue(cw.salesman.text.start.bHideName == true)

	self.noSaleText:SetValue(cw.salesman.text.noSale.text or "Я не могу торговать с тобой!")
	self.noSaleSound:SetValue(cw.salesman.text.noSale.sound or "")

	self.noSaleHideName:SetValue(cw.salesman.text.noSale.bHideName == true)

	self.noStockText:SetValue(cw.salesman.text.noStock.text or "Нет в наличии!")
	self.noStockSound:SetValue(cw.salesman.text.noStock.sound or "")

	self.noStockHideName:SetValue(cw.salesman.text.noStock.bHideName == true)

	self.needMoreText:SetValue(cw.salesman.text.needMore.text or "У тебя не хватает денег!")
	self.needMoreSound:SetValue(cw.salesman.text.needMore.sound or "")

	self.needMoreHideName:SetValue(cw.salesman.text.needMore.bHideName == true)

	self.cannotAffordText:SetValue(cw.salesman.text.cannotAfford.text or "Я не могу себе это позволить!")
	self.cannotAffordSound:SetValue(cw.salesman.text.cannotAfford.sound or "")

	self.cannotAffordHideName:SetValue(cw.salesman.text.cannotAfford.bHideName == true)

	self.doneBusinessText:SetValue(cw.salesman.text.doneBusiness.text or "Спасибо за покупку, увидимся!")
	self.doneBusinessSound:SetValue(cw.salesman.text.doneBusiness.sound or "")

	self.doneBusinessHideName:SetValue(cw.salesman.text.doneBusiness.bHideName == true)

	self.factionsForm = vgui.Create("DForm")
	self.factionsForm:SetPadding(4)
	self.factionsForm:SetName("Фракции")
	self.settingsForm:AddItem(self.factionsForm)
	self.factionsForm:Help("Оставьте пустым, чтобы позволить всем фракциям торговать с этим торговцем.")

	self.classesForm = vgui.Create("DForm")
	self.classesForm:SetPadding(4)
	self.classesForm:SetName("Классы")
	self.settingsForm:AddItem(self.classesForm)
	self.classesForm:Help("Оставьте пустым, чтобы позволить всем классам торговать с этим торговцем.")

	self.classBoxes = {}
	self.factionBoxes = {}

	for k, v in pairs(faction.GetStored()) do
		self.factionBoxes[k] = self.factionsForm:CheckBox(v.name)
		self.factionBoxes[k].OnChange = function(checkBox)
			if (checkBox:GetChecked()) then
				cw.salesman.factions[k] = true
			else
				cw.salesman.factions[k] = nil
			end
		end

		if (cw.salesman.factions[k]) then
			self.factionBoxes[k]:SetValue(true)
		end
	end

	for k, v in pairs(cw.class:GetStored()) do
		self.classBoxes[k] = self.classesForm:CheckBox(v.name)
		self.classBoxes[k].OnChange = function(checkBox)
			if (checkBox:GetChecked()) then
				cw.salesman.classes[k] = true
			else
				cw.salesman.classes[k] = nil
			end
		end

		if (cw.salesman.classes[k]) then
			self.classBoxes[k]:SetValue(true)
		end
	end

	self.propertySheet = vgui.Create("DPropertySheet", self)
		self.propertySheet:SetPadding(4)
		self.propertySheet:AddSheet(L"Sells", self.sellsPanel, "icon16/box.png", nil, nil, "Предметы, которые "..salesmanName.." продает.")
		self.propertySheet:AddSheet(L"Buys", self.buysPanel, "icon16/add.png", nil, nil, "Предметы, которые "..salesmanName.." покупает.")
		self.propertySheet:AddSheet(L"Items", self.itemsPanel, "icon16/application_view_tile.png", nil, nil, "Предметы для торговли.")
		self.propertySheet:AddSheet(L"Settings", self.settingsPanel, "icon16/tick.png", nil, nil, "Настройки торговца.")
	cw.core:SetNoticePanel(self)
end

-- A function to rebuild a panel.
function PANEL:RebuildPanel(panelList, typeName, inventory)
	panelList:Clear(true)
	panelList.typeName = typeName
	panelList.inventory = inventory

	local categories = {}
	local items = {}

	for k, v in pairs(panelList.inventory) do
		local itemTable = item.FindByID(k)

		if (itemTable) then
			local category = itemTable.category

			if (category) then
				items[category] = items[category] or {}
				items[category][#items[category] + 1] = {k, v}
			end
		end
	end

	for k, v in pairs(items) do
		categories[#categories + 1] = {
			category = k,
			items = v
		}
	end

	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = cw.core:CreateCustomCategoryPanel(L(v.category), panelList)
				collapsibleCategory:SetCookieName("Salesman"..typeName..v.category)
			panelList:AddItem(collapsibleCategory)

			local categoryList = vgui.Create("DPanelList", collapsibleCategory)
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
					vgui.Create("cwSalesmanItem", categoryList)
				)
			end
		end
	end
end

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self:RebuildPanel(self.sellsPanel, "Sells",
		cw.salesman:GetSells()
	)

	self:RebuildPanel(self.buysPanel, "Buys",
		cw.salesman:GetBuys()
	)

	self:RebuildPanel(self.itemsPanel, "Items",
		cw.salesman:GetItems()
	)
end

-- Called each frame.
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
	cw.salesman.buyRate = self.buyRate:GetValue()
	cw.salesman.stock = self.stock:GetValue()
	cw.salesman.model = self.model:GetValue()
	cw.salesman.cash = self.cash:GetValue()

	local priceScale = self.priceScale:GetValue()
	cw.salesman.priceScale = tonumber(priceScale) or 1

	cw.salesman.flags = self.flagsEntry:GetValue() or ""
end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self)

	if (self.propertySheet) then
		self.propertySheet:StretchToParent(4, 28, 4, 4)
	end
end

vgui.Register("cwSalesman", PANEL, "DFrame")

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	local itemData = self:GetParent().itemData or CURRENT_ITEM_DATA
	self:SetSize(40, 40)
	self.itemTable = itemData.itemTable
	self.typeName = itemData.typeName
	self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self))
	self.spawnIcon:SetColor(self.itemTable.color)

	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.typeName == "Items") then
			if (config.Get("cash_enabled"):Get()) then
				local cashName = cw.option:GetKey("name_cash")

				cw.core:AddMenuFromData(nil, {
					[L"Buys"] = function()
						Derma_StringRequest(cashName, "За сколько этот предмет будет продаваться торговцем?", "", function(text)
							cw.salesman.buys[self.itemTable.uniqueID] = tonumber(text) or true
							cw.salesman:GetPanel():Rebuild()
						end)
					end,
					[L"Sells"] = function()
						Derma_StringRequest(cashName, "За сколько этот предмет будет покупаться торговцем?", "", function(text)
							cw.salesman.sells[self.itemTable.uniqueID] = tonumber(text) or true
							cw.salesman:GetPanel():Rebuild()
						end)
					end,
					[L"Both"] = function()
						Derma_StringRequest(cashName, "За сколько этот предмет будет продаваться торговцем?", "", function(sellPrice)
							Derma_StringRequest(cashName, "За сколько этот предмет будет покупаться торговцем?", "", function(buyPrice)
								cw.salesman.sells[self.itemTable.uniqueID] = tonumber(sellPrice) or true
								cw.salesman.buys[self.itemTable.uniqueID] = tonumber(buyPrice) or true
								cw.salesman:GetPanel():Rebuild()
							end)
						end)
					end
				})
			else
				cw.core:AddMenuFromData(nil, {
					["Buys"] = function()
						cw.salesman.buys[self.itemTable.uniqueID] = true
						cw.salesman:GetPanel():Rebuild()
					end,
					["Sells"] = function()
						cw.salesman.sells[self.itemTable.uniqueID] = true
						cw.salesman:GetPanel():Rebuild()
					end,
					["Both"] = function()
						cw.salesman.sells[self.itemTable.uniqueID] = true
						cw.salesman.buys[self.itemTable.uniqueID] = true
						cw.salesman:GetPanel():Rebuild()
					end
				})
			end
		elseif (self.typeName == "Sells") then
			cw.salesman.sells[self.itemTable.uniqueID] = nil
			cw.salesman:GetPanel():Rebuild()
		elseif (self.typeName == "Buys") then
			cw.salesman.buys[self.itemTable.uniqueID] = nil
			cw.salesman:GetPanel():Rebuild()
		end
	end

	local model, skin = item.GetIconInfo(self.itemTable)
	self.spawnIcon:SetModel(model, skin)
	self.spawnIcon:SetTooltip("")
	self.spawnIcon:SetSize(40, 40)
end

-- Called each frame.
function PANEL:Think()
	local function DisplayCallback(displayInfo)
		local priceScale = 1
		local amount = 0

		if (cw.salesman:BuyInShipments()) then
			amount = self.itemTable.batch
		else
			amount = 1
		end

		if (self.typeName == "Sells") then
			priceScale = cw.salesman:GetPriceScale()
		elseif (self.typeName == "Buys") then
			priceScale = cw.salesman:GetBuyRate() / 100
		end

		if (config.Get("cash_enabled"):Get()) then
			if (self.itemTable.cost != 0) then
				displayInfo.weight = cw.core:FormatCash(
					(self.itemTable.cost * priceScale) * math.max(amount, 1)
				)
			else
				displayInfo.weight = "Free"
			end

			local overrideCash = cw.salesman.sells[self.itemTable.uniqueID]

			if (self.typeName == "Buys") then
				overrideCash = cw.salesman.buys[self.itemTable.uniqueID]
			end

			if (type(overrideCash) == "number") then
				displayInfo.weight = cw.core:FormatCash(overrideCash * math.max(amount, 1))
			end
		end

		if (amount > 1) then
			displayInfo.name = amount.." x "..self.itemTable.PrintName
		else
			displayInfo.name = self.itemTable.PrintName
		end

		if (self.typeName == "Sells" and cw.salesman.stock != -1) then
			displayInfo.itemTitle = "["..cw.salesman.stock.."] ["..displayInfo.name..", "..displayInfo.weight.."]"
		end
	end

	self.spawnIcon:SetMarkupToolTip(
		item.GetMarkupToolTip(self.itemTable, true, DisplayCallback)
	)
	self.spawnIcon:SetColor(self.itemTable.color)
end

vgui.Register("cwSalesmanItem", PANEL, "DPanel");
