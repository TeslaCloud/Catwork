--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- A function to add a new sheet.
function PANEL:AddSheet(label, panel, material)
	if (!IsValid(panel)) then
		return
	end

	local newSheet = {}

	if (self.ButtonOnly) then
		newSheet.Button = vgui.Create("DImageButton", self.Navigation)
		newSheet.Button:Dock(TOP)
		newSheet.Button:DockMargin(0, 1, 0, 0)
	else
		newSheet.Button = vgui.Create("cwIconButton", self.Navigation)

		local size = cw.fonts:GetSize(cw.option:GetFont("menu_text_tiny"), 16)

		newSheet.Button:SetTall(24)
		newSheet.Button:Dock(TOP)
		newSheet.Button:DockMargin(0, 0, 0, 4)
		newSheet.Button:SetFont(size)

		function newSheet.Button:Paint(width, height)
			draw.RoundedBox(0, 0, 0, width, height, cw.option:GetColor("panel_outline"))
			draw.RoundedBox(0, 1, 1, width - 2, height - 2, cw.option:GetColor("panel_background"))
		end
	end

	newSheet.Button:SetImage(material)
	newSheet.Button.Target = panel
	newSheet.Button:SetText(label)
	newSheet.Button.DoClick = function()
		self:SetActiveButton(newSheet.Button)
	end

	newSheet.Panel = panel
	newSheet.Panel:SetParent(self.Content)
	newSheet.Panel:SetVisible(false)

	if (self.ButtonOnly) then
		newSheet.Button:SizeToContents()
	end

	newSheet.Button:SetColor(cw.option:GetColor("columnsheet_text_normal"))

	table.insert(self.Items, newSheet)

	if (!IsValid(self.ActiveButton)) then
		self:SetActiveButton(newSheet.Button)
	end
end

-- A function to set the active button.
function PANEL:SetActiveButton(active)
	if (self.ActiveButton == active) then
		return
	end

	if (self.ActiveButton && self.ActiveButton.Target) then	
		self.ActiveButton.Target:SetVisible(false)
		self.ActiveButton:SetSelected(false)
		self.ActiveButton:SetColor(cw.option:GetColor("columnsheet_text_normal"))
	end

	self.ActiveButton = active

	active.Target:SetVisible(true)
	active:SetSelected(true)
	active:SetColor(cw.option:GetColor("columnsheet_text_active"))

	self.Content:InvalidateLayout()
end

vgui.Register("cwColumnSheet", PANEL, "DColumnSheet");
