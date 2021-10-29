--[[
	Rework © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

local TOOL = cw.tool:New()

TOOL.Category = "Clockwork"
TOOL.Name = "Text Tool"
TOOL.UniqueID = "texts"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["text"] = "Sample Text"
TOOL.ClientConVar["style"] = "1"
TOOL.ClientConVar["scale"] = "1"
TOOL.ClientConVar["fade"] = "0"
TOOL.ClientConVar["color"] = "white"
TOOL.ClientConVar["extraColor"] = "red"

function TOOL:LeftClick(trace)
	if (CLIENT) then return true end

	local player = self:GetOwner()

	if (!IsValid(player) or !player:IsAdmin()) then return end

	local text = self:GetClientInfo("text")
	local style = self:GetClientNumber("style")
	local scale = self:GetClientNumber("scale")
	local color = Color(self:GetClientInfo("color") or "white")
	local extraColor = Color(self:GetClientInfo("extraColor") or "#FF0000AA")
	local fadeOffset = self:GetClientNumber("fade")

	if (!text or text == "") then return false end

	local angle = trace.HitNormal:Angle()
	angle:RotateAroundAxis(angle:Forward(), 90)
	angle:RotateAroundAxis(angle:Right(), 270)

	local data = {
		text = text,
		style = style,
		color = color,
		extraColor = extraColor,
		angle = angle,
		pos = trace.HitPos,
		normal = trace.HitNormal,
		scale = scale,
		fadeOffset = fadeOffset
	}

	cwSurfaceTexts:AddText(data)

	cw.player:Notify(player, "You have added a 3D text.")

 	return true
end

function TOOL:RightClick(trace)
	if (CLIENT) then return true end

	cwSurfaceTexts:Remove(self:GetOwner())

	return true
end

local textStyles = {
	["#tool.texts.opt1"] = 1,
	["#tool.texts.opt2"] = 2,
	["#tool.texts.opt3"] = 3,
	["#tool.texts.opt4"] = 4,
	["#tool.texts.opt5"] = 5,
	["#tool.texts.opt6"] = 6
}

function TOOL.BuildCPanel(CPanel)
	local options = {}

	for k, v in pairs(textStyles) do
		options[k] = {["texts_style"] = v}
	end

	CPanel:AddControl("Header", { Description = "#tool.texts.desc" })

	local controlPresets = CPanel:AddControl("ComboBox", { MenuButton = 1, Folder = "textstyle", Options = options, CVars = {"texts_style"} })
	controlPresets.Button:SetVisible(false)
	controlPresets.DropDown:SetValue("Please Choose")

	CPanel:AddControl("TextBox", { Label = "#tool.texts.text", Command = "texts_text", MaxLenth = "128" })
	CPanel:AddControl("TextBox", { Label = "#tool.texts.color", Command = "texts_color", MaxLenth = "16" })
	CPanel:AddControl("TextBox", { Label = "#tool.texts.extraColor", Command = "texts_extraColor", MaxLenth = "16" })
	CPanel:AddControl("Slider", { Label = "#tool.texts.scale", Command = "texts_scale", Type = "Float", Min = 0.01, Max = 10 })
	CPanel:AddControl("Slider", { Label = "#tool.texts.fade", Command = "texts_fade", Type = "Integer", Min = -1024, Max = 10000 })
end

TOOL:Register()