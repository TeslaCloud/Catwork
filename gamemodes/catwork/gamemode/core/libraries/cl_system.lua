--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('system', cw)

cw.system.stored = cw.system.stored or {}

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = { __index = CLASS_TABLE }

--- Registers the system with `cw.system:Register`.
function CLASS_TABLE:Register()
  return cw.system:Register(self)
end

--- Returns every registered system.
-- @return [Map<Map> Systems keyed by name]
function cw.system:GetAll()
  return self.stored
end

--- Creates a new admin system object to fill in and register.
--
-- A system is a page of the system menu. Set `toolTip`, `access` (the flags
-- needed to see it, unless `HasAccess` is defined) and `doesCreateForm`, and
-- define `OnDisplay(systemPanel, systemForm)` to build the page.
--
-- ```
-- local SYSTEM = cw.system:New('Manage Players')
-- SYSTEM.toolTip = '#System_ManagePlayers_ToolTip'
-- SYSTEM.access = 'o'
--
-- function SYSTEM:OnDisplay(systemPanel, systemForm)
--   -- build the page
-- end
--
-- SYSTEM:Register()
-- ```
--
-- @param name='Unknown' [String Name of the system, used as its identifier]
-- @return [Map The new system object]
function cw.system:New(name)
  local object = cw.core:NewMetaTable(CLASS_TABLE)
    object.name = name or 'Unknown'
  return object
end

--- Returns a registered system.
-- @param identifier [String Name of the system]
-- @return [Map The system, or `nil` if there is none]
function cw.system:FindByID(identifier)
  return self.stored[identifier]
end

--- Returns the system menu panel.
-- @return [Panel The panel, or `nil` if it has not been created or was removed]
function cw.system:GetPanel()
  if IsValid(self.panel) then
    return self.panel
  end
end

--- Rebuilds the system menu if it is showing a system.
-- @param name [String Name of the system]
function cw.system:Rebuild(name)
  local panel = self:GetPanel()

  if panel and self:GetActive() == name then
    panel:Rebuild()
  end
end

--- Returns the system the system menu is showing.
-- @return [String Name of the active system, or `nil` if the menu does not exist or shows none]
function cw.system:GetActive()
  local panel = self:GetPanel()

  if panel then
    return panel.system
  end
end

--- Shows a system in the system menu.
--
-- Does nothing if the menu does not exist.
-- @param name [String Name of the system]
function cw.system:SetActive(name)
  local panel = self:GetPanel()

  if panel then
    panel.system = name
    panel:Rebuild()
  end
end

--- Registers a system so it is listed in the system menu.
--
-- Adds `HasAccess` (checks the local player for the system's `access` flags) if
-- the system does not define it, and the `IsActive` and `Rebuild` methods.
-- @param system [Map The system object from `cw.system:New`]
function cw.system:Register(system)
  self.stored[system.name] = system

  if !system.HasAccess then
    system.HasAccess = function(systemTable)
      return cw.player:HasFlags(cw.client, systemTable.access)
    end
  end

  -- A function to get whether the system is active.
  system.IsActive = function(systemTable)
    local activeAdmin = self:GetActive()

    if activeAdmin == systemTable.name then
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
