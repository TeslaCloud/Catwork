--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when a player's character data should be restored.
function cwKarma:PlayerRestoreCharacterData(player, data)
	if (!data["karma"]) then
		data["karma"] = 0
	end
end

function cwKarma:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	player:SetNetVar("karma", player:GetCharacterData("karma", 0))
end
