local PLUGIN = PLUGIN

function PLUGIN:SaveCombineDevices()
	local cmbMonitors = {}

	for k, v in pairs(ents.FindByClass("cw_combineaccessmonitor")) do
		cmbMonitors[#cmbMonitors + 1] = {
			angles = v:GetAngles(),
			position = v:GetPos(),
			text1 = v:GetDTString(0),
			text2 = v:GetDTString(1),
			text3 = v:GetDTString(2),
			level = v:GetDTString(3),
			status = v:GetDTInt(5),
		}
	end

	cw.core:SaveSchemaData("plugins/combinedevices/monitors/"..game.GetMap(), cmbMonitors)

	local infoCitizen = {}
	for k, v in pairs(ents.FindByClass("hl2_info_citizen")) do
		infoCitizen[#infoCitizen + 1] = {
			angles = v:GetAngles(),
			position = v:GetPos(),
			locked = v:GetNWBool("locked"),
		}
	end
	cw.core:SaveSchemaData("plugins/combinedevices/infocitizen/"..game.GetMap(), infoCitizen)

	local infoCard = {}
	for k, v in pairs(ents.FindByClass("hl2_info_card")) do
		infoCard[#infoCard + 1] = {
			angles = v:GetAngles(),
			position = v:GetPos(),
			locked = v:GetNWBool("locked"),
		}
	end
	cw.core:SaveSchemaData("plugins/combinedevices/infocard/"..game.GetMap(), infoCard)

	local infoMonitor = {}
	for k, v in pairs(ents.FindByClass("hl2_combinemonitor")) do
		infoMonitor[#infoMonitor + 1] = {
			angles = v:GetAngles(),
			position = v:GetPos(),
		}
	end
	cw.core:SaveSchemaData("plugins/combinedevices/infomonitor/"..game.GetMap(), infoMonitor)
end

function PLUGIN:LoadCombineDevices()
	local cmbMonitors = cw.core:RestoreSchemaData("plugins/combinedevices/monitors/"..game.GetMap())

	for k, v in pairs(cmbMonitors) do
		local combineAMonitor = ents.Create("cw_combineaccessmonitor")

		if combineAMonitor then
			combineAMonitor:SetPos(v.position)
			combineAMonitor:SetAngles(v.angles)
			combineAMonitor:Spawn()
			combineAMonitor:GetPhysicsObject():EnableMotion(false)
			combineAMonitor:SetDTString(0,v.text1)
			combineAMonitor:SetDTString(1,v.text2)
			combineAMonitor:SetDTString(2,v.text3)
			combineAMonitor:SetDTString(3,v.level)
			combineAMonitor:SetStatus(v.status)
		end
	end

	local infoCitizen = cw.core:RestoreSchemaData("plugins/combinedevices/infocitizen/"..game.GetMap())
	for k, v in pairs(infoCitizen) do
		local device = ents.Create("hl2_info_citizen")

		if device then
			device:SetPos(v.position)
			device:SetAngles(v.angles)
			device:Spawn()
			device:GetPhysicsObject():EnableMotion(false)
			device:SetNWBool("locked",v.locked)
		end
	end

	local infoCard = cw.core:RestoreSchemaData("plugins/combinedevices/infocard/"..game.GetMap())
	for k, v in pairs(infoCard) do
		local device = ents.Create("hl2_info_card")

		if device then
			device:SetPos(v.position)
			device:SetAngles(v.angles)
			device:Spawn()
			device:GetPhysicsObject():EnableMotion(false)
			device:SetNWBool("locked",v.locked)
		end
	end

	local infoMonitor = cw.core:RestoreSchemaData("plugins/combinedevices/infomonitor/"..game.GetMap())
	for k, v in pairs(infoMonitor) do
		local monitor = ents.Create("hl2_combinemonitor")

		if monitor then
			monitor:SetPos(v.position)
			monitor:SetAngles(v.angles)
			monitor:Spawn()
			monitor:GetPhysicsObject():EnableMotion(false)
		end
	end
end