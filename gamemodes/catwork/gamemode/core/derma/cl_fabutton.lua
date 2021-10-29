local PANEL = {}

PANEL.isCollapsible = false
PANEL.isOpen = true
PANEL.shouldHover = true
PANEL.iconW = 0
PANEL.iconH = 0
PANEL.iconX = 0
PANEL.iconY = 0

function PANEL:SetOpen(bIsOpen)
	self.isOpen = bIsOpen
end

function PANEL:SetDrawBackground(bDrawBackground)
	self.drawBackground = bDrawBackground
end

function PANEL:SetIcon(id)
	self.iconID = id
end

function PANEL:SetIconSize(w, h, x, y)
	self.iconW = w or 16
	self.iconH = h or 16
	self.iconX = x or 0
	self.iconY = y or 0
end

function PANEL:SetText(text)
	self.drawText = text
	self.shouldDrawText = true
end

function PANEL:SetFont(font)
	self.m_Font = font
end

function PANEL:SetTextOffset(x, y)
	self.textOX = x
	self.textOY = y
end

PANEL.SetTextFont = PANEL.SetFont

function PANEL:SizeToText()
	local w, h = util.GetTextSize((self.m_Font or "Derma16"), self.drawText)

	self:SetSize((self.iconW + self.iconX or 0) + w + 8 + (self.textOX or 0), (self.iconH + self.iconY * 2 or h + 8))
end

PANEL.SizeToContents = PANEL.SizeToText

function PANEL:Toggle()
	if (self.isOpen) then
		self.isOpen = false
	else
		self.isOpen = true
	end
end

function PANEL:SetCollapsible(coll)
	self.isCollapsible = coll
end

function PANEL:OnMousePressed()
	if (self.isCollapsible) then
		self:Toggle()
	end

	if (self._callback) then
		local bSuccess, val = pcall(self._callback, self)

		if (!bSuccess) then
			ErrorNoHalt("[Catwork - FAButton] "..val.."\n")
		end
	end
end

function PANEL:ShouldHover(hover)
	self.shouldHover = hover
end

function PANEL:SetCallback(cb)
	self._callback = cb
end

function PANEL:Paint(w, h)
	if (self.drawBackground) then
		local drawColor = Color(35, 35, 35)

		if (self:IsHovered() and self.shouldHover) then
			drawColor = Color(60, 60, 60)
		else
			self:OverrideTextColor(Color(255, 255, 255))
		end

		draw.RoundedBox(0, 0, 0, w, h, Color(8, 8, 8))
		draw.RoundedBox(0, 1, 1, w - 2, h - 2, drawColor)
	end

	local textColor = Color(255, 255, 255)

	if (self:IsHovered() and self.shouldHover) then
		textColor = cw.option:GetColor("information")
	end

	if (self.iconID) then
		//draw.RoundedBox(0, self.iconX, self.iconY, self.iconSize, self.iconSize, Color(255, 0, 0)) --debug
		cw.FontIcons:Draw(self.iconID, (self.iconX or 0) + 1, (self.iconY or 0) - 1, (self.iconH or 16), (self.overrideColor or textColor or Color(255, 255, 255)))
	end

	if (self.shouldDrawText) then
		local offsetX = 0

		if (self.iconW) then
			offsetX = self.iconW + 8
		end

		if (self.drawText) then
			draw.SimpleText(self.drawText, (self.m_Font or "Derma16"), (self.textOX or offsetX), (self.textOY or 0), (self.overrideColor or textColor or Color(255, 255, 255)))
		end
	end
end

PANEL.wasOpen = true

function PANEL:Think()
	if (self.isOpen) then
		self.shouldDrawText = true

		if (!self.wasOpen) then
			//self:SizeToText()
		end
	else
		self.shouldDrawText = false
		self.wasOpen = false

		if (self.iconW) then
			//self:SetSize((self.iconW + self.iconX * 2) or 32, (self.iconH + self.iconY * 2) or 32)
		end
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

function PANEL:OverrideTextColor(color)
	self.overrideColor = color
end

vgui.Register("cwFAButton", PANEL, "Panel")

concommand.Add("cw_testButton", function()
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 500)
	frame:SetPos(200, 200)
	frame:MakePopup()

	local button = vgui.Create("cwFAButton", frame)
	button:SetDrawBackground(true)
	button:SetSize(100, 32)
	button:SetPos(100, 100)
	button:SetIcon("bars")
	button:SetIconSize(24, 24, 4, 4)
	button:SetText("It works even if I put in a bunch of text!")
	button:SizeToText()
	button:SetOpen(false)
end);