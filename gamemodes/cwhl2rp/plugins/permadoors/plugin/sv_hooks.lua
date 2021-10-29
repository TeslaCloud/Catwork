--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwPermaDoors:PlayerDoesHaveDoorAccess(player, door, access, isAccurate)
	local secretKey = player:GetCharacterData("PermaDoorSecret")

	if (secretKey) then
		local permaDoor = self.stored[door]

		if (permaDoor and permaDoor.secret == secretKey) then
			return true
		end
	end
end

function cwPermaDoors:ClockworkInitPostEntity()
	self:LoadPermaDoors()
end

function cwPermaDoors:LoadPermaDoors()
	local positions = {}
	local data = cw.core:RestoreSchemaData("plugins/permadoors/"..game.GetMap())

	for k, v in pairs(cw.entity:GetDoorEntities()) do
		if (IsValid(v)) then
			local position = v:GetPos()

			if (position) then
				positions[tostring(position)] = v
			end
		end
	end

	for k, v in pairs(data) do
		local door = positions[tostring(v.position)]

		if (IsValid(door) and cw.entity:IsDoor(door)) then
			cw.entity:SetDoorUnownable(door, true)
			cw.entity:SetDoorName(door, v.name)
			cw.entity:SetDoorText(door, v.text)

			self.stored[door] = v
		end
	end
end

function cwPermaDoors:SavePermaDoors()
	local toSave = {}

	for k, v in pairs(self.stored) do
		if (v) then
			local saveTable = {
				name = v.name,
				text = v.text,
				secret = v.secret,
				position = k:GetPos()
			}

			table.insert(toSave, saveTable)
		end
	end

	cw.core:SaveSchemaData("plugins/permadoors/"..game.GetMap(), toSave)
end
