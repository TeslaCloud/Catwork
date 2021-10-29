--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PLUGIN = PLUGIN

netstream.Hook("TakeBook", function(player, data)
	if (IsValid(data)) then
		if (data:GetClass() == "cw_book") then
			if (player:GetPos():Distance(data:GetPos()) <= 192 and player:GetEyeTraceNoCursor().Entity == data) then
				local success, fault = player:GiveItem(item.CreateInstance(data.book.uniqueID))

				if (!success) then
					cw.player:Notify(player, fault)
				else
					data:Remove()
				end
			end
		end
	end
end)

-- A function to load the books.
function PLUGIN:LoadBooks()
	local books = cw.core:RestoreSchemaData("plugins/books/"..game.GetMap())

	for k, v in pairs(books) do
		if (item.GetAll()[v.book]) then
			local entity = ents.Create("cw_book")

			cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

			entity:SetAngles(v.angles)
			entity:SetBook(v.book)
			entity:SetPos(v.position)
			entity:Spawn()

			if (!v.moveable) then
				local physicsObject = entity:GetPhysicsObject()

				if (IsValid(physicsObject)) then
					physicsObject:EnableMotion(false)
				end
			end
		end
	end
end

-- A function to save the books.
function PLUGIN:SaveBooks()
	local books = {}

	for k, v in pairs(ents.FindByClass("cw_book")) do
		local physicsObject = v:GetPhysicsObject()
		local moveable

		if (IsValid(physicsObject)) then
			moveable = physicsObject:IsMoveable()
		end

		books[#books + 1] = {
			key = cw.entity:QueryProperty(v, "key"),
			book = v.book.uniqueID,
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		}
	end

	cw.core:SaveSchemaData("plugins/books/"..game.GetMap(), books)
end
