--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

cw.fonts:Add("cwMenuButtonSmall", {
	font		= "Roboto Condensed",
	size		= 24,
	weight		= 600,
	antialiase	= true,
	additive 	= false,
	extended	= true
})

function PANEL:SetupLabel(menuItem, panel)
	self:SetFont("cwMenuButtonSmall")

	if (!menuItem.text:StartWith("#")) then
		menuItem.text = "#"..menuItem.text
	end

	local text = cw.lang:GetString(GetConVar("gmod_language"):GetString(), menuItem.text)

	self:SetText(text:utf8upper())

	if (menuItem.iconData.path != "") then
		self:SetIcon(menuItem.iconData.path)
	else
		self:SetIcon("bars")
	end

	local offsetX = 4

	if (menuItem.iconData.size) then
		offsetX = menuItem.iconData.size
	end

	self:SetIconSize(24, 24, offsetX, 4)
	self:SetTextOffset(34, 4)

	self:FadeIn(0.5)

	self:SetTooltip(menuItem.tip)

	self:SetCallback(function(button)
		if (cw.menu:GetActivePanel() != panel) then
			cw.menu:GetPanel():OpenPanel(panel)
		end
	end)

	self:SizeToContents()
	self:SetMouseInputEnabled(true)

	self.ContentPanel = panel
	self:UpdatePositioning()
end

-- A function to update the positioning of child items.
function PANEL:UpdatePositioning()
	self:SetSize(200, 32)
end

vgui.Register("cw.menuButton", PANEL, "cwFAButton");
