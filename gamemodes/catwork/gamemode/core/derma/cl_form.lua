--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- A function to add a text entry.
function PANEL:TextEntry(strLabel)
	local labelPanel = vgui.Create("DLabel", self)

	self:AddItem(labelPanel)

	labelPanel:SetText(strLabel)
	labelPanel:SetDark(true)

	local textEntryPanel = vgui.Create("DTextEntry", self)

	self:AddItem(textEntryPanel)

	return textEntryPanel, labelPanel
end

vgui.Register("cwForm", PANEL, "DForm");
