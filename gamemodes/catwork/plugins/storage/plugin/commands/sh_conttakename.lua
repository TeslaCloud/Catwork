--- Registers the `/ContTakeName` admin command, which removes the custom name of the container the player is looking
-- at.

local COMMAND = cw.command:New('ContTakeName')
COMMAND.tip = '#Command_Conttakename_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Removes the custom name of the container the player is looking at.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()

  if IsValid(trace.Entity) then
    if cw.entity:IsPhysicsEntity(trace.Entity) then
      local model = string.lower(trace.Entity:GetModel())
      local name = table.concat(arguments, ' ')

      if cwStorage.containerList[model] then
        if !trace.Entity.inventory then
          cwStorage.storage[trace.Entity] = trace.Entity
          trace.Entity.inventory = {}
        end

        trace.Entity:SetNWString('Name', '')
        cwStorage:SaveStorage()
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
