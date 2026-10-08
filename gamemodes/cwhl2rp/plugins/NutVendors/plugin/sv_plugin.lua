--- Server-side functions of the Nutscript Vending Machines plugin that save and load the `nut_vend` entities of the
-- current map.
--
-- `PLUGIN:SaveNuttyVendingMachines` writes each machine's position, angles, active state and the stock of its four
-- buttons to the schema data under `plugins/nutVend/<map>`, and `PLUGIN:LoadNuttyVendingMachines` spawns them again
-- from it.

local PLUGIN = PLUGIN

--- Spawns the vending machines saved for the current map.
--
-- Reads `plugins/nutVend/<map>` from the schema data and restores each machine's position,
-- angles, active state and the stock of its four buttons. Entries without a position or angles are skipped.
-- @see PLUGIN:SaveNuttyVendingMachines
function PLUGIN:LoadNuttyVendingMachines()
  local nutVend = cw.core:RestoreSchemaData('plugins/nutVend/'..game.GetMap())

  for k, v in pairs(nutVend) do
    if !istable(v) or !isvector(v.pos) or !isangle(v.angles) then continue end

    local entity = ents.Create('nut_vend')
    entity:SetPos(v.pos)
    entity:SetAngles(v.angles)
    entity:Spawn()
    entity:Activate()
    entity:SetDTBool(0, v.active != false)
    entity:SetDTFloat(1, tonumber(v.stock1) or 0)
    entity:SetDTFloat(2, tonumber(v.stock2) or 0)
    entity:SetDTFloat(3, tonumber(v.stock3) or 0)
    entity:SetDTFloat(4, tonumber(v.stock4) or 0)
  end
end

--- Saves every `nut_vend` entity on the map to the schema data.
--
-- Stores position, angles, active state and stock per machine under `plugins/nutVend/<map>`.
-- @see PLUGIN:LoadNuttyVendingMachines
function PLUGIN:SaveNuttyVendingMachines()
  local nutVend = {}

  for k, v in pairs(ents.FindByClass('nut_vend')) do
    nutVend[#nutVend + 1] = {
      pos = v:GetPos(),
      angles = v:GetAngles(),
      active = v:GetDTBool(0),
      stock1 = v:GetDTFloat(1),
      stock2 = v:GetDTFloat(2),
      stock3 = v:GetDTFloat(3),
      stock4 = v:GetDTFloat(4)
    }
  end

  cw.core:SaveSchemaData('plugins/nutVend/'..game.GetMap(), nutVend)
end
