--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwCraft:PlayerCraftItem(player, bpTable)
	local materials = bpTable["recipe"]
	local result = bpTable["finish"]
	local updatt = bpTable["updatt"]

	if (materials) then
		for k, v in pairs(materials) do
			for i = 1, v[2] do
				player:TakeItemByID(v[1])
			end
		end
	end

	if (result) then
		for k, v in pairs(result) do
			for i = 1, v[2] do
				if (!player:GiveItem(v[1])) then
					cw.entity:CreateItem(nil, v[1], player:GetEyeTraceNoCursor().HitPos, Angle(0, 0, 0))
				end
			end
		end
	end

	if (updatt) then
		for k, v in pairs(updatt) do
			player:ProgressAttribute(v[1], v[2], true)
		end
	end

	cw.player:Notify(player, L("Craft_Notify", bpTable["name"]))
end

function cwCraft:SaveCraftTables()
	local craftTables = {}
	for k, v in ipairs(ents.GetAll()) do
		if (v.IsCraft) then
			craftTables[#craftTables + 1] = {
				class = v:GetClass(),
				angles = v:GetAngles(),
				position = v:GetPos()
			}
		end
	end
	cw.core:SaveSchemaData("plugins/craft/"..game.GetMap(), craftTables)
end

function cwCraft:LoadCraftTables()
	local craftTables = cw.core:RestoreSchemaData("plugins/craft/"..game.GetMap())
	
	for k, v in pairs(craftTables) do
		local device = ents.Create(v.class)

		if device then
			device:SetPos(v.position)
			device:SetAngles(v.angles)
			device:Spawn()
			device:GetPhysicsObject():EnableMotion(false)
		end
	end
end

function cwCraft:ClockworkInitPostEntity()
	self:LoadCraftTables()
end

function cwCraft:PostSaveData()
	self:SaveCraftTables()
end
