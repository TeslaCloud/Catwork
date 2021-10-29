--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

if (cw.class) then return end

library.New("class", cw)
local stored = {}
local buffer = {}

function cw.class:GetStored()
	return stored
end

function cw.class:GetBuffer()
	return buffer
end

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE}

-- A function to register a new class.
function CLASS_TABLE:Register()
	return cw.class:Register(self, self.name)
end

-- A function to get a new class.
function cw.class:New(name)
	local object = cw.core:NewMetaTable(CLASS_TABLE)
		object.name = name or "Unknown"
	return object
end

-- A function to register a new class.
function cw.class:Register(data, name)
	if (!data.maleModel) then
		data.maleModel = data.femaleModel
	end

	if (!data.femaleModel) then
		data.femaleModel = data.maleModel
	end

	data.flags = data.flags or "b"
	data.limit = data.limit or 128
	data.wages = data.wages or 0
	data.index = cw.core:GetShortCRC(name)
	data.name = name
	data.factions = data.factions or {}

	team.SetUp(data.index, data.name, data.color)

	buffer[data.index] = data
	stored[data.name] = data

	if (SERVER and data.image and !_G["cwSharedBooted"]) then
		cw.core:AddFile("materials/"..data.image..".png")
	end

	return data.index
end

-- A function to get the class limit.
function cw.class:GetLimit(name)
	local class = self:FindByID(name)

	if (class) then
		if (class.limit != 128) then
			return math.ceil(class.limit / (128 / #_player.GetAll()))
		else
			return game.MaxPlayers()
		end
	else
		return 0
	end
end

-- A function to get all of the classes.
function cw.class:GetAll()
	return stored
end

-- A function to find a class by an identifier.
function cw.class:FindByID(identifier)
	if (!identifier) then return end

	if (tonumber(identifier)) then
		return buffer[tonumber(identifier)]
	else
		return stored[identifier]
	end
end

function cw.class:AssignToDefault(player)
	local defaultClasses = {}
	local faction = player:GetFaction()

	for k, v in pairs(stored) do
		if (v.factions and v.isDefault and table.HasValue(v.factions, faction)) then
			defaultClasses[#defaultClasses + 1] = v.index
		end
	end

	if (#defaultClasses > 0) then
		local class = defaultClasses[math.random(1, #defaultClasses)]

		if (class) then
			return self:Set(player, class)
		end
	else
		for k, v in pairs(stored) do
			if (v.factions and table.HasValue(v.factions, faction)) then
				return self:Set(player, v.index)
			end
		end

		for k, v in pairs(stored) do
			if (cw.core:HasObjectAccess(player, v)) then
				return self:Set(player, v.index)
			end
		end
	end
end

-- A function to get an appropriate class model for a player.
function cw.class:GetAppropriateModel(name, player, noSubstitute)
	local defaultModel
	local class = self:FindByID(name)
	local model
	local skin

	if (SERVER) then
		defaultModel = player:GetDefaultModel()
	else
		defaultModel = player:GetNetVar("Model")
	end

	if (class) then
		model, skin = self:GetModelByGender(name, player:GetGender())

		if (class.GetModel) then
			model, skin = class:GetModel(player, defaultModel)
		end
	end

	if (!model and !noSubstitute) then
		model = defaultModel
	end

	if (!skin and !noSubstitute) then
		skin = 1
	end

	return model, skin
end

-- A function to get a class's model by gender.
function cw.class:GetModelByGender(name, gender)
	local model = self:Query(name, string.lower(gender).."Model")

	if (type(model) == "table") then
		return model[1], model[2]
	else
		return model, 0
	end
end

-- A function to check if a class has any flags.
function cw.class:HasAnyFlags(name, flags)
	local sFlagString = self:Query(name, "flags")

	if (sFlagString) then
		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i)

			if (string.find(sFlagString, flag)) then
				return true
			end
		end
	end
end

-- A function to check if a class has flags.
function cw.class:HasFlags(name, flags)
	local sFlagString = self:Query(name, "flags")

	if (sFlagString) then
		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i)

			if (!string.find(sFlagString, flag)) then
				return false
			end
		end

		return true
	end
end

-- A function to query a class.
function cw.class:Query(name, key, default)
	local class = self:FindByID(name)

	if (class) then
		return class[key] or default
	else
		return default
	end
end

if (SERVER) then
	function cw.class:Set(player, name, noRespawn, addDelay, noModelChange)
		local weapons = cw.player:GetWeapons(player)
		local oldClass = self:FindByID(player:Team())
		local newClass = self:FindByID(name)
		local ammo = cw.player:GetAmmo(player, !player.cwFirstSpawn)

		if (newClass) then
			player:SetTeam(newClass.index)

			if (!noModelChange) then
				hook.Run("PlayerSetModel", player)
			end

			if (!noRespawn) then
				player.cwChangeClass = true

				if (!player:Alive() or player.cwFirstSpawn) then
					player:Spawn()
				elseif (!player:IsRagdolled()) then
					cw.player:LightSpawn(player, weapons, ammo)
				end
			end

			if (addDelay) then
				player.cwNextChangeClass = CurTime() + config.Get("change_class_interval"):Get()
			end

			hook.Run("PlayerClassSet", player, newClass, oldClass, noRespawn, addDelay, noModelChange)

			return true
		else
			return false, "This is not a valid class!"
		end
	end
end
