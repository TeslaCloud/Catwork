--- Defines the `cwCombinePDA` main menu panel of the Combine Civil Authority plugin, a mock web browser for looking up
-- players by name, and the `cwCombinePlayerCard` window it opens for a player.
--
-- The PDA shows a search bar under a random search engine name, lists up to six matching players while typing
-- (refugees and rebels are left out) and opens the card when enter is pressed. The card shows the player's model,
-- faction, residence, points, loyalist tier, citizen status and civil record (`cwCombinePlayerLog`), plus the action
-- buttons that the `AddCombinePDAButons` hook adds with `AddButton`.

local combine_search_engine_name = 'Combinoogle'
local engineNames = {
  'Combinoogle',
  'Alliandex',
  'Mail.Combine',
  'Ming',
  'OTAhoo',
  'Capitol.NET'
}

local browserNames = {
  'Combine Chrome',
  'Alliance Firefox',
  'OTA Edge',
  'UU Explorer',
  'Orbera',
  'CapitolNET'
}

local PANEL = {}

--- Creates the PDA's search bar and registers the panel as `Schema.pdaPanel`.
function PANEL:Init()
  self.searchBar = vgui.Create('DTextEntry', self)

  Schema.pdaPanel = self
  Schema.pdaPanel:Rebuild()
end

--- Lays out the PDA with a random browser and search engine name.
--
-- Pressing enter in the search bar opens a `cwCombinePlayerCard` for the player whose name matches.
function PANEL:Rebuild()
  self:SetSize(ScrW() * 0.5, ScrH() * 0.6)
  self:SetTitle(table.Random(browserNames))

  local width, height = self:GetWide(), self:GetTall()

  combine_search_engine_name = table.Random(engineNames)

  self.searchBar:SetSize(width - 64, 32)
  self.searchBar:SetPos(32, height / 2 - 16)
  self.searchBar.OnEnter = function(bar)
    if IsValid(self.playerCard) then
      self.playerCard:SafeRemove()
    end

    local player = _player.Find(bar:GetValue())

    if IsValid(player) then
      self.playerCard = vgui.Create('cwCombinePlayerCard')
      self.playerCard:SetPlayer(player)
      self.playerCard:MakePopup()
    end
  end
end

--- Hides the frame's close, minimise and maximise buttons.
function PANEL:Think()
  if IsValid(self.btnClose) and self.btnClose:IsVisible() then
    self.btnClose:SetVisible(false)
    self.btnMinim:SetVisible(false)
    self.btnMaxim:SetVisible(false)
  end
end

--- Draws the search engine name and up to six players whose names match the search text.
--
-- Refugees and rebels are left out of the matches.
--
-- @warning [Expensive] Iterates every player each frame while the search bar has text.
function PANEL:PaintOver(width, height)
  local w, h = util.GetTextSize('DermaNarrow42', combine_search_engine_name)
  local sX, sY = self.searchBar:GetPos()

  draw.SimpleText(
    combine_search_engine_name,
    'DermaNarrowBold42',
    width / 2 - w / 2,
    height / 2 - h - 32,
    Color(255, 255, 255, (self.alpha or 255))
  )

  if IsValid(self.searchBar) then
    local val = self.searchBar:GetValue()

    if isstring(val) and val != '' then
      val = val:utf8lower()

      local matches = {}

      for k, v in ipairs(player.GetAll()) do
        if #matches >= 6 then break end

        local faction = v:GetFaction()

        if faction == FACTION_REFUGEE or faction == FACTION_REBEL then continue end

        if v:Name():utf8lower():find(val, 1, true) then
          table.insert(matches, v)
        end
      end

      if #matches > 0 then
        local curY = 0
        self.alpha = 50

        for k, v in ipairs(matches) do
          draw.SimpleText(v:Name()..' ('..v:GetFaction()..')', 'DermaNarrow28', sX, curY + 64, _team.GetColor(v:Team()))

          curY = curY + 34
        end
      end
    else
      self.alpha = 255
    end
  end
end

--- Returns the PDA's width in the main menu.
-- @return [Number Half the screen width]
function PANEL:GetMenuWidth()
  return ScrW() * 0.5
end

--- Returns the PDA's height in the main menu.
-- @return [Number 60% of the screen height]
function PANEL:GetMenuHeight()
  return ScrH() * 0.6
end

vgui.Register('cwCombinePDA', PANEL, 'DFrame')

local PANEL = {}
PANEL.buttons = {}

--- Creates the player card's civil record list and fires `AddCombinePDAButons` to collect its buttons.
function PANEL:Init()
  self.buttons = {}

  self.logs = vgui.Create('cwCombinePlayerLog', self)
  self.logs:SetPos(0, 220)
  self.logs:SetSize(self:GetWide(), self:GetTall() - 221)

  hook.Run('AddCombinePDAButons', self)

  self:Rebuild()
end

--- Lays out the card for its player: civil record, model and the buttons the viewer may use.
--
-- Buttons are hidden for Combine targets, and Combine-only buttons for non-Combine viewers.
function PANEL:Rebuild()
  self:SetTitle('')

  if !IsValid(self.player) then return end

  self.logs:SetPlayer(self.player)

  self:SetTitle(self.player:Name())

  local scrW, scrH = ScrW(), ScrH()

  self:SetSize(scrW / 2, scrH / 2)
  self:SetPos(scrW / 4, scrH / 4)

  self.logs:SetPos(1, 330)
  self.logs:SetSize(self:GetWide() - 2, self:GetTall() - 331)
  self.logs:Rebuild()

  self.model = vgui.Create('DModelPanel', self)
  self.model:SetSize(200, 200)
  self.model:SetPos(-32, 32)
  self.model:SetModel(self.player:GetModel())

  function self.model:LayoutEntity(entity) return end

  if Schema:PlayerIsCombine(self.player) then return end

  local isCombine = Schema:PlayerIsCombine(cw.client)
  local line = 0
  local offset = 0
  local offsetX = 0

  for k, v in pairs(self.buttons) do
    if v.combine and !isCombine then continue end

    local btn = vgui.Create('DButton', self)
    btn:SetPos(155 + offsetX, 130 + offset)
    btn:SetText(v.name)
    btn:SizeToContents()
    btn:SetTall(32)
    btn.DoClick = function(btn)
      v.callback(self, btn)
    end

    line = line + 1
    offsetX = offsetX + btn:GetWide() + 8

    if line >= 3 then
      offset = offset + 40
      line = 0
      offsetX = 0
    end
  end
end

--- Adds an action button to the player card; it appears on the next `Rebuild`.
--
-- ```
-- pda:AddButton('jail', '#PDA_Jail', true, function(card, button)
--   netstream.Start('Application::PDA::Controller::Jail', card.player)
-- end)
-- ```
--
-- @param id [String Unique ID of the button]
-- @param name [String Button text or language key]
-- @param bIsCombine [Boolean Whether only Combine players see the button]
-- @param callback [Function Called with the card panel and the button when clicked]
function PANEL:AddButton(id, name, bIsCombine, callback)
  table.insert(self.buttons, {
    name = name,
    uniqueID = id,
    combine = bIsCombine,
    callback = callback
  })
end

--- Sets the player the card shows and rebuilds it.
-- @param player [Player The player, or a name to look up with `_player.Find`; invalid values are ignored]
function PANEL:SetPlayer(player)
  if IsValid(player) then
    self.player = player
    self:Rebuild()
  elseif isstring(player) then
    local ply = _player.Find(player)

    if IsValid(ply) then
      self:SetPlayer(ply)
    end
  end
end

--- Draws the player's name, faction, residence, points, loyalist tier and citizen status.
--
-- Combine players show an insufficient permissions message instead of their details.
function PANEL:PaintOver(width, height)
  if !IsValid(self.player) then
    draw.SimpleText('#PDA_Error', 'DermaNarrow42', 32, 32, Color(255, 100, 100))

    return
  end

  draw.SimpleText(self.player:Name(), 'DermaNarrow30', 155, 50, Color(255, 255, 255))
  draw.SimpleText(self.player:GetFaction(), 'DermaNarrow22', 155, 80, team.GetColor(self.player:Team()))

  if Schema:PlayerIsCombine(self.player) then
    draw.SimpleText('#Err_CMB_InsufficientPermissions', 'DermaNarrow24', 155, 120, Color(255, 50, 50))
  else
    local points = math.floor(Schema:GetLP(self.player))
    local tier = Schema:DetermineLoyalistTier(points)
    local status = '#Status_'..Schema:GetCitizenStatus(self.player)
    local color = tier.color
    local color2 = Schema:GetCitizenStatusColor(self.player)
    local w, h = util.GetTextSize('DermaNarrow15', tier.name)
    local xPos, yPos, boxW = 10, 250, 140
    local pointsText =
      '#LP: '..points..' | #CP: '..Schema:GetCP(self.player)..' | #WP: '..Schema:GetWorkPoints(self.player)
    local pW, pH = util.GetTextSize('DermaNarrow15', pointsText)

    draw.SimpleText('#Residence: '..Schema:GetResidence(self.player), 'DermaNarrow15', 155, 107, Color(255, 255, 255))

    draw.SimpleText(pointsText, 'DermaNarrow15', 76 - pW / 2, yPos - 26, Color(255, 255, 255))

    draw.RoundedBox(0, xPos - 4, yPos - 6, boxW, h + 12, color)
    draw.SimpleText(tier.name, 'DermaNarrow15', (xPos + boxW) / 2 - w / 2, yPos, color:Darken(80))

    yPos = yPos + h + 18

    w, h = util.GetTextSize('DermaNarrow15', status)

    draw.RoundedBox(0, xPos - 4, yPos - 6, boxW, h + 12, color2)
    draw.SimpleText(status, 'DermaNarrow15', (xPos + boxW) / 2 - w / 2, yPos, color2:Darken(80))
  end
end

vgui.Register('cwCombinePlayerCard', PANEL, 'DFrame')
