--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local TOOL = cw.tool:New()

TOOL.Category = "Clockwork"
TOOL.UniqueID = "static"
TOOL.Name = "Static Add/Remove"
TOOL.Command = nil
TOOL.ConfigName = ""

function TOOL:LeftClick(trace)
	if (CLIENT) then return true end

	local player = self:GetOwner()

	plugin.Call("PlayerMakeStatic", player, true)

 	return true
end

function TOOL:RightClick(trace)
	if (CLIENT) then return true end

	local player = self:GetOwner()

	plugin.Call("PlayerMakeStatic", player, false)

	return true
end

TOOL:Register();
