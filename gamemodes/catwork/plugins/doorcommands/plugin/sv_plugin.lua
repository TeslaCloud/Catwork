--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local IsDoorLocked = cw.entity.IsDoorLocked
local GetDoorState = cw.entity.GetDoorState

config.Add("default_doors_hidden", true, nil, nil, nil, nil, true)
config.Add("doors_save_state", true, nil, nil, nil, nil, true)

-- A function to load the parent data.
function cwDoorCmds:LoadParentData()
	self.parentData = self.parentData or {}

	local parentData = cw.core:RestoreSchemaData("plugins/parents/"..game.GetMap())
	local positions = {}

	for k, v in pairs(cw.entity:GetDoorEntities()) do
		if (IsValid(v)) then
			local position = v:GetPos()

			if (position) then
				positions[tostring(position)] = v
			end
		end
	end

	for k, v in pairs(parentData) do
		local parent = positions[tostring(v.parentPosition)]
		local entity = positions[tostring(v.position)]

		if (IsValid(entity) and IsValid(parent) and !self.parentData[entity]) then
			if (cw.entity:IsDoor(entity) and cw.entity:IsDoor(parent)) then
				cw.entity:SetDoorParent(entity, parent)

				self.parentData[entity] = parent
			end
		end
	end
end

-- A function to load the door data.
function cwDoorCmds:LoadDoorData()
	self.doorData = self.doorData or {}

	local positions = {}
	local doorData = cw.core:RestoreSchemaData("plugins/doors/"..game.GetMap())

	for k, v in pairs(cw.entity:GetDoorEntities()) do
		if (IsValid(v)) then
			local position = v:GetPos()

			if (position) then
				positions[tostring(position)] = v
			end
		end
	end

	for k, v in pairs(doorData) do
		local entity = positions[tostring(v.position)]

		if (IsValid(entity) and !self.doorData[entity]) then
			if (cw.entity:IsDoor(entity)) then
				local data = {
					customName = v.customName,
					position = v.position,
					entity = entity,
					name = v.name,
					text = v.text
				}

				if (!data.customName) then
					cw.entity:SetDoorUnownable(data.entity, true)
					cw.entity:SetDoorName(data.entity, data.name)
					cw.entity:SetDoorText(data.entity, data.text)
				else
					cw.entity:SetDoorName(data.entity, data.name)
				end

				self.doorData[data.entity] = data
			end
		end
	end

	if (config.Get("default_doors_hidden"):Get()) then
		for k, v in pairs(positions) do
			if (!self.doorData[v]) then
				cw.entity:SetDoorHidden(v, true)
			end
		end
	end
end

-- A function to save the parent data.
function cwDoorCmds:SaveParentData()
	local parentData = {}

	for k, v in pairs(self.parentData) do
		if (IsValid(k) and IsValid(v)) then
			parentData[#parentData + 1] = {
				parentPosition = v:GetPos(),
				position = k:GetPos()
			}
		end
	end

	cw.core:SaveSchemaData("plugins/parents/"..game.GetMap(), parentData)
end

-- A function to save the door data.
function cwDoorCmds:SaveDoorData()
	local doorData = {}

	for k, v in pairs(self.doorData) do
		local data = {
			customName = v.customName,
			position = v.position,
			name = v.name,
			text = v.text
		}

		doorData[#doorData + 1] = data
	end

	cw.core:SaveSchemaData("plugins/doors/"..game.GetMap(), doorData)
end

function cwDoorCmds:SaveDoorStates()
	local doorTable = {}

	for k, v in pairs(cw.entity:GetDoorEntities()) do
		if (v:IsValid()) then
			doorTable[#doorTable + 1] = {
				position = v:GetPos(),
				bLocked = IsDoorLocked(cw.entity, v),
				state = GetDoorState(cw.entity, v)
			}
		end
	end

	cw.core:SaveSchemaData("plugins/doorstates/"..game.GetMap(), doorTable)
end

function cwDoorCmds:LoadDoorStates()
	local doorTable = cw.core:RestoreSchemaData("plugins/doorstates/"..game.GetMap())
	local positions = {}

	for k, v in pairs(cw.entity:GetDoorEntities()) do
		if (IsValid(v)) then
			local position = v:GetPos()

			if (position) then
				positions[tostring(position)] = v
			end
		end
	end

	for k, v in pairs(doorTable) do
		local entity = positions[tostring(v.position)]

		if (IsValid(entity) and cw.entity:IsDoor(entity)) then

			if (v.state == 1 or v.state == 2) then
				cw.entity:OpenDoor(entity, 0)
			end

			if (v.bLocked) then
				entity:Fire("lock", "", 0)
			end
		end
	end
end
