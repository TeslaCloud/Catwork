--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local FACTION = faction.New("#Faction_Citizen")

FACTION.useFullName = true
FACTION.material = "halfliferp/factions/citizen"
FACTION.giveCard = "cid_card"
FACTION.maximumAttributePoints = 25
FACTION.models = {
	female = {},
	male = {}
}

do
	for i = 1, 18 do
		local num = i

		if (i < 10) then
			num = "0"..i
		end

		if (i != 17) then
			table.insert(FACTION.models.male, "models/tnb/citizens/male_"..num..".mdl")
		end

		if (i < 12) then
			table.insert(FACTION.models.female, "models/tnb/citizens/female_"..num..".mdl")
		end
	end
end

-- Called when a player is transferred to the faction.
function FACTION:OnTransferred(player, faction, name)
	if (player:IsCombine()) then
		if (name) then
			local models = self.models[string.lower(player:QueryCharacter("gender"))]

			if (models) then
				player:SetCharacterData("model", models[math.random(#models)], true)

				cw.player:SetName(player, name, true)
			end
		else
			return false, "You need to specify a name as the third argument!"
		end
	end
end

FACTION_CITIZEN = FACTION:Register();
