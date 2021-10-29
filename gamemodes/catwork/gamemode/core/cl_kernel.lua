--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[
	Derive from Sandbox, because we want the spawn menu and such!
	We also want the base Sandbox entities and weapons.
--]]
DeriveGamemode("sandbox")

local CreateClientConVar = CreateClientConVar
local CloseDermaMenus = CloseDermaMenus
local ChangeTooltip = ChangeTooltip
local ScreenScale = ScreenScale
local FrameTime = FrameTime
local DermaMenu = DermaMenu
local ScrW = ScrW
local ScrH = ScrH
local surface = surface
local render = render
local draw = draw
local vgui = vgui
local cam = cam
local gui = gui

do
	--[[
		This is a hack to display world tips correctly based on their owner.
	--]]

	local ClockworkAddWorldTip = cw.AddWorldTip or AddWorldTip
	cw.AddWorldTip = ClockworkAddWorldTip

	function AddWorldTip(entIndex, text, dieTime, position, entity)
		local weapon = cw.client:GetActiveWeapon()

		if (IsValid(weapon) and string.lower(weapon:GetClass()) == "gmod_tool") then
			if (IsValid(entity) and entity.GetPlayerName) then
				if (cw.client:Name() == entity:GetPlayerName()) then
					ClockworkAddWorldTip(entIndex, text, dieTime, position, entity)
				end
			end
		end
	end
end

timer.Destroy("HintSystem_OpeningMenu")
timer.Destroy("HintSystem_Annoy1")
timer.Destroy("HintSystem_Annoy2")

base64 = base64 or {}

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function base64.encode(data)
	return ((data:gsub('.', function(x)
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function base64.decode(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x != 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
	end))
end

do
	local cwOldRunConsoleCommand = RunConsoleCommand

	function RunConsoleCommand(...)
		local arguments = {...}

		if (arguments[1] == nil) then
			return
		end

		cwOldRunConsoleCommand(...)
	end
end

function surface.DrawScaledText(text, font, x, y, scale, color)
	local matrix = Matrix()
	local pos = Vector(x, y)

	matrix:Translate(pos)
	matrix:Scale(Vector(1, 1, 1) * scale)
	matrix:Translate(-pos)

	cam.PushModelMatrix(matrix)
		surface.SetFont(font)
		surface.SetTextColor(color)
		surface.SetTextPos(x, y)
		surface.DrawText(text)
	cam.PopModelMatrix()
end

function surface.DrawRotatedText(text, font, x, y, angle, color)
	local matrix = Matrix()
	local pos = Vector(x, y)

	matrix:Translate(pos)
	matrix:Rotate(Angle(0, angle, 0))
	matrix:Translate(-pos)

	cam.PushModelMatrix(matrix)
		surface.SetFont(font)
		surface.SetTextColor(color)
		surface.SetTextPos(x, y)
		surface.DrawText(text)
	cam.PopModelMatrix()
end

function surface.DrawScaled(x, y, scale, callback)
	local matrix = Matrix()
	local pos = Vector(x, y)

	matrix:Translate(pos)
	matrix:Scale(Vector(1, 1, 0) * scale)
	matrix:Rotate(Angle(0, 0, 0))
	matrix:Translate(-pos)

	cam.PushModelMatrix(matrix)
		if (callback) then
			Try("DrawScaled", callback, x, y, scale)
		end
	cam.PopModelMatrix()
end

function surface.DrawRotated(x, y, angle, callback)
	local matrix = Matrix()
	local pos = Vector(x, y)

	matrix:Translate(pos)
	matrix:Rotate(Angle(0, angle, 0))
	matrix:Translate(-pos)

	cam.PushModelMatrix(matrix)
		if (callback) then
			Try("DrawRotated", callback, x, y, angle)
		end
	cam.PopModelMatrix()
end

concommand.Add("cwSay", function(player, command, arguments)
	return netstream.Start("PlayerSay", table.concat(arguments, " "))
end)

concommand.Add("cwLua", function(player, command, arguments)
	if (player:IsSuperAdmin()) then
		RunString(table.concat(arguments, " "))
		return
	end

	print("#Commands_cwLua_accessDenied:"..player:Name()..";")
end)

cw.BackgroundBlurs = cw.BackgroundBlurs or {}
cw.RecognisedNames = cw.RecognisedNames or {}
cw.NetworkProxies = cw.NetworkProxies or {}
cw.AccessoryData = cw.AccessoryData or {}
cw.InfoMenuOpen = cw.InfoMenuOpen or false
cw.ColorModify = cw.ColorModify or {}
cw.ClothesData = cw.ClothesData or {}
cw.Cinematics = cw.Cinematics or {}

cw.core.CenterHints = cw.core.CenterHints or {}
cw.core.ESPInfo = cw.core.ESPInfo or {}
cw.core.Hints = cw.core.Hints or {}

-- A function to register a network proxy.
function cw.core:RegisterNetworkProxy(entity, name, Callback)
	if (!cw.NetworkProxies[entity]) then
		cw.NetworkProxies[entity] = {}
	end

	cw.NetworkProxies[entity][name] = {
		Callback = Callback,
		oldValue = nil
	}
end

-- A function to get whether the info menu is open.
function cw.core:IsInfoMenuOpen()
	return cw.InfoMenuOpen
end

-- A function to create a client ConVar.
function cw.core:CreateClientConVar(name, value, save, userData, Callback)
	local conVar = CreateClientConVar(name, value, save, userData)

	cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
		hook.Run("ClockworkConVarChanged", conVar, previousValue, newValue)

		if (Callback) then
			Callback(conVar, previousValue, newValue)
		end
	end)

	return conVar
end

do
	local aspect = ScrW() / ScrH()

	function ScreenIsRatio(w, h)
		return (aspect == w / h)
	end
end

-- A function to scale a font size to the screen.
function cw.core:FontScreenScale(size)
	size = size * 3

	if (ScreenIsRatio(16, 10)) then
		return size * (ScrH() / 1200)
	elseif (ScreenIsRatio(4, 3)) then
		return size * (ScrH() / 1024)
	end

	return size * (ScrH() / 1080)
end

-- A function to scale a font size to the screen without multiplying.
function cw.core:HDFontScreenScale(size)
	if (ScreenIsRatio(16, 10)) then
		return size * (ScrH() / 1200)
	elseif (ScreenIsRatio(4, 3)) then
		return size * (ScrH() / 1024)
	end

	return size * (ScrH() / 1080)
end

-- A function to get a material.
function cw.core:GetMaterial(materialPath, pngParameters)
	if (typeof(materialPath) != "string") then
		return materialPath
	end

	self.CachedMaterial = self.CachedMaterial or {}

	if (!self.CachedMaterial[materialPath]) then
		self.CachedMaterial[materialPath] = Material(materialPath, pngParameters)
	end

	return self.CachedMaterial[materialPath]
end

-- A function to get the 3D font size.
function cw.core:GetFontSize3D()
	return 128
end

-- A function to get the size of text.
function cw.core:GetTextSize(font, text)
	local defaultWidth, defaultHeight = self:GetCachedTextSize(font, "U")
	local height = defaultHeight
	local width = 0
	local textLength = 0

	for i in string.gmatch(text, "([%z\1-\127\194-\244][\128-\191]*)") do
		local currentCharacter = textLength + 1
		local textWidth, textHeight = self:GetCachedTextSize(font, string.utf8sub(text, currentCharacter, currentCharacter))

		if (textWidth == 0) then
			textWidth = defaultWidth
		end

		if (textHeight > height) then
			height = textHeight
		end

		width = width + textWidth
		textLength = textLength + 1
	end

	return width, height
end

-- A function to calculate alpha from a distance.
function cw.core:CalculateAlphaFromDistance(maximum, start, finish)
	if (type(start) == "Player") then
		start = start:GetShootPos()
	elseif (type(start) == "Entity") then
		start = start:GetPos()
	end

	if (type(finish) == "Player") then
		finish = finish:GetShootPos()
	elseif (type(finish) == "Entity") then
		finish = finish:GetPos()
	end

	return math.Clamp(255 - ((255 / maximum) * (start:Distance(finish))), 0, 255)
end

-- A function to wrap text into a table.
function cw.core:WrapText(text, font, maximumWidth, baseTable)
	if (maximumWidth <= 0 or !text or text == "") then
		return
	end

	if (self:GetTextSize(font, text) > maximumWidth) then
		local currentWidth = 0
		local firstText = nil
		local secondText = nil

		for i = 0, #text do
			local currentCharacter = string.utf8sub(text, i, i)
			local currentSingleWidth = self:GetTextSize(font, currentCharacter)

			if ((currentWidth + currentSingleWidth) >= maximumWidth) then
				baseTable[#baseTable + 1] = string.utf8sub(text, 0, (i - 1))
				text = string.utf8sub(text, i)

				break
			else
				currentWidth = currentWidth + currentSingleWidth
			end
		end

		if (self:GetTextSize(font, text) > maximumWidth) then
			self:WrapText(text, font, maximumWidth, baseTable)
		else
			baseTable[#baseTable + 1] = text
		end
	else
		baseTable[#baseTable + 1] = text
	end
end

-- A function to handle an entity's menu.
function cw.core:HandleEntityMenu(entity)
	local options = {}
	local itemTable = nil

	hook.Run("GetEntityMenuOptions", entity, options)

	if (entity:GetClass() == "cw_item") then
		itemTable = entity:GetItemTable()
		if (itemTable and itemTable:IsInstance() and itemTable.GetOptions) then
			local itemOptions = itemTable:GetOptions(entity)

			for k, v in pairs(itemOptions) do
				options[k] = {
					title = k,
					name = v,
					isOptionTable = true,
					isArgTable = true
				}
			end
		end
	end

	if (table.Count(options) == 0) then return end

	if (self:GetEntityMenuType()) then
		local menuPanel = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
			if (itemTable and type(arguments) == "table" and arguments.isOptionTable) then
				menuPanel:AddOption(arguments.title, function()
					if (itemTable.HandleOptions) then
						local transmit, data = itemTable:HandleOptions(arguments.name, nil, nil, entity)

						if (transmit) then
							netstream.Start("MenuOption", {
								option = arguments.name,
								data = data,
								item = itemTable.itemID,
								entity = entity
							})
						end
					end
				end)
			else
				menuPanel:AddOption(option, function()
					if (type(arguments) == "table" and arguments.isArgTable) then
						if (arguments.Callback) then
							arguments.Callback(function(arguments)
								cw.entity:ForceMenuOption(
									entity, option, arguments
								)
							end)
						else
							cw.entity:ForceMenuOption(
								entity, option, arguments.arguments
							)
						end
					else
						cw.entity:ForceMenuOption(
							entity, option, arguments
						)
					end

					timer.Simple(FrameTime(), function()
						self:RemoveActiveToolTip()
					end)
				end)
			end

			menuPanel.Items = menuPanel:GetChildren()
			local panel = menuPanel.Items[#menuPanel.Items]

			if (IsValid(panel)) then
				if (type(arguments) == "table") then
					if (arguments.isOrdered) then
						menuPanel.Items[#menuPanel.Items] = nil
						table.insert(menuPanel.Items, 1, panel)
					end

					if (arguments.toolTip) then
						self:CreateMarkupToolTip(panel)
						panel:SetMarkupToolTip(arguments.toolTip)
					end
				end
			end
		end)

		self:RegisterBackgroundBlur(menuPanel, SysTime())
		self:SetTitledMenu(menuPanel, "ВЗАИМОДЕЙСТВИЕ")
		menuPanel.entity = entity
		cw.client.openedEnt = entity

		return menuPanel
	end
end

function draw.TexturedRect(x, y, w, h, material, color)
	if (!material) then return end

	color = (IsColor(color) and color) or Color(255, 255, 255)

	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	surface.SetMaterial(material)
	surface.DrawTexturedRect(x, y, w, h)
end

-- A function to get what type of entity menu to use.
function cw.core:GetEntityMenuType()
	return true
end

-- A function to get the gradient texture.
function cw.core:GetGradientTexture()
	return cw.GradientTexture
end

-- A function to add a menu from data.
function cw.core:AddMenuFromData(menuPanel, data, Callback, iMinimumWidth, bManualOpen)
	local bCreated = false
	local options = {}

	if (!menuPanel) then
		bCreated = true; menuPanel = DermaMenu()

		if (iMinimumWidth) then
			menuPanel:SetMinimumWidth(iMinimumWidth)
		end
	end

	for k, v in pairs(data) do
		options[#options + 1] = {k, v}
	end

	table.sort(options, function(a, b)
		return a[1] < b[1]
	end)

	for k, v in pairs(options) do
		if (type(v[2]) == "table" and !v[2].isArgTable) then
			if (table.Count(v[2]) > 0) then
				self:AddMenuFromData(menuPanel:AddSubMenu(v[1]), v[2], Callback)
			end
		elseif (type(v[2]) == "function") then
			menuPanel:AddOption(v[1], v[2])
		elseif (Callback) then
			Callback(menuPanel, v[1], v[2])
		end
	end

	if (!bCreated) then return end

	if (!bManualOpen) then
		if (#options > 0) then
			menuPanel:Open()
		else
			menuPanel:Remove()
		end
	end

	return menuPanel
end

-- A function to adjust the width of text.
function cw.core:AdjustMaximumWidth(font, text, width, addition, extra)
	local textString = tostring(self:Replace(text, "&", "U"))
	local textWidth = self:GetCachedTextSize(font, textString) + (extra or 0)

	if (textWidth > width) then
		width = textWidth + (addition or 0)
	end

	return width
end

--[[
	A function to add a center hint. If bNoSound is false then no
	sound will play, otherwise if it is a string then it will
	play that sound.
--]]
function cw.core:AddCenterHint(text, delay, color, bNoSound, showDuplicated)
	local colorWhite = cw.option:GetColor("white")

	if (color) then
		if (type(color) == "string") then
			color = cw.option:GetColor(color)
		end
	else
		color = colorWhite
	end

	if (!showDuplicated) then
		for k, v in pairs(self.CenterHints) do
			if (v.text == text) then
				return
			end
		end
	end

	if (table.Count(self.CenterHints) == 10) then
		table.remove(self.CenterHints, 10)
	end

	if (type(bNoSound) == "string") then
		surface.PlaySound(bNoSound)
	elseif (bNoSound == nil) then
		surface.PlaySound("hl1/fvox/blip.wav")
	end

	self.CenterHints[#self.CenterHints + 1] = {
		startTime = SysTime(),
		velocityX = -5,
		velocityY = 0,
		targetAlpha = 255,
		alphaSpeed = 64,
		color = color,
		delay = delay,
		alpha = 0,
		text = text,
		y = ScrH() * 0.6,
		x = ScrW() * 0.5
	}
end

local function UpdateCenterHint(index, hintInfo, iCount)
	local hintsFont = cw.option:GetFont("hints_text")
	local fontWidth, fontHeight = cw.core:GetCachedTextSize(
		hintsFont, hintInfo.text
	)
	local height = fontHeight
	local width = fontWidth
	local alpha = 255
	local x = hintInfo.x
	local y = hintInfo.y

	local idealY = (ScrH() * 0.4) + (height * (index - 1))
	local idealX = (ScrW() * 0.5) - (width * 0.5)
	local timeLeft = (hintInfo.startTime - (SysTime() - hintInfo.delay) + 2)

	if (timeLeft < 0.7) then
		idealX = idealX - 50
		alpha = 0
	end

	if (timeLeft < 0.2) then
		idealX = idealX + width * 2
	end

	local fSpeed = FrameTime() * 15
		y = y + hintInfo.velocityY * fSpeed
		x = x + hintInfo.velocityX * fSpeed
	local distanceY = idealY - y
	local distanceX = idealX - x
	local distanceA = (alpha - hintInfo.alpha)

	hintInfo.velocityY = hintInfo.velocityY + distanceY * fSpeed * 1
	hintInfo.velocityX = hintInfo.velocityX + distanceX * fSpeed * 1

	if (math.abs(distanceY) < 2 and math.abs(hintInfo.velocityY) < 0.1) then
		hintInfo.velocityY = 0
	end

	if (math.abs(distanceX) < 2 and math.abs(hintInfo.velocityX) < 0.1) then
		hintInfo.velocityX = 0
	end

	hintInfo.velocityX = hintInfo.velocityX * (0.95 - FrameTime() * 8)
	hintInfo.velocityY = hintInfo.velocityY * (0.95 - FrameTime() * 8)
	hintInfo.alpha = hintInfo.alpha + distanceA * fSpeed * 0.1
	hintInfo.x = x
	hintInfo.y = y

	return (timeLeft < 0.1)
end

--[[
	A function to add a top hint. If bNoSound is false then no
	sound will play, otherwise if it is a string then it will
	play that sound.
--]]
function cw.core:AddTopHint(text, delay, color, bNoSound, showDuplicated)
	local colorWhite = cw.option:GetColor("white")

	if (color) then
		if (type(color) == "string") then
			color = cw.option:GetColor(color)
		end
	else
		color = colorWhite
	end

	if (!showDuplicated) then
		for k, v in pairs(self.Hints) do
			if (v.text == text) then
				return
			end
		end
	end

	if (table.Count(self.Hints) == 10) then
		table.remove(self.Hints, 10)
	end

	if (type(bNoSound) == "string") then
		surface.PlaySound(bNoSound)
	elseif (bNoSound == nil) then
		surface.PlaySound("hl1/fvox/blip.wav")
	end

	self.Hints[#self.Hints + 1] = {
		startTime = SysTime(),
		velocityX = -5,
		velocityY = 0,
		targetAlpha = 255,
		alphaSpeed = 64,
		color = color,
		delay = delay,
		alpha = 0,
		text = text,
		y = ScrH() * 0.2,
		x = ScrW()
	}
end

local function UpdateHint(index, hintInfo, iCount)
	local hintsFont = cw.option:GetFont("hints_text")
	local fontWidth, fontHeight = cw.core:GetCachedTextSize(
		hintsFont, hintInfo.text
	)
	local height = fontHeight
	local width = fontWidth
	local alpha = 255
	local x = hintInfo.x
	local y = hintInfo.y

	local idealY = 24 + (height * (index - 1))
	local idealX = ScrW() - width - 48
	local timeLeft = (hintInfo.startTime - (SysTime() - hintInfo.delay) + 2)

	if (timeLeft < 0.7) then
		idealX = idealX - 50
		alpha = 0
	end

	if (timeLeft < 0.2) then
		idealX = idealX + width * 2
	end

	local fSpeed = FrameTime() * 15
		y = y + hintInfo.velocityY * fSpeed
		x = x + hintInfo.velocityX * fSpeed
	local distanceY = idealY - y
	local distanceX = idealX - x
	local distanceA = (alpha - hintInfo.alpha)

	hintInfo.velocityY = hintInfo.velocityY + distanceY * fSpeed * 1
	hintInfo.velocityX = hintInfo.velocityX + distanceX * fSpeed * 1

	if (math.abs(distanceY) < 2 and math.abs(hintInfo.velocityY) < 0.1) then
		hintInfo.velocityY = 0
	end

	if (math.abs(distanceX) < 2 and math.abs(hintInfo.velocityX) < 0.1) then
		hintInfo.velocityX = 0
	end

	hintInfo.velocityX = hintInfo.velocityX * (0.95 - FrameTime() * 8)
	hintInfo.velocityY = hintInfo.velocityY * (0.95 - FrameTime() * 8)
	hintInfo.alpha = hintInfo.alpha + distanceA * fSpeed * 0.1
	hintInfo.x = x
	hintInfo.y = y

	return (timeLeft < 0.1)
end

-- A function to calculate the hints.
function cw.core:CalculateHints()
	for k, v in pairs(self.Hints) do
		if (UpdateHint(k, v, #self.Hints)) then
			table.remove(self.Hints, k)
		end
	end

	for k, v in pairs(self.CenterHints) do
		if (UpdateCenterHint(k, v, #self.CenterHints)) then
			table.remove(self.CenterHints, k)
		end
	end
end

-- A utility function to draw text within an info block.
local function Util_DrawText(info, text, color, bCentered, sFont)
	local realWidth = 0

	if (sFont) then cw.core:OverrideMainFont(sFont); end

	if (!bCentered) then
		info.y, realWidth = cw.core:DrawInfo(
			text, info.x - (info.width / 2), info.y, color, nil, true
		)
	else
		info.y, realWidth = cw.core:DrawInfo(
			text, info.x, info.y, color
		)
	end

	if (realWidth > info.width) then
		info.width = realWidth + 16
	end

	if (sFont) then
		cw.core:OverrideMainFont(false)
	end
end

do
	local texInfo = {
		shouldDisplay = true,
		textures = {},
		names = {}
	}

	local backgroundColor = Color(255, 255, 255)
	local mainTextFont = Color(255, 255, 255)
	local colorWhite = Color(255, 255, 255)
	local colorInfo = Color(255, 255, 255)

	function cw.core:CacheLimbs()
		texInfo = {
			textures = {
				[HITGROUP_RIGHTARM] = cw.limb:GetTexture(HITGROUP_RIGHTARM),
				[HITGROUP_RIGHTLEG] = cw.limb:GetTexture(HITGROUP_RIGHTLEG),
				[HITGROUP_LEFTARM] = cw.limb:GetTexture(HITGROUP_LEFTARM),
				[HITGROUP_LEFTLEG] = cw.limb:GetTexture(HITGROUP_LEFTLEG),
				[HITGROUP_STOMACH] = cw.limb:GetTexture(HITGROUP_STOMACH),
				[HITGROUP_CHEST] = cw.limb:GetTexture(HITGROUP_CHEST),
				[HITGROUP_HEAD] = cw.limb:GetTexture(HITGROUP_HEAD),
				["body"] = cw.limb:GetTexture("body")
			},
			names = {
				[HITGROUP_RIGHTARM] = cw.limb:GetName(HITGROUP_RIGHTARM),
				[HITGROUP_RIGHTLEG] = cw.limb:GetName(HITGROUP_RIGHTLEG),
				[HITGROUP_LEFTARM] = cw.limb:GetName(HITGROUP_LEFTARM),
				[HITGROUP_LEFTLEG] = cw.limb:GetName(HITGROUP_LEFTLEG),
				[HITGROUP_STOMACH] = cw.limb:GetName(HITGROUP_STOMACH),
				[HITGROUP_CHEST] = cw.limb:GetName(HITGROUP_CHEST),
				[HITGROUP_HEAD] = cw.limb:GetName(HITGROUP_HEAD),
			}
		}

		backgroundColor = cw.option:GetColor("background")
		mainTextFont = cw.option:GetFont("main_text")
		colorWhite = cw.option:GetColor("white")
		colorInfo = cw.option:GetColor("information")
	end

	-- A function to draw the date and time.
	function cw.core:DrawDateTime()
		local scrW = ScrW()
		local scrH = ScrH()
		local info = {
			DrawText = Util_DrawText,
			width = math.min(scrW * 0.35, 500),
			x = scrW / 2,
			y = scrH * 0.2
		}

		info.originalX = info.x
		info.originalY = info.y

		if (cw.LastDateTimeInfo and cw.LastDateTimeInfo.y > info.y) then
			local height = (cw.LastDateTimeInfo.y - info.y) + 8
			local width = cw.LastDateTimeInfo.width + 16
			local x = cw.LastDateTimeInfo.x - (cw.LastDateTimeInfo.width / 2) - 8
			local y = cw.LastDateTimeInfo.y - height - 8

			self:OverrideMainFont(cw.option:GetFont("menu_text_tiny"))
			self:DrawInfo("#InfoMenu_Title", x, y + 4, colorInfo, nil, true, function(x, y, width, height)
				return x, y - height
			end)

			cdraw.DrawBox(x, y + 8, width, height, backgroundColor)
			y = y + height + 16

			if (self:CanCreateInfoMenuPanel() and self:IsInfoMenuOpen()) then
				local menuPanelX = x
				local menuPanelY = y

				self:DrawInfo("#InfoMenu_SelectOption", x, y, colorInfo, nil, true, function(x, y, width, height)
					menuPanelY = menuPanelY + height + 8

					return x, y
				end)

				self:CreateInfoMenuPanel(menuPanelX, menuPanelY, width)

				local menuWide, menuTall = cw.InfoMenuPanel:GetWide(), cw.InfoMenuPanel:GetTall()

				cdraw.DrawBox(cw.InfoMenuPanel.x - 4, cw.InfoMenuPanel.y - 4, menuWide + 8, menuTall + 8, backgroundColor)

				--[[ Override the menu's width to fit nicely. --]]
				cw.InfoMenuPanel:SetSize(width, menuTall)
				cw.InfoMenuPanel:SetMinimumWidth(width)

				if (!cw.InfoMenuPanel.VisibilitySet) then
					cw.InfoMenuPanel.VisibilitySet = true

					timer.Simple(FrameTime() * 2, function()
						if (IsValid(cw.InfoMenuPanel)) then
							cw.InfoMenuPanel:SetVisible(true)
						end
					end)
				end

				local infoData = {
					x = menuPanelX,
					y = menuPanelY + menuTall + 16,
					width = width,
					height = height,
					Adjust = function(itable, n)
						itable.y = itable.y + n
						itable.height = itable.height + n
					end
				}

				hook.Run("PaintInfoMenuExtras", infoData)

				height = infoData.height
			end

			self:OverrideMainFont(false)
			cw.LastDateTimeInfo.height = height
		end

		if (hook.Run("PlayerCanSeeDateTime")) then
			local dateTimeFont = cw.option:GetFont("date_time_text")
			local dateString = os.date("%x")
			local timeString = cw.time:GetString()

			if (dateString and timeString) then
				local dayName = L(cw.option:GetKey("default_days")[tonumber(os.date("%w"))])
				local text = string.upper(dateString..". "..dayName..", "..timeString..".")

				self:OverrideMainFont(dateTimeFont)
					info.y = self:DrawInfo(text, info.x, info.y, colorWhite, 255)
				self:OverrideMainFont(false)
			end
		end

		self:DrawBars(info, "tab")
			cw.PlayerInfoBox = self:DrawPlayerInfo(info)
			hook.Run("PostDrawDateTimeBox", info)
		cw.LastDateTimeInfo = info

		if (!hook.Run("PlayerCanSeeLimbDamage")) then
			return
		end

		local tipHeight = 0
		local tipWidth = 0
		local limbInfo = {}
		local height = 240
		local width = 120
		local x = info.x + (info.width / 2) + 32
		local y = info.originalY + 8

		if (texInfo.shouldDisplay) then
			surface.SetDrawColor(255, 255, 255, 150)
			surface.SetMaterial(texInfo.textures["body"])
			surface.DrawTexturedRect(x, y, width, height)

			for k, v in pairs(cw.limb.hitGroups) do
				local limbHealth = cw.limb:GetHealth(k)
				local limbColor = cw.limb:GetColor(limbHealth)

				surface.SetDrawColor(limbColor.r, limbColor.g, limbColor.b, 150)
				surface.SetMaterial(texInfo.textures[k])
				surface.DrawTexturedRect(x, y, width, height)

				local idx = table.insert(limbInfo, {
					color = limbColor,
					text = L(texInfo.names[k])..": "..limbHealth.."%"
				})

				local textWidth, textHeight = self:GetCachedTextSize(mainTextFont, limbInfo[idx].text)
				tipHeight = tipHeight + textHeight + 4

				if (textWidth > tipWidth) then
					tipWidth = textWidth
				end

				limbInfo[idx].textHeight = textHeight
			end

			local mouseX = gui.MouseX()
			local mouseY = gui.MouseY()

			if (mouseX >= x and mouseX <= x + width
			and mouseY >= y and mouseY <= y + height) then
				local tipX = mouseX + 16
				local tipY = mouseY + 16

				self:DrawSimpleGradientBox(
					2, tipX - 8, tipY - 8, tipWidth + 16, tipHeight + 12, backgroundColor
				)

				for k, v in pairs(limbInfo) do
					self:DrawInfo(v.text, tipX, tipY, v.color, 255, true)

					if (k < #limbInfo) then
						tipY = tipY + v.textHeight + 4
					else
						tipY = tipY + v.textHeight
					end
				end
			end
		end
	end
end

-- A function to draw the top hints.
function cw.core:DrawHints()
	if (hook.Run("PlayerCanSeeHints") and #self.Hints > 0) then
		local hintsFont = cw.option:GetFont("hints_text")

		for k, v in pairs(self.Hints) do
			self:OverrideMainFont(hintsFont)
				self:DrawInfo(v.text, v.x, v.y, v.color, v.alpha, true)
			self:OverrideMainFont(false)
		end
	end

	if (hook.Run("PlayerCanSeeCenterHints") and #self.CenterHints > 0) then
		for k, v in pairs(self.CenterHints) do
			self:OverrideMainFont(hintsFont)
				self:DrawInfo(v.text, v.x, v.y, v.color, v.alpha, true)
			self:OverrideMainFont(false)
		end
	end
end

-- A function to draw the top bars.
function cw.core:DrawBars(info, class)
	if (hook.Run("PlayerCanSeeBars", class)) then
		local barTextFont = cw.option:GetFont("bar_text")

		cw.bars.width = info.width
		cw.bars.height = cw.bars.height or 16
		cw.bars.padding = cw.bars.padding or 20
		cw.bars.y = info.y

		if (class == "tab") then
			cw.bars.x = info.x - (info.width / 2)
		else
			cw.bars.x = info.x
		end

		cw.option:SetFont("bar_text", cw.option:GetFont("auto_bar_text"))
			for k, v in ipairs(cw.bars.stored) do
				cw.bars.y = self:DrawBar(cw.bars.x, cw.bars.y, cw.bars.width, cw.bars.height, v.color, v.text, v.value, v.maximum, v.flash, table.Copy(v)) + (cw.bars.padding + 2)
			end
		cw.option:SetFont("bar_text", barTextFont)

		info.y = cw.bars.y
	end
end

-- A function to get the ESP info.
function cw.core:GetESPInfo()
	return self.ESPInfo
end

do
	local color_red = Color(255, 0, 0)
	local color_blue = Color(0, 0, 255)
	local color_grey = Color(100, 100, 100)
	local color_white = Color(255, 255, 255)
	local color_salesmen = Color(255, 150, 0)
	local color_items = Color(0, 255, 100)
	local color_props = Color(0, 150, 255)
	local color_lightred = Color(255, 100, 100)
	local color_lightblue = Color(200, 200, 255)
	local vector_salesman_offset = Vector(0, 0, 80)

	-- A function to draw the admin ESP.
	function cw.core:DrawAdminESP()
		if (CW_CONVAR_ADMINESP:GetInt() == 1) then
			if (IsValid(cw.client) and cw.client:Alive()) then
				local scrW, scrH = ScrW(), ScrH()
				local font = cw.option:GetFont("esp_text")
				local smallFont = cw.fonts:GetSize(font, 12)

				for k, v in ipairs(_player.GetAll()) do
					if (v == cw.client) then continue end
					if (!v:HasInitialized()) then continue end

					local pos = v:GetPos()
					local head = Vector(pos.x, pos.y, pos.z + 60)
					local screenPos = pos:ToScreen()
					local headPos = head:ToScreen()
					local textPos = Vector(head.x, head.y, head.z + 30):ToScreen()
					local distance = cw.client:GetPos():Distance(v:GetPos())
					local x, y = headPos.x, headPos.y
					local f = math.abs(350 / distance)
					local size = 52 * f
					local teamColor = team.GetColor(v:Team()) or color_white
					local offset = 0

					local w, h = util.GetTextSize(font, v:Name())
					draw.SimpleText(v:Name(), font, textPos.x - w / 2, textPos.y, teamColor)

					local icon = cw.player:GetChatIcon(v)

					if (icon) then
						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial(cw.core:GetMaterial(icon))
						surface.DrawTexturedRect(textPos.x - w / 2 - 18, textPos.y, 16, 16)
					end

					offset = offset + 14

					local w, h = util.GetTextSize(smallFont, v:SteamName())
					draw.SimpleText(v:SteamName(), smallFont, textPos.x - w / 2, textPos.y + offset, color_lightblue)

					offset = offset + 12

					local activeWeapon = v:GetActiveWeapon()
					local weaponName = "[No Weapon]"

					if (IsValid(activeWeapon)) then
						weaponName = "["..activeWeapon:GetClass().."]"
					end

					local w, h = util.GetTextSize(smallFont, weaponName)
					draw.SimpleText(weaponName, smallFont, textPos.x - w / 2, textPos.y + offset, color_lightblue)

					offset = offset + 12

					local statusInfo = {}
					hook.Run("GetStatusInfo", v, statusInfo)
					local infoText = statusInfo[1]

					if (v:Alive()) then
						surface.SetDrawColor(teamColor)
						surface.DrawOutlinedRect(x - size / 2, y - size / 2, size, (screenPos.y - y) * 1.25)
					end

					if (infoText) then
						local w, h = util.GetTextSize(smallFont, cw.lang:TranslateText(infoText))

						draw.SimpleText(infoText, smallFont, textPos.x - w / 2, textPos.y + offset, color_lightred)
					end

					local bx, by = x - size / 2, y - size / 2 + (screenPos.y - y) * 1.25
					local hpM = math.Clamp((v:Health() or 0) / v:GetMaxHealth(), 0, 1)

					if (hpM > 0) then
						draw.RoundedBox(0, bx, by, size, 2, color_grey)
						draw.RoundedBox(0, bx, by, size * hpM, 2, color_red)
					end

					local arM = math.Clamp((v:Armor() or 0) / 100, 0, 1)

					if (arM > 0) then
						draw.RoundedBox(0, bx, by + 3, size, 2, color_grey)
						draw.RoundedBox(0, bx, by + 3, size * arM, 2, color_blue)
					end
				end

				local drawSalesmen = (CW_CONVAR_SALEESP:GetInt() == 1)
				local drawItems = (CW_CONVAR_ITEMESP:GetInt() == 1)
				local drawProps = (CW_CONVAR_PROPESP:GetInt() == 1)

				if (drawSalesmen or drawItems or drawProps) then
					for k, v in ipairs(ents.GetAll()) do
						if (!IsValid(v)) then continue end

						local pos = v:GetPos()
						local entClass = v:GetClass()

						if (drawProps and v:GetPersistent()) then
							local entText = "Static Ent ["..tostring(v:GetModel()).."]"
							local position = pos:ToScreen()
							local ws, hs = util.GetTextSize(font, entText)

							draw.SimpleText(entText, smallFont, position.x - ws / 2, position.y, color_props)
						elseif (drawItems and entClass == "cw_item") then
							local itemTable = cw.entity:FetchItemTable(v)

							if (itemTable) then
								local entText = "Item ["..itemTable.name.."]"
								local position = pos:ToScreen()
								local ws, hs = util.GetTextSize(smallFont, entText)

								draw.SimpleText(entText, smallFont, position.x - ws / 2, position.y, color_items)
							end
						elseif (drawSalesmen and entClass == "cw_salesman") then
							pos = pos + vector_salesman_offset

							local entText = "Saleman ["..v:GetNWString("Name").."]"
							local position = pos:ToScreen()
							local ws, hs = util.GetTextSize(font, entText)

							draw.SimpleText(entText, smallFont, position.x - ws / 2, position.y, color_salesmen)
						end
					end
				end
			end
		end
	end
end

-- A function to draw a bar with a value and a maximum.
function cw.core:DrawBar(x, y, width, height, color, text, value, maximum, flash, barInfo)
	local backgroundColor = cw.option:GetColor("background")
	local foregroundColor = cw.option:GetColor("foreground")
	local progressWidth = math.Clamp(((width - 4) / maximum) * value, 0, width - 4)
	local colorWhite = cw.option:GetColor("white")
	local newBarInfo = {
		progressWidth = progressWidth,
		drawBackground = true,
		drawProgress = true,
		cornerSize = 2,
		maximum = maximum,
		height = height,
		width = width,
		color = color,
		value = value,
		flash = flash,
		text = text,
		maxValue = barInfo.maxValue,
		limitText = barInfo.limitText,
		x = x,
		y = y,
		isBlocky = false,
		blocksAmt = 24
	}

	if (barInfo) then
		for k, v in pairs(newBarInfo) do
			if (barInfo[k] == nil) then
				barInfo[k] = v
			end
		end
	else
		barInfo = newBarInfo
	end

	if (!hook.Run("PreDrawBar", barInfo)) then
		if (barInfo.drawBackground) then
			cdraw.DrawBox(barInfo.x, barInfo.y, barInfo.width, barInfo.height, backgroundColor)
		end

		if (barInfo.drawProgress) then
			render.SetScissorRect(barInfo.x, barInfo.y, barInfo.x + barInfo.progressWidth, barInfo.y + barInfo.height, true)
				cdraw.DrawBox(barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4, barInfo.color)
			render.SetScissorRect(barInfo.x, barInfo.y, barInfo.x + barInfo.progressWidth, barInfo.height, false)
		end

		if (barInfo.flash) then
			local alpha = math.Clamp(math.abs(math.sin(UnPredictedCurTime()) * 50), 0, 50)

			if (alpha > 0) then
				draw.RoundedBox(0, barInfo.x + 2, barInfo.y + 2, barInfo.width - 4, barInfo.height - 4,
				Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha))
			end
		end
	end

	if (!hook.Run("PostDrawBar", barInfo)) then
		if (barInfo.text and barInfo.text != "") then
			self:OverrideMainFont(cw.option:GetFont("bar_text"))
				self:DrawSimpleText(
					barInfo.text, barInfo.x + (barInfo.width / 2), barInfo.y + (barInfo.height / 2),
					Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha), 1, 1
				)
			self:OverrideMainFont(false)
		end
	end

	if (barInfo.maxValue and (barInfo.maximum - barInfo.maxValue) > 5) then
		if (!hook.Run("DrawBarLimit", barInfo)) then
			local width = barInfo.width
			local length = width * ((barInfo.maximum - barInfo.maxValue) / barInfo.maximum)

			draw.RoundedBox(2, barInfo.x + width - length, barInfo.y, length, barInfo.height, Color("#D5AD27"))

			if (barInfo.limitText) then
				local limitText = cw.lang:TranslateText(barInfo.limitText)
				local textWide = util.GetTextSize(cw.fonts:GetSize("hl2_BarsFont", 15), limitText)

				render.SetScissorRect(barInfo.x + width - length, barInfo.y, barInfo.x + width, barInfo.y + barInfo.height, true)
					draw.SimpleText(limitText, cw.fonts:GetSize("hl2_BarsFont", 15), barInfo.x + barInfo.width - textWide - 8, barInfo.y - 1, Color("white"))
				render.SetScissorRect(0, 0, 0, 0, false)
			end
		end
	end

	return barInfo.y
end

-- A function to set the recognise menu.
function cw.core:SetRecogniseMenu(menuPanel)
	cw.RecogniseMenu = menuPanel
	self:SetTitledMenu(menuPanel, "#RecogniseMenu")
end

-- A function to get the recognise menu.
function cw.core:GetRecogniseMenu(menuPanel)
	return cw.RecogniseMenu
end

-- A function to override the main font.
function cw.core:OverrideMainFont(font)
	if (font) then
		if (!cw.PreviousMainFont) then
			cw.PreviousMainFont = cw.option:GetFont("main_text")
		end

		cw.option:SetFont("main_text", font)
	elseif (cw.PreviousMainFont) then
		cw.option:SetFont("main_text", cw.PreviousMainFont)
	end
end

-- A function to get the screen's center.
function cw.core:GetScreenCenter()
	return ScrW() / 2, (ScrH() / 2) + 32
end

-- A function to draw some simple text.
function cw.core:DrawSimpleText(text, x, y, color, alignX, alignY, shadowless, shadowDepth)
	local mainTextFont = cw.option:GetFont("main_text")
	local realX = math.Round(x)
	local realY = math.Round(y)

	if (!shadowless) then
		local outlineColor = Color(25, 25, 25, math.min(225, color.a))

		for i = 1, (shadowDepth or 1) do
			draw.SimpleText(text, mainTextFont, realX + -i, realY + -i, outlineColor, alignX, alignY)
			draw.SimpleText(text, mainTextFont, realX + -i, realY + i, outlineColor, alignX, alignY)
			draw.SimpleText(text, mainTextFont, realX + i, realY + -i, outlineColor, alignX, alignY)
			draw.SimpleText(text, mainTextFont, realX + i, realY + i, outlineColor, alignX, alignY)
		end
	end

	draw.SimpleText(text, mainTextFont, realX, realY, color, alignX, alignY)
	local width, height = self:GetCachedTextSize(mainTextFont, text)

	return realY + height + 2, width
end

-- A function to get the black fade alpha.
function cw.core:GetBlackFadeAlpha()
	return cw.BlackFadeIn or cw.BlackFadeOut or 0
end

-- A function to get whether the screen is faded black.
function cw.core:IsScreenFadedBlack()
	return (cw.BlackFadeIn == 255)
end

--[[
	A function to print colored text to the console.
	Sure, it's hacky, but Garry is being a douche.
--]]
function cw.core:PrintColoredText(...)
	local currentColor = nil
	local colorWhite = cw.option:GetColor("white")
	local text = {}

	for k, v in ipairs({...}) do
		if (type(v) == "Player") then
			text[#text + 1] = _team.GetColor(v:Team())
			text[#text + 1] = v:Name()
		elseif (type(v) == "table") then
			currentColor = v
		elseif (currentColor) then
			text[#text + 1] = currentColor
			text[#text + 1] = v
			currentColor = nil
		else
			text[#text + 1] = colorWhite
			text[#text + 1] = v
		end
	end

	chatbox.oldAddText(unpack(text))
end

-- A function to get whether a custom crosshair is used.
function cw.core:UsingCustomCrosshair()
	return cw.CustomCrosshair
end

-- A function to get a cached text size.
function cw.core:GetCachedTextSize(font, text)
	if (!cw.CachedTextSizes) then
		cw.CachedTextSizes = {}
	end

	if (!cw.CachedTextSizes[font]) then
		cw.CachedTextSizes[font] = {}
	end

	if (!cw.CachedTextSizes[font][text]) then
		surface.SetFont(font)

		cw.CachedTextSizes[font][text] = { surface.GetTextSize(text) }
	end

	return cw.CachedTextSizes[font][text][1], cw.CachedTextSizes[font][text][2]
end

-- A function to draw scaled information at a position.
function cw.core:DrawInfoScaled(scale, text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)
	local newFont = cw.fonts:GetMultiplied("cwMainText", scale)
	local returnY = 0

	self:OverrideMainFont(newFont)

	returnY = self:DrawInfo(text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)

	self:OverrideMainFont(false)

	return returnY
end

-- A function to draw information at a position.
function cw.core:DrawInfo(text, x, y, color, alpha, bAlignLeft, Callback, shadowDepth)
	text = cw.lang:TranslateText(text)

	local width, height = self:GetCachedTextSize(cw.option:GetFont("main_text"), text)

	if (width and height) then
		if (!bAlignLeft) then
			x = x - (width / 2)
		end

		if (Callback) then
			x, y = Callback(x, y, width, height)
		end

		return self:DrawSimpleText(text, x, y, Color(color.r, color.g, color.b, alpha or color.a), nil, nil, nil, shadowDepth)
	end
end

-- A function to get the player info box.
function cw.core:GetPlayerInfoBox()
	return cw.PlayerInfoBox
end

-- A function to draw the local player's information.
function cw.core:DrawPlayerInfo(info)
	if (!hook.Run("PlayerCanSeePlayerInfo")) then
		return
	end

	local foregroundColor = cw.option:GetColor("foreground")
	local subInformation = cw.PlayerInfoText.subText
	local information = cw.PlayerInfoText.text
	local colorWhite = cw.option:GetColor("white")
	local textWidth, textHeight = self:GetCachedTextSize(
		cw.option:GetFont("player_info_text"), "U"
	)
	local width = cw.PlayerInfoText.width

	if (width < info.width) then
		width = info.width
	elseif (width > width) then
		info.width = width
	end

	if (#information == 0 and #subInformation == 0) then
		return
	end

	local height = (textHeight * #information) + ((textHeight + 12) * #subInformation)
	local scrW = ScrW()
	local scrH = ScrH()

	if (#information > 0) then
		height = height + 8
	end

	local y = info.y + 8
	local x = info.x - (width / 2)

	local boxInfo = {
		subInformation = subInformation,
		drawBackground = true,
		information = information,
		textHeight = textHeight,
		cornerSize = 2,
		textWidth = textWidth,
		height = height,
		width = width,
		x = x,
		y = y
	}

	if (!hook.Run("PreDrawPlayerInfo", boxInfo, information, subInformation)) then
		self:OverrideMainFont(cw.option:GetFont("player_info_text"))

		for k, v in pairs(subInformation) do
			x, y = self:DrawPlayerInfoSubBox(v.text, x, y, width, boxInfo)
		end

		if (#information > 0 and boxInfo.drawBackground) then
			cdraw.DrawBox(x, y, width, height - ((textHeight + 12) * #subInformation), Color(200, 200, 200))
		end

		if (#information > 0) then
			x = x + 8
			y = y + 4
		end

		for k, v in pairs(information) do
			self:DrawInfo(v.text, x, y - 1, colorWhite, 255, true)
			y = y + textHeight
		end

		self:OverrideMainFont(false)
	end

	hook.Run("PostDrawPlayerInfo", boxInfo, information, subInformation)
	info.y = info.y + boxInfo.height + 12

	return boxInfo
end

-- A function to get whether the info menu panel can be created.
function cw.core:CanCreateInfoMenuPanel()
	return (table.Count(cw.quickmenu.stored) > 0 or table.Count(cw.quickmenu.categories) > 0)
end

-- A function to create the info menu panel.
function cw.core:CreateInfoMenuPanel(x, y, iMinimumWidth)
	if (IsValid(cw.InfoMenuPanel)) then return end

	local options = {}

	for k, v in pairs(cw.quickmenu.categories) do
		options[k] = {}

		for k2, v2 in pairs(v) do
			local info = v2.GetInfo()

			if (type(info) == "table") then
				options[k][k2] = info
				options[k][k2].isArgTable = true
			end
		end
	end

	for k, v in pairs(cw.quickmenu.stored) do
		local info = v.GetInfo()

		if (type(info) == "table") then
			options[k] = info
			options[k].isArgTable = true
		end
	end

	cw.InfoMenuPanel = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
		if (arguments.name) then
			option = arguments.name
		end

		if (arguments.options) then
			local subMenu = menuPanel:AddSubMenu(option)

			for k, v in pairs(arguments.options) do
				local name = v

				if (type(v) == "table") then
					name = v[1]
				end

				subMenu:AddOption(name, function()
					if (arguments.Callback) then
						if (type(v) == "table") then
							arguments.Callback(v[2])
						else
							arguments.Callback(v)
						end
					end

					self:RemoveActiveToolTip()
					self:CloseActiveDermaMenus()
				end)
			end

			if (IsValid(subMenu)) then
				if (arguments.toolTip) then
					subMenu:SetTooltip(arguments.toolTip)
				end
			end
		else
			menuPanel:AddOption(option, function()
				if (arguments.Callback) then
					arguments.Callback()
				end

				self:RemoveActiveToolTip()
				self:CloseActiveDermaMenus()
			end)

			menuPanel.Items = menuPanel:GetChildren()
			local panel = menuPanel.Items[#menuPanel.Items]

			if (IsValid(panel) and arguments.toolTip) then
				panel:SetTooltip(arguments.toolTip)
			end
		end
	end, iMinimumWidth)

	if (IsValid(cw.InfoMenuPanel)) then
		cw.InfoMenuPanel:SetVisible(false)
		cw.InfoMenuPanel:SetSize(iMinimumWidth, cw.InfoMenuPanel:GetTall())
		cw.InfoMenuPanel:SetPos(x, y)
	end
end

-- A function to get the ragdoll eye angles.
function cw.core:GetRagdollEyeAngles()
	if (!cw.RagdollEyeAngles) then
		cw.RagdollEyeAngles = Angle(0, 0, 0)
	end

	return cw.RagdollEyeAngles
end

-- A function to draw a gradient.
function cw.core:DrawGradient(gradientType, x, y, width, height, color)
	if (!cw.Gradients or !cw.Gradients[gradientType]) then
		return
	end

	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	surface.SetTexture(cw.Gradients[gradientType])
	surface.DrawTexturedRect(x, y, width, height)
end

-- A function to draw a simple gradient box.
function cw.core:DrawSimpleGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
	local gradientAlpha = math.min(color.a, maxAlpha or 100)

	draw.RoundedBox(cornerSize, x, y, width, height, Color(color.r, color.g, color.b, color.a * 0.75))

	-- Let's face it: gradients are UGLY.
	/*if (x + cornerSize < x + width and y + cornerSize < y + height) then
		surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha)
		surface.SetMaterial(self:GetGradientTexture())
		surface.DrawTexturedRect(x + cornerSize, y + cornerSize, width - (cornerSize * 2), height - (cornerSize * 2))
	end*/
end

-- A function to draw a textured gradient.
function cw.core:DrawTexturedGradientBox(cornerSize, x, y, width, height, color, maxAlpha)
	local gradientAlpha = math.min(color.a, maxAlpha or 100)

	draw.RoundedBox(cornerSize, x, y, width, height, Color(color.r, color.g, color.b, color.a * 0.75))

	if (x + cornerSize < x + width and y + cornerSize < y + height) then
		surface.SetDrawColor(gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha)
		surface.SetMaterial(self:GetGradientTexture())
		surface.DrawTexturedRect(x + cornerSize, y + cornerSize, width - (cornerSize * 2), height - (cornerSize * 2))
	end
end

-- A function to draw a player information sub box.
function cw.core:DrawPlayerInfoSubBox(text, x, y, width, boxInfo)
	local foregroundColor = cw.option:GetColor("foreground")
	local colorInfo = cw.option:GetColor("information")
	local boxHeight = boxInfo.textHeight + 8

	if (boxInfo.drawBackground) then
		cdraw.DrawBox(x, y, width, boxHeight, foregroundColor)
	end

	self:DrawInfo(text, x + 8, y + (boxHeight / 2), colorInfo, 255, true,
		function(x, y, width, height)
			return x, y - (height / 2)
		end
	)

	return x, y + boxHeight + 4
end

-- A function to handle an item's spawn icon click.
function cw.core:HandleItemSpawnIconClick(itemTable, spawnIcon, Callback)
	local customFunctions = itemTable.customFunctions
	local itemFunctions = {}
	local destroyName = cw.option:GetKey("name_destroy")
	local dropName = cw.option:GetKey("name_drop")
	local useName = cw.option:GetKey("name_use")

	if (itemTable.OnUse) then
		itemFunctions[#itemFunctions + 1] = (itemTable.useText or useName)
	end

	if (itemTable.OnDrop) then
		itemFunctions[#itemFunctions + 1] = (itemTable.dropText or dropName)
	end

	if (itemTable.OnDestroy) then
		itemFunctions[#itemFunctions + 1] = (itemTable.destroyText or destroyName)
	end

	if (customFunctions) then
		for k, v in pairs(customFunctions) do
			itemFunctions[#itemFunctions + 1] = v
		end
	end

	if (itemTable.GetOptions) then
		local options = itemTable:GetOptions(nil, nil)
		for k, v in pairs(options) do
			itemFunctions[#itemFunctions + 1] = {title = k, name = v}
		end
	end

	if (itemTable.OnEditFunctions) then
		itemTable:OnEditFunctions(itemFunctions)
	end

	hook.Run("PlayerAdjustItemFunctions", itemTable, itemFunctions)
	self:ValidateTableKeys(itemFunctions)

	table.sort(itemFunctions, function(a, b) return ((type(a) == "table" and a.title) or a) < ((type(b) == "table" and b.title) or b); end)
	if (#itemFunctions == 0 and !Callback) then return end

	local options = {}

	if (itemTable.GetEntityMenuOptions) then
		itemTable:GetEntityMenuOptions(nil, options)
	end

	local itemMenu = self:AddMenuFromData(nil, options, function(menuPanel, option, arguments)
		menuPanel:AddOption(option, function()
			if (type(arguments) == "table" and arguments.isArgTable) then
				if (arguments.Callback) then
					arguments.Callback()
				end
			elseif (arguments == "function") then
				arguments()
			end

			timer.Simple(FrameTime(), function()
				self:RemoveActiveToolTip()
			end)
		end)

		menuPanel.Items = menuPanel:GetChildren()
		local panel = menuPanel.Items[#menuPanel.Items]

		if (IsValid(panel)) then
			if (type(arguments) == "table") then
				if (arguments.toolTip) then
					self:CreateMarkupToolTip(panel)
					panel:SetMarkupToolTip(arguments.toolTip)
				end
			end
		end
	end, nil, true)

	if (Callback) then Callback(itemMenu); end

	itemMenu:SetMinimumWidth(100)
	hook.Run("PlayerAdjustItemMenu", itemTable, itemMenu, itemFunctions)

	for k, v in pairs(itemFunctions) do
		local useText = (itemTable.useText or "Use")
		local dropText = (itemTable.dropText or "Drop")
		local destroyText = (itemTable.destroyText or "Destroy")

		if ((!useText and v == "Use") or (useText and v == useText)) then
			itemMenu:AddOption(L(v), function()
				if (itemTable) then
					if (itemTable.OnHandleUse) then
						itemTable:OnHandleUse(function()
							self:RunCommand(
								"InvAction", "use", itemTable.uniqueID, itemTable.itemID
							)
						end)
					else
						self:RunCommand(
							"InvAction", "use", itemTable.uniqueID, itemTable.itemID
						)
					end
				end
			end)
		elseif ((!dropText and v == "Drop") or (dropText and v == dropText)) then
			itemMenu:AddOption(L(v), function()
				if (itemTable) then
					self:RunCommand(
						"InvAction", "drop", itemTable.uniqueID, itemTable.itemID
					)
				end
			end)
		elseif ((!destroyText and v == "Destroy") or (destroyText and v == destroyText)) then
			local subMenu = itemMenu:AddSubMenu(L(v))

			subMenu:AddOption(L("Yes"), function()
				if (itemTable) then
					self:RunCommand(
						"InvAction", "destroy", itemTable.uniqueID, itemTable.itemID
					)
				end
			end)

			subMenu:AddOption(L("No"), function() end)
		elseif (type(v) == "table") then
			itemMenu:AddOption(L(v.title), function()
				local defaultAction = true

				if (itemTable.HandleOptions) then
					local transmit, data = itemTable:HandleOptions(v.name)

					if (transmit) then
						netstream.Start("MenuOption", {option = v.name, data = data, item = itemTable.itemID})
						defaultAction = false
					end
				end

				if (defaultAction) then
					self:RunCommand(
						"InvAction", v.name, itemTable.uniqueID, itemTable.itemID
					)
				end
			end)
		else
			if (itemTable.OnCustomFunction) then
				itemTable:OnCustomFunction(v)
			end

			itemMenu:AddOption(L(v), function()
				if (itemTable) then
					self:RunCommand(
						"InvAction", v, itemTable.uniqueID, itemTable.itemID
					)
				end
			end)
		end
	end

	itemMenu:Open()
end

-- A function to handle an item's spawn icon right click.
function cw.core:HandleItemSpawnIconRightClick(itemTable, spawnIcon)
	if (itemTable.OnHandleRightClick) then
		local functionName = itemTable:OnHandleRightClick()

		if (functionName and functionName != "Use") then
			local customFunctions = itemTable.customFunctions

			if (customFunctions and table.HasValue(customFunctions, functionName)) then
				if (itemTable.OnCustomFunction) then
					itemTable:OnCustomFunction(v)
				end
			end

			self:RunCommand(
				"InvAction", string.lower(functionName), itemTable.uniqueID, itemTable.itemID
			)
			return
		end
	end

	if (itemTable.OnUse) then
		if (itemTable.OnHandleUse) then
			itemTable:OnHandleUse(function()
				self:RunCommand("InvAction", "use", itemTable.uniqueID, itemTable.itemID)
			end)
		else
			self:RunCommand("InvAction", "use", itemTable.uniqueID, itemTable.itemID)
		end
	end
end

-- A function to set a panel's perform layout callback.
function cw.core:SetOnLayoutCallback(target, Callback)
	if (target.PerformLayout) then
		target.OldPerformLayout = target.PerformLayout

		-- Called when the panel's layout is performed.
		function target.PerformLayout()
			target:OldPerformLayout(); Callback(target)
		end
	end
end

-- A function to set the active titled DMenu.
function cw.core:SetTitledMenu(menuPanel, title)
	cw.TitledMenu = {
		menuPanel = menuPanel,
		title = title
	}
end

-- A function to add a markup line.
function cw.core:AddMarkupLine(markupText, text, color)
	if (markupText != "") then
		markupText = markupText.."\n"
	end

	return markupText..self:MarkupTextWithColor(text, color)
end

-- A function to draw a markup tool tip.
function cw.core:DrawMarkupToolTip(markupObject, x, y, alpha)
	local height = markupObject:GetHeight()
	local width = markupObject:GetWidth()

	if (x - (width / 2) > 0) then
		x = x - (width / 2)
	end

	if (x + width > ScrW()) then
		x = x - width - 8
	end

	if (y + (height + 8) > ScrH()) then
		y = y - height - 8
	end

	self:DrawSimpleGradientBox(2, x - 8, y - 8, width + 16, height + 16, Color(50, 50, 50, alpha))
	markupObject:Draw(x, y, nil, nil, alpha)
end

-- A function to override a markup object's draw function.
function cw.core:OverrideMarkupDraw(markupObject, sCustomFont)
	function markupObject:Draw(xOffset, yOffset, hAlign, vAlign, alphaOverride)
		for k, v in pairs(self.blocks) do
			if (!v.colour) then
				debug.Trace()
				return
			end

			local alpha = v.colour.a or 255
			local y = yOffset + (v.height - v.thisY) + v.offset.y
			local x = xOffset

			if (hAlign == TEXT_ALIGN_CENTER) then
				x = x - (self.totalWidth / 2)
			elseif (hAlign == TEXT_ALIGN_RIGHT) then
				x = x - self.totalWidth
			end

			x = x + v.offset.x

			if (hAlign == TEXT_ALIGN_CENTER) then
				y = y - (self.totalHeight / 2)
			elseif (hAlign == TEXT_ALIGN_BOTTOM) then
				y = y - self.totalHeight
			end

			if (alphaOverride) then
				alpha = alphaOverride
			end

			cw.core:OverrideMainFont(sCustomFont or v.font)
				cw.core:DrawSimpleText(v.text, x, y, Color(v.colour.r or 255, v.colour.g or 255, v.colour.b or 255, alpha))
			cw.core:OverrideMainFont(false)
		end
	end
end

-- A function to get the active markup tool tip.
function cw.core:GetActiveMarkupToolTip()
	return cw.MarkupToolTip
end

-- A function to get markup from a color.
function cw.core:ColorToMarkup(color)
	return "<color="..math.ceil(color.r)..","..math.ceil(color.g)..","..math.ceil(color.b)..">"
end

-- A function to markup text with a color.
function cw.core:MarkupTextWithColor(text, color, scale)
	local fontName = cw.fonts:GetMultiplied("cwTooltip", scale or 1)
	local finalText = text

	if (color) then
		finalText = self:ColorToMarkup(color)..text.."</color>"
	end

	finalText = "<font="..fontName..">"..finalText.."</font>"

	return finalText
end

-- A function to create a markup tool tip.
function cw.core:CreateMarkupToolTip(panel)
	panel.OldCursorExited = panel.OnCursorExited
	panel.OldCursorEntered = panel.OnCursorEntered

	-- Called when the cursor enters the panel.
	function panel.OnCursorEntered(panel, ...)
		if (panel.OldCursorEntered) then
			panel:OldCursorEntered(...)
		end

		cw.MarkupToolTip = panel
	end

	-- Called when the cursor exits the panel.
	function panel.OnCursorExited(panel, ...)
		if (panel.OldCursorExited) then
			panel:OldCursorExited(...)
		end

		if (cw.MarkupToolTip == panel) then
			cw.MarkupToolTip = nil
		end
	end

	-- A function to set the panel's markup tool tip.
	function panel.SetMarkupToolTip(panel, text)
		if (!text or text == "") then
			return
		end

		text = cw.lang:TranslateText(text)

		if (!panel.MarkupToolTip or panel.MarkupToolTip.text != text) then
			panel.MarkupToolTip = {
				object = markup.Parse(text, ScrW() * 0.25),
				text = text
			}

			self:OverrideMarkupDraw(panel.MarkupToolTip.object)
		end
	end

	-- A function to get the panel's markup tool tip.
	function panel.GetMarkupToolTip(panel)
		return panel.MarkupToolTip
	end

	-- A function to set the panel's tool tip.
	function panel.SetToolTip(panel, toolTip)
		panel:SetMarkupToolTip(toolTip)
	end

	return panel
end

-- A function to create a custom category panel.
function cw.core:CreateCustomCategoryPanel(categoryName, parent)
	if (!parent.CategoryList) then
		parent.CategoryList = {}
	end

	local collapsibleCategory = vgui.Create("DCollapsibleCategory", parent)
		collapsibleCategory:SetExpanded(true)
		collapsibleCategory:SetPadding(2)
		collapsibleCategory:SetLabel(categoryName)
	parent.CategoryList[#parent.CategoryList + 1] = collapsibleCategory

	return collapsibleCategory
end

-- A function to draw the armor bar.
function cw.core:DrawArmorBar()
	local armor = math.Clamp(cw.client:Armor(), 0, cw.client:GetMaxArmor())

	if (!self.armor) then
		self.armor = armor
	else
		self.armor = math.Approach(self.armor, armor, 1)
	end

	if (armor > 0) then
		cw.bars:Add("#Bars_Armor", Color(139, 174, 179, 255), "", self.armor, cw.client:GetMaxArmor(), self.health < 10, 1)
	end
end

-- A function to draw the health bar.
function cw.core:DrawHealthBar()
	local health = math.Clamp(cw.client:Health(), 0, cw.client:GetMaxHealth())

	if (!self.armor) then
		self.health = health
	else
		self.health = math.Approach(self.health, health, 1)
	end

	if (health > 0) then
		cw.bars:Add("#Bars_Health", Color(179, 46, 49, 255), "", self.health, cw.client:GetMaxHealth(), self.health < 10, 2)
	end
end

-- A function to remove the active tool tip.
function cw.core:RemoveActiveToolTip()
	ChangeTooltip()
end

-- A function to close active Derma menus.
function cw.core:CloseActiveDermaMenus()
	CloseDermaMenus()
end

-- A function to register a background blur.
function cw.core:RegisterBackgroundBlur(panel, fCreateTime)
	cw.BackgroundBlurs[panel] = fCreateTime or SysTime()
end

-- A function to remove a background blur.
function cw.core:RemoveBackgroundBlur(panel)
	cw.BackgroundBlurs[panel] = nil
end

-- A function to draw the background blurs.
function cw.core:DrawBackgroundBlurs()
	local scrH, scrW = ScrH(), ScrW()
	local sysTime = SysTime()

	if (!cw.ScreenBlur) then
		cw.ScreenBlur = Material("pp/blurscreen")
	end

	for k, v in pairs(cw.BackgroundBlurs) do
		if (type(k) == "string" or (IsValid(k) and k:IsVisible())) then
			local fraction = math.Clamp((sysTime - v) / 1, 0, 1)
			local x, y = 0, 0

			surface.SetMaterial(cw.ScreenBlur)
			surface.SetDrawColor(255, 255, 255, 255)

			for i = 0.33, 1, 0.33 do
				cw.ScreenBlur:SetFloat("$blur", fraction * 5 * i)
				cw.ScreenBlur:Recompute()

				if (render) then render.UpdateScreenEffectTexture();end

				surface.DrawTexturedRect(x, y, scrW, scrH)
			end

			surface.SetDrawColor(10, 10, 10, 200 * fraction)
			surface.DrawRect(x, y, scrW, scrH)
		end
	end
end

-- A function to get the notice panel.
function cw.core:GetNoticePanel()
	if (IsValid(cw.NoticePanel) and cw.NoticePanel:IsVisible()) then
		return cw.NoticePanel
	end
end

-- A function to set the notice panel.
function cw.core:SetNoticePanel(noticePanel)
	cw.NoticePanel = noticePanel
end

-- A function to add some cinematic text.
function cw.core:AddCinematicText(text, color, barLength, hangTime, font, bThisOnly)
	local colorWhite = cw.option:GetColor("white")
	local cinematicTable = {
		barLength = barLength or (ScrH() * 8),
		hangTime = hangTime or 3,
		color = color or colorWhite,
		font = font,
		text = text,
		add = 0
	}

	if (bThisOnly) then
		cw.Cinematics[1] = cinematicTable
	else
		cw.Cinematics[#cw.Cinematics + 1] = cinematicTable
	end
end

-- A function to get whether the local player is using the tool gun.
function cw.core:IsUsingTool()
	if (IsValid(cw.client:GetActiveWeapon())
	and cw.client:GetActiveWeapon():GetClass() == "gmod_tool") then
		return true
	else
		return false
	end
end

-- A function to get whether the local player is using the camera.
function cw.core:IsUsingCamera()
	if (IsValid(cw.client:GetActiveWeapon())
	and cw.client:GetActiveWeapon():GetClass() == "gmod_camera") then
		return true
	else
		return false
	end
end

-- A function to get the target ID data.
function cw.core:GetTargetIDData()
	return cw.TargetIDData
end

-- A function to calculate the screen fading.
function cw.core:CalculateScreenFading()
	if (hook.Run("ShouldPlayerScreenFadeBlack")) then
		if (!cw.BlackFadeIn) then
			if (cw.BlackFadeOut) then
				cw.BlackFadeIn = cw.BlackFadeOut
			else
				cw.BlackFadeIn = 0
			end
		end

		cw.BlackFadeIn = math.Clamp(cw.BlackFadeIn + (FrameTime() * 20), 0, 255)
		cw.BlackFadeOut = nil
		self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, cw.BlackFadeIn))
	else
		if (cw.BlackFadeIn) then
			cw.BlackFadeOut = cw.BlackFadeIn
		end

		cw.BlackFadeIn = nil

		if (cw.BlackFadeOut) then
			cw.BlackFadeOut = math.Clamp(cw.BlackFadeOut - (FrameTime() * 40), 0, 255)
			self:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, cw.BlackFadeOut))

			if (cw.BlackFadeOut == 0) then
				cw.BlackFadeOut = nil
			end
		end
	end
end

-- A function to draw a cinematic.
function cw.core:DrawCinematic(cinematicTable, curTime)
	local maxBarLength = cinematicTable.barLength or (ScrH() / 13)
	local font = cinematicTable.font or cw.option:GetFont("cinematic_text")

	if (cinematicTable.goBack and curTime > cinematicTable.goBack) then
		cinematicTable.add = math.Clamp(cinematicTable.add - 2, 0, maxBarLength)

		if (cinematicTable.add == 0) then
			table.remove(cw.Cinematics, 1)
			cinematicTable = nil
		end
	else
		cinematicTable.add = math.Clamp(cinematicTable.add + 1, 0, maxBarLength)

		if (cinematicTable.add == maxBarLength and !cinematicTable.goBack) then
			cinematicTable.goBack = curTime + cinematicTable.hangTime
		end
	end

	if (cinematicTable) then
		draw.RoundedBox(0, 0, -maxBarLength + cinematicTable.add, ScrW(), maxBarLength, Color(0, 0, 0, 255))
		draw.RoundedBox(0, 0, ScrH() - cinematicTable.add, ScrW(), maxBarLength, Color(0, 0, 0, 255))
		draw.SimpleText(cinematicTable.text, font, ScrW() / 2, (ScrH() - cinematicTable.add) + (maxBarLength / 2), cinematicTable.color, 1, 1)
	end
end

-- A function to draw the cinematic introduction.
function cw.core:DrawCinematicIntro(curTime)
	local cinematicInfo = hook.Run("GetCinematicIntroInfo")
	local colorWhite = cw.option:GetColor("white")

	if (cinematicInfo) then
		if (cw.CinematicScreenAlpha and cw.CinematicScreenTarget) then
			cw.CinematicScreenAlpha = math.Approach(cw.CinematicScreenAlpha, cw.CinematicScreenTarget, 1)

			if (cw.CinematicScreenAlpha == cw.CinematicScreenTarget) then
				if (cw.CinematicScreenTarget == 255) then
					if (!cw.CinematicScreenGoBack) then
						cw.CinematicScreenGoBack = curTime + 2.5
						cw.option:PlaySound("rollover")
					end
				else
					cw.CinematicScreenDone = true
				end
			end

			if (cw.CinematicScreenGoBack and curTime >= cw.CinematicScreenGoBack) then
				cw.CinematicScreenGoBack = nil
				cw.CinematicScreenTarget = 0
				cw.option:PlaySound("rollover")
			end

			if (!cw.CinematicScreenDone and cinematicInfo.credits) then
				local alpha = math.Clamp(cw.CinematicScreenAlpha, 0, 255)

				self:OverrideMainFont(cw.option:GetFont("intro_text_tiny"))
					self:DrawSimpleText(cinematicInfo.credits, ScrW() / 8, ScrH() * 0.75, Color(colorWhite.r, colorWhite.g, colorWhite.b, alpha))
				self:OverrideMainFont(false)
			end
		else
			cw.CinematicScreenAlpha = 0
			cw.CinematicScreenTarget = 255
			cw.option:PlaySound("rollover")
		end
	end
end

-- A function to draw the cinematic introduction bars.
function cw.core:DrawCinematicIntroBars()
	if (config.GetVal("draw_intro_bars")) then
		local maxBarLength = ScrH() / 8

		if (!cw.CinematicBarsTarget and !cw.CinematicBarsAlpha) then
			cw.CinematicBarsAlpha = 0
			cw.CinematicBarsTarget = 255
			cw.option:PlaySound("rollover")
		end

		cw.CinematicBarsAlpha = math.Approach(cw.CinematicBarsAlpha, cw.CinematicBarsTarget, 1)

		if (cw.CinematicScreenDone) then
			if (cw.CinematicScreenBarLength != 0) then
				cw.CinematicScreenBarLength = math.Clamp((maxBarLength / 255) * cw.CinematicBarsAlpha, 0, maxBarLength)
			end

			if (cw.CinematicBarsTarget != 0) then
				cw.CinematicBarsTarget = 0
				cw.option:PlaySound("rollover")
			end

			if (cw.CinematicBarsAlpha == 0) then
				cw.CinematicBarsDrawn = true
			end
		elseif (cw.CinematicScreenBarLength != maxBarLength) then
			if (!cw.IntroBarsMultiplier) then
				cw.IntroBarsMultiplier = 1
			else
				cw.IntroBarsMultiplier = math.Clamp(cw.IntroBarsMultiplier + (FrameTime() * 8), 1, 12)
			end

			cw.CinematicScreenBarLength = math.Clamp((maxBarLength / 255) * math.Clamp(cw.CinematicBarsAlpha * cw.IntroBarsMultiplier, 0, 255), 0, maxBarLength)
		end

		draw.RoundedBox(0, 0, 0, ScrW(), cw.CinematicScreenBarLength, Color(0, 0, 0, 255))
		draw.RoundedBox(0, 0, ScrH() - cw.CinematicScreenBarLength, ScrW(), maxBarLength, Color(0, 0, 0, 255))
	end
end

-- A function to draw the cinematic info.
function cw.core:DrawCinematicInfo()
	if (!cw.CinematicInfoAlpha and !cw.CinematicInfoSlide) then
		cw.CinematicInfoAlpha = 255
		cw.CinematicInfoSlide = 0
	end

	cw.CinematicInfoSlide = math.Approach(cw.CinematicInfoSlide, 255, 1)

	if (cw.CinematicScreenAlpha and cw.CinematicScreenTarget) then
		cw.CinematicInfoAlpha = math.Approach(cw.CinematicInfoAlpha, 0, 1)

		if (cw.CinematicInfoAlpha == 0) then
			cw.CinematicInfoDrawn = true
		end
	end

	local cinematicInfo = hook.Run("GetCinematicIntroInfo")
	local colorWhite = cw.option:GetColor("white")
	local colorInfo = cw.option:GetColor("information")

	if (cinematicInfo) then
		local scrH = ScrH()
		local scrW = ScrW()
		local textPosScale = 1 - (cw.CinematicInfoAlpha / 255)
		local textPosY = (scrH * 0.35) - ((scrH * 0.15) * textPosScale)
		local textPosX = scrW * 0.3

		if (cinematicInfo.title) then
			local cinematicInfoTitle = string.upper(cinematicInfo.title)
			local cinematicIntroText = string.upper(cinematicInfo.text)
			local introTextSmallFont = cw.option:GetFont("intro_text_small")
			local introTextBigFont = cw.option:GetFont("intro_text_big")
			local textWidth, textHeight = self:GetCachedTextSize(introTextBigFont, cinematicInfoTitle)
			local boxAlpha = math.Clamp(cw.CinematicInfoAlpha, 0, 130)

			if (cinematicInfo.text) then
				local smallTextWidth, smallTextHeight = self:GetCachedTextSize(introTextSmallFont, cinematicIntroText)
				local tabY = textPosY + textHeight + smallTextHeight + 80
				local verts = {
					{x = 0, y = textPosY - 60}, -- left upper
					{x = scrW, y = textPosY - 40}, -- right upper
					{x = scrW, y = tabY}, -- right lower
					{x = 0, y = tabY + 20} -- left lower
				}

				surface.SetDrawColor(0, 0, 0, boxAlpha)
				draw.NoTexture()
				surface.DrawPoly(verts)
			else
				self:DrawGradient(
					GRADIENT_RIGHT, 0, textPosY - 80, scrW, textHeight + 160, Color(100, 100, 100, boxAlpha)
				)
			end

			self:OverrideMainFont(introTextBigFont)
				self:DrawSimpleText(cinematicInfoTitle, textPosX, textPosY, Color(colorInfo.r, colorInfo.g, colorInfo.b, cw.CinematicInfoAlpha), nil, nil, true)
			self:OverrideMainFont(false)

			if (cinematicInfo.text) then
				self:OverrideMainFont(introTextSmallFont)
					self:DrawSimpleText(cinematicIntroText, textPosX, textPosY + textHeight + 8, Color(colorWhite.r, colorWhite.g, colorWhite.b, cw.CinematicInfoAlpha), nil, nil, true)
				self:OverrideMainFont(false)
			end
		elseif (cinematicInfo.text) then
			self:OverrideMainFont(introTextSmallFont)
				self:DrawSimpleText(cinematicIntroText, textPosX, textPosY, Color(colorWhite.r, colorWhite.g, colorWhite.b, cw.CinematicInfoAlpha), nil, nil, true)
			self:OverrideMainFont(false)
		end
	end
end

-- A function to draw some door text.
function cw.core:DrawDoorText(entity, eyePos, eyeAngles, font, nameColor, textColor)
	local entityColor = entity:GetColor()

	if (entityColor.a <= 0 or entity:IsEffectActive(EF_NODRAW)) then
		return
	end

	local doorData = cw.entity:CalculateDoorTextPosition(entity)

	if (!doorData.hitWorld) then
		local frontY = -26
		local backY = -26
		local alpha = self:CalculateAlphaFromDistance(256, eyePos, entity:GetPos())

		if (alpha <= 0) then
			return
		end

		local name = hook.Run("GetDoorInfo", entity, DOOR_INFO_NAME)
		local text = hook.Run("GetDoorInfo", entity, DOOR_INFO_TEXT)

		if (name or text) then
			local nameWidth, nameHeight = self:GetCachedTextSize(font, name or "")
			local textWidth, textHeight = self:GetCachedTextSize(font, text or "")
			local boxAlpha = math.min(alpha, 255)

			if (textWidth > nameWidth) then
				nameWidth = textWidth
			end

			local scale = math.abs((doorData.width * 0.75) / nameWidth)
			local nameScale = math.min(scale, 0.05)
			local textScale = math.min(scale, 0.03)
			local longHeight = (nameHeight + textHeight + 8)
			local backX = -nameWidth / 2 - 32
			local blackCol = Color(0, 0, 0, math.Clamp(boxAlpha, 0, 130))
			local whiteCol = Color(220, 220, 220, boxAlpha)
			local boxWidth = nameWidth + 64

			nameWidth = math.Clamp(nameWidth, 0, 1500)

			cam.Start3D2D(doorData.position, doorData.angles, 0.03)
				draw.RoundedBox(0, backX, frontY - 5, boxWidth, longHeight + 14, blackCol)
				draw.RoundedBox(0, backX, frontY - 8, boxWidth, 3, whiteCol)
				draw.RoundedBox(0, backX, frontY + longHeight + 8, boxWidth, 3, whiteCol)
			cam.End3D2D()

			cam.Start3D2D(doorData.positionBack, doorData.anglesBack, 0.03)
				draw.RoundedBox(0, backX, frontY - 5, boxWidth, longHeight + 14, blackCol)
				draw.RoundedBox(0, backX, frontY - 8, boxWidth, 3, whiteCol)
				draw.RoundedBox(0, backX, frontY + longHeight + 8, boxWidth, 3, whiteCol)
			cam.End3D2D()

			if (name) then
				if (!text or text == "") then
					nameColor = textColor or nameColor
				end

				cam.Start3D2D(doorData.position, doorData.angles, nameScale)
					self:OverrideMainFont(font)
						frontY = self:DrawInfo(name, 0, frontY, nameColor, alpha, nil, nil, 3)
					self:OverrideMainFont(false)
				cam.End3D2D()

				cam.Start3D2D(doorData.positionBack, doorData.anglesBack, nameScale)
					self:OverrideMainFont(font)
						backY = self:DrawInfo(name, 0, backY, nameColor, alpha, nil, nil, 3)
					self:OverrideMainFont(false)
				cam.End3D2D()
			end

			if (text) then
				cam.Start3D2D(doorData.position, doorData.angles, textScale)
					self:OverrideMainFont(font)
						frontY = self:DrawInfo(text, 0, frontY, textColor, alpha, nil, nil, 3)
					self:OverrideMainFont(false)
				cam.End3D2D()

				cam.Start3D2D(doorData.positionBack, doorData.anglesBack, textScale)
					self:OverrideMainFont(font)
						backY = self:DrawInfo(text, 0, backY, textColor, alpha, nil, nil, 3)
					self:OverrideMainFont(false)
				cam.End3D2D()
			end
		end
	end
end

-- A function to get whether the local player's character screen is open.
function cw.core:IsCharacterScreenOpen(isVisible)
	if (cw.character:IsPanelOpen()) then
		local panel = cw.character:GetPanel()

		if (isVisible) then
			if (panel) then
				return panel:IsVisible()
			end
		else
			return panel != nil
		end
	end
end

-- A function to save schema data.
function cw.core:SaveSchemaData(fileName, data)
	if (type(data) != "table") then
		MsgC(Color(255, 100, 0, 255), "[CW:Kernel] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..", table required.\n")

		return
	end

	_file.Write("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", self:Serialize(data))
end

-- A function to delete schema data.
function cw.core:DeleteSchemaData(fileName)
	_file.Delete("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt")
end

-- A function to check if schema data exists.
function cw.core:SchemaDataExists(fileName)
	return _file.Exists("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", "DATA")
end

-- A function to find schema data in a directory.
function cw.core:FindSchemaDataInDir(directory)
	return _file.Find("clockwork/schemas/"..self:GetSchemaFolder().."/"..directory, "LUA", "namedesc")
end

-- A function to restore schema data.
function cw.core:RestoreSchemaData(fileName, failSafe)
	if (!fileName) then return failSafe; end

	if (self:SchemaDataExists(fileName)) then
		local data = _file.Read("clockwork/schemas/"..self:GetSchemaFolder().."/"..fileName..".txt", "DATA")

		if (data) then
			local bSuccess, value = pcall(self.Deserialize, self, data)

			if (bSuccess and value != nil) then
				return value
			else
				if (value) then
					MsgC(Color(255, 100, 0, 255), "[CW:Kernel] '"..fileName.."' schema data has failed to restore.\n"..value.."\n")
				end

				self:DeleteSchemaData(fileName)
			end
		end
	end

	if (failSafe != nil) then
		return failSafe
	else
		return {}
	end
end

-- A function to restore Clockwork data.
function cw.core:RestoreClockworkData(fileName, failSafe)
	if (self:ClockworkDataExists(fileName)) then
		local data = _file.Read("clockwork/"..fileName..".txt", "DATA")

		if (data) then
			local bSuccess, value = pcall(self.Deserialize, self, data)

			if (bSuccess and value != nil) then
				return value
			else
				MsgC(Color(255, 100, 0, 255), "[CW:Kernel] '"..fileName.."' clockwork data has failed to restore.\n"..value.."\n")

				self:DeleteClockworkData(fileName)
			end
		end
	end

	if (failSafe != nil) then
		return failSafe
	else
		return {}
	end
end

-- A function to save Clockwork data.
function cw.core:SaveClockworkData(fileName, data)
	if (type(data) != "table") then
		MsgC(Color(255, 100, 0, 255), "[CW:Kernel] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..", table required.\n")

		return
	end

	_file.Write("clockwork/"..fileName..".txt", self:Serialize(data))
end

-- A function to check if Clockwork data exists.
function cw.core:ClockworkDataExists(fileName)
	return _file.Exists("clockwork/"..fileName..".txt", "DATA")
end

-- A function to delete Clockwork data.
function cw.core:DeleteClockworkData(fileName)
	_file.Delete("clockwork/"..fileName..".txt")
end

-- A function to run a Clockwork command.
function cw.core:RunCommand(command, ...)
	RunConsoleCommand("cwCmd", command, ...)
end

-- A function to get whether the local player is choosing a character.
function cw.core:IsChoosingCharacter()
	if (cw.character:GetPanel()) then
		return cw.character:IsPanelOpen()
	else
		return true
	end
end

-- A function to include the schema.
function cw.core:IncludeSchema()
	local schemaFolder = self:GetSchemaFolder()

	if (schemaFolder and type(schemaFolder) == "string") then
		self:LoadSchema()
	end
end

function Derma_NumRequest(strTitle, strText, nDefaultValue, min, max, dec, fnEnter, fnCancel, strButtonText, strButtonCancelText)
	local Window = vgui.Create("DFrame")
	Window:SetTitle(strTitle or "Message Title (First Parameter)")
	Window:SetDraggable(false)
	Window:ShowCloseButton(false)
	Window:SetBackgroundBlur(true)
	Window:SetDrawOnTop(true)

	local InnerPanel = vgui.Create("DPanel", Window)
	InnerPanel:SetPaintBackground(false)

	local Text = vgui.Create("DLabel", InnerPanel)
	Text:SetText(strText or "Message Text (Second Parameter)")
	Text:SizeToContents()
	Text:SetContentAlignment(5)
	Text:SetTextColor(Color(255, 255, 255))

	local NumSlider = vgui.Create("DNumSlider", InnerPanel)
	NumSlider:SetValue(nDefaultValue or 0)
	NumSlider:SetMin(min or 0)
	NumSlider:SetMax(max or 256)
	NumSlider:SetDecimals(dec or 0)

	local ButtonPanel = vgui.Create("DPanel", Window)
	ButtonPanel:SetTall(30)
	ButtonPanel:SetPaintBackground(false)

	local Button = vgui.Create("DButton", ButtonPanel)
	Button:SetText(strButtonText or "OK")
	Button:SizeToContents()
	Button:SetTall(20)
	Button:SetWide(Button:GetWide() + 20)
	Button:SetPos(5, 5)
	Button.DoClick = function() Window:Close() fnEnter(NumSlider:GetValue()) end

	local ButtonCancel = vgui.Create("DButton", ButtonPanel)
	ButtonCancel:SetText(strButtonCancelText or "Cancel")
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall(20)
	ButtonCancel:SetWide(Button:GetWide() + 20)
	ButtonCancel:SetPos(5, 5)
	ButtonCancel.DoClick = function() Window:Close() if (fnCancel) then fnCancel(NumSlider:GetValue()) end end
	ButtonCancel:MoveRightOf(Button, 5)

	ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10)

	local w, h = Text:GetSize()
	w = math.max(w, 400)

	Window:SetSize(w + 50, h + 25 + 75 + 10)
	Window:Center()

	InnerPanel:StretchToParent(5, 25, 5, 45)

	Text:StretchToParent(5, 5, 5, 35)

	NumSlider:StretchToParent(5, nil, 5, nil)
	NumSlider:AlignBottom(5)

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom(8)

	Window:MakePopup()
	Window:DoModal()

	return Window
end

local entityMeta = FindMetaTable("Entity")
local weaponMeta = FindMetaTable("Weapon")
local playerMeta = FindMetaTable("Player")

entityMeta.ClockworkFireBullets = entityMeta.ClockworkFireBullets or entityMeta.FireBullets
weaponMeta.OldGetPrintName = weaponMeta.OldGetPrintName or weaponMeta.GetPrintName
playerMeta.SteamName = playerMeta.SteamName or playerMeta.Name

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if (self:IsPlayer()) then
		hook.Run("PlayerAdjustBulletInfo", self, bulletInfo)
	end

	hook.Run("EntityFireBullets", self, bulletInfo)
	return self:ClockworkFireBullets(bulletInfo)
end

-- A function to get a weapon's print name.
function weaponMeta:GetPrintName()
	local itemTable = item.GetByWeapon(self)

	if (itemTable) then
		return cw.lang:TranslateText(itemTable.PrintName) or itemTable.name
	else
		return self:OldGetPrintName()
	end
end

-- A function to get a player's name.
function playerMeta:Name(bRealName)
	local name = (!bRealName and self:GetNetVar("NameOverride", nil)) or self:GetDTString(STRING_NAME)

	if (!name or name == "") then
		return self:SteamName()
	else
		return name
	end
end

-- A function to get a player's playback rate.
function playerMeta:GetPlaybackRate()
	return self.cwPlaybackRate or 1
end

-- A function to get whether a player is noclipping.
function playerMeta:IsNoClipping()
	return cw.player:IsNoClipping(self)
end

-- A function to get whether a player is running.
function playerMeta:IsRunning(bNoWalkSpeed)
	if (self:Alive() and !self:IsRagdolled() and !self:InVehicle() and !self:Crouching()
	and self:GetDTBool(BOOL_ISRUNNING)) then
		if (self:GetVelocity():Length() >= self:GetWalkSpeed()
		or bNoWalkSpeed) then
			return true
		end
	end

	return false
end

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	local forcedAnimation = self:GetNetVar("ForceAnim")

	if (forcedAnimation != 0) then
		return {
			animation = forcedAnimation,
		}
	end
end

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return cw.player:IsRagdolled(self, exception, entityless)
end

-- A function to set a shared variable for a player.
-- Can't set them on client at all.
function playerMeta:SetSharedVar(key, value) end

-- A function to get a player's shared variable.
function playerMeta:GetSharedVar(key, default)
	return self:GetNetVar(key, default)
end

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	if (IsValid(self)) then
		return self:GetNetVar("Initialized")
	end
end

-- A function to get a player's gender.
function playerMeta:GetGender()
	if (self:GetNetVar("Gender") == nil) then return GENDER_MALE; end

	if (self:GetNetVar("Gender") == 1) then
		return GENDER_FEMALE
	else
		return GENDER_MALE
	end
end

-- A function to get a player's faction.
function playerMeta:GetFaction()
	local index = self:GetNetVar("Faction")

	if (faction.FindByID(index)) then
		return faction.FindByID(index).name
	else
		return "Unknown"
	end
end

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return cw.player:GetWagesName(self)
end

-- A function to get a player's data.
function playerMeta:GetData(key, default)
	local playerData = cw.player:GetPlayerData(key)

	if (playerData and (!playerData.playerOnly or self == cw.client)) then
		return self:GetNetVar(key)
	end

	return default
end

-- A function to get a player's character data.
function playerMeta:GetCharacterData(key, default)
	local characterData = cw.player:GetCharacterData(key)

	if (characterData and (!characterData.playerOnly or self == cw.client)) then
		return self:GetNetVar(key)
	end

	return default
end

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetNetVar("MaxAP") or 100

	if (maxArmor > 0) then
		return maxArmor
	else
		return 100
	end
end

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetNetVar("MaxHP") or 100

	if (maxHealth > 0) then
		return maxHealth
	else
		return 100
	end
end

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState()
	return self:GetDTInt(INT_RAGDOLLSTATE)
end

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity()
	return cw.player:GetRagdollEntity(self)
end

-- A function to get a player's rank within their faction.
function playerMeta:GetFactionRank(character)
	return cw.player:GetFactionRank(self, character)
end

-- A function to get a player's chat icon.
function playerMeta:GetChatIcon()
	return cw.player:GetChatIcon(self)
end

playerMeta.GetName = playerMeta.Name
playerMeta.Nick = playerMeta.Name;
