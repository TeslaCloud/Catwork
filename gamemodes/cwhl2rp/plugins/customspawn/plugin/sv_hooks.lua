--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwCustomSpawn:ShouldSavePlayerSpawn(player)
	if (player:GetCharacterData("CustomSpawn")) then
		return false
	end

	return true
end

-- Called just after a player spawns.
function cwCustomSpawn:PostPlayerSpawn(player, bLightSpawn, bChangeClass, bFirstSpawn)
	if (!bLightSpawn) then
		local spawnPos = player:GetCharacterData("CustomSpawn")

		if (spawnPos) then
			if (spawnPos.map == game.GetMap()) then
				player:SetPos(Vector(spawnPos.x, spawnPos.y, spawnPos.z))

				if (spawnPos.angles) then
					player:SetEyeAngles(spawnPos.angles)
				end
			end
		end
	end
end
