--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PLUGIN = PLUGIN

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass()

	if (class == "cw_book" and arguments == "cw_bookTake" or arguments == "cw_bookView") then
		if (arguments == "cw_bookView") then
			netstream.Start(player, "ViewBook", entity)
		else
			local success, fault = player:GiveItem(item.CreateInstance(entity.book.uniqueID))

			if (!success) then
				cw.player:Notify(player, fault)
			else
				entity:Remove()
			end
		end
	end
end

-- Called when CW has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadBooks()
end

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SaveBooks()
end
