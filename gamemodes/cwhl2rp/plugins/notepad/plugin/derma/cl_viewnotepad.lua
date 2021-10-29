--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	self:SetTitle("#Notepad_Title");

	-- Called when the button is clicked.
	function self.btnClose.DoClick(button)
		self:Close(); self:Remove();

		gui.EnableScreenClicker(false);
	end;

	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();

	self:SetSize(scrW * 0.45, scrH * 0.6);
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );

	if (!IsValid(self.entity) or self.entity:GetPos():Distance( cw.client:GetPos() ) > 192) then
		self:Close(); self:Remove();

		gui.EnableScreenClicker(false);
	end;
end;

-- A function to set the panel's entity.
function PANEL:SetEntity(entity)
	self.entity = entity;
end;

surface.CreateFont("cwNotepadFont", {
	font = "Roboto Condensed",
	extended = true,
	weight = 500,
	size = 16
});

-- A function to populate the panel.
function PANEL:Populate(text)
	local colorWhite = cw.option:GetColor("white");

	self.panelList:Clear();
	self.labels = {};

	self.textPanel = vgui.Create("DTextEntry");
	self.textPanel:SetMultiline(true);
	self.textPanel:SetValue(text);
	self.textPanel:SetSize(ScrW() * 0.45 - 4, ScrH() * 0.6 - 36);
	self.textPanel:SetPos(2, 2);
	self.textPanel:SetDisabled(true);
	self.textPanel:SetDrawBorder(false);
	self.textPanel:SetDrawBackground(false);
	self.textPanel:SetTextColor(Color("white"));
	self.textPanel:SetFont("cwNotepadFont");
	self.textPanel:SetVerticalScrollbarEnabled(true);
	self.textPanel.AllowInput = function(textEntry, text)
		return true;
	end;

	self.panelList:AddItem(self.textPanel);
end;

function PANEL:Paint(w, h)
	draw.RoundedBox(2, 0, 0, w, h, Color(35, 35, 35, 235));
	draw.RoundedBox(2, 4, 28, w - 8, h - 32, Color(30, 30, 30, 255))
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);

	DFrame.PerformLayout(self);
end;

vgui.Register("cwViewNotepad", PANEL, "DFrame");