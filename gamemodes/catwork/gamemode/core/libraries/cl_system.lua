--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("system", cw)

cw.system.stored = cw.system.stored or {}

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE}

-- A function to register a new system.
function CLASS_TABLE:Register()
	return cw.system:Register(self)
end

-- A function to get all systems.
function cw.system:GetAll()
	return self.stored
end

-- A function to get a new system.
function cw.system:New(name)
	local object = cw.core:NewMetaTable(CLASS_TABLE)
		object.name = name or "Unknown"
	return object
end

-- A function to get a system by an identifier.
function cw.system:FindByID(identifier)
	return self.stored[identifier]
end

-- A function to get the system panel.
function cw.system:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel
	end
end

-- A function to rebuild an system.
function cw.system:Rebuild(name)
	local panel = self:GetPanel()

	if (panel and self:GetActive() == name) then
		panel:Rebuild()
	end
end

-- A function to get the active system.
function cw.system:GetActive()
	local panel = self:GetPanel()

	if (panel) then
		return panel.system
	end
end

-- A function to set the active system.
function cw.system:SetActive(name)
	local panel = self:GetPanel()

	if (panel) then
		panel.system = name
		panel:Rebuild()
	end
end

-- A function to register a new system.
function cw.system:Register(system)
	self.stored[system.name] = system

	if (!system.HasAccess) then
		system.HasAccess = function(systemTable)
			return cw.player:HasFlags(cw.client, systemTable.access)
		end
	end

	-- A function to get whether the system is active.
	system.IsActive = function(systemTable)
		local activeAdmin = self:GetActive()

		if (activeAdmin == systemTable.name) then
			return true
		else
			return false
		end
	end

	-- A function to rebuild the system.
	system.Rebuild = function(systemTable)
		self:Rebuild(systemTable.name)
	end
end
