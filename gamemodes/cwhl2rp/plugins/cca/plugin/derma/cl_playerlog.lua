--- Defines the `cwCombinePlayerLog` panel of the Combine Civil Authority plugin, a scrolling list of a player's civil
-- record, and `cwPlayerLogEntry`, one row of it.
--
-- The list reads the entries from the player's `CCA_Logs` net var and shows them newest first, or a notice when there
-- are none. Each row draws the entry's text, author and time on the color that `cca.GetLogType` gives for its type.

local color_black = Color(0, 0, 0)
local colorBackground = Color(20, 20, 20)
local colorBorder = Color(40, 40, 40)

local PANEL = {}
PANEL.player = nil

--- Creates the scroll panel that holds the civil record entries.
function PANEL:Init()
  self.scrollPanel = vgui.Create('DScrollPanel', self)
  self.scrollPanel:SetSize(self:GetWide(), self:GetTall())
  self.scrollPanel:SetPos(0, 0)
  self.scrollPanel.Paint = function(panel, w, h) draw.RoundedBox(0, 0, 0, w, h, colorBackground) end
end

--- Sets the player whose civil record is listed and rebuilds the list.
-- @param player [Player The player]
function PANEL:SetPlayer(player)
  self.player = player

  self:Rebuild()
end

--- Lists the player's civil record entries from the `CCA_Logs` net var, newest first.
--
-- Replaces the entries listed before. Shows a "no logs" notice when the record is empty.
function PANEL:Rebuild()
  local player = self.player
  local width = self:GetWide()
  local height = self:GetTall()

  self.scrollPanel:SetSize(width, height)
  self.scrollPanel:SetPos(0, 0)
  self.scrollPanel:Clear()

  if IsValid(player) then
    local logs = player:GetNetVar('CCA_Logs') or {}

    if #logs > 0 then
      local lastPos = 0

      for i = #logs, 1, -1 do
        local panel = vgui.Create('cwPlayerLogEntry', self.scrollPanel)
          panel:SetData(logs[i])
          panel:SetSize(width, 24)
          panel:SetPos(0, lastPos)
        self.scrollPanel:AddItem(panel)

        lastPos = lastPos + 24
      end
    else
      self.nope = vgui.Create('cwInfoText', self.scrollPanel)
        self.nope:SetText('#PDA_NoLogs')
        self.nope:SetInfoColor('red')
        self.nope:SetSize(width, 32)
        self.nope:SetPos(0, 0)
      self.scrollPanel:AddItem(self.nope)
    end
  end
end

--- Paints nothing; the scroll panel draws the background.
function PANEL:Paint(w, h) end

vgui.Register('cwCombinePlayerLog', PANEL, 'EditablePanel')

local PANEL = {}

--- Sets the civil record entry the row shows.
-- @param data [Map The entry, as stored by `cca.AppendLog`: `entry`, `type`, `time` and `appender`]
function PANEL:SetData(data)
  self.data = data
  self.timeText = nil

  if istable(data) then
    self.timeText = os.date('%H:%M, %d.%m.%Y', tonumber(data.time))
  end
end

--- Draws the entry's text, author and time on the colour of its log type.
function PANEL:Paint(w, h)
  draw.RoundedBox(0, 0, 0, w, h, colorBorder)

  if istable(self.data) then
    local text = self.data.entry or '#PDA_Log_UnknownEntry'
    local type = self.data.type or 'default'
    local name = self.data.appender or '#PDA_Log_Overwatch'
    local data = cca.GetLogType(type)
    local font = 'DermaNarrowBold15'

    draw.RoundedBox(0, 1, 1, w - 2, h - 2, data.color)

    draw.SimpleText(text, font, 4, 4, color_black)
    draw.SimpleText(name, font, w - w / 2.5, 4, color_black)
    draw.SimpleText(self.timeText, font, w - w / 6, 4, color_black)
  end
end

vgui.Register('cwPlayerLogEntry', PANEL, 'EditablePanel')
