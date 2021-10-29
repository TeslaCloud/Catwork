--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwCraft:PlayerCanSeeCraft(bpTable)
	local flags = bpTable["flag"]
	local atts = bpTable["reqatt"]

	if (atts) then
		for k, v in pairs(atts) do
			local att = cw.attributes:Fraction(v[1], 100)

			if (v[2] and att) then
				if ((v[2] >= 25 and att < 25) or
				(v[2] >= 50 and att < 50) or
				(v[2] >= 75 and att < 75)) then
					return false
				end
			end
		end
	end

	return true
end

netstream.Hook("Craft::OpenMenu", function(class, name)
	if (CRAFT_TABLE_MENU) then
		CRAFT_TABLE_MENU:Remove()
		CRAFT_TABLE_MENU = nil
	end

	CRAFT_TABLE_MENU = vgui.Create("cwCraft")
	CRAFT_TABLE_MENU:MakePopup()
	CRAFT_TABLE_MENU:Center()
	CRAFT_TABLE_MENU.class = class
	CRAFT_TABLE_MENU.name = name
end)
