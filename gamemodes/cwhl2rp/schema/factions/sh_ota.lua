--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local FACTION = faction.New("#Faction_OTA")

FACTION.isCombineFaction = true
FACTION.whitelist = true
FACTION.material = "halfliferp/factions/ota"
FACTION.maximumAttributePoints = 70
FACTION.models = {
	female = {"models/combine_soldier.mdl"},
	male = {"models/combine_soldier.mdl"}
}

-- Called when a player's name should be assigned for the faction.
function FACTION:GetName(player, character)
	local unitID = math.random(1, 999)

	return "OTA.C24.ECHO.OWS:"..cw.core:ZeroNumberToDigits(unitID, 3)
end

-- Called when a player's model should be assigned for the faction.
function FACTION:GetModel(player, character)
	if (character.gender == GENDER_MALE) then
		return self.models.male[1]
	else
		return self.models.female[1]
	end
end

-- Called when a player is transferred to the faction.
function FACTION:OnTransferred(player, faction, name)
	if (faction.name == FACTION_MPF) then
		cw.player:SetName(player, string.gsub(player:QueryCharacter("name"), ".+(%d%d%d)", "OTA.C24.ECHO.OWS:%1"), true)
	else
		cw.player:SetName(player, self:GetName(player, player:GetCharacter()), true)
	end

	if (player:QueryCharacter("gender") == GENDER_MALE) then
		player:SetCharacterData("model", self.models.male[1], true)
	else
		player:SetCharacterData("model", self.models.female[1], true)
	end
end

FACTION_OTA = FACTION:Register();
