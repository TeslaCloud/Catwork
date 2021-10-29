--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("option", cw)

local keys = cw.option.keys or {}
cw.option.keys = keys

local sounds = cw.option.sounds or {}
cw.option.sounds = sounds

-- A function to set a schema key.
function cw.option:SetKey(key, value)
	keys[key] = value
end

-- A function to get a schema key.
function cw.option:GetKey(key, lowerValue)
	local value = keys[key]

	if (lowerValue and isstring(value)) then
		return string.lower(value)
	else
		return value
	end
end

-- A function to set a schema sound.
function cw.option:SetSound(name, sound)
	sounds[name] = sound
end

-- A function to get a schema sound.
function cw.option:GetSound(name)
	return sounds[name]
end

-- A function to play a schema sound.
function cw.option:PlaySound(name)
	local sound = self:GetSound(name)

	if (sound) then
		if (CLIENT) then
			surface.PlaySound(sound)
		else
			cw.player:PlaySound(nil, sound)
		end
	end
end

cw.option:SetKey("default_date", {month = 1, year = 2010, day = 1})
cw.option:SetKey("default_time", {minute = 0, hour = 0, day = 1})
cw.option:SetKey("default_days", {"#Monday", "#Tuesday", "#Wednesday", "#Thursday", "#Friday", "#Saturday", "#Sunday"})
cw.option:SetKey("description_business", "#BusinessDesc")
cw.option:SetKey("description_inventory", "#InventoryDesc")
cw.option:SetKey("description_directory", "#DirectoryDesc")
cw.option:SetKey("description_system", "#SystemDesc")
cw.option:SetKey("description_scoreboard", "#ScoreboardDesc")
cw.option:SetKey("description_attributes", "#AttributesDesc")
cw.option:SetKey("intro_background_url", "")
cw.option:SetKey("intro_logo_url", "")
cw.option:SetKey("model_shipment", "models/items/item_item_crate.mdl")
cw.option:SetKey("model_cash", "models/props_c17/briefcase001a.mdl")
cw.option:SetKey("format_singular_cash", "$%a")
cw.option:SetKey("format_cash", "$%a")
cw.option:SetKey("name_attributes", "#Attributes")
cw.option:SetKey("name_attribute", "#Attribute")
cw.option:SetKey("name_system", "#System")
cw.option:SetKey("name_scoreboard", "#Scoreboard")
cw.option:SetKey("name_directory", "#Directory")
cw.option:SetKey("name_inventory", "#Inventory")
cw.option:SetKey("name_business", "#Business")
cw.option:SetKey("name_destroy", "#Destroy")
cw.option:SetKey("schema_logo", "")
cw.option:SetKey("intro_image", "")
cw.option:SetKey("intro_sound", "music/HL2_song25_Teleporter.mp3")
cw.option:SetKey("menu_music", "music/hl2_song32.mp3")
cw.option:SetKey("name_cash", "#Cash")
cw.option:SetKey("name_drop", "#Drop")
cw.option:SetKey("top_bars", false)
cw.option:SetKey("name_use", "#Use")
cw.option:SetKey("gradient", "gui/gradient_up")

cw.option:SetSound("click_release", "ui/buttonclickrelease.wav")
cw.option:SetSound("rollover", "ui/buttonrollover.wav")
cw.option:SetSound("click", "ui/buttonclick.wav")
cw.option:SetSound("tick", "common/talk.wav")

if (CLIENT) then
	cw.option.fonts = cw.option.fonts or {}
	cw.option.colors = cw.option.colors or {}

	-- A function to set a schema color.
	function cw.option:SetColor(name, color)
		self.colors[name] = color
	end

	-- A function to get a schema color.
	function cw.option:GetColor(name)
		return self.colors[name]
	end

	-- A function to set a schema font.
	function cw.option:SetFont(name, font)
		self.fonts[name] = font
	end

	-- A function to get a schema font.
	function cw.option:GetFont(name)
		return self.fonts[name]
	end

	cw.option:SetColor("columnsheet_shadow_normal", Color(200, 200, 200, 255))
	cw.option:SetColor("columnsheet_text_normal", Color(255, 255, 255, 255))
	cw.option:SetColor("columnsheet_shadow_active", Color(150, 150, 150, 255))
	cw.option:SetColor("columnsheet_text_active", Color(200, 200, 200, 255))

	cw.option:SetColor("panel_background", Color(70, 70, 70, 255))
	cw.option:SetColor("panel_outline", Color(0, 0, 0, 255))

	cw.option:SetColor("basic_form_highlight", Color(0, 0, 0, 255))
	cw.option:SetColor("basic_form_color", Color(0, 0, 0, 255))

	cw.option:SetKey("icon_data_classes", {path = "tag", size = nil})
	cw.option:SetKey("icon_data_settings", {path = "wrench", size = nil})
	cw.option:SetKey("icon_data_system", {path = "cog", size = nil})
	cw.option:SetKey("icon_data_scoreboard", {path = "list-alt", size = 3})
	cw.option:SetKey("icon_data_inventory", {path = "inbox", size = nil})
	cw.option:SetKey("icon_data_directory", {path = "book", size = nil})
	cw.option:SetKey("icon_data_attributes", {path = "bar-chart", size = 2})
	cw.option:SetKey("icon_data_business", {path = "briefcase", size = 2})
	cw.option:SetKey("icon_data_traits", {path = "star", size = 2})

	cw.option:SetKey("top_bar_width_scale", 0.3)

	cw.option:SetKey("info_text_icon_size", 16)
	cw.option:SetKey("info_text_red_icon", "icon16/exclamation.png")
	cw.option:SetKey("info_text_green_icon", "icon16/tick.png")
	cw.option:SetKey("info_text_orange_icon", "icon16/error.png")
	cw.option:SetKey("info_text_blue_icon", "icon16/information.png")

	cw.option:SetColor("scoreboard_name", Color(0, 0, 0, 255))
	cw.option:SetColor("scoreboard_desc", Color(0, 0, 0, 255))

	cw.option:SetColor("positive_hint", Color(100, 175, 100, 255))
	cw.option:SetColor("negative_hint", Color(175, 100, 100, 255))
	cw.option:SetColor("background", Color(0, 0, 0, 125))
	cw.option:SetColor("foreground", Color(50, 50, 50, 125))
	cw.option:SetColor("target_id", Color(50, 75, 100, 255))
	cw.option:SetColor("white", Color(255, 255, 255, 255))

	cw.option:SetColor("panel_primarycolor", Color(45, 45, 45, 255))
	cw.option:SetColor("panel_primarycolor_blur", Color(45, 45, 45, 160))
	cw.option:SetColor("panel_secondarycolor", Color("#ED6115"))
	cw.option:SetColor("panel_primarylight", Color(60, 60, 60, 255))
	cw.option:SetColor("panel_primarylighter", Color(70, 70, 70, 255))
	cw.option:SetColor("panel_primarylightest", Color(90, 90, 90, 255))
	cw.option:SetColor("panel_primarydark", Color(39, 39, 39, 255))
	cw.option:SetColor("panel_primarydarker", Color(22, 22, 22, 255))
	cw.option:SetColor("panel_primarydarkest", Color(8, 8, 8, 255))
	cw.option:SetColor("panel_textcolor", Color(240, 240, 240, 255))

	cw.option:SetFont("schema_description", "cwMainText")
	cw.option:SetFont("scoreboard_desc", "cwScoreboardDesc")
	cw.option:SetFont("scoreboard_name", "cwScoreboardName")
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
	cw.option:SetFont("hints_text", "cwIntroTextTiny")
	cw.option:SetFont("main_text", "cwMainText")
	cw.option:SetFont("bar_text", "cwMainText")
	cw.option:SetFont("esp_text", "cwESPText")
end
