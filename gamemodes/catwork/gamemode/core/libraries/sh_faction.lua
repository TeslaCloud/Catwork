--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New "faction"

local stored = faction.stored or {}
faction.stored = stored

local buffer = faction.buffer or {}
faction.buffer = buffer

function faction.GetStored()
	return stored
end

function faction.GetBuffer()
	return buffer
end

FACTION_CITIZENS_FEMALE = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl"
}

FACTION_CITIZENS_MALE = {
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl"
}

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE}

-- A function to register a new faction.
function CLASS_TABLE:Register()
	return faction.Register(self, self.name)
end

-- A function to get a new faction.
function faction.New(name)
	local object = cw.core:NewMetaTable(CLASS_TABLE)
		object.name = name or "Unknown"
	return object
end

-- A function to register a new faction.
function faction.Register(data, name)
	if (data.models) then
		data.models.female = data.models.female or FACTION_CITIZENS_FEMALE
		data.models.male = data.models.male or FACTION_CITIZENS_MALE
	else
		data.models = {
			female = FACTION_CITIZENS_FEMALE,
			male = FACTION_CITIZENS_MALE
		}
	end

	data.limit = data.limit or 128
	data.index = cw.core:GetShortCRC(name)
	data.name = data.name or name

	buffer[data.index] = data
	stored[data.name] = data

	if (SERVER and !_G["cwSharedBooted"]) then
		if (data.models) then
			for k, v in pairs(data.models.female) do
				cw.core:AddFile(v)
			end

			for k, v in pairs(data.models.male) do
				cw.core:AddFile(v)
			end
		end

		if (data.material) then
			cw.core:AddFile("materials/"..data.material..".png")
		end
	end

	return data.name
end

-- A function to get the faction limit.
function faction.GetLimit(name)
	local faction = faction.FindByID(name)

	if (faction) then
		if (faction.limit != 128) then
			return math.ceil(faction.limit / (128 / #_player.GetAll()))
		else
			return game.MaxPlayers()
		end
	else
		return 0
	end
end

-- A function to get whether a gender is valid.
function faction.IsGenderValid(faction, gender)
	local factionTable = _faction.FindByID(faction)

	if (factionTable and (gender == GENDER_MALE or gender == GENDER_FEMALE)) then
		if (!factionTable.singleGender or gender == factionTable.singleGender) then
			return true
		end
	end
end

-- A function to get whether a model is valid.
function faction.IsModelValid(faction, gender, model)
	if (gender and model) then
		local factionTable = _faction.FindByID(faction)

		if (factionTable
		and table.HasValue(factionTable.models[string.lower(gender)], model)) then
			return true
		end
	end
end

-- A function to find a faction by an identifier.
function faction.FindByID(identifier)
	if (!identifier) then return end

	if (tonumber(identifier)) then
		return buffer[tonumber(identifier)]
	elseif (stored[identifier]) then
		return stored[identifier]
	else
		local shortest = nil
		local shortestLength = math.huge
		local lowerIdentifier = string.lower(identifier)

		for k, v in pairs(faction.GetAll())do
			if (string.find(string.lower(k), lowerIdentifier)
				and string.utf8len(k) < shortestLength) then
				shortestLength = string.utf8len(k)
				shortest = v
			end
		end

		return shortest
	end
end

-- A function to get all factions.
function faction.GetAll()
	return stored
end

-- A function to get each player in a faction.
function faction.GetPlayers(faction)
	local players = {}

	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (v:GetFaction() == faction) then
				players[#players + 1] = v
			end
		end
	end

	return players
end

-- A function to get the rank with the lowest 'position' (highest rank) in this faction.
function faction.GetHighestRank(factionID)
	local faction = _faction.FindByID(factionID)

	if (istable(faction.ranks)) then
		local lowestPos
		local highestRank
		local rankTable

		for k, v in pairs(faction.ranks) do
			if (!lowestPos) then
				lowestPos = v.position
				rankTable = v
				highestRank = k
			else
				if (v.position) then
					if (math.min(lowestPos, v.position) == v.position) then
						highestRank = k
						rankTable = v
						lowestPos = v.position
					end
				end
			end
		end

		return highestRank, rankTable
	end
end

-- A function to get the rank with the highest 'position' (lowest rank) in this faction.
function faction.GetLowestRank(factionID)
	local faction = _faction.FindByID(factionID)

	if (istable(faction.ranks)) then
		local highestPos
		local lowestRank
		local rankTable

		for k, v in pairs(faction.ranks) do
			if (!highestPos) then
				highestPos = v.position
				lowestRank = k
				rankTable = v
			else
				if (v.position) then
					if (math.max(highestPos, v.position) == v.position) then
						lowestRank = k
						rankTable = v
						highestPos = v.position
					end
				end
			end
		end

		return lowestRank, rankTable
	end
end

-- A function to get the rank with the next lowest 'position' (next highest rank).
function faction.GetHigherRank(factionID, rank)
	local highestRank, rankTable = faction.GetHighestRank(factionID)

	factionID = faction.FindByID(factionID)

	if (istable(faction.ranks) and istable(rank) and rank.position and rank.position != rankTable.position) then
		for k, v in pairs(faction.ranks) do
			if (v.position == (rank.position - 1)) then
				return k, v
			end
		end
	end
end

-- A function to get the rank with the next highest 'position' (next lowest rank).
function faction.GetLowerRank(factionID, rank)
	local lowestRank, rankTable = faction.GetLowestRank(factionID)

	factionID = faction.FindByID(factionID)

	if (istable(factionID.ranks) and istable(rank) and rank.position and rank.position != rankTable.position) then
		for k, v in pairs(factionID.ranks) do
			if (v.position == (rank.position + 1)) then
				return k, v
			end
		end
	end
end

-- A function to get the default rank of a faction.
function faction.GetDefaultRank(factionID)
	local faction = faction.FindByID(factionID)

	if (istable(faction.ranks)) then
		local lowestPos
		local highestRank

		for k, v in pairs(faction.ranks) do
			if (v.default) then
				return k, v
			end
		end
	end
end

if (SERVER) then
	function faction.HasReachedMaximum(player, factionID)
		local factionTable = faction.FindByID(factionID)
		local characters = player:GetCharacters()

		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0

			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1
				end
			end

			if (totalCharacters >= factionTable.maximum) then
				return true
			end
		end
	end
else
	function faction.HasReachedMaximum(factionID)
		local factionTable = faction.FindByID(factionID)
		local characters = cw.character:GetAll()

		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0

			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1
				end
			end

			if (totalCharacters >= factionTable.maximum) then
				return true
			end
		end
	end
end

_faction = faction
