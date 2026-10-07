--[[
  © 2012 Iron-Wall.org do not share, re-distribute or modify
  without permission of its author (ext@iam1337.ru).
--]]

local COMMAND = cw.command:New('FactoryDispenserAdd')
COMMAND.tip = '#Command_Factorydispenseradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.text = '#Command_Factorydispenseradd_Syntax'

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local entity = ents.Create('cw_factorydispenser')

  entity:SetPos(trace.HitPos + Vector(0, 0, 10))
  entity:Spawn()

  if IsValid(entity) then
    entity:SetAngles(Angle(90, player:EyeAngles().yaw + 180, 0))
    entity:SetSpawnType(arguments[1] - 1)

    cw.player:Notify(player, L('Factory_DispenserAdded', arguments[1]))
  end
end

COMMAND:Register()
