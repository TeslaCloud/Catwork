--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("menu", cw)
cw.menu.width = math.min(ScrW() * 0.7, 768)
cw.menu.height = ScrH() * 0.75
cw.menu.stored = cw.menu.stored or {}

-- A function to get the menu's active panel.
function cw.menu:GetActivePanel()
	local panel = self:GetPanel()

	if (panel) then
		return panel.activePanel
	end
end

-- A function to get whether a panel is active.
function cw.menu:IsPanelActive(panel)
	return (cw.menu:GetOpen() and self:GetActivePanel() == panel)
end

-- A function to get the menu hold time.
function cw.menu:GetHoldTime()
	return self.holdTime
end

-- A function to get the menu's items.
function cw.menu:GetItems()
	return self.stored
end

-- A function to get the menu's width.
function cw.menu:GetWidth()
	return self.width
end

-- A function to get the menu's height.
function cw.menu:GetHeight()
	return self.height
end

-- A function to toggle whether the menu is open.
function cw.menu:ToggleOpen()
	local panel = self:GetPanel()

	if (panel) then
		if (self:GetOpen()) then
			panel:SetOpen(false)
		else
			panel:SetOpen(true)
		end
	end
end

-- A function to set whether the menu is open.
function cw.menu:SetOpen(bIsOpen)
	local panel = self:GetPanel()

	if (panel) then
		panel:SetOpen(bIsOpen)
	end
end

-- A function to get whether the menu is open.
function cw.menu:GetOpen()
	return self.bIsOpen
end

-- A function to get the menu panel.
function cw.menu:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel
	end
end

-- A function to create the menu.
function cw.menu:Create(setOpen)
	local panel = self:GetPanel()

	if (!panel) then
		self.panel = vgui.Create("cw.menu")

		if (IsValid(self.panel)) then
			self.panel:SetOpen(setOpen)
			self.panel:MakePopup()
		end
	end
end
