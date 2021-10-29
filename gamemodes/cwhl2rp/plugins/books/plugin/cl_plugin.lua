--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PLUGIN = PLUGIN

netstream.Hook("ViewBook", function(data)
	local entity = data

	if (IsValid(entity)) then
		local index = entity:GetDTInt(0)

		if (index != 0) then
			local itemTable = item.FindByID(index)

			if (itemTable and itemTable.bookInformation) then
				if (IsValid(PLUGIN.bookPanel)) then
					PLUGIN.bookPanel:Close()
					PLUGIN.bookPanel:Remove()
				end

				PLUGIN.bookPanel = vgui.Create("cwViewBook")
				PLUGIN.bookPanel:SetEntity(entity)
				PLUGIN.bookPanel:Populate(itemTable)
				PLUGIN.bookPanel:MakePopup()
			end
		end
	end
end);
