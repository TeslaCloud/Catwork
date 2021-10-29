--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	local salesmenuName = cw.salesmenu:GetName()

	self:SetTitle(salesmenuName)
	self:SetBackgroundBlur(true)
	self:SetDeleteOnClose(false)

	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		CloseDermaMenus()
		self:Close(); self:Remove()

		netstream.Start("SalesmanDone", cw.salesmenu.entity)
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

	self.propertySheet = vgui.Create("DPropertySheet", self)
	self.propertySheet:SetPadding(4)

	if (table.Count(cw.salesmenu:GetSells()) > 0) then
		self.sellsPanel = vgui.Create("cwPanelList")
		self.sellsPanel:SetPadding(2)
		self.sellsPanel:SetSpacing(3)
		self.sellsPanel:SizeToContents()
		self.sellsPanel:EnableVerticalScrollbar()

		self.propertySheet:AddSheet(L"Sells", self.sellsPanel, "icon16/box.png", nil, nil, "View items that "..salesmenuName.." sells.")
	end

	if (table.Count(cw.salesmenu:GetBuys()) > 0) then
		self.buysPanel = vgui.Create("cwPanelList")
		self.buysPanel:SetPadding(2)
		self.buysPanel:SetSpacing(3)
		self.buysPanel:SizeToContents()
		self.buysPanel:EnableVerticalScrollbar()

		self.propertySheet:AddSheet(L"Buys", self.buysPanel, "icon16/add.png", nil, nil, "View items that "..salesmenuName.." buys.")
	end

	cw.core:SetNoticePanel(self)
end

-- A function to rebuild a panel.
function PANEL:RebuildPanel(typeName, panelList, inventory)
	panelList:Clear(true)
	panelList.inventory = inventory

	if (config.Get("cash_enabled"):Get()) then
		local totalCash = cw.salesmenu:GetCash()

		if (totalCash > -1) then
			local cashForm = vgui.Create("DForm", panelList)
				cashForm:SetName(cw.option:GetKey("name_cash"))
				cashForm:SetPadding(4)
			panelList:AddItem(cashForm)

			cashForm:Help(
				cw.salesmenu:GetName().." has "..cw.core:FormatCash(totalCash, nil, true).." to their name."
			)
		end
	end

	local categories = {}
	local items = {}

	for k, v in pairs(panelList.inventory) do
		if (typeName == "Sells") then
			local itemTable = item.FindByID(k)

			if (itemTable) then
				local itemCategory = itemTable.category

				if (itemCategory) then
					items[itemCategory] = items[itemCategory] or {}
					items[itemCategory][#items[itemCategory] + 1] = {k, v}
				end
			end
		else
			local itemsList = cw.inventory:GetItemsByID(
				cw.inventory:GetClient(), k
			)

			if (itemsList) then
				for k2, v2 in pairs(itemsList) do
					local itemCategory = v2.category

					if (itemCategory) then
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

	if (table.Count(categories) > 0) then
		for k, v in pairs(categories) do
			local collapsibleCategory = cw.core:CreateCustomCategoryPanel(L(v.category), panelList)
				collapsibleCategory:SetCookieName("Salesmenu"..typeName..v.category)
			panelList:AddItem(collapsibleCategory)

			local categoryList = vgui.Create("DPanelList", collapsibleCategory)
				categoryList:EnableHorizontal(true)
				categoryList:SetAutoSize(true)
				categoryList:SetPadding(4)
				categoryList:SetSpacing(4)
			collapsibleCategory:SetContents(categoryList)

			if (typeName == "Sells") then
				table.sort(v.items, function(a, b)
					local itemTableA = item.FindByID(a[1])
					local itemTableB = item.FindByID(b[1])

					if (itemTableA.cost == itemTableB.cost) then
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
						vgui.Create("cwSalesmenuItem", categoryList)
					)
				end
			else
				table.sort(v.items, function(a, b)
					if (a.cost == b.cost) then
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
						vgui.Create("cwSalesmenuItem", categoryList)
					)
				end
			end
		end
	end
end

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if (IsValid(self.sellsPanel)) then
		self:RebuildPanel("Sells", self.sellsPanel, cw.salesmenu:GetSells())
	end

	if (IsValid(self.buysPanel)) then
		self:RebuildPanel("Buys", self.buysPanel, cw.salesmenu:GetBuys())
	end
end

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW()
	local scrH = ScrH()

	self:SetSize(scrW * 0.5, scrH * 0.75)
	self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2))
end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	DFrame.PerformLayout(self)

	self.propertySheet:StretchToParent(4, 28, 4, 4)
end

vgui.Register("cwSalesmenu", PANEL, "DFrame")

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
		local entity = cw.salesmenu:GetEntity()

		if (IsValid(entity)) then
			netstream.Start("Salesmenu", {
				tradeType = self.typeName,
				uniqueID = self.itemTable.uniqueID,
				itemID = self.itemTable.itemID,
				entity = entity
			})
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

		if (cw.salesmenu:BuyInShipments()) then
			amount = self.itemTable.batch
		else
			amount = 1
		end

		if (self.typeName == "Sells") then
			priceScale = cw.salesmenu:GetPriceScale()
		elseif (self.typeName == "Buys") then
			priceScale = cw.salesmenu:GetBuyRate() / 100
		end

		if (config.Get("cash_enabled"):Get()) then
			if (self.itemTable.cost != 0) then
				displayInfo.weight = cw.core:FormatCash(
					(self.itemTable.cost * priceScale) * math.max(amount, 1)
				)
			else
				displayInfo.weight = "Free"
			end

			local overrideCash = cw.salesmenu.sells[self.itemTable.uniqueID]

			if (self.typeName == "Buys") then
				overrideCash = cw.salesmenu.buys[self.itemTable.uniqueID]
			end

			if (type(overrideCash) == "number") then
				displayInfo.weight = cw.core:FormatCash(overrideCash * math.max(amount, 1))
			end
		end

		local name = cw.lang:TranslateText(self.itemTable.PrintName)

		if (amount > 1) then
			displayInfo.name = amount.." "..cw.core:Pluralize(name)
		else
			displayInfo.name = name
		end

		if (cw.salesmenu.stock) then
			local iStockLeft = cw.salesmenu.stock[self.itemTable.uniqueID]

			if (self.typeName == "Sells" and iStockLeft) then
				displayInfo.itemTitle = "["..iStockLeft.."] ["..displayInfo.name..", "..displayInfo.weight.."]"
			end
		end
	end

	self.spawnIcon:SetMarkupToolTip(
		item.GetMarkupToolTip(self.itemTable, true, DisplayCallback)
	)
	self.spawnIcon:SetColor(self.itemTable.color)
end

vgui.Register("cwSalesmenuItem", PANEL, "DPanel");
