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
 	self.panelList:SetSpacing(8)
	self.panelList:StretchToParent(4, 4, 4, 4)
	self.panelList:HideBackground()

	self:Rebuild()
end

-- A function to get whether the button is visible.
function PANEL:IsButtonVisible()
	for k, v in pairs(cw.class:GetStored()) do
		if (cw.core:HasObjectAccess(cw.client, v)) then
			if (hook.Run("PlayerCanSeeClass", v)) then
				if (cw.client:Team() != v.index) then
					return true
				end
			end
		end
	end
end

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true)
	self.classTable = nil

	local available = nil
	local classes = {}

	for k, v in pairs(cw.class:GetStored()) do
		classes[#classes + 1] = v
	end

	table.sort(classes, function(a, b)
		local aWages = a.wages or 0
		local bWages = b.wages or 0

		if (aWages == bWages) then
			return a.name < b.name
		else
			return aWages > bWages
		end
	end)

	if (#classes > 0) then
		local label = vgui.Create("cwInfoText", self)
			label:SetText("#ClassesMenu_NoStay")
			label:SetInfoColor("blue")
		self.panelList:AddItem(label)

		for k, v in pairs(classes) do
			if (cw.core:HasObjectAccess(cw.client, v)) then
				if (hook.Run("PlayerCanSeeClass", v)) then
					self.classTable = cw.class:GetStored()[v.name]
					self.panelList:AddItem(vgui.Create("cwClassesItem", self))
				end
			end
		end
	else
		local label = vgui.Create("cwInfoText", self)
			label:SetText("#ClassesMenu_NoAccess")
			label:SetInfoColor("red")
		self.panelList:AddItem(label)
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
	cdraw.DrawBox(0, 0, w, h, COLOR_WHITE)

	return true
end

-- Called each frame.
function PANEL:Think()
	local team = cw.client:Team()

	if (!self.playerClass) then
		self.playerClass = team
	end

	if (team != self.playerClass) then
		self.playerClass = team
		self:Rebuild()
	end
end

vgui.Register("cwClasses", PANEL, "EditablePanel")

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = Color(0, 0, 0, 200)
	local parent = self:GetParent()

	self.classTable = parent.classTable
	self:SetSize(parent:GetWide(), 32)

	if (parent.overrideData) then
		self.overrideData = parent.overrideData
	else
		self.overrideData = {}
	end

	local players = _team.NumPlayers(self.classTable.index)
	local limit = cw.class:GetLimit(self.classTable.name)

	self.nameLabel = vgui.Create("DLabel", self)
	self.nameLabel:SetText(self.classTable.name)
	self.nameLabel:SetDark(true)

	self.information = vgui.Create("DLabel", self)

	if (self.overrideData.information) then
		self.information:SetText(self.overrideData.information)
	else
		self.information:SetText("#ClassesMenu_CurrentPlayers:"..players..","..limit..";")
	end

	self.information:SetDark(true)
	self.information:SizeToContents()

	local model, skin = cw.class:GetAppropriateModel(self.classTable.index, cw.client)
	local info = {
		model = model,
		skin = skin
	}

	hook.Run("PlayerAdjustClassModelInfo", self.classTable.index, info)

	if (!self.classTable.image) then
		self.spawnIcon = vgui.Create("cwSpawnIcon", self)
		self.spawnIcon:SetModel(info.model, info.skin)
		self.spawnIcon:SetTooltip(self.classTable.description)
		self.spawnIcon:SetSize(32, 32)
	else
		self.spawnIcon = vgui.Create("DImageButton", self)
		self.spawnIcon:SetTooltip(self.classTable.description)
		self.spawnIcon:SetImage(self.classTable.image..".png")
		self.spawnIcon:SetSize(32, 32)
	end

	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		if (self.overrideData.Callback) then
			self.overrideData.Callback(self.classTable)
		else
			cw.core:RunCommand("SetClass", tonumber(self.classTable.index))
		end
	end
end

-- Called each frame.
function PANEL:Think()
	if (self.classTable and !self.overrideData.information) then
		self.information:SetText("#ClassesMenu_CurrentPlayers:".._team.NumPlayers(self.classTable.index)..","..cw.class:GetLimit(self.classTable.name)..";")
		self.information:SizeToContents()
	end

	self.spawnIcon:SetPos(1, 1)
	self.spawnIcon:SetSize(30, 30)
end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.nameLabel:SizeToContents()
	self.information:SizeToContents()

	self.spawnIcon:SetPos(1, 1)
	self.nameLabel:SetPos(40, 2)
	self.spawnIcon:SetSize(30, 30)
	self.information:SetPos(40, 30 - self.information:GetTall())
end

vgui.Register("cwClassesItem", PANEL, "DPanel");
