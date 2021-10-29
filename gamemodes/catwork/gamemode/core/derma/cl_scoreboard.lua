--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

	self.panelList = vgui.Create("cwPanelList", self)
 	self.panelList:SetPadding(8)
 	self.panelList:SetSpacing(8)
	self.panelList:StretchToParent(4, 4, 4, 4)
	self.panelList:HideBackground()

	cw.scoreboard = self
	cw.scoreboard:Rebuild()
end

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear()

	local availableClasses = {}
	local classes = {}

	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			local class = hook.Run("GetPlayerScoreboardClass", v)

			if (class) then
				if (!availableClasses[class]) then
					availableClasses[class] = {}
				end

				if (hook.Run("PlayerShouldShowOnScoreboard", v)) then
					availableClasses[class][#availableClasses[class] + 1] = v
				end
			end
		end
	end

	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return hook.Run("ScoreboardSortClassPlayers", k, a, b)
		end)

		if (#v > 0) then
			classes[#classes + 1] = {name = k, players = v}
		end
	end

	table.sort(classes, function(a, b)
		return a.name < b.name
	end)

	if (table.Count(classes) > 0) then
		local label = vgui.Create("cwInfoText", self)
			label:SetText("#Scoreboard_Tip")
			label:SetInfoColor("blue")
		self.panelList:AddItem(label)

		local playersLabel = vgui.Create("DLabel", self)
			playersLabel:SetText("Игроков онлайн: "..tostring(#_player.GetAll()).." / "..tostring(game.MaxPlayers()))
			playersLabel:SetFont(cw.option:GetFont("scoreboard_desc"))
			playersLabel:SizeToContents()
		self.panelList:AddItem(playersLabel)

		for k, v in pairs(classes) do
			local classData = cw.class:FindByID(v.name)
			local classColor = nil

			if (classData) then
				--classColor = classData.color
			end

			local characterForm = vgui.Create("cwBasicForm", self)
			characterForm:SetPadding(8)
			characterForm:SetSpacing(8)
			characterForm:SetAutoSize(true)
			characterForm:SetText(cw.lang:TranslateText(v.name)..(istable(v.players) and " ("..tostring(#v.players)..")"), cw.option:GetFont("scoreboard_class"), classColor)

			local panelList = vgui.Create("DPanelList", self)

			panelList:SetAutoSize(true)
			panelList:SetPadding(4)
			panelList:SetSpacing(4)

			for k2, v2 in pairs(v.players) do
				self.playerData = {
					avatarImage = true,
					steamName = v2:SteamName(),
					faction = v2:GetFaction(),
					player = v2,
					class = _team.GetName(v2:Team()),
					model = v2:GetModel(),
					skin = v2:GetSkin(),
					name = v2:Name()
				}

				panelList:AddItem(vgui.Create("cwScoreboardItem", self))
			end

			characterForm:AddItem(panelList)

			self.panelList:AddItem(characterForm)

			panelList:InvalidateLayout(true)
		end
	else
		local label = vgui.Create("cwInfoText", self)
			label:SetText("There are no players to display.")
			label:SetInfoColor("orange")
		self.panelList:AddItem(label)
	end

	self.panelList:InvalidateLayout(true)
end

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (cw.menu:IsPanelActive(self)) then
		self:Rebuild()
	end
end

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h) end

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, cw.option:GetColor("panel_outline"))
	draw.RoundedBox(0, 1, 1, w - 2, h - 2, cw.option:GetColor("panel_background"))

	return true
end

vgui.Register("cwScoreboard", PANEL, "EditablePanel")

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	SCOREBOARD_PANEL = true

	self:SetSize(self:GetParent():GetWide(), 38)

	local nameFont = cw.option:GetFont("scoreboard_name")
	local descFont = cw.option:GetFont("scoreboard_desc")
	local playerData = self:GetParent().playerData
	local info = {
		doesRecognise = cw.player:DoesRecognise(playerData.player),
		avatarImage = playerData.avatarImage,
		steamName = playerData.steamName,
		faction = playerData.faction,
		player = playerData.player,
		class = playerData.class,
		model = playerData.model,
		skin = playerData.skin,
		name = playerData.name
	}

	info.text = hook.Run("GetPlayerScoreboardText", info.player)

	hook.Run("ScoreboardAdjustPlayerInfo", info)

	self.toolTip = info.toolTip
	self.player = info.player

	self.nameLabel = vgui.Create("DLabel", self)
	self.nameLabel:SetText(info.name)
	self.nameLabel:SetFont(nameFont)
	self.nameLabel:SetTextColor(cw.option:GetColor("scoreboard_name"))
	self.nameLabel:SizeToContents()

	self.factionLabel = vgui.Create("DLabel", self)
	self.factionLabel:SetText(info.faction)
	self.factionLabel:SetFont(descFont)
	self.factionLabel:SetTextColor(cw.option:GetColor("scoreboard_desc"))
	self.factionLabel:SizeToContents()

	if (isstring(info.text)) then
		self.factionLabel:SetText(info.text)
		self.factionLabel:SizeToContents()
	end

	if (info.doesRecognise) then
		self.spawnIcon = vgui.Create("cwSpawnIcon", self)
		self.spawnIcon:SetModel(info.model, info.skin)
		self.spawnIcon:SetSize(32, 32)
	else
		self.spawnIcon = vgui.Create("DImageButton", self)
		self.spawnIcon:SetImage("clockwork/unknown.png")
		self.spawnIcon:SetSize(32, 32)
	end

	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local options = {}

		hook.Run("GetPlayerScoreboardOptions", info.player, options)
		cw.core:AddMenuFromData(nil, options)
	end

	self.avatarImage = vgui.Create("AvatarImage", self)
	self.avatarImage:SetSize(32, 32)

	self.avatarButton = vgui.Create("DButton", self.avatarImage)
	self.avatarButton:Dock(FILL)
	self.avatarButton:SetText("")
	self.avatarButton:SetDrawBorder(false)
	self.avatarButton:SetDrawBackground(false)

	if (info.avatarImage) then
		self.avatarButton:SetTooltip("This player's name is "..info.steamName..".\nThis player's Steam ID is "..info.player:SteamID()..".")
		self.avatarButton.DoClick = function(button)
			if (IsValid(info.player)) then
				info.player:ShowProfile()
			end
		end

		self.avatarImage:SetPlayer(info.player, 64)
	end

	SCOREBOARD_PANEL = nil
end

function PANEL:Paint(width, height)
	draw.RoundedBox(2, 0, 0, width, height, Color(75, 75, 75))

	return true
end

-- Called each frame.
function PANEL:Think()
	if (IsValid(self.player)) then
		if (self.toolTip) then
			self.spawnIcon:SetTooltip(self.toolTip)
		else
			self.spawnIcon:SetTooltip("This player's ping is "..self.player:Ping()..".")
		end
	end

	self.spawnIcon:SetPos(4, 4)
	self.spawnIcon:SetSize(40, 40)
end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.factionLabel:SizeToContents()

	self.spawnIcon:SetPos(4, 4)
	self.spawnIcon:SetSize(32, 32)
	self.avatarImage:SetPos(44, 4)
	self.avatarImage:SetSize(32, 32)

	self.nameLabel:SetPos(92, 2)
	self.factionLabel:SetPos(92, self.nameLabel.y + self.nameLabel:GetTall() + 2)
end

vgui.Register("cwScoreboardItem", PANEL, "DPanel");
