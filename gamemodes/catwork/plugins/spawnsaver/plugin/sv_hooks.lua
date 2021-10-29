--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when a player's character has unloaded.
function cwSpawnSaver:PlayerCharacterUnloaded(player)
	if (config.Get("spawn_where_left"):Get() and hook.Run("ShouldSavePlayerSpawn", player) != false and player:Alive()) then
		local position = player:GetPos()
		local posTable = {
			map = game.GetMap(),
			x = position.x,
			y = position.y,
			z = position.z,
			angles = player:EyeAngles()
		}

		player:SetCharacterData("SpawnPoint", posTable)
	end
end

function cwSpawnSaver:OnMapChange(newMap)
	for k, v in ipairs(_player.GetAll()) do
		self:PlayerCharacterUnloaded(v)
	end
end

-- Called just after a player spawns.
function cwSpawnSaver:PostPlayerSpawn(player, bLightSpawn, bChangeClass, bFirstSpawn)
	if (!bLightSpawn and hook.Run("ShouldSavePlayerSpawn", player) != false) then
		local spawnPos = player:GetCharacterData("SpawnPoint")

		if (spawnPos and config.GetVal("spawn_where_left")) then
			if (spawnPos.map == game.GetMap()) then
				player:SetPos(Vector(spawnPos.x, spawnPos.y, spawnPos.z))
				player:SetEyeAngles(spawnPos.angles)
				player:SetCharacterData("SpawnPoint", nil)
			end
		end
	end
end
