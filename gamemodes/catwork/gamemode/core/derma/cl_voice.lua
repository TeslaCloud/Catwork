--- Redefines the `VoiceNotify` derma control, the notice shown while a player speaks over voice chat.
--
-- Players the local player does not recognise are shown with their unrecognised name and an unknown avatar instead of
-- their name and Steam avatar.

local PANEL = {}

Derma_Hook(PANEL, 'Paint', 'Paint', 'VoiceNotify')
Derma_Hook(PANEL, 'PerformLayout', 'Layout', 'VoiceNotify')
Derma_Hook(PANEL, 'ApplySchemeSettings', 'Scheme', 'VoiceNotify')

--- Creates the voice notice's name label.
function PANEL:Init()
  self.LabelName = vgui.Create('DLabel', self)
end

--- Sets the voice notice up for a speaking player.
--
-- Players the local player does not fully recognise are shown with their unrecognised name in brackets,
-- cut to 24 characters when it is a physical description, and an unknown avatar. Recognised players are
-- shown with their name and Steam avatar. The background uses the player's team color.
--
-- @param player [Player The speaking player]
function PANEL:Setup(player)
  if !cw.player:DoesRecognise(player, RECOGNISE_TOTAL) then
    local unrecognisedName, usedPhysDesc = cw.player:GetUnrecognisedName(player)

    if usedPhysDesc and string.utf8len(unrecognisedName) > 24 then
      unrecognisedName = string.utf8sub(unrecognisedName, 1, 21)..'...'
    end

    self.Recognises = false
    self.LabelName:SetText('['..unrecognisedName..']')
    self.Avatar = vgui.Create('DImage', self)
  else
    self.Recognises = true
    self.LabelName:SetText(player:Name())

    self.Avatar = vgui.Create('AvatarImage', self)
    self.Avatar:SetSize(32, 32)
  end

  self.LabelName:SetFont('DermaDefault')
  self.LabelName:SetContentAlignment(4)
  self.LabelName:SetColor(color_white)
  self:InvalidateLayout()

  self.TeamColor = _team.GetColor(player:Team())
  self.Color = self.TeamColor
  self.Player = player
  self.Initialized = true
  self.Volume = 0

  if self.Recognises then
    self.Avatar:SetPlayer(player)
  else
    self.Avatar:SetImage('clockwork/unknown.png')
  end
end

--- Removes the voice notice once its player stops speaking or leaves.
function PANEL:Think()
  if self.Initialized and (!IsValid(self.Player) or !self.Player:IsSpeaking()) then
    self:Remove()
  end
end

--- Draws the voice notice's background in the team color, brighter with the player's voice volume.
function PANEL:Paint(w, h)
  if IsValid(self.Player) then
    local r, g, b = self.Color.r, self.Color.g, self.Color.b
    local volume = math.Approach(self.Volume, self.Player:VoiceVolume(), FrameTime() * 30)

    self.Volume = volume

    surface.SetDrawColor(50 + (r * volume), 50 + (g * volume), 50 + (b * volume), 250)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(150, 150, 150, 100)
    surface.DrawOutlinedRect(0, 0, w, h)
  end
end

--- Places the voice notice's avatar and name in a 200 by 40 pixel box.
function PANEL:PerformLayout()
  self:SetSize(200, 40)
  self.Avatar:SetPos(4, 4)
  self.Avatar:SetSize(32, 32)
  self.LabelName:SetPos(42, 16)
  self.LabelName:CenterVertical()
  self.LabelName:SizeToContents()
end

-- Called when the panel should be layed out.
derma.DefineControl('VoiceNotify', '', PANEL, 'DPanel')
