--- Server-side functions of the Combine Devices plugin that save and load the Combine devices of the current map.
--
-- `PLUGIN:SaveCombineDevices` and `PLUGIN:LoadCombineDevices` cover four entity classes, each in its own schema data
-- file under `plugins/combinedevices/`: `cw_combineaccessmonitor` with its texts, access level and status, the
-- `hl2_info_citizen` and `hl2_info_card` terminals with their locked state, and `hl2_combinemonitor`. Loaded devices
-- are frozen in place.

local PLUGIN = PLUGIN

--- Spawns a saved device frozen in place.
-- @param class [String The entity class]
-- @param data [Map The saved device, with its `position` and `angles`]
-- @return [Entity The device, or `nil` when it could not be created, such as when its class no longer exists]
local function SpawnDevice(class, data)
  local device = ents.Create(class)

  if !IsValid(device) then return end

  device:SetPos(data.position)
  device:SetAngles(data.angles)
  device:Spawn()

  local physicsObject = device:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:EnableMotion(false)
  end

  return device
end

--- Saves the Combine devices on the map to the schema data.
--
-- Writes access monitors (with their texts, access level and status), `hl2_info_citizen` and
-- `hl2_info_card` terminals (with their locked state) and `hl2_combinemonitor` screens to
-- separate files under `plugins/combinedevices/` for the current map.
function PLUGIN:SaveCombineDevices()
  local cmbMonitors = {}

  for k, v in pairs(ents.FindByClass('cw_combineaccessmonitor')) do
    cmbMonitors[#cmbMonitors + 1] = {
      angles = v:GetAngles(),
      position = v:GetPos(),
      text1 = v:GetDTString(0),
      text2 = v:GetDTString(1),
      text3 = v:GetDTString(2),
      level = v:GetDTString(3),
      status = v:GetDTInt(5)
    }
  end

  cw.core:SaveSchemaData('plugins/combinedevices/monitors/'..game.GetMap(), cmbMonitors)

  local infoCitizen = {}

  for k, v in pairs(ents.FindByClass('hl2_info_citizen')) do
    infoCitizen[#infoCitizen + 1] = {
      angles = v:GetAngles(),
      position = v:GetPos(),
      locked = v:GetNWBool('locked')
    }
  end

  cw.core:SaveSchemaData('plugins/combinedevices/infocitizen/'..game.GetMap(), infoCitizen)

  local infoCard = {}

  for k, v in pairs(ents.FindByClass('hl2_info_card')) do
    infoCard[#infoCard + 1] = {
      angles = v:GetAngles(),
      position = v:GetPos(),
      locked = v:GetNWBool('locked')
    }
  end

  cw.core:SaveSchemaData('plugins/combinedevices/infocard/'..game.GetMap(), infoCard)

  local infoMonitor = {}

  for k, v in pairs(ents.FindByClass('hl2_combinemonitor')) do
    infoMonitor[#infoMonitor + 1] = {
      angles = v:GetAngles(),
      position = v:GetPos()
    }
  end

  cw.core:SaveSchemaData('plugins/combinedevices/infomonitor/'..game.GetMap(), infoMonitor)
end

--- Spawns the Combine devices saved for the current map, frozen in place.
--
-- Restores the access monitors' texts, access level and status and the terminals' locked
-- state.
function PLUGIN:LoadCombineDevices()
  local cmbMonitors = cw.core:RestoreSchemaData('plugins/combinedevices/monitors/'..game.GetMap())

  for k, v in pairs(cmbMonitors) do
    local combineAMonitor = SpawnDevice('cw_combineaccessmonitor', v)

    if combineAMonitor then
      combineAMonitor:SetDTString(0, v.text1 or '')
      combineAMonitor:SetDTString(1, v.text2 or '')
      combineAMonitor:SetDTString(2, v.text3 or '')
      combineAMonitor:SetDTString(3, v.level or '')
      combineAMonitor:SetStatus(v.status or 0)
    end
  end

  local infoCitizen = cw.core:RestoreSchemaData('plugins/combinedevices/infocitizen/'..game.GetMap())

  for k, v in pairs(infoCitizen) do
    local device = SpawnDevice('hl2_info_citizen', v)

    if device then
      device:SetNWBool('locked', v.locked)
    end
  end

  local infoCard = cw.core:RestoreSchemaData('plugins/combinedevices/infocard/'..game.GetMap())

  for k, v in pairs(infoCard) do
    local device = SpawnDevice('hl2_info_card', v)

    if device then
      device:SetNWBool('locked', v.locked)
    end
  end

  local infoMonitor = cw.core:RestoreSchemaData('plugins/combinedevices/infomonitor/'..game.GetMap())

  for k, v in pairs(infoMonitor) do
    SpawnDevice('hl2_combinemonitor', v)
  end
end
