--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

if (cw.player) then return end
if (!plugin) then include("sh_plugin.lua"); end
if (!config) then include("sh_config.lua"); end
if (!cw.attribute) then include("sh_attribute.lua"); end
if (!cw.faction) then include("sh_faction.lua"); end
if (!cw.class) then include("sh_class.lua"); end
if (!cw.command) then include("sh_command.lua"); end
if (!cw.attribute) then include("sh_attribute.lua"); end
if (!cw.option) then include("sh_option.lua"); end
if (!cw.entity) then include("sh_entity.lua"); end
if (!item) then include("sh_item.lua"); end
if (!cw.inventory) then include("sh_inventory.lua"); end

library.New("player", cw)

local playerData = cw.player.playerData or {}
local characterData = cw.player.characterData or {}
cw.player.playerData = playerData
cw.player.characterData = characterData

function cw.player:GetPlayerDataTable()
	return playerData
end

function cw.player:GetCharacterDataTable()
	return characterData
end

function cw.player:GetPlayerData(key)
	return playerData[key]
end

function cw.player:GetCharacterData(key)
	return characterData[key]
end

function cw.player:SetNetVar(player, key, value)
	if (SERVER) then
		if (IsValid(player)) then
			player:SetNetVar(key, value)
		end
	end
end

function cw.player:GetNetVar(player, key)
	if (IsValid(player)) then
		return player:GetNetVar(key)
	end
end

cw.player.GetSharedVar = cw.player.GetNetVar
cw.player.SetSharedVar = cw.player.SetNetVar

function player.Find(name, bCaseSensitive)
	if (name == nil) then return end
	if (!isstring(name)) then return (IsValid(name) and name) or nil end

	for k, v in ipairs(_player.GetAll()) do
		if (!v:HasInitialized()) then continue end

		local plyName = v:Name(true)

		if (!bCaseSensitive and plyName:utf8lower():find(name:utf8lower())) then
			return v
		elseif (plyName:find(name)) then
			return v
		elseif (v:SteamID() == name) then
			return v
		end
	end
end

--[[
	@codebase Shared
	@details Add a new character data type that can be synced over the network.
	@param String The name of the data type (can be pretty much anything.)
	@param Int The type of the object (must be a type of NWTYPE_* enum).
	@param Various The default value of the data type.
	@param Function Alter the value that gets networked.
	@param Bool Whether or not the data is networked to the player only (defaults to false.)
--]]
function cw.player:AddCharacterData(name, nwType, default, playerOnly, callback)
	characterData[name] = {
		default = default,
		nwType = nwType,
		callback = callback,
		playerOnly = playerOnly
	}
end

--[[
	@codebase Shared
	@details Add a new player data type that can be synced over the network.
	@param String The name of the data type (can be pretty much anything.)
	@param Int The type of the object (must be a type of NWTYPE_* enum).
	@param Various The default value of the data type.
	@param Function Alter the value that gets networked.
	@param Bool Whether or not the data is networked to the player only (defaults to false.)
--]]
function cw.player:AddPlayerData(name, nwType, default, playerOnly, callback)
	playerData[name] = {
		default = default,
		nwType = nwType,
		callback = callback,
		playerOnly = playerOnly
	}
end

--[[
	@codebase Shared
	@details A function to get a player's rank within their faction.
	@param Userdata The player whose faction rank you are trying to obtain.
--]]
function cw.player:GetFactionRank(player, character)
	if (character) then
		local faction = faction.FindByID(character.faction)

		if (faction and istable(faction.ranks)) then
			local rank

			for k, v in pairs(faction.ranks) do
				if (k == character.data["factionrank"]) then
					rank = v
					break
				end
			end

			return character.data["factionrank"], rank
		end
	else
		local faction = faction.FindByID(player:GetFaction())

		if (faction and istable(faction.ranks)) then
			local rank

			for k, v in pairs(faction.ranks) do
				if (k == player:GetCharacterData("factionrank")) then
					rank = v
					break
				end
			end

			return player:GetCharacterData("factionrank"), rank
		end
	end
end

--[[
	@codebase Shared
	@details A function to check if a player can promote the target.
	@param Userdata The player whose permissions you are trying to check.
	@param Userdata The player who may be promoted.
--]]
function cw.player:CanPromote(player, target)
	local stringRank, rank = self:GetFactionRank(player)

	if (rank) then
		if (rank.canPromote) then
			local stringTargetRank, targetRank = self:GetFactionRank(target)
			local highestRank, rankTable = faction.GetHighestRank(player:Faction()).position

			if (targetRank.position and targetRank.position != rankTable.position) then
				return (rank.canPromote <= targetRank.position)
			end
		end
	end
end

--[[
	@codebase Shared
	@details A function to check if a player can demote the target.
	@param Userdata The player whose permissions you are trying to check.
	@param Userdata The player who may be demoted.
--]]
function cw.player:CanDemote(player, target)
	local stringRank, rank = self:GetFactionRank(player)

	if (rank) then
		if (rank.canDemote) then
			local stringTargetRank, targetRank = self:GetFactionRank(target)
			local lowestRank, rankTable = faction.GetLowestRank(player:Faction()).position

			if (targetRank.position and targetRank.position != rankTable.position) then
				return (rank.canDemote <= targetRank.position)
			end
		end
	end
end
