--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local THEME = cw.theme:New("Clockwork")

-- Called when fonts should be created.
function THEME:CreateFonts()
	cw.fonts:Add("cwMainText", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(7),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwESPText", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(5.5),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwTooltip", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(5),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cw.menuTextBig", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(18),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cw.menuTextTiny", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(7),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwInfoTextFont", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(6),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cw.menuTextHuge", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(30),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cw.menuTextSmall", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(10),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwIntroTextBig", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(18),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwIntroTextTiny",
	{
		font		= "Arial",
		size		= cw.core:FontScreenScale(9),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})
	cw.fonts:Add("cwIntroTextSmall", {
		font		= "Arial",
		size		= cw.core:FontScreenScale(7),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwLarge3D2D", {
		font		= "Arial",
		size		= cw.core:GetFontSize3D(),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwScoreboardName", {
		font		= "Roboto Condensed",
		size		= 18,
		weight		= 600,
		antialiase	= true,
		additive 	= false
	}, true)

	cw.fonts:Add("cwScoreboardDesc", {
		font		= "Roboto",
		size		= 12,
		weight		= 600,
		antialiase	= true,
		additive 	= false
	}, true)

	cw.fonts:Add("cwScoreboardClass", {
		font		= "Roboto Condensed",
		size		= 20,
		weight		= 700,
		antialiase	= true,
		additive 	= false
	}, true)

	cw.fonts:Add("cwCinematicText", {
		font		= "Trebuchet",
		size		= cw.core:FontScreenScale(8),
		weight		= 700,
		antialiase	= true,
		additive 	= false
	})

	cw.fonts:Add("cwChatSyntax", {
		font		= "Courier New",
		size		= cw.core:FontScreenScale(7),
		weight		= 600,
		antialiase	= true,
		additive 	= false
	})
end

-- Called when the theme is initialized.
function THEME:Initialize()
	--[[ Set Default Options --]]
	--cw.option:SetKey("schema_logo", "test.png")

	cw.option:SetKey("icon_data_classes", {path = "tag", size = nil})
	cw.option:SetKey("icon_data_settings", {path = "wrench", size = nil})
	cw.option:SetKey("icon_data_system", {path = "cog", size = nil})
	cw.option:SetKey("icon_data_scoreboard", {path = "list-alt", size = 3})
	cw.option:SetKey("icon_data_inventory", {path = "inbox", size = nil})
	cw.option:SetKey("icon_data_directory", {path = "book", size = nil})
	cw.option:SetKey("icon_data_attributes", {path = "bar-chart", size = 2})
	cw.option:SetKey("icon_data_business", {path = "briefcase", size = 2})

	cw.option:SetKey("top_bar_width_scale", 0.3)

	cw.option:SetKey("info_text_icon_size", 16)
	cw.option:SetKey("info_text_red_icon", "icon16/exclamation.png")
	cw.option:SetKey("info_text_green_icon", "icon16/tick.png")
	cw.option:SetKey("info_text_orange_icon", "icon16/error.png")
	cw.option:SetKey("info_text_blue_icon", "icon16/information.png")

	cw.option:SetKey("name_attributes", "Attributes")
	cw.option:SetKey("name_attribute", "Attribute")
	cw.option:SetKey("name_system", "System")
	cw.option:SetKey("name_scoreboard", "Scoreboard")
	cw.option:SetKey("name_directory", "Directory")
	cw.option:SetKey("name_inventory", "Inventory")
	cw.option:SetKey("name_business", "Business")
	cw.option:SetKey("name_destroy", "Destroy")

	cw.option:SetKey("description_business", "Order items for your business.")
	cw.option:SetKey("description_inventory", "Manage the items in your inventory.")
	cw.option:SetKey("description_directory", "A directory of various topics and information.")
	cw.option:SetKey("description_system", "Access a variety of server-side options.")
	cw.option:SetKey("description_scoreboard", "See which players are on the server.")
	cw.option:SetKey("description_attributes", "Check the status of your attributes.")

	cw.option:SetKey("gradient", nil)

	--[[ Set Default Colors --]]
	cw.option:SetColor("columnsheet_shadow_normal", Color(200, 200, 200, 255))
	cw.option:SetColor("columnsheet_text_normal", Color(255, 255, 255, 255))
	cw.option:SetColor("columnsheet_shadow_active", Color(150, 150, 150, 255))
	cw.option:SetColor("columnsheet_text_active", Color(220, 220, 110, 255))

	cw.option:SetColor("basic_form_highlight", Color(240, 240, 240, 255))
	cw.option:SetColor("basic_form_color", Color(240, 240, 240, 255))

	cw.option:SetColor("scoreboard_name", Color(255, 255, 255, 255))
	cw.option:SetColor("scoreboard_desc", Color(255, 255, 255, 255))
	cw.option:SetColor("scoreboard_item_background", Color(255, 255, 255, 50))

	cw.option:SetColor("positive_hint", Color(100, 175, 100, 255))
	cw.option:SetColor("negative_hint", Color(175, 100, 100, 255))
	cw.option:SetColor("background", Color(0, 0, 0, 125))
	cw.option:SetColor("foreground", Color(50, 50, 50, 125))
	cw.option:SetColor("target_id", Color(50, 75, 100, 255))
	cw.option:SetColor("white", Color(255, 255, 255, 255))

	--[[ Set Default Fonts --]]
	cw.option:SetFont("schema_description", "cwMainText")
	cw.option:SetFont("scoreboard_desc", "cwScoreboardDesc")
	cw.option:SetFont("scoreboard_name", "cwScoreboardName")
	cw.option:SetFont("scoreboard_class", "cwScoreboardClass")
	cw.option:SetFont("player_info_text", "cwMainText")
	cw.option:SetFont("intro_text_small", "cwIntroTextSmall")
	cw.option:SetFont("intro_text_tiny", "cwIntroTextTiny")
	cw.option:SetFont("menu_text_small", "cw.menuTextSmall")
	cw.option:SetFont("chat_box_syntax", "cwChatSyntax")
	cw.option:SetFont("menu_text_huge", "cw.menuTextHuge")
	cw.option:SetFont("intro_text_big", "cwIntroTextBig")
	cw.option:SetFont("info_text_font", "cwInfoTextFont")
	cw.option:SetFont("menu_text_tiny", "cw.menuTextTiny")
	cw.option:SetFont("date_time_text", "cw.menuTextSmall")
	cw.option:SetFont("cinematic_text", "cwCinematicText")
	cw.option:SetFont("target_id_text", "cwMainText")
	cw.option:SetFont("auto_bar_text", "cwMainText")
	cw.option:SetFont("menu_text_big", "cw.menuTextBig")
	cw.option:SetFont("chat_box_text", "cwMainText")
	cw.option:SetFont("large_3d_2d", "cwLarge3D2D")
	cw.option:SetFont("surface_text_font", "cwLarge3D2D")
	cw.option:SetFont("hints_text", "cwIntroTextTiny")
	cw.option:SetFont("main_text", "cwMainText")
	cw.option:SetFont("bar_text", "cwMainText")
	cw.option:SetFont("esp_text", "cwESPText")

	--[[ Set Default Sounds --]]
	cw.option:SetSound("click_release", "ui/buttonclickrelease.wav")
	cw.option:SetSound("rollover", "ui/buttonrollover.wav")
	cw.option:SetSound("click", "ui/buttonclick.wav")
	cw.option:SetSound("tick", "common/talk.wav")

	--[[ Bar Settings --]]
	cw.bars.height = 14
	cw.bars.padding = 17
end

-- Called when the menu is closed.
function THEME.module:MenuClosed()
	if (cw.client:HasInitialized()) then
		cw.core:RemoveBackgroundBlur("MainMenu")
	end
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

THEME.skin = {}

THEME.skin.PrintName		= "Clockwork Derma Skin"
THEME.skin.Author			= "Mr. Meow"
THEME.skin.DermaVersion	= 1
THEME.skin.GwenTexture	= Material("gwenskin/GModDefault.png")

THEME.skin.bg_color					= Color(101, 100, 105, 255)
THEME.skin.bg_color_sleep				= Color(70, 70, 70, 255)
THEME.skin.bg_color_dark				= Color(55, 57, 61, 255)
THEME.skin.bg_color_bright			= Color(220, 220, 220, 255)
THEME.skin.frame_border				= Color(50, 50, 50, 255)

THEME.skin.fontFrame					= "DermaDefault"

THEME.skin.control_color				= Color(120, 120, 120, 255)
THEME.skin.control_color_highlight	= Color(150, 150, 150, 255)
THEME.skin.control_color_active		= Color(110, 150, 250, 255)
THEME.skin.control_color_bright		= Color(255, 200, 100, 255)
THEME.skin.control_color_dark			= Color(100, 100, 100, 255)

THEME.skin.bg_alt1					= Color(50, 50, 50, 255)
THEME.skin.bg_alt2					= Color(55, 55, 55, 255)

THEME.skin.listview_hover				= Color(70, 70, 70, 255)
THEME.skin.listview_selected			= Color(100, 170, 220, 255)

THEME.skin.text_bright				= Color(255, 255, 255, 255)
THEME.skin.text_normal				= Color(180, 180, 180, 255)
THEME.skin.text_dark					= Color(20, 20, 20, 255)
THEME.skin.text_highlight				= Color(255, 20, 20, 255)

THEME.skin.texGradientUp				= Material("gui/gradient_up")
THEME.skin.texGradientDown			= Material("gui/gradient_down")

THEME.skin.combobox_selected			= THEME.skin.listview_selected

THEME.skin.panel_transback			= Color(255, 255, 255, 50)
THEME.skin.tooltip					= Color(255, 245, 175, 255)

THEME.skin.colPropertySheet			= Color(170, 170, 170, 255)
THEME.skin.colTab						= THEME.skin.colPropertySheet
THEME.skin.colTabInactive				= Color(140, 140, 140, 255)
THEME.skin.colTabShadow				= Color(0, 0, 0, 170)
THEME.skin.colTabText					= Color(255, 255, 255, 255)
THEME.skin.colTabTextInactive			= Color(0, 0, 0, 200)
THEME.skin.fontTab					= "DermaDefault"

THEME.skin.colCollapsibleCategory		= Color(255, 255, 255, 20)

THEME.skin.colCategoryText			= Color(255, 255, 255, 255)
THEME.skin.colCategoryTextInactive	= Color(200, 200, 200, 255)
THEME.skin.fontCategoryHeader			= "TabLarge"

THEME.skin.colNumberWangBG			= Color(255, 240, 150, 255)
THEME.skin.colTextEntryBG				= Color(240, 240, 240, 255)
THEME.skin.colTextEntryBorder			= Color(20, 20, 20, 255)
THEME.skin.colTextEntryText			= Color(20, 20, 20, 255)
THEME.skin.colTextEntryTextHighlight	= Color(20, 200, 250, 255)
THEME.skin.colTextEntryTextCursor		= Color(0, 0, 100, 255)

THEME.skin.colMenuBG					= Color(255, 255, 255, 200)
THEME.skin.colMenuBorder				= Color(0, 0, 0, 200)

THEME.skin.colButtonText				= Color(255, 255, 255, 255)
THEME.skin.colButtonTextDisabled		= Color(255, 255, 255, 55)
THEME.skin.colButtonBorder			= Color(20, 20, 20, 255)
THEME.skin.colButtonBorderHighlight	= Color(255, 255, 255, 50)
THEME.skin.colButtonBorderShadow		= Color(0, 0, 0, 100)

THEME.skin.tex = {}

THEME.skin.tex.Selection					= GWEN.CreateTextureBorder(384, 32, 31, 31, 4, 4, 4, 4)

THEME.skin.tex.Panels = {}
THEME.skin.tex.Panels.Normal				= GWEN.CreateTextureBorder(256,	0, 63, 63, 16, 16, 16, 16)
THEME.skin.tex.Panels.Bright				= GWEN.CreateTextureBorder(256+64, 0, 63, 63, 16, 16, 16, 16)
THEME.skin.tex.Panels.Dark				= GWEN.CreateTextureBorder(256,	64, 63, 63, 16, 16, 16, 16)
THEME.skin.tex.Panels.Highlight			= GWEN.CreateTextureBorder(256+64, 64, 63, 63, 16, 16, 16, 16)

THEME.skin.tex.Button						= GWEN.CreateTextureBorder(480, 0, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Button_Hovered				= GWEN.CreateTextureBorder(480, 32, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Button_Dead				= GWEN.CreateTextureBorder(480, 64, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Button_Down				= GWEN.CreateTextureBorder(480, 96, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Shadow						= GWEN.CreateTextureBorder(448, 0, 31, 31, 8, 8, 8, 8)

THEME.skin.tex.Tree						= GWEN.CreateTextureBorder(256, 128, 127, 127, 16, 16, 16, 16)
THEME.skin.tex.Checkbox_Checked			= GWEN.CreateTextureNormal(448, 32, 15, 15)
THEME.skin.tex.Checkbox					= GWEN.CreateTextureNormal(464, 32, 15, 15)
THEME.skin.tex.CheckboxD_Checked			= GWEN.CreateTextureNormal(448, 48, 15, 15)
THEME.skin.tex.CheckboxD					= GWEN.CreateTextureNormal(464, 48, 15, 15)
THEME.skin.tex.RadioButton_Checked		= GWEN.CreateTextureNormal(448, 64, 15, 15)
THEME.skin.tex.RadioButton				= GWEN.CreateTextureNormal(464, 64, 15, 15)
THEME.skin.tex.RadioButtonD_Checked		= GWEN.CreateTextureNormal(448, 80, 15, 15)
THEME.skin.tex.RadioButtonD				= GWEN.CreateTextureNormal(464, 80, 15, 15)
THEME.skin.tex.TreePlus					= GWEN.CreateTextureNormal(448, 96, 15, 15)
THEME.skin.tex.TreeMinus					= GWEN.CreateTextureNormal(464, 96, 15, 15)
THEME.skin.tex.TextBox					= GWEN.CreateTextureBorder(0, 150, 127, 21, 4, 4, 4, 4)
THEME.skin.tex.TextBox_Focus				= GWEN.CreateTextureBorder(0, 172, 127, 21, 4, 4, 4, 4)
THEME.skin.tex.TextBox_Disabled			= GWEN.CreateTextureBorder(0, 194, 127, 21, 4, 4, 4, 4)
THEME.skin.tex.MenuBG_Column				= GWEN.CreateTextureBorder(128, 128, 127, 63, 24, 8, 8, 8)
THEME.skin.tex.MenuBG						= GWEN.CreateTextureBorder(128, 192, 127, 63, 8, 8, 8, 8)
THEME.skin.tex.MenuBG_Hover				= GWEN.CreateTextureBorder(128, 256, 127, 31, 8, 8, 8, 8)
THEME.skin.tex.MenuBG_Spacer				= GWEN.CreateTextureNormal(128, 288, 127, 3)
THEME.skin.tex.Menu_Strip					= GWEN.CreateTextureBorder(0, 128, 127, 21, 8, 8, 8, 8)
THEME.skin.tex.Menu_Check					= GWEN.CreateTextureNormal(448, 112, 15, 15)
THEME.skin.tex.Tab_Control				= GWEN.CreateTextureBorder(0, 256, 127, 127, 8, 8, 8, 8)
THEME.skin.tex.TabB_Active				= GWEN.CreateTextureBorder(0,		416, 63, 31, 8, 8, 8, 8)
THEME.skin.tex.TabB_Inactive				= GWEN.CreateTextureBorder(128,	416, 63, 31, 8, 8, 8, 8)
THEME.skin.tex.TabT_Active				= GWEN.CreateTextureBorder(0,		384, 63, 31, 8, 8, 8, 8)
THEME.skin.tex.TabT_Inactive				= GWEN.CreateTextureBorder(128,	384, 63, 31, 8, 8, 8, 8)
THEME.skin.tex.TabL_Active				= GWEN.CreateTextureBorder(64,		384, 31, 63, 8, 8, 8, 8)
THEME.skin.tex.TabL_Inactive				= GWEN.CreateTextureBorder(64+128, 384, 31, 63, 8, 8, 8, 8)
THEME.skin.tex.TabR_Active				= GWEN.CreateTextureBorder(96,		384, 31, 63, 8, 8, 8, 8)
THEME.skin.tex.TabR_Inactive				= GWEN.CreateTextureBorder(96+128, 384, 31, 63, 8, 8, 8, 8)
THEME.skin.tex.Tab_Bar					= GWEN.CreateTextureBorder(128, 352, 127, 31, 4, 4, 4, 4)

THEME.skin.tex.Window = {}

THEME.skin.tex.Window.Normal			= GWEN.CreateTextureBorder(0, 0, 127, 127, 8, 32, 8, 8)
THEME.skin.tex.Window.Inactive		= GWEN.CreateTextureBorder(128, 0, 127, 127, 8, 32, 8, 8)

THEME.skin.tex.Window.Close			= GWEN.CreateTextureNormal(32, 448, 31, 31)
THEME.skin.tex.Window.Close_Hover		= GWEN.CreateTextureNormal(64, 448, 31, 31)
THEME.skin.tex.Window.Close_Down		= GWEN.CreateTextureNormal(96, 448, 31, 31)

THEME.skin.tex.Window.Maxi			= GWEN.CreateTextureNormal(32 + 96 * 2, 448, 31, 31)
THEME.skin.tex.Window.Maxi_Hover		= GWEN.CreateTextureNormal(64 + 96 * 2, 448, 31, 31)
THEME.skin.tex.Window.Maxi_Down		= GWEN.CreateTextureNormal(96 + 96 * 2, 448, 31, 31)

THEME.skin.tex.Window.Restore			= GWEN.CreateTextureNormal(32 + 96 * 2, 448 + 32, 31, 31)
THEME.skin.tex.Window.Restore_Hover	= GWEN.CreateTextureNormal(64 + 96 * 2, 448 + 32, 31, 31)
THEME.skin.tex.Window.Restore_Down	= GWEN.CreateTextureNormal(96 + 96 * 2, 448 + 32, 31, 31)

THEME.skin.tex.Window.Mini			= GWEN.CreateTextureNormal(32 + 96, 448, 31, 31)
THEME.skin.tex.Window.Mini_Hover		= GWEN.CreateTextureNormal(64 + 96, 448, 31, 31)
THEME.skin.tex.Window.Mini_Down		= GWEN.CreateTextureNormal(96 + 96, 448, 31, 31)

THEME.skin.tex.Scroller = {}
THEME.skin.tex.Scroller.TrackV				= GWEN.CreateTextureBorder(384,		208, 15, 127, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonV_Normal		= GWEN.CreateTextureBorder(384 + 16,	208, 15, 127, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonV_Hover			= GWEN.CreateTextureBorder(384 + 32,	208, 15, 127, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonV_Down			= GWEN.CreateTextureBorder(384 + 48,	208, 15, 127, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonV_Disabled		= GWEN.CreateTextureBorder(384 + 64,	208, 15, 127, 4, 4, 4, 4)

THEME.skin.tex.Scroller.TrackH				= GWEN.CreateTextureBorder(384, 128,		127, 15, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonH_Normal		= GWEN.CreateTextureBorder(384, 128 + 16,	127, 15, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonH_Hover			= GWEN.CreateTextureBorder(384, 128 + 32,	127, 15, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonH_Down			= GWEN.CreateTextureBorder(384, 128 + 48,	127, 15, 4, 4, 4, 4)
THEME.skin.tex.Scroller.ButtonH_Disabled		= GWEN.CreateTextureBorder(384, 128 + 64,	127, 15, 4, 4, 4, 4)

THEME.skin.tex.Scroller.LeftButton_Normal		= GWEN.CreateTextureBorder(464,		208, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.LeftButton_Hover		= GWEN.CreateTextureBorder(480,		208, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.LeftButton_Down		= GWEN.CreateTextureBorder(464,		272, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.LeftButton_Disabled	= GWEN.CreateTextureBorder(480 + 48,	272, 15, 15, 2, 2, 2, 2)

THEME.skin.tex.Scroller.UpButton_Normal		= GWEN.CreateTextureBorder(464,		208 + 16, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.UpButton_Hover		= GWEN.CreateTextureBorder(480,		208 + 16, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.UpButton_Down			= GWEN.CreateTextureBorder(464,		272 + 16, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.UpButton_Disabled		= GWEN.CreateTextureBorder(480 + 48,	272 + 16, 15, 15, 2, 2, 2, 2)

THEME.skin.tex.Scroller.RightButton_Normal	= GWEN.CreateTextureBorder(464,		208 + 32, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.RightButton_Hover		= GWEN.CreateTextureBorder(480,		208 + 32, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.RightButton_Down		= GWEN.CreateTextureBorder(464,		272 + 32, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.RightButton_Disabled	= GWEN.CreateTextureBorder(480 + 48,	272 + 32, 15, 15, 2, 2, 2, 2)

THEME.skin.tex.Scroller.DownButton_Normal		= GWEN.CreateTextureBorder(464,		208 + 48, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.DownButton_Hover		= GWEN.CreateTextureBorder(480,		208 + 48, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.DownButton_Down		= GWEN.CreateTextureBorder(464,		272 + 48, 15, 15, 2, 2, 2, 2)
THEME.skin.tex.Scroller.DownButton_Disabled	= GWEN.CreateTextureBorder(480 + 48,	272 + 48, 15, 15, 2, 2, 2, 2)

THEME.skin.tex.Menu = {}
THEME.skin.tex.Menu.RightArrow = GWEN.CreateTextureNormal(464, 112, 15, 15)

THEME.skin.tex.Input = {}

THEME.skin.tex.Input.ComboBox = {}
THEME.skin.tex.Input.ComboBox.Normal		= GWEN.CreateTextureBorder(384, 336,	127, 31, 8, 8, 32, 8)
THEME.skin.tex.Input.ComboBox.Hover		= GWEN.CreateTextureBorder(384, 336+32, 127, 31, 8, 8, 32, 8)
THEME.skin.tex.Input.ComboBox.Down		= GWEN.CreateTextureBorder(384, 336+64, 127, 31, 8, 8, 32, 8)
THEME.skin.tex.Input.ComboBox.Disabled	= GWEN.CreateTextureBorder(384, 336+96, 127, 31, 8, 8, 32, 8)

THEME.skin.tex.Input.ComboBox.Button = {}
THEME.skin.tex.Input.ComboBox.Button.Normal	= GWEN.CreateTextureNormal(496, 272, 15, 15)
THEME.skin.tex.Input.ComboBox.Button.Hover	= GWEN.CreateTextureNormal(496, 272+16, 15, 15)
THEME.skin.tex.Input.ComboBox.Button.Down		= GWEN.CreateTextureNormal(496, 272+32, 15, 15)
THEME.skin.tex.Input.ComboBox.Button.Disabled	= GWEN.CreateTextureNormal(496, 272+48, 15, 15)

THEME.skin.tex.Input.UpDown = {}
THEME.skin.tex.Input.UpDown.Up = {}
THEME.skin.tex.Input.UpDown.Up.Normal		= GWEN.CreateTextureCentered(384,		112, 7, 7)
THEME.skin.tex.Input.UpDown.Up.Hover		= GWEN.CreateTextureCentered(384+8,	112, 7, 7)
THEME.skin.tex.Input.UpDown.Up.Down		= GWEN.CreateTextureCentered(384+16,	112, 7, 7)
THEME.skin.tex.Input.UpDown.Up.Disabled	= GWEN.CreateTextureCentered(384+24,	112, 7, 7)

THEME.skin.tex.Input.UpDown.Down = {}
THEME.skin.tex.Input.UpDown.Down.Normal	= GWEN.CreateTextureCentered(384,		120, 7, 7)
THEME.skin.tex.Input.UpDown.Down.Hover	= GWEN.CreateTextureCentered(384+8,	120, 7, 7)
THEME.skin.tex.Input.UpDown.Down.Down		= GWEN.CreateTextureCentered(384+16,	120, 7, 7)
THEME.skin.tex.Input.UpDown.Down.Disabled	= GWEN.CreateTextureCentered(384+24,	120, 7, 7)

THEME.skin.tex.Input.Slider = {}
THEME.skin.tex.Input.Slider.H = {}
THEME.skin.tex.Input.Slider.H.Normal		= GWEN.CreateTextureNormal(416, 32,	15, 15)
THEME.skin.tex.Input.Slider.H.Hover		= GWEN.CreateTextureNormal(416, 32+16, 15, 15)
THEME.skin.tex.Input.Slider.H.Down		= GWEN.CreateTextureNormal(416, 32+32, 15, 15)
THEME.skin.tex.Input.Slider.H.Disabled	= GWEN.CreateTextureNormal(416, 32+48, 15, 15)

THEME.skin.tex.Input.Slider.V = {}
THEME.skin.tex.Input.Slider.V.Normal		= GWEN.CreateTextureNormal(416+16, 32, 15, 15)
THEME.skin.tex.Input.Slider.V.Hover		= GWEN.CreateTextureNormal(416+16, 32+16, 15, 15)
THEME.skin.tex.Input.Slider.V.Down		= GWEN.CreateTextureNormal(416+16, 32+32, 15, 15)
THEME.skin.tex.Input.Slider.V.Disabled	= GWEN.CreateTextureNormal(416+16, 32+48, 15, 15)

THEME.skin.tex.Input.ListBox = {}
THEME.skin.tex.Input.ListBox.Background		= GWEN.CreateTextureBorder(256, 256, 63, 127, 8, 8, 8, 8)
THEME.skin.tex.Input.ListBox.Hovered			= GWEN.CreateTextureBorder(320, 320, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Input.ListBox.EvenLine			= GWEN.CreateTextureBorder(352, 256, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Input.ListBox.OddLine			= GWEN.CreateTextureBorder(352, 288, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Input.ListBox.EvenLineSelected	= GWEN.CreateTextureBorder(320, 256, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.Input.ListBox.OddLineSelected	= GWEN.CreateTextureBorder(320, 288, 31, 31, 8, 8, 8, 8)

THEME.skin.tex.ProgressBar = {}
THEME.skin.tex.ProgressBar.Back	= GWEN.CreateTextureBorder(384,	0, 31, 31, 8, 8, 8, 8)
THEME.skin.tex.ProgressBar.Front	= GWEN.CreateTextureBorder(384+32, 0, 31, 31, 8, 8, 8, 8)

THEME.skin.tex.CategoryList = {}
THEME.skin.tex.CategoryList.Outer		= GWEN.CreateTextureBorder(256, 384, 63, 63, 8, 8, 8, 8)
THEME.skin.tex.CategoryList.Inner		= GWEN.CreateTextureBorder(320, 384, 63, 63, 8, 21, 8, 8)
THEME.skin.tex.CategoryList.Header	= GWEN.CreateTextureBorder(320, 352, 63, 31, 8, 8, 8, 8)

THEME.skin.tex.Tooltip = GWEN.CreateTextureBorder(384, 64, 31, 31, 8, 8, 8, 8)

THEME.skin.Colours = {}

THEME.skin.Colours.Window = {}
THEME.skin.Colours.Window.TitleActive		= GWEN.TextureColor(4 + 8 * 0, 508)
THEME.skin.Colours.Window.TitleInactive	= GWEN.TextureColor(4 + 8 * 1, 508)

THEME.skin.Colours.Button = {}
THEME.skin.Colours.Button.Normal			= GWEN.TextureColor(4 + 8 * 2, 508)
THEME.skin.Colours.Button.Hover			= GWEN.TextureColor(4 + 8 * 3, 508)
THEME.skin.Colours.Button.Down			= GWEN.TextureColor(4 + 8 * 2, 500)
THEME.skin.Colours.Button.Disabled		= GWEN.TextureColor(4 + 8 * 3, 500)

THEME.skin.Colours.Tab = {}
THEME.skin.Colours.Tab.Active = {}
THEME.skin.Colours.Tab.Active.Normal		= GWEN.TextureColor(4 + 8 * 4, 508)
THEME.skin.Colours.Tab.Active.Hover		= GWEN.TextureColor(4 + 8 * 5, 508)
THEME.skin.Colours.Tab.Active.Down		= GWEN.TextureColor(4 + 8 * 4, 500)
THEME.skin.Colours.Tab.Active.Disabled	= GWEN.TextureColor(4 + 8 * 5, 500)

THEME.skin.Colours.Tab.Inactive = {}
THEME.skin.Colours.Tab.Inactive.Normal	= GWEN.TextureColor(4 + 8 * 6, 508)
THEME.skin.Colours.Tab.Inactive.Hover		= GWEN.TextureColor(4 + 8 * 7, 508)
THEME.skin.Colours.Tab.Inactive.Down		= GWEN.TextureColor(4 + 8 * 6, 500)
THEME.skin.Colours.Tab.Inactive.Disabled	= GWEN.TextureColor(4 + 8 * 7, 500)

THEME.skin.Colours.Label = {}
THEME.skin.Colours.Label.Default			= GWEN.TextureColor(4 + 8 * 8, 508)
THEME.skin.Colours.Label.Bright			= GWEN.TextureColor(4 + 8 * 9, 508)
THEME.skin.Colours.Label.Dark				= GWEN.TextureColor(4 + 8 * 8, 500)
THEME.skin.Colours.Label.Highlight		= GWEN.TextureColor(4 + 8 * 9, 500)

THEME.skin.Colours.Tree = {}
THEME.skin.Colours.Tree.Lines				= GWEN.TextureColor(4 + 8 * 10, 508) ---- !!!
THEME.skin.Colours.Tree.Normal			= GWEN.TextureColor(4 + 8 * 11, 508)
THEME.skin.Colours.Tree.Hover				= GWEN.TextureColor(4 + 8 * 10, 500)
THEME.skin.Colours.Tree.Selected			= GWEN.TextureColor(4 + 8 * 11, 500)

THEME.skin.Colours.Properties = {}
THEME.skin.Colours.Properties.Line_Normal			= GWEN.TextureColor(4 + 8 * 12, 508)
THEME.skin.Colours.Properties.Line_Selected		= GWEN.TextureColor(4 + 8 * 13, 508)
THEME.skin.Colours.Properties.Line_Hover			= GWEN.TextureColor(4 + 8 * 12, 500)
THEME.skin.Colours.Properties.Title				= GWEN.TextureColor(4 + 8 * 13, 500)
THEME.skin.Colours.Properties.Column_Normal		= GWEN.TextureColor(4 + 8 * 14, 508)
THEME.skin.Colours.Properties.Column_Selected		= GWEN.TextureColor(4 + 8 * 15, 508)
THEME.skin.Colours.Properties.Column_Hover		= GWEN.TextureColor(4 + 8 * 14, 500)
THEME.skin.Colours.Properties.Border				= GWEN.TextureColor(4 + 8 * 15, 500)
THEME.skin.Colours.Properties.Label_Normal		= GWEN.TextureColor(4 + 8 * 16, 508)
THEME.skin.Colours.Properties.Label_Selected		= GWEN.TextureColor(4 + 8 * 17, 508)
THEME.skin.Colours.Properties.Label_Hover			= GWEN.TextureColor(4 + 8 * 16, 500)

THEME.skin.Colours.Category = {}
THEME.skin.Colours.Category.Header				= GWEN.TextureColor(4 + 8 * 18, 500)
THEME.skin.Colours.Category.Header_Closed			= GWEN.TextureColor(4 + 8 * 19, 500)
THEME.skin.Colours.Category.Line = {}
THEME.skin.Colours.Category.Line.Text				= GWEN.TextureColor(4 + 8 * 20, 508)
THEME.skin.Colours.Category.Line.Text_Hover		= GWEN.TextureColor(4 + 8 * 21, 508)
THEME.skin.Colours.Category.Line.Text_Selected	= GWEN.TextureColor(4 + 8 * 20, 500)
THEME.skin.Colours.Category.Line.Button			= GWEN.TextureColor(4 + 8 * 21, 500)
THEME.skin.Colours.Category.Line.Button_Hover		= GWEN.TextureColor(4 + 8 * 22, 508)
THEME.skin.Colours.Category.Line.Button_Selected	= GWEN.TextureColor(4 + 8 * 23, 508)
THEME.skin.Colours.Category.LineAlt = {}
THEME.skin.Colours.Category.LineAlt.Text				= GWEN.TextureColor(4 + 8 * 22, 500)
THEME.skin.Colours.Category.LineAlt.Text_Hover		= GWEN.TextureColor(4 + 8 * 23, 500)
THEME.skin.Colours.Category.LineAlt.Text_Selected		= GWEN.TextureColor(4 + 8 * 24, 508)
THEME.skin.Colours.Category.LineAlt.Button			= GWEN.TextureColor(4 + 8 * 25, 508)
THEME.skin.Colours.Category.LineAlt.Button_Hover		= GWEN.TextureColor(4 + 8 * 24, 500)
THEME.skin.Colours.Category.LineAlt.Button_Selected	= GWEN.TextureColor(4 + 8 * 25, 500)

THEME.skin.Colours.TooltipText = GWEN.TextureColor(4 + 8 * 26, 500)

--[[---------------------------------------------------------
	Panel
-----------------------------------------------------------]]
function THEME.skin:PaintPanel(panel, w, h)
	if (!panel.m_bBackground) then return end
	self.tex.Panels.Normal(0, 0, w, h, panel.m_bgColor)
end

--[[---------------------------------------------------------
	Panel
-----------------------------------------------------------]]
function THEME.skin:PaintShadow(panel, w, h)
	THEME.skin.tex.Shadow(0, 0, w, h)
end

--[[---------------------------------------------------------
	Frame
-----------------------------------------------------------]]
function THEME.skin:PaintFrame(panel, w, h)
	if (panel.m_bPaintShadow) then
		DisableClipping(true)
		THEME.skin.tex.Shadow(-4, -4, w+10, h+10)
		DisableClipping(false)
	end
	if (panel:HasHierarchicalFocus()) then
		self.tex.Window.Normal(0, 0, w, h)
	else
		self.tex.Window.Inactive(0, 0, w, h)
	end
end

--[[---------------------------------------------------------
	Button
-----------------------------------------------------------]]
function THEME.skin:PaintButton(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel.Depressed || panel:IsSelected() || panel:GetToggle()) then
		return self.tex.Button_Down(0, 0, w, h)
	end

	if (panel:GetDisabled()) then
		return self.tex.Button_Dead(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Button_Hovered(0, 0, w, h)
	end

	self.tex.Button(0, 0, w, h)
end

--[[---------------------------------------------------------
	Tree
-----------------------------------------------------------]]
function THEME.skin:PaintTree(panel, w, h)
	if (!panel.m_bBackground) then return end
	self.tex.Tree(0, 0, w, h, panel.m_bgColor)
end

--[[---------------------------------------------------------
	CheckBox
-----------------------------------------------------------]]
function THEME.skin:PaintCheckBox(panel, w, h)
	if (panel:GetChecked()) then
		if (panel:GetDisabled()) then
			self.tex.CheckboxD_Checked(0, 0, w, h)
		else
			self.tex.Checkbox_Checked(0, 0, w, h)
		end
	else
		if (panel:GetDisabled()) then
			self.tex.CheckboxD(0, 0, w, h)
		else
			self.tex.Checkbox(0, 0, w, h)
		end
	end
end

--[[---------------------------------------------------------
	ExpandButton
-----------------------------------------------------------]]
function THEME.skin:PaintExpandButton(panel, w, h)
	if (!panel:GetExpanded()) then
		self.tex.TreePlus(0, 0, w, h)
	else
		self.tex.TreeMinus(0, 0, w, h)
	end
end

--[[---------------------------------------------------------
	TextEntry
-----------------------------------------------------------]]
function THEME.skin:PaintTextEntry(panel, w, h)

	if (panel.m_bBackground) then
		if (panel:GetDisabled()) then
			self.tex.TextBox_Disabled(0, 0, w, h)
		elseif (panel:HasFocus()) then
			self.tex.TextBox_Focus(0, 0, w, h)
		else
			self.tex.TextBox(0, 0, w, h)
		end
	end

	panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor())
end

--[[---------------------------------------------------------
	Menu
-----------------------------------------------------------]]
function THEME.skin:PaintMenu(panel, w, h)
	if (panel:GetDrawColumn()) then
		self.tex.MenuBG_Column(0, 0, w, h)
	else
		self.tex.MenuBG(0, 0, w, h)
	end
end

--[[---------------------------------------------------------
	Menu
-----------------------------------------------------------]]
function THEME.skin:PaintMenuSpacer(panel, w, h)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	surface.DrawRect(0, 0, w, h)
end

--[[---------------------------------------------------------
	MenuOption
-----------------------------------------------------------]]
function THEME.skin:PaintMenuOption(panel, w, h)
	if (panel.m_bBackground && (panel.Hovered || panel.Highlight)) then
		self.tex.MenuBG_Hover(0, 0, w, h)
	end

	if (panel:GetChecked()) then
		self.tex.Menu_Check(5, h/2-7, 15, 15)
	end
end

--[[---------------------------------------------------------
	MenuRightArrow
-----------------------------------------------------------]]
function THEME.skin:PaintMenuRightArrow(panel, w, h)
	self.tex.Menu.RightArrow(0, 0, w, h)
end

--[[---------------------------------------------------------
	PropertySheet
-----------------------------------------------------------]]
function THEME.skin:PaintPropertySheet(panel, w, h)
	-- TODO: Tabs at bottom, left, right
	local ActiveTab = panel:GetActiveTab()
	local Offset = 0

	if (ActiveTab) then Offset = ActiveTab:GetTall() - 8 end

	self.tex.Tab_Control(0, Offset, w, h - Offset)
end

--[[---------------------------------------------------------
	Tab
-----------------------------------------------------------]]
function THEME.skin:PaintTab(panel, w, h)
	surface.SetDrawColor(255, 0, 255)
	surface.DrawRect(0, 0, w, h)
end

function THEME.skin:PaintActiveTab(panel, w, h)
	self.tex.TabT_Active(0, 0, w, h - 2)
end

--[[---------------------------------------------------------
	Button
-----------------------------------------------------------]]
function THEME.skin:PaintWindowCloseButton(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel:GetDisabled()) then
		return self.tex.Window.Close(0, 0, w, h, Color(255, 255, 255, 50))
	end

	if (panel.Depressed || panel:IsSelected()) then
		return self.tex.Window.Close_Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Window.Close_Hover(0, 0, w, h)
	end

	self.tex.Window.Close(0, 0, w, h)
end

function THEME.skin:PaintWindowMinimizeButton(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel:GetDisabled()) then
		return self.tex.Window.Mini(0, 0, w, h, Color(255, 255, 255, 50))
	end

	if (panel.Depressed || panel:IsSelected()) then
		return self.tex.Window.Mini_Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Window.Mini_Hover(0, 0, w, h)
	end

	self.tex.Window.Mini(0, 0, w, h)
end

function THEME.skin:PaintWindowMaximizeButton(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel:GetDisabled()) then
		return self.tex.Window.Maxi(0, 0, w, h, Color(255, 255, 255, 50))
	end

	if (panel.Depressed || panel:IsSelected()) then
		return self.tex.Window.Maxi_Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Window.Maxi_Hover(0, 0, w, h)
	end

	self.tex.Window.Maxi(0, 0, w, h)
end

--[[---------------------------------------------------------
	VScrollBar
-----------------------------------------------------------]]
function THEME.skin:PaintVScrollBar(panel, w, h)
	self.tex.Scroller.TrackV(0, 0, w, h)
end

--[[---------------------------------------------------------
	ScrollBarGrip
-----------------------------------------------------------]]
function THEME.skin:PaintScrollBarGrip(panel, w, h)
	if (panel:GetDisabled()) then
		return self.tex.Scroller.ButtonV_Disabled(0, 0, w, h)
	end

	if (panel.Depressed) then
		return self.tex.Scroller.ButtonV_Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Scroller.ButtonV_Hover(0, 0, w, h)
	end

	return self.tex.Scroller.ButtonV_Normal(0, 0, w, h)
end

--[[---------------------------------------------------------
	ButtonDown
-----------------------------------------------------------]]
function THEME.skin:PaintButtonDown(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel.Depressed || panel:IsSelected()) then
		return self.tex.Scroller.DownButton_Down(0, 0, w, h)
	end

	if (panel:GetDisabled()) then
		return self.tex.Scroller.DownButton_Dead(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Scroller.DownButton_Hover(0, 0, w, h)
	end

	self.tex.Scroller.DownButton_Normal(0, 0, w, h)
end

--[[---------------------------------------------------------
	ButtonUp
-----------------------------------------------------------]]
function THEME.skin:PaintButtonUp(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel.Depressed || panel:IsSelected()) then
		return self.tex.Scroller.UpButton_Down(0, 0, w, h)
	end
	if (panel:GetDisabled()) then
		return self.tex.Scroller.UpButton_Dead(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Scroller.UpButton_Hover(0, 0, w, h)
	end

	self.tex.Scroller.UpButton_Normal(0, 0, w, h)
end

--[[---------------------------------------------------------
	ButtonLeft
-----------------------------------------------------------]]
function THEME.skin:PaintButtonLeft(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel.Depressed || panel:IsSelected()) then
		return self.tex.Scroller.LeftButton_Down(0, 0, w, h)
	end

	if (panel:GetDisabled()) then
		return self.tex.Scroller.LeftButton_Dead(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Scroller.LeftButton_Hover(0, 0, w, h)
	end

	self.tex.Scroller.LeftButton_Normal(0, 0, w, h)
end

--[[---------------------------------------------------------
	ButtonRight
-----------------------------------------------------------]]
function THEME.skin:PaintButtonRight(panel, w, h)
	if (!panel.m_bBackground) then return end

	if (panel.Depressed || panel:IsSelected()) then
		return self.tex.Scroller.RightButton_Down(0, 0, w, h)
	end

	if (panel:GetDisabled()) then
		return self.tex.Scroller.RightButton_Dead(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Scroller.RightButton_Hover(0, 0, w, h)
	end

	self.tex.Scroller.RightButton_Normal(0, 0, w, h)
end

--[[---------------------------------------------------------
	ComboDownArrow
-----------------------------------------------------------]]
function THEME.skin:PaintComboDownArrow(panel, w, h)
	if (panel.ComboBox:GetDisabled()) then
		return self.tex.Input.ComboBox.Button.Disabled(0, 0, w, h)
	end

	if (panel.ComboBox.Depressed || panel.ComboBox:IsMenuOpen()) then
		return self.tex.Input.ComboBox.Button.Down(0, 0, w, h)
	end

	if (panel.ComboBox.Hovered) then
		return self.tex.Input.ComboBox.Button.Hover(0, 0, w, h)
	end

	self.tex.Input.ComboBox.Button.Normal(0, 0, w, h)
end

--[[---------------------------------------------------------
	ComboBox
-----------------------------------------------------------]]
function THEME.skin:PaintComboBox(panel, w, h)
	if (panel:GetDisabled()) then
		return self.tex.Input.ComboBox.Disabled(0, 0, w, h)
	end

	if (panel.Depressed || panel:IsMenuOpen()) then
		return self.tex.Input.ComboBox.Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Input.ComboBox.Hover(0, 0, w, h)
	end

	self.tex.Input.ComboBox.Normal(0, 0, w, h)
end
--[[---------------------------------------------------------
	ComboBox
-----------------------------------------------------------]]
function THEME.skin:PaintListBox(panel, w, h)
	self.tex.Input.ListBox.Background(0, 0, w, h)
end
--[[---------------------------------------------------------
	NumberUp
-----------------------------------------------------------]]
function THEME.skin:PaintNumberUp(panel, w, h)
	if (panel:GetDisabled()) then
		return self.tex.Input.UpDown.Up.Disabled(0, 0, w, h)
	end

	if (panel.Depressed) then
		return self.tex.Input.UpDown.Up.Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Input.UpDown.Up.Hover(0, 0, w, h)
	end

	self.tex.Input.UpDown.Up.Normal(0, 0, w, h)
end

--[[---------------------------------------------------------
	NumberDown
-----------------------------------------------------------]]
function THEME.skin:PaintNumberDown(panel, w, h)
	if (panel:GetDisabled()) then
		return self.tex.Input.UpDown.Down.Disabled(0, 0, w, h)
	end

	if (panel.Depressed) then
		return self.tex.Input.UpDown.Down.Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Input.UpDown.Down.Hover(0, 0, w, h)
	end

	self.tex.Input.UpDown.Down.Normal(0, 0, w, h)
end

function THEME.skin:PaintTreeNode(panel, w, h)
	if (!panel.m_bDrawLines) then return end

	surface.SetDrawColor(self.Colours.Tree.Lines)

	if (panel.m_bLastChild) then
		surface.DrawRect(9, 0, 1, 7)
		surface.DrawRect(9, 7, 9, 1)
	else
		surface.DrawRect(9, 0, 1, h)
		surface.DrawRect(9, 7, 9, 1)
	end
end

function THEME.skin:PaintTreeNodeButton(panel, w, h)
	if (!panel.m_bSelected) then return end

	-- Don't worry this isn't working out the size every render
	-- it just gets the cached value from inside the Label
	local w, _ = panel:GetTextSize()
	self.tex.Selection(38, 0, w + 6, h)
end

function THEME.skin:PaintSelection(panel, w, h)
	self.tex.Selection(0, 0, w, h)
end

function THEME.skin:PaintSliderKnob(panel, w, h)
	if (panel:GetDisabled()) then
		return self.tex.Input.Slider.H.Disabled(0, 0, w, h)
	end

	if (panel.Depressed) then
		return self.tex.Input.Slider.H.Down(0, 0, w, h)
	end

	if (panel.Hovered) then
		return self.tex.Input.Slider.H.Hover(0, 0, w, h)
	end

	self.tex.Input.Slider.H.Normal(0, 0, w, h)
end

local function PaintNotches(x, y, w, h, num)
	if (!num) then return end
	local space = w / num
	for i=0, num do
		surface.DrawRect(x + i * space, y + 4, 1, 5)
	end
end

function THEME.skin:PaintNumSlider(panel, w, h)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	surface.DrawRect(8, h / 2 - 1, w - 15, 1)
	PaintNotches(8, h / 2 - 1, w - 16, 1, panel.m_iNotches)
end

function THEME.skin:PaintProgress(panel, w, h)
	self.tex.ProgressBar.Back(0, 0, w, h)
	self.tex.ProgressBar.Front(0, 0, w * panel:GetFraction(), h)
end

function THEME.skin:PaintCollapsibleCategory(panel, w, h)
	if (h < 21) then
		return self.tex.CategoryList.Header(0, 0, w, h)
	end

	self.tex.CategoryList.Inner(0, 0, w, 63)
end

function THEME.skin:PaintCategoryList(panel, w, h)
	self.tex.CategoryList.Outer(0, 0, w, h)
end

function THEME.skin:PaintCategoryButton(panel, w, h)
	if (panel.AltLine) then
		if (panel.Depressed || panel.m_bSelected) then surface.SetDrawColor(self.Colours.Category.LineAlt.Button_Selected)
		elseif (panel.Hovered) then surface.SetDrawColor(self.Colours.Category.LineAlt.Button_Hover)
		else surface.SetDrawColor(self.Colours.Category.LineAlt.Button) end
	else
		if (panel.Depressed || panel.m_bSelected) then surface.SetDrawColor(self.Colours.Category.Line.Button_Selected)
		elseif (panel.Hovered) then surface.SetDrawColor(self.Colours.Category.Line.Button_Hover)
		else surface.SetDrawColor(self.Colours.Category.Line.Button) end
	end

	surface.DrawRect(0, 0, w, h)
end

function THEME.skin:PaintListViewLine(panel, w, h)
	if (panel:IsSelected()) then
		self.tex.Input.ListBox.EvenLineSelected(0, 0, w, h)
	elseif (panel.Hovered) then
		self.tex.Input.ListBox.Hovered(0, 0, w, h)
	elseif (panel.m_bAlt) then
		self.tex.Input.ListBox.EvenLine(0, 0, w, h)
	end
end

function THEME.skin:PaintListView(panel, w, h)
	if (!panel.m_bBackground) then return end
	self.tex.Input.ListBox.Background(0, 0, w, h)
end

function THEME.skin:PaintTooltip(panel, w, h)
	self.tex.Tooltip(0, 0, w, h)
end

function THEME.skin:PaintMenuBar(panel, w, h)
	self.tex.Menu_Strip(0, 0, w, h)
end

derma.DefineSkin("Clockwork", "Made for Clockwork Framework.", THEME.skin)

cw.theme:Register()
