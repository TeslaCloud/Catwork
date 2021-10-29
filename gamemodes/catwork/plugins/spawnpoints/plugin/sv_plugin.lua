--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- A function to load the player spawn points.
function cwSpawnPoints:LoadSpawnPoints()
	local spawnPoints = cw.core:RestoreSchemaData("plugins/spawnpoints/"..game.GetMap())
	self.spawnPoints = self.spawnPoints or {}

	for k, v in pairs(spawnPoints) do
		local faction = faction.FindByID(k)
		local class = cw.class:FindByID(k)
		local name

		if (class or faction) then
			if (faction) then
				name = faction.name
			else
				name = class.name
			end

			self.spawnPoints[name] = self.spawnPoints[name] or {}

			for k2, v2 in pairs(v) do
				if (type(v2.position) == "string") then
					local x, y, z = string.match(v2.position, "(.-), (.-), (.+)")
					v2.position = Vector(tonumber(x), tonumber(y), tonumber(z))
				end

				self.spawnPoints[name][#self.spawnPoints[name] + 1] = v2
			end
		elseif (k == "default") then
			self.spawnPoints["default"] = self.spawnPoints["default"] or {}

			for k2, v2 in pairs(v) do
				if (type(v2.position) == "string") then
					local x, y, z = string.match(v2.position, "(.-), (.-), (.+)")
					v2.position = Vector(tonumber(x), tonumber(y), tonumber(z))
				end

				self.spawnPoints["default"][#self.spawnPoints["default"] + 1] = v2
			end
		end
	end
end

-- A function to save the player spawn points.
function cwSpawnPoints:SaveSpawnPoints()
	local spawnPoints = {}

	for k, v in pairs(self.spawnPoints) do
		spawnPoints[k] = {}

		for k2, v2 in pairs(v) do
			spawnPoints[k][#spawnPoints[k] + 1] = {
				position = v2.position.x..", "..v2.position.y..", "..v2.position.z,
				rotate = v2.rotate
			}
		end
	end

	for k, player in ipairs(_player.GetAll()) do
		if (player:IsAdmin()) then
			netstream.Start(player, "SpawnPointESPSync", self:GetSpawnPoints())
		end
	end

	cw.core:SaveSchemaData("plugins/spawnpoints/"..game.GetMap(), spawnPoints)
end

-- A function to get the CW spawnpoints and combine them with source spawnpoints for syncing.
function cwSpawnPoints:GetSpawnPoints()
	local spawnPoints = table.Copy(self.spawnPoints)

	for k, v in pairs(ents.FindByClass("info_player_start")) do
		spawnPoints["Source Spawnpoint"] = spawnPoints["Source Spawnpoint"] or {}
		spawnPoints["Source Spawnpoint"][#spawnPoints["Source Spawnpoint"] + 1] = {
			position = v:GetPos()
		}
	end

	return spawnPoints
end
