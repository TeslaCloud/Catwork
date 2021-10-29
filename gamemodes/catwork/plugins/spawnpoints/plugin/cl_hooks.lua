--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local cwSpawnPoints = cwSpawnPoints
local spawnPointData
local cwClass = cw.class

--Called when the plugin is initialized.
function cwSpawnPoints:Initialize()
	CW_CONVAR_SPAWNPOINTESP = cw.core:CreateClientConVar("cwSpawnPointESP", 0, true, true)

	cw.setting:AddCheckBox("#AdminESP", "#ShowSpawnPoints", "cwSpawnPointESP", "#ShowSpawnPointsDesc", function()
		return cw.player:IsAdmin(cw.client)
	end)
end

local colorWhite = Color(255, 255, 255, 255)
local colorViolet = Color(180, 100, 255, 255)
local spawnColor

-- Called when the ESP info is needed.
function cwSpawnPoints:GetAdminESPInfo(info)
	if (CW_CONVAR_SPAWNPOINTESP:GetInt() == 1 and spawnPointData) then
		for typeName, spawnPoints in pairs(spawnPointData) do
			spawnColor = colorViolet

			for k, class in pairs(cwClass:GetAll()) do
				if (class.factions[1] == typeName or typeName == k) then
					spawnColor = class.color
				end
			end

			for k, v in pairs(spawnPoints) do
				table.insert(info, {
					position = v.position,
					text = {
						{
							text = "SpawnPoint",
							color = colorWhite
						},
						{
							text = string.upper(typeName),
							color = spawnColor
						}
					}
				})
			end
		end
	end
end

-- Called to sync up the ESP data from the server.
netstream.Hook("SpawnPointESPSync", function(data)
	spawnPointData = data
end);
