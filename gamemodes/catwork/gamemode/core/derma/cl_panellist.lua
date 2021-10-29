--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	self.backgroundColor = Color(50, 50, 50, 255)
	self.backgroundColorOutline = Color(0, 0, 0, 255)
end

-- A function to set the background color.
function PANEL:SetBackgroundColor(color, col2)
	self.backgroundColor = color
	self.backgroundColorOutline = col2 or Color(0, 0, 0)
end

function PANEL:HideBackground()
	self.backgroundHidden = true
end

function PANEL:SetSpacing(spacing)
	self.defaultSpacing = spacing
end

function PANEL:EnableVerticalScrollbar() end

function PANEL:AddItem(item, bottomMargin)
	bottomMargin = bottomMargin or self.defaultSpacing or 8

	local padding = self:GetPadding()

	item:Dock(TOP)
	item:DockMargin(padding, padding, padding, bottomMargin)

	DCategoryList.AddItem(self, item)

	-- TODO: Maybe not have this.
	self:InvalidateLayout(true)
end

-- Called when the panel should be painted.
function PANEL:Paint(width, height)
	if (!self.backgroundHidden) then
		draw.RoundedBox(0, 0, 0, width, height, self.backgroundColorOutline)
		draw.RoundedBox(0, 1, 1, width - 2, height - 2, self.backgroundColor)
	end

	return true
end

vgui.Register("cwPanelList", PANEL, "DCategoryList");
