local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(ScrW() * 0.5, ScrH() * 0.6)

	self.craft = vgui.Create("DScrollPanel", self)
	self.craft:SetBackgroundColor(Color("gray"))
	self.craft:SizeToContents()

	self.list = vgui.Create("DPanel", self)
	self.list:SetBackgroundColor(Color("darkgray"))

	self.info = vgui.Create("cwInfoText", self.list)
	self.info:Dock(TOP)
	self.info:DockMargin(4, 4, 4, 4)
	self.info:SetInfoColor(Color("black"))

	self.panelList = vgui.Create("cwPanelList", self.list)
	self.panelList:Dock(FILL)
 	self.panelList:SetPadding(8)
 	self.panelList:SetSpacing(4)
 	self.panelList:StretchToParent(4, 38, 4, 38)
 	self.panelList:HideBackground()

	self.closeButton = vgui.Create("cwInfoText", self.list)
	self.closeButton:SetText("#Craft_CloseMenu")
	self.closeButton:Dock(BOTTOM)
	self.closeButton:SetButton(true)
	self.closeButton:SetInfoColor(Color("black"))
	self.closeButton:DockMargin(4, 4, 4, 4)
	self.closeButton:SetShowIcon(false)
	self.closeButton.DoClick = function(button)
		self:Remove()
	end

	timer.Simple(0, function()
		self:Rebuild()
		self.info:SetText(self.name)
	end)
end

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear()
	self.craft:Clear()

	local categories = {}
	local blueprints = {}

	for k, v in pairs(cw.blueprints:GetAll()) do
		if (v.craftplace == self.class and cwCraft:PlayerCanSeeCraft(v)) then
			local blueprintCategory = v.category
			blueprints[blueprintCategory] = blueprints[blueprintCategory] or {}
			blueprints[blueprintCategory][#blueprints[blueprintCategory] + 1] = v
		end
	end

	for k, v in pairs(blueprints) do
		categories[#categories + 1] = {
			blueprints = v,
			category = k
		}
	end

	table.sort(categories, function(a, b)
		return a.category < b.category
	end)


	for k, v in pairs(categories) do
		local categoryForm = vgui.Create("DCollapsibleCategory", self.panelList)
		categoryForm:SetLabel(v.category, nil, "basic_form_highlight")

		local categoryList = vgui.Create("DPanelList", categoryForm)
			categoryList:EnableHorizontal(true)
			categoryList:SetAutoSize(true)
		categoryForm:SetContents(categoryList)

		table.sort(v.blueprints, function(a, b)
			return a.name < b.name
		end)

		for k2, v2 in pairs(v.blueprints) do
			local blueprintItem = vgui.Create("DButton", categoryForm)
			blueprintItem:Dock(TOP)
			blueprintItem:SetText(v2("name"))
			blueprintItem:SizeToContents()
			blueprintItem:SetTall(20)
			blueprintItem.DoClick = function(blueprintItem)
				self.bpData = v2
				self:Rebuild()
			end
			blueprintItem:SetSize(self.panelList:GetWide() - 48, 40)

			local itemIcon = vgui.Create("SpawnIcon", blueprintItem)
			itemIcon:SetSize(blueprintItem:GetTall(), blueprintItem:GetTall())
			itemIcon:SetTooltip("")
			itemIcon:SetModel(v2("model"))
			itemIcon:SetDisabled(true)

			categoryList:AddItem(blueprintItem)
		end

		self.panelList:AddItem(categoryForm)
	end

	self.panelList:InvalidateLayout(true)

	if (self.bpData) then
		self.craft.name = vgui.Create("cwInfoText", self.craft)
		self.craft.name:Dock(TOP)
		self.craft.name:DockMargin(4, 4, 4, 4)
		self.craft.name:SetInfoColor(Color("black"))
		self.craft.name:SetText(self.bpData["name"])

		self.craft.descLabel = vgui.Create("DLabel", self.craft)
		self.craft.descLabel:SetAutoStretchVertical(true)
		self.craft.descLabel:SetText(self.bpData["description"])
		self.craft.descLabel:SetPos(self.craft:GetWide() / 2, 36)
		self.craft.descLabel:SetSize(self.craft:GetWide() / 2 - 8, 15)
		self.craft.descLabel:SetTextColor(Color("white"))
		self.craft.descLabel:SetFont("DermaNarrow15")
		self.craft.descLabel:SetWrap(true)

		self.craft.modelIcon = vgui.Create("DModelPanel", self.craft)
		self.craft.modelIcon:Dock(TOP)
		self.craft.modelIcon:DockMargin(0, 0, self.craft:GetWide() / 2, 0)
		self.craft.modelIcon:SetSize(self.craft:GetWide() / 2, self.craft:GetTall() / 2)

		local ent = ents.CreateClientProp(self.bpData["model"])
		local mn, mx = ent:GetRenderBounds()
		local size = 0

		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

		self.craft.modelIcon:SetFOV(45)
		self.craft.modelIcon:SetCamPos(Vector(50 - size, 50 - size, 50 - size))
		self.craft.modelIcon:SetLookAt((mn + mx) * 0.8)
		self.craft.modelIcon:SetModel(self.bpData["model"])
		ent:Remove()

		if (!self.craft.doCraft) then
			self.craft.doCraft = vgui.Create("cwInfoText", self)
			self.craft.doCraft:SetText("#Craft_Create")
			self.craft.doCraft:Dock(BOTTOM)
			self.craft.doCraft:SetButton(true)
			self.craft.doCraft:SetInfoColor(Color("black"))
			self.craft.doCraft:DockMargin(8 + self.craft:GetWide() / 2, 4, 4, 8)
			self.craft.doCraft:SetShowIcon(false)
			self.craft.doCraft.DoClick = function(button)
				netstream.Start("Craft::CraftItem", self.bpData)

				timer.Simple(0, function()
					self:Rebuild()
				end)
			end
		end

		if (table.Count(self.bpData["reqatt"]) > 0) then
			self.craft.requirements = vgui.Create("DScrollPanel", self.craft)
			self.craft.requirements:SetPos(self.craft:GetWide() / 2, self.craft:GetTall() / 2 - 128)
			self.craft.requirements:SetSize(self.craft:GetWide() / 2 - 8, 128)

			self.craft.requirements.Paint = function(panel, w, h)
				draw.RoundedBox(4, 0, 0, w, h, Color("gray"))
			end

			local label = vgui.Create("DLabel", self.craft.requirements)
			label:Dock(TOP)
			label:DockMargin(4, 4, 4, 4)
			label:SetSize(self.craft:GetWide() / 2 - 8, 16)
			label:SetFont("DermaNarrow20")
			label:SetText("#Craft_Requirements")
			label:SetTextColor(Color("white"))

			for k, v in pairs(self.bpData["reqatt"]) do
				if (v[2] > 0) then
					local label = vgui.Create("DLabel", self.craft.requirements)
					label:Dock(TOP)
					label:DockMargin(4, -4, 4, 4)
					label:SetSize(self.craft:GetWide() / 2 - 8, 16)
					label:SetFont("DermaNarrow16")
					label:SetText(L(cw.attribute:FindByID(v[1]).name)..": "..cw.attributes:Fraction(v[1], 100).." / "..v[2])

					if (cw.attributes:Fraction(v[1], 100) >= v[2]) then
						label:SetTextColor(Color("lightgreen"))
					else
						label:SetTextColor(Color("pink"))
					end

					self.craft.requirements:AddItem(label)
				end
			end

			for k, v in pairs(self.bpData["requirements"]) do
				if (v) then
					local bCheck, text = v(cw.client)

					local label = vgui.Create("DLabel", self.craft.requirement)
					label:Dock(TOP)
					label:DockMargin(4, -4, 4, 4)
					label:SetSize(self.craft:GetWide() / 2 - 8, 16)
					label:SetFont("DermaNarrow16")
					label:SetText(L(text))

					if (bCheck) then
						label:SetTextColor(Color("lightgreen"))
					else
						label:SetTextColor(Color("pink"))
					end

					self.craft.requirements:AddItem(label)
				end
			end
		end

		if (table.Count(self.bpData["recipe"]) > 0) then
			self.craft.reqLabel = vgui.Create("DLabel", self.craft)
			self.craft.reqLabel:Dock(TOP)
			self.craft.reqLabel:DockMargin(4, 0, 4, 0)
			self.craft.reqLabel:SetFont("DermaNarrow30")
			self.craft.reqLabel:SetTextColor(Color("white"))
			self.craft.reqLabel:SetText("#Craft_Materials")
			self.craft.reqLabel:SizeToContents()

			self.craft.req = vgui.Create("DHorizontalScroller", self.craft)
			self.craft.req:Dock(TOP)
			self.craft.req:DockMargin(4, 8, 4, 8)
			self.craft.req:SetSize(0, 88)
			self.craft.req:SetOverlap(-4)
			self.craft.req.Paint = function(panel, w, h)
				draw.RoundedBox(4, 0, 0, w, h, Color("gray"))
			end

			for k, v in pairs(self.bpData["recipe"]) do
				local itemTable = item.GetAll()[v[1]]
				local inventory = cw.inventory:GetClient()

				if (itemTable) then
					local panel = vgui.Create("DPanel", self.craft.req)
					panel:SetSize(64, 0)
					panel:SetBackgroundColor(Color("gray"))

					local model, skin = item.GetIconInfo(itemTable)

					local icon = cw.core:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", panel))
					icon:SetModel(model, skin)
					icon:SetTooltip()
					icon:SetSize(64, 64)
					icon:SetMarkupToolTip(item.GetMarkupToolTip(itemTable, false))

					local label = vgui.Create("DLabel", panel)
					label:Dock(BOTTOM)
					label:SetText((cw.inventory:GetItemCountByID(inventory, v[1]) or 0).." / "..v[2])
					label:SetFont("DermaNarrow18")
					label:SetContentAlignment(5)

					if (cw.inventory:GetItemCountByID(inventory, v[1]) >= v[2]) then
						label:SetTextColor(Color("lightgreen"))
					else
						label:SetTextColor(Color("pink"))
					end

					self.craft.req:AddPanel(panel)
				end
			end
		end

		if (table.Count(self.bpData["required"]) > 0) then
			self.craft.toolLabel = vgui.Create("DLabel", self.craft)
			self.craft.toolLabel:Dock(TOP)
			self.craft.toolLabel:DockMargin(4, 0, 4, 0)
			self.craft.toolLabel:SetFont("DermaNarrow30")
			self.craft.toolLabel:SetTextColor(Color("white"))
			self.craft.toolLabel:SetText("#Craft_Tools")
			self.craft.toolLabel:SizeToContents()

			self.craft.tools = vgui.Create("DHorizontalScroller", self.craft)
			self.craft.tools:Dock(TOP)
			self.craft.tools:DockMargin(4, 8, 4, 8)
			self.craft.tools:SetSize(0, 88)
			self.craft.tools:SetOverlap(-4)
			self.craft.tools.Paint = function(panel, w, h)
				draw.RoundedBox(4, 0, 0, w, h, Color("gray"))
			end

			for k, v in pairs(self.bpData["required"]) do
				local itemTable = item.GetAll()[v[1]]
				local inventory = cw.inventory:GetClient()

				if (itemTable) then
					local panel = vgui.Create("DPanel", self.craft.tools)
					panel:SetSize(64, 0)
					panel:SetBackgroundColor(Color("gray"))

					local model, skin = item.GetIconInfo(itemTable)

					local icon = cw.core:CreateMarkupToolTip(vgui.Create("cwSpawnIcon", panel))
					icon:SetModel(model, skin)
					icon:SetTooltip()
					icon:SetSize(64, 64)
					icon:SetMarkupToolTip(item.GetMarkupToolTip(itemTable, false))

					local label = vgui.Create("DLabel", panel)
					label:Dock(BOTTOM)
					label:SetText((cw.inventory:GetItemCountByID(inventory, v[1]) or 0).." / "..v[2])
					label:SetFont("DermaNarrow15")
					label:SetContentAlignment(5)

					if (cw.inventory:GetItemCountByID(inventory, v[1]) >= v[2]) then
						label:SetTextColor(Color("lightgreen"))
					else
						label:SetTextColor(Color("white"))
					end

					self.craft.tools:AddPanel(panel)
				end
			end
		end
	end
end

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h) 
	self.list:SetSize(w / 3 - 4, h - 8)
	self.list:SetPos(4, 4)
	self.craft:SetSize( 2 * w / 3 - 8, h - 40)
	self.craft:SetPos(w / 3 + 4, 4)
end

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, cw.option:GetColor("panel_background"))

	return true
end

vgui.Register("cwCraft", PANEL, "EditablePanel")

