--- Registers the `/ContSetMessage` command, which sets the message shown to players who open the prop the player is
-- looking at.

local COMMAND = cw.command:New('ContSetMessage')
COMMAND.tip = '#Command_Contsetmessage_Description'
COMMAND.text = '#Command_Contsetmessage_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

--- Sets the message shown when the physics entity the player is looking at is opened.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()

  if IsValid(trace.Entity) then
    if cw.entity:IsPhysicsEntity(trace.Entity) then
      trace.Entity.cwMessage = arguments[1]
      cwStorage:SaveStorage()

      cw.player:Notify(player, L('Container_MessageSet'))
    else
      cw.player:Notify(player, L('Container_NotValid'))
    end
  else
    cw.player:Notify(player, L('Container_NotValid'))
  end
end

COMMAND:Register()
