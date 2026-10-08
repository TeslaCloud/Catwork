--- Registers the `/ContSetName` admin command, which gives the container the player is looking at a custom name.

local COMMAND = cw.command:New('ContSetName')
COMMAND.tip = '#Command_Contsetname_Description'
COMMAND.text = '#Command_Contsetname_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Gives the container the player is looking at a custom name.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()

  if IsValid(trace.Entity) then
    if cw.entity:IsPhysicsEntity(trace.Entity) then
      local model = string.lower(trace.Entity:GetModel())
      local name = table.concat(arguments, ' ')

      if cwStorage.containerList[model] then
        if !trace.Entity.cwInventory then
          cwStorage.storage[trace.Entity] = trace.Entity

          trace.Entity.cwInventory = {}
        end

        trace.Entity:SetNWString('Name', name)
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
