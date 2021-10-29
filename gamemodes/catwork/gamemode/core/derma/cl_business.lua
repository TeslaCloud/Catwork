--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

	self.panelList = vgui.Create("cwPanelList", self)
 	self.panelList:SetPadding(8)
 	self.panelList:SetSpacing(4)
 	self.panelList:StretchToParent(4, 4, 4, 4)
 	self.panelList:HideBackground()

	self:Rebuild()
end

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear()

	local categories = {}
	local itemsList = {}

	for k, v in pairs(item.GetAll()) do
		if (v:CanBeOrdered() and cw.core:HasObjectAccess(cw.client, v)) then
			if (hook.Run("PlayerCanSeeBusinessItem", v)) then
				local itemCategory = v.category
				itemsList[itemCategory] = itemsList[itemCategory] or {}
				itemsList[itemCategory][#itemsList[itemCategory] + 1] = v
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

	if (#categories == 0) then
		local label = vgui.Create("cwInfoText", self)
			label:SetText("#BusinessMenu_NoAccess:"..cw.option:GetKey("name_business", true)..";")
			label:SetInfoColor("red")
		self.panelList:AddItem(label)

		hook.Run("PlayerBusinessRebuilt", self, categories)
	else
		hook.Run("PlayerBusinessRebuilt", self, categories)

		for k, v in pairs(categories) do
			local categoryForm = vgui.Create("cwBasicForm", self)
			categoryForm:SetPadding(8)
			categoryForm:SetSpacing(8)
			categoryForm:SetAutoSize(true)
			categoryForm:SetText(v.category, nil, "basic_form_highlight")

			local categoryList = vgui.Create("DPanelList", categoryForm)
				categoryList:EnableHorizontal(true)
				categoryList:SetAutoSize(true)
				categoryList:SetPadding(4)
				categoryList:SetSpacing(4)
			categoryForm:AddItem(categoryList)

			table.sort(v.itemsList, function(a, b)
				local itemTableA = a
				local itemTableB = b

				if (itemTableA.cost == itemTableB.cost) then
					return itemTableA.name < itemTableB.name
				else
					return itemTableA.cost > itemTableB.cost
				end
			end)

			for k2, v2 in pairs(v.itemsList) do
				self.itemData = {
					itemTable = v2
				}

				categoryList:AddItem(vgui.Create("cwBusinessItem", self))
			end

			self.panelList:AddItem(categoryForm)
		end
	end

	self.panelList:InvalidateLayout(true)
end

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (cw.menu:IsPanelActive(self)) then
		self:Rebuild()
	end
end

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h) end

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, cw.option:GetColor("panel_outline"))
	draw.RoundedBox(0, 1, 1, w - 2, h - 2, cw.option:GetColor("panel_background"))

	return true
end

vgui.Register("cwBusiness", PANEL, "EditablePanel")

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 40)

	local customData = self:GetParent().customData or {}
	local toolTip = nil

	if (customData.information) then
		if (type(customData.information) == "number") then
			if (customData.information != 0) then
				customData.information = cw.core:FormatCash(customData.information)
			else
				customData.information = "#BusinessMenu_Free"
			end
		end
	end

	if (customData.description) then
		toolTip = config.Parse(customData.description)
	end

	self.nameLabel = vgui.Create("DLabel", self)
	self.nameLabel:SetPos(48, 6)
	self.nameLabel:SetDark(true)
	self.nameLabel:SetText(customData.name)
	self.nameLabel:SizeToContents()

	self.infoLabel = vgui.Create("DLabel", self)
	self.infoLabel:SetPos(48, 6)
	self.infoLabel:SetDark(true)
	self.infoLabel:SetText(customData.information)
	self.infoLabel:SizeToContents()

	self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self))
	self.spawnIcon:SetColor(customData.spawnIconColor)

	if (customData.cooldown) then
		self.spawnIcon:SetCooldown(
			customData.cooldown.expireTime,
			customData.cooldown.textureID
		)
	end

	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (customData.Callback) then
			customData.Callback()
		end
	end

	self.spawnIcon:SetModel(customData.model, customData.skin)
	self.spawnIcon:SetTooltip(toolTip)
	self.spawnIcon:SetSize(40, 40)
	self.spawnIcon:SetPos(0, 0)
end

function PANEL:Paint(width, height)
	cdraw.DrawBox(0, 0, width, height, Color(255, 255, 255, 150))

	return true
end

-- Called each frame.
function PANEL:Think()
	self.infoLabel:SetPos(self.infoLabel.x, 34 - self.infoLabel:GetTall())
end

vgui.Register("cwBusinessCustom", PANEL, "DPanel")

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	local FACTION = faction.FindByID(cw.client:GetFaction())
	local CLASS = cw.class:FindByID(cw.client:Team())
	local costScale = CLASS.costScale or FACTION.costScale or 1
	local itemData = self:GetParent().itemData
		self:SetSize(48, 48)
		self.itemTable = itemData.itemTable
	hook.Run("PlayerAdjustBusinessItemTable", self.itemTable)

	if (!self.itemTable.originalCost) then
		self.itemTable.originalCost = self.itemTable.cost
	end

	if (costScale >= 0) then
		self.itemTable.cost = self.itemTable.originalCost * costScale
	end

	local model, skin = item.GetIconInfo(self.itemTable)
	self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", self))

	if (cw.OrderCooldown and CurTime() < cw.OrderCooldown) then
		self.spawnIcon:SetCooldown(cw.OrderCooldown)
	end

	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		cw.core:RunCommand(
			"OrderShipment", self.itemTable.uniqueID
		)
	end

	self.spawnIcon:SetModel(model, skin)
	self.spawnIcon:SetTooltip("")
	self.spawnIcon:SetSize(48, 48)
end

-- Called each frame.
function PANEL:Think()
	if (!self.nextUpdateMarkup) then
		self.nextUpdateMarkup = 0
	end

	if (CurTime() < self.nextUpdateMarkup) then
		return
	end

	self.spawnIcon:SetMarkupToolTip(item.GetMarkupToolTip(self.itemTable, true))
	self.spawnIcon:SetColor(self.itemTable.color)

	self.nextUpdateMarkup = CurTime() + 1
end

vgui.Register("cwBusinessItem", PANEL, "DPanel")
