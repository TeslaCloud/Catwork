--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('ContTakePassword')
COMMAND.tip = '#Command_Conttakepassword_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Removes the password of the container the player is looking at.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()

  if IsValid(trace.Entity) then
    if cw.entity:IsPhysicsEntity(trace.Entity) then
      local model = string.lower(trace.Entity:GetModel())

      if cwStorage.containerList[model] then
        if !trace.Entity.inventory then
          cwStorage.storage[trace.Entity] = trace.Entity

          trace.Entity.inventory = {}
          cwStorage:SaveStorage()
        end

        trace.Entity.cwPassword = nil
        cw.player:Notify(player, L('Container_PasswordRemoved'))
      else
        cw.player:Notify(player, L('Container_NotValid'))
      end
    else
      cw.player:Notify(player, L('Container_NotValid'))
    end
  else
    cw.player:Notify(player, L('Container_NotValid'))
  end
end

COMMAND:Register()
