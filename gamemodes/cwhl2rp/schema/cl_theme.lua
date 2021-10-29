--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local THEME = cw.theme:Begin()

function THEME:CreateFonts()
	cw.fonts:Add("hl2_PlayerInfoText", {
			font		= "Exo 2",
			size		= cw.core:FontScreenScale(7),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_Large3D2D", {
			font		= "Exo 2",
			size		= cw.core:GetFontSize3D(),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_SurfaceTextFont", {
			font		= "Kelly Slab",
			size		= cw.core:GetFontSize3D(),
			weight		= 400,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_IntroTextSmall", {
			font		= "Exo 2",
			size		= 28,
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_IntroTextTiny", {
			font		= "Exo 2",
			size		= cw.core:FontScreenScale(9),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_CinematicText", {
			font		= "Exo 2",
			size		= cw.core:FontScreenScale(8),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_IntroTextBig", {
			font		= "Exo 2",
			size		= cw.core:FontScreenScale(18),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_MainText", {
			font		= "Exo 2",
			size		= cw.core:FontScreenScale(7),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_TargetIDText", {
			font		= "Exo 2",
			size		= cw.core:FontScreenScale(7),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_MenuTextHuge", {
			font		= "Exo 2",
			size		= cw.core:FontScreenScale(30),
			weight		= 600,
			antialiase	= true,
			additive 	= false
	})

	cw.fonts:Add("hl2_MenuTextBig", {
		font		= "Exo 2",
		size		= cw.core:FontScreenScale(18),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("hl2_BarsFont", {
		font = "Roboto Condensed",
		size = 18,
		weight = 600,
		extended = true
	})

	cw.fonts:Add("hl2_dermafont", {
		font = "Roboto Condensed",
		size = 14,
		weight = 400,
		extended = true
	})
end

-- Called when to initialize the theme.
function THEME:Initialize()
	cw.option:SetColor("information", Color("#8C16E6"))
	cw.option:SetColor("background", Color(0, 0, 0, 255))
	cw.option:SetColor("target_id", Color("#8C16E6"))

	cw.option:SetKey("schema_logo", "data/catwork/tc_logo_512")
	cw.option:SetKey("intro_image", "data/catwork/tc_logo_512")

	cw.option:SetFont("bar_text", "hl2_TargetIDText")
	cw.option:SetFont("main_text", "hl2_MainText")
	cw.option:SetFont("hints_text", "hl2_IntroTextTiny")
	cw.option:SetFont("large_3d_2d", "hl2_Large3D2D")
	cw.option:SetFont("surface_text_font", "hl2_SurfaceTextFont")
	cw.option:SetFont("menu_text_big", "hl2_MenuTextBig")
	cw.option:SetFont("menu_text_huge", "hl2_MenuTextHuge")
	cw.option:SetFont("target_id_text", "hl2_TargetIDText")
	cw.option:SetFont("cinematic_text", "hl2_CinematicText")
	cw.option:SetFont("date_time_text", "hl2_IntroTextSmall")
	cw.option:SetFont("intro_text_big", "hl2_IntroTextBig")
	cw.option:SetFont("menu_text_tiny", "hl2_IntroTextTiny")
	cw.option:SetFont("menu_text_small", "hl2_IntroTextSmall")
	cw.option:SetFont("intro_text_tiny", "hl2_IntroTextTiny")
	cw.option:SetFont("intro_text_small", "hl2_IntroTextSmall")
	cw.option:SetFont("player_info_text", "hl2_PlayerInfoText")

	Schema:DownloadMaterial("http://teslacdn.net/assets/blowback/gradient.png", "catwork/gradient.png")
	Schema:DownloadMaterial("http://teslacdn.net/files/logo/logo_white_512_256.png", "catwork/tc_logo_512.png")
end

local function drawHL2Bar(x, y, w, h, amt, spacing, percentage, color)
	local ox, oy = 0, 0
	local width = (w - (amt * spacing)) / amt
	local amtToDraw = math.ceil(amt / (w / percentage))

	for i = 1, amtToDraw do
		cdraw.DrawBox(x + ox, y, width, h, color, 0)
		ox = ox + width + spacing
	end
end

-- Called just before a bar is drawn.
function THEME.module:PreDrawBar(barInfo)
	if (!barInfo.uniqueID) then
		cdraw.DrawBox(barInfo.x - 2, barInfo.y - 2, barInfo.width + 4, barInfo.height + 4, Color(220, 220, 220), 0)
	else
		surface.SetDrawColor(75, 75, 75, 180)
		surface.SetMaterial(cw.core:GetMaterial("data/catwork/gradient.png"))
		surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.width, barInfo.height)
	end

	barInfo.drawBackground = false
	barInfo.drawProgress = false

	if (barInfo.text) then
		barInfo.text = string.utf8upper(barInfo.text)
	end
end

-- Called just after a bar is drawn.
function THEME.module:PostDrawBar(barInfo)
	if (!barInfo.uniqueID) then
		drawHL2Bar(barInfo.x, barInfo.y, barInfo.width, barInfo.height, 42, 4, barInfo.progressWidth, barInfo.color)
	else
		if (barInfo.progressWidth > 4) then
			local color = barInfo.color:Darken(10)
			local x, y, w, h = barInfo.x, barInfo.y, barInfo.width, barInfo.height

			surface.SetDrawColor(color.r, color.g, color.b, 255)
			surface.SetMaterial(cw.core:GetMaterial("data/catwork/gradient.png"))

			render.SetScissorRect(x, y, x + (barInfo.progressWidth + 4 or w), y + h, true)
				surface.DrawTexturedRect(x, y, w, h)
			render.SetScissorRect(0, 0, 0, 0, false)

			DisableClipping(true)
				draw.SimpleText(barInfo.uniqueID, cw.fonts:GetSize("hl2_BarsFont", 15), barInfo.x + 6, barInfo.y - 1, Color("white"))
			DisableClipping(false)
		end
	end
end

function THEME.module:DrawBarLimit(barInfo)
	local x, y, w, h = barInfo.x, barInfo.y, barInfo.width, barInfo.height
	local length = w * ((barInfo.maximum - barInfo.maxValue) / barInfo.maximum)
	local color = Color("#D5AD27")

	if (barInfo.limitText) then
		local limitText = cw.lang:TranslateText(barInfo.limitText)
		local textWide = util.GetTextSize(cw.fonts:GetSize("hl2_BarsFont", 15), limitText)

		render.SetScissorRect(x + w - length, y, x + w, y + h, true)
			surface.SetDrawColor(color.r, color.g, color.b, 255)
			surface.SetMaterial(cw.core:GetMaterial("data/catwork/gradient.png"))
			surface.DrawTexturedRect(x, y, w, h)

			draw.SimpleText(limitText, cw.fonts:GetSize("hl2_BarsFont", 15), x + w - textWide - 8, y - 1, Color("white"))
		render.SetScissorRect(0, 0, 0, 0, false)
	end

	return true
end

-- Called just before the weapon selection info is drawn.
function THEME.module:PreDrawWeaponSelectionInfo(info)
	draw.RoundedBox(2, info.x, info.y, info.width, info.height, Color(120, 120, 120, 120))

	info.drawBackground = false
end

-- Called just before the local player's information is drawn.
function THEME.module:PreDrawPlayerInfo(boxInfo, information, subInformation)
	boxInfo.drawBackground = false
end

-- Called after the character menu has initialized.
function THEME.hooks:PostCharacterMenuInit(panel) end

-- Called every frame that the character menu is open.
function THEME.hooks:PostCharacterMenuThink(panel) end

-- Called after the character menu is painted.
function THEME.hooks:PostCharacterMenuPaint(panel) end

-- Called after a character menu panel is opened.
function THEME.hooks:PostCharacterMenuOpenPanel(panel) end

-- Called after the main menu has initialized.
function THEME.hooks:PostMainMenuInit(panel) end

-- Called after the main menu is rebuilt.
function THEME.hooks:PostMainMenuRebuild(panel) end

-- Called after a main menu panel is opened.
function THEME.hooks:PostMainMenuOpenPanel(panel, panelToOpen) end

-- Called after the main menu is painted.
function THEME.hooks:PostMainMenuPaint(panel) end

-- Called every frame that the main menu is open.
function THEME.hooks:PostMainMenuThink(panel) end

THEME.skin.frameBorder = Color(255, 255, 255, 255)
THEME.skin.frameTitle = Color(255, 255, 255, 255)

THEME.skin.bgColorBright = Color(255, 255, 255, 255)
THEME.skin.bgColorSleep = Color(70, 70, 70, 255)
THEME.skin.bgColorDark = Color(50, 50, 50, 255)
THEME.skin.bgColor = Color(40, 40, 40, 240)

THEME.skin.controlColorHighlight = Color(70, 70, 70, 255)
THEME.skin.controlColorActive = Color(175, 175, 175, 255)
THEME.skin.controlColorBright = Color(100, 100, 100, 255)
THEME.skin.controlColorDark = Color(30, 30, 30, 255)
THEME.skin.controlColor = Color(60, 60, 60, 255)

THEME.skin.colPropertySheet = Color(255, 255, 255, 255)
THEME.skin.colTabTextInactive = Color(0, 0, 0, 255)
THEME.skin.colTabInactive = Color(255, 255, 255, 255)
THEME.skin.colTabShadow = Color(0, 0, 0, 170)
THEME.skin.colTabText = Color(255, 255, 255, 255)
THEME.skin.colTab = Color(0, 0, 0, 125)

THEME.skin.fontCategoryHeader = "Exo8"
THEME.skin.fontMenuOption = "Exo8"
THEME.skin.fontFormLabel = "Exo8"
THEME.skin.fontButton = "Exo8"
THEME.skin.fontFrame = "Exo8"
THEME.skin.fontTab = "Exo8"

-- A function to draw a generic background.
function THEME.skin:DrawGenericBackground(x, y, w, h, color)
	surface.SetDrawColor(color)
	surface.DrawRect(x, y, w, h)
end

-- Called when a frame is layed out.
function THEME.skin:LayoutFrame(panel)
	panel.lblTitle:SetFont(self.fontFrame)
	panel.lblTitle:SetText(panel.lblTitle:GetText():upper())
	panel.lblTitle:SetTextColor(Color(0, 0, 0, 255))
	panel.lblTitle:SizeToContents()
	panel.lblTitle:SetExpensiveShadow(nil)

	panel.btnClose:SetDrawBackground(true)
	panel.btnClose:SetPos(panel:GetWide() - 22, 2)
	panel.btnClose:SetSize(18, 18)
	panel.lblTitle:SetPos(8, 2)
	panel.lblTitle:SetSize(panel:GetWide() - 25, 20)
end

-- Called when a form is schemed.
function THEME.skin:SchemeForm(panel)
	panel.Label:SetFont(self.fontFormLabel)
	panel.Label:SetText(panel.Label:GetText():upper())
	panel.Label:SetTextColor(Color(255, 255, 255, 255))
	panel.Label:SetExpensiveShadow(1, Color(0, 0, 0, 200))
end

-- Called when a tab is painted.
function THEME.skin:PaintTab(panel, w, h)
	if (panel:GetPropertySheet():GetActiveTab() == panel) then
		self:DrawGenericBackground(0, 0, w - 2, h - 8, self.colTab)
	else
		self:DrawGenericBackground(0, 0, w, h, Color(40, 40, 40))
	end
end

-- Called when a list view is painted.
function THEME.skin:PaintListView(panel, w, h)
	if (panel.m_bBackground) then
		surface.SetDrawColor(255, 255, 255, 255)
		panel:DrawFilledRect()
	end
end

-- Called when a list view line is painted.
function THEME.skin:PaintListViewLine(panel)
	local color = Color(50, 50, 50, 255)
	local textColor = Color(255, 255, 255, 255)

	if (panel:IsSelected()) then
		color = Color(255, 255, 255, 255)
		textColor = Color(0, 0, 0, 255)
	elseif (panel.Hovered) then
		color = Color(100, 100, 100, 255)
	elseif (panel.m_bAlt) then
		color = Color(75, 75, 75, 255)
	end

	for k, v in pairs(panel.Columns) do
		v:SetTextColor(textColor)
	end

	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
end

-- Called when a list view label is schemed.
function THEME.skin:SchemeListViewLabel(panel)
	panel:SetTextInset(3)
	panel:SetTextColor(Color(255, 255, 255, 255))
end

-- Called when a menu is painted.
function THEME.skin:PaintMenu(panel, w, h)
	surface.SetDrawColor(Color(15, 15, 15, 255))
	panel:DrawFilledRect(0, 0, w, h)
end

-- Called when a menu is painted over.
function THEME.skin:PaintOverMenu(panel) end

-- Called when a menu option is schemed.
function THEME.skin:SchemeMenuOption(panel)
	panel:SetFGColor(255, 255, 255, 255)
end

-- Called when a menu option is painted.
function THEME.skin:PaintMenuOption(panel, w, h)
	local textColor = Color(255, 255, 255, 255)

	if (panel.m_bBackground and panel.Hovered) then
		local color = nil

		if (panel.Depressed) then
			color = Color(225, 225, 225, 255)
		else
			color = Color(255, 255, 255, 255)
		end

		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.DrawRect(0, 0, w, h)

		textColor = Color(0, 0, 0, 255)
	end

	panel:SetFGColor(textColor)
end

-- Called when a menu option is layed out.
function THEME.skin:LayoutMenuOption(panel, w, h)
	panel:SetFont(self.fontMenuOption)
	panel:SizeToContents()
	panel:SetWide(panel:GetWide() + 30)
	panel:SetSize(math.max(panel:GetParent():GetWide(), panel:GetWide()), 18)

	if (panel.SubMenuArrow) then
		panel.SubMenuArrow:SetSize(panel:GetTall(), panel:GetTall())
		panel.SubMenuArrow:CenterVertical()
		panel.SubMenuArrow:AlignRight()
	end
end

-- Called when a button is painted.
function THEME.skin:PaintButton(panel, w, h)
	local textColor = Color(255, 255, 255, 255)

	if (panel.m_bBackground) then
		local color = Color(40, 40, 40, 255)
		local borderColor = Color(0, 0, 0, 255)

		if (panel:GetDisabled()) then
			color = self.controlColorDark
		elseif (panel.Depressed) then
			color = Color(255, 255, 255, 255)
			textColor = Color(0, 0, 0, 255)
		elseif (panel.Hovered) then
			color = self.controlColorHighlight
		end

		self:DrawGenericBackground(0, 0, w, h, borderColor)
		self:DrawGenericBackground(1, 1, w - 2, h - 2, color)
	end

	panel:SetFGColor(textColor)
end

-- Called when a scroll bar grip is painted.
function THEME.skin:PaintScrollBarGrip(panel)
	local w, h = panel:GetSize()
	local color = Color(255, 255, 255, 255)

	self:DrawGenericBackground(0, 0, w, h, color)
	self:DrawGenericBackground(1, 1, w - 2, h - 2, Color(0, 0, 0, 255))
end

function THEME.skin:PaintFrame(panel, w, h)
	local color = cw.option:GetColor("information")

	surface.SetDrawColor(Color(10, 10, 10))
	surface.DrawRect(0, 24, w, h)

	surface.SetDrawColor(Color(40, 40, 40))
	surface.DrawRect(1, 0, w - 2, h - 1)

	surface.SetDrawColor(color:Darken(20))
	surface.DrawRect(0, 0, w, 24)
end

function THEME.skin:PaintCollapsibleCategory(panel, w, h)
	panel.Header:SetFont(cw.fonts:GetSize("hl2_dermafont", 16))

	self:DrawGenericBackground(0, 0, w, 21, Color(0, 0, 0))

	if (h < 21) then return end

	self:DrawGenericBackground(0, 0, w, 21, Color(20, 20, 20))
end

cw.theme:Finish(THEME);
