--- Defines the `cwScoreboard` menu tab, which lists the players grouped by scoreboard class, and its `cwScoreboardItem`
-- player rows.
--
-- Grouping, visibility, sorting and the text of a row come from the `GetPlayerScoreboardClass`,
-- `PlayerShouldShowOnScoreboard`, `ScoreboardSortClassPlayers` and `GetPlayerScoreboardText` hooks. Clicking a row's
-- model opens the options from `GetPlayerScoreboardOptions`.

local PANEL = {}

--- Sizes the scoreboard menu tab to the menu, stores it as `cw.scoreboard` and builds it.
function PANEL:Init()
  self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

  self.panelList = vgui.Create('cwPanelList', self)
  self.panelList:SetPadding(8)
  self.panelList:SetSpacing(8)
  self.panelList:StretchToParent(4, 4, 4, 4)
  self.panelList:HideBackground()

  cw.scoreboard = self
  cw.scoreboard:Rebuild()
end

--- Rebuilds the scoreboard, grouping initialized players by scoreboard class.
--
-- The class comes from the `GetPlayerScoreboardClass` hook, and players are listed when
-- `PlayerShouldShowOnScoreboard` allows it. Players in a class are sorted with the
-- `ScoreboardSortClassPlayers` hook and classes by name; each player is a `cwScoreboardItem`.
function PANEL:Rebuild()
  self.panelList:Clear()

  local availableClasses = {}
  local classes = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      local class = hook.Run('GetPlayerScoreboardClass', v)

      if class then
        if !availableClasses[class] then
          availableClasses[class] = {}
        end

        if hook.Run('PlayerShouldShowOnScoreboard', v) then
          availableClasses[class][#availableClasses[class] + 1] = v
        end
      end
    end
  end

  for k, v in pairs(availableClasses) do
    table.sort(v, function(a, b)
      return hook.Run('ScoreboardSortClassPlayers', k, a, b)
    end)

    if #v > 0 then
      classes[#classes + 1] = { name = k, players = v }
    end
  end

  table.sort(classes, function(a, b)
    return a.name < b.name
  end)

  if table.Count(classes) > 0 then
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#Scoreboard_Tip')
      label:SetInfoColor('blue')
    self.panelList:AddItem(label)

    local playersLabel = vgui.Create('DLabel', self)
      playersLabel:SetText(
        '#Scoreboard_PlayersOnline:'..tostring(#_player.GetAll())..','..tostring(game.MaxPlayers())..';'
      )
      playersLabel:SetFont(cw.option:GetFont('scoreboard_desc'))
      playersLabel:SizeToContents()
    self.panelList:AddItem(playersLabel)

    for k, v in pairs(classes) do
      local classData = cw.class:FindByID(v.name)
      local classColor = nil

      if classData then
        -- classColor = classData.color
      end

      local characterForm = vgui.Create('cwBasicForm', self)
      characterForm:SetPadding(8)
      characterForm:SetSpacing(8)
      characterForm:SetAutoSize(true)
      characterForm:SetText(
        cw.lang:TranslateText(v.name)..(istable(v.players) and ' ('..tostring(#v.players)..')'),
        cw.option:GetFont('scoreboard_class'),
        classColor
      )

      local panelList = vgui.Create('DPanelList', self)

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

        panelList:AddItem(vgui.Create('cwScoreboardItem', self))
      end

      characterForm:AddItem(panelList)

      self.panelList:AddItem(characterForm)

      panelList:InvalidateLayout(true)
    end
  else
    local label = vgui.Create('cwInfoText', self)
      label:SetText('#Scoreboard_NoPlayers')
      label:SetInfoColor('orange')
    self.panelList:AddItem(label)
  end

  self.panelList:InvalidateLayout(true)
end

--- Rebuilds the scoreboard when the menu is opened while this tab is active.
function PANEL:OnMenuOpened()
  if cw.menu:IsPanelActive(self) then
    self:Rebuild()
  end
end

--- Rebuilds the scoreboard when the tab is selected in the menu.
function PANEL:OnSelected() self:Rebuild() end

--- Does nothing; the list lays itself out.
function PANEL:PerformLayout(w, h) end

--- Draws the outlined panel background.
function PANEL:Paint(w, h)
  draw.RoundedBox(0, 0, 0, w, h, cw.option:GetColor('panel_outline'))
  draw.RoundedBox(0, 1, 1, w - 2, h - 2, cw.option:GetColor('panel_background'))

  return true
end

vgui.Register('cwScoreboard', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds a player row (`cwScoreboardItem`) from the parent's `playerData`: name, faction or custom text,
-- model (or an unknown icon when the player is not recognised) and Steam avatar.
--
-- The text comes from the `GetPlayerScoreboardText` hook and the whole info table can be changed with
-- `ScoreboardAdjustPlayerInfo`. Clicking the model opens a menu with the options from
-- `GetPlayerScoreboardOptions`; clicking the avatar opens the Steam profile. The global
-- `SCOREBOARD_PANEL` is `true` while the row is being built.
function PANEL:Init()
  SCOREBOARD_PANEL = true

  self:SetSize(self:GetParent():GetWide(), 38)

  local nameFont = cw.option:GetFont('scoreboard_name')
  local descFont = cw.option:GetFont('scoreboard_desc')
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

  info.text = hook.Run('GetPlayerScoreboardText', info.player)

  hook.Run('ScoreboardAdjustPlayerInfo', info)

  self.toolTip = info.toolTip
  self.player = info.player

  self.nameLabel = vgui.Create('DLabel', self)
  self.nameLabel:SetText(info.name)
  self.nameLabel:SetFont(nameFont)
  self.nameLabel:SetTextColor(cw.option:GetColor('scoreboard_name'))
  self.nameLabel:SizeToContents()

  self.factionLabel = vgui.Create('DLabel', self)
  self.factionLabel:SetText(info.faction)
  self.factionLabel:SetFont(descFont)
  self.factionLabel:SetTextColor(cw.option:GetColor('scoreboard_desc'))
  self.factionLabel:SizeToContents()

  if isstring(info.text) then
    self.factionLabel:SetText(info.text)
    self.factionLabel:SizeToContents()
  end

  if info.doesRecognise then
    self.spawnIcon = vgui.Create('cwSpawnIcon', self)
    self.spawnIcon:SetModel(info.model, info.skin)
    self.spawnIcon:SetSize(32, 32)
  else
    self.spawnIcon = vgui.Create('DImageButton', self)
    self.spawnIcon:SetImage('clockwork/unknown.png')
    self.spawnIcon:SetSize(32, 32)
  end

  -- Called when the spawn icon is clicked.
  function self.spawnIcon.DoClick(spawnIcon)
    local options = {}

    hook.Run('GetPlayerScoreboardOptions', info.player, options)
    cw.core:AddMenuFromData(nil, options)
  end

  self.avatarImage = vgui.Create('AvatarImage', self)
  self.avatarImage:SetSize(32, 32)

  self.avatarButton = vgui.Create('DButton', self.avatarImage)
  self.avatarButton:Dock(FILL)
  self.avatarButton:SetText('')
  self.avatarButton:SetDrawBorder(false)
  self.avatarButton:SetPaintBackground(false)

  if info.avatarImage then
    self.avatarButton:SetTooltip(
      L('#Scoreboard_SteamNameIs')..' '..info.steamName..'.\n'..L('#Scoreboard_SteamIDIs')..' '..info.player:SteamID()..
        '.'
    )
    self.avatarButton.DoClick = function(button)
      if IsValid(info.player) then
        info.player:ShowProfile()
      end
    end

    self.avatarImage:SetPlayer(info.player, 64)
  end

  SCOREBOARD_PANEL = nil
end

--- Draws the player row's grey background.
function PANEL:Paint(width, height)
  draw.RoundedBox(2, 0, 0, width, height, Color(75, 75, 75))

  return true
end

--- Shows the player's ping, or the custom tooltip, on the row's icon.
function PANEL:Think()
  if IsValid(self.player) then
    if self.toolTip then
      self.spawnIcon:SetTooltip(self.toolTip)
    else
      self.spawnIcon:SetTooltip(L('#Scoreboard_Ping:'..self.player:Ping()..';'))
    end
  end

  self.spawnIcon:SetPos(4, 4)
  self.spawnIcon:SetSize(40, 40)
end

--- Places the player row's icon, avatar and labels.
function PANEL:PerformLayout(w, h)
  self.factionLabel:SizeToContents()

  self.spawnIcon:SetPos(4, 4)
  self.spawnIcon:SetSize(32, 32)
  self.avatarImage:SetPos(44, 4)
  self.avatarImage:SetSize(32, 32)

  self.nameLabel:SetPos(92, 2)
  self.factionLabel:SetPos(92, self.nameLabel.y + self.nameLabel:GetTall() + 2)
end

vgui.Register('cwScoreboardItem', PANEL, 'DPanel')
