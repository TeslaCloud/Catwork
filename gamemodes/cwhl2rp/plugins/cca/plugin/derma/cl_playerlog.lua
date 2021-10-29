local color_black = Color(0, 0, 0)

local PANEL = {}
PANEL.player = nil

function PANEL:Init()
	self.scrollPanel = vgui.Create("DScrollPanel", self)
	self.scrollPanel:SetSize(self:GetWide(), self:GetTall())
	self.scrollPanel:SetPos(0, 0)
end

function PANEL:SetPlayer(player)
	self.player = player

	print(self.player)

	self:Rebuild()
end

function PANEL:Rebuild()
	local player = self.player
	local width = self:GetWide()
	local height = self:GetTall()

	self.scrollPanel:SetSize(width, height)
	self.scrollPanel:SetPos(0, 0)
	self.scrollPanel.Paint = function(panel, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20)) end

	if (IsValid(player)) then
		local logs = player:GetNetVar("CCA_Logs") or {}

		if (#logs > 0) then
			if (IsValid(self.nope)) then
				self.nope:SetVisible(false)
				self.nope:Remove()
			end

			local lastPos = 0

			for i = #logs, 1, -1 do
				local panel = vgui.Create("cwPlayerLogEntry", self.scrollPanel)
					panel:SetData(logs[i])
					panel:SetSize(width, 24)
					panel:SetPos(0, lastPos)
				self.scrollPanel:AddItem(panel)

				lastPos = lastPos + 24
			end
		else
			self.nope = vgui.Create("cwInfoText", self.scrollPanel)
				self.nope:SetText("There are no logs to display!")
				self.nope:SetInfoColor("red")
				self.nope:SetSize(width, 32)
				self.nope:SetPos(0, 0)
			self.scrollPanel:AddItem(self.nope)
		end
	end
end

function PANEL:Paint(w, h) end

vgui.Register("cwCombinePlayerLog", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:SetData(data)
	self.data = data
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 255))

	if (istable(self.data)) then
		local text = self.data.entry or "UNKNOWN ENTRY"
		local type = self.data.type or "default"
		local name = self.data.appender or "Overwatch"
		local time = os.date("%H:%M, %d.%m.%Y", self.data.time)
		local data = cca.GetLogType(type)
		local font = "DermaNarrowBold15"

		draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40))
		draw.RoundedBox(0, 1, 1, w - 2, h - 2, data.color)

		draw.SimpleText(text, font, 4, 4, color_black)
		draw.SimpleText(name, font, w - w / 2.5, 4, color_black)
		draw.SimpleText(time, font, w - w / 6, 4, color_black)
	end
end

vgui.Register("cwPlayerLogEntry", PANEL, "EditablePanel")