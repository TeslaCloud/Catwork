--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = faction.New("#Faction_Vort")

FACTION.useFullName = true
FACTION.whitelist = true
FACTION.models = {
	female = {"models/vortigaunt.mdl"},
	male = {"models/vortigaunt.mdl"}
}

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

FACTION_VORT = FACTION:Register();