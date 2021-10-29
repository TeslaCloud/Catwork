--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

PANEL.BackgroundColor = Color(100, 100, 100)

-- A function to set whether the panel is disabled.
function PANEL:SetDisabled(disabled)
	self.Disabled = disabled
end

-- A function to get whether the panel is disabled.
function PANEL:GetDisabled()
	return self.Disabled
end

-- A function to set whether the panel is depressed.
function PANEL:SetDepressed(depressed)
	self.Depressed = depressed
end

-- A function to get whether the panel is depressed.
function PANEL:GetDepressed()
	return self.Depressed
end

-- A function to set whether the panel is hovered.
function PANEL:SetHovered(hovered)
	self.Hovered = hovered
end

-- A function to get whether the panel is hovered.
function PANEL:GetHovered()
	return self.Hovered
end

-- Called when the cursor has entered the panel.
function PANEL:OnCursorEntered()
	if (!self:GetDisabled()) then
		self:SetHovered(true)
	end

	self:InvalidateLayout()
end

function PANEL:SetDrawBackground(bDraw)
	self.ShouldDrawBackground = bDraw or false
end

function PANEL:SetBackgroundSize(w, h)
	if (w == nil or h == nil) then
		self.BackgroundIsContentSize = true
		return
	end

	self.BackgroundSize.w = w
	self.BackgroundSize.h = h
end

-- Called when the cursor has exited the panel.
function PANEL:OnCursorExited()
	self:SetHovered(false)
	self:InvalidateLayout()
end

-- Called when the mouse is pressed.
function PANEL:OnMousePressed(code)
	self:MouseCapture(true)
	self:SetDepressed(true)
end

-- Called when the mouse is released.
function PANEL:OnMouseReleased(code)
	self:MouseCapture(false)

	if (!self:GetDepressed()) then
		return
	end

	self:SetDepressed(false)

	if (!self:GetHovered()) then
		return
	end

	if (code == MOUSE_LEFT and self.DoClick
	and !self:GetDisabled()) then
		self.DoClick(self)
	end
end

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
		panel:SetAlpha(255 - (delta * 255))

		if (animation.Finished) then
			panel:SetVisible(false)
				if (Callback) then
					Callback()
				end
			self.animation = nil
		end
	end)

	if (self.animation) then
		self.animation:Start(speed)
	end

	cw.option:PlaySound("rollover")
end

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
		panel:SetAlpha(delta * 255)

		if (animation.Finished) then
			if (Callback) then
				Callback()
			end

			self.animation = nil
		end
	end)

	if (self.animation) then
		self.animation:Start(speed)
	end

	cw.option:PlaySound("click_release")
	self:SetVisible(true)
end

-- A function to override the text color.
function PANEL:OverrideTextColor(color)
	if (color) then
		self.OverrideColorNormal = color
		self.OverrideColorHover = Color(math.max(color.r - 50, 0), math.max(color.g - 50, 0), math.max(color.b - 50, 0), color.a)
	else
		self.OverrideColorNormal = nil
		self.OverrideColorHover = nil
	end
end

-- Called every frame.
function PANEL:Think()
	if (self.animation) then
		self.animation:Run()
	end

	local colorWhite = cw.option:GetColor("white")
	local colorDisabled = Color(
		math.max(colorWhite.r - 50, 0),
		math.max(colorWhite.g - 50, 0),
		math.max(colorWhite.b - 50, 0),
		255
	)
	local colorInfo = cw.option:GetColor("information")

	if (self.ShouldDrawBackground) then
		self.BackgroundSize = self.BackgroundSize or {}

		if (self.BackgroundIsContentSize) then
			local w, h = util.GetTextSize(self.m_FontName, self:GetText())

			self.BackgroundSize.w = w
			self.BackgroundSize.h = h
		end

		if (!self.BackgroundSize.w or !self.BackgroundSize.h) then
			self.BackgroundSize.w = 200
			self.BackgroundSize.h = 32
		end

		self:SetSize(self.BackgroundSize.w + 8, self.BackgroundSize.h)
	end

	if (self:GetDisabled()) then
		self:SetTextColor(self.OverrideColorHover or colorDisabled)
	elseif (self:GetHovered()) then
		self:SetTextColor(self.OverrideColorHover or colorInfo)
	else
		self:SetTextColor(self.OverrideColorNormal or colorWhite)
	end

	self:SetExpensiveShadow(1, Color(0, 0, 0, 150))
end

function PANEL:Paint(w, h)
	DisableClipping(true)

		if (self.ShouldDrawBackground and self.BackgroundSize) then
			if (self.Hovered) then
				draw.RoundedBox(0, -2, -2, self.BackgroundSize.w + 4, h + 4, Color(255, 255, 255, 80))
			else
				draw.RoundedBox(0, -2, -2, self.BackgroundSize.w + 4, h + 4, Color(160, 160, 160, 80))
			end
		end

	DisableClipping(false)
end

-- A function to set the panel's Callback.
function PANEL:SetCallback(Callback)
	self.DoClick = function(button)
		cw.option:PlaySound("click")
		Callback(button)
	end
end

vgui.Register("cwLabelButton", PANEL, "DLabel");
