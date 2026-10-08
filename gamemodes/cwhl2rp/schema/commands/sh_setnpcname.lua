--- Registers `/SetNPCName`, an operator command that sets the `cw_Name` and `cw_Title` networked strings of the NPC
-- being looked at.

local COMMAND = cw.command:New('SetNPCName')
COMMAND.tip = '#Command_Setnpcname_Description'
COMMAND.text = '#Command_Setnpcname_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 2

--- Sets the name (first argument) and title (second argument) of the NPC being looked at.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local target = trace.Entity

  if target and target:IsNPC() then
    if trace.HitPos:Distance(player:GetShootPos()) <= 192 then
      target:SetNWString('cw_Name', arguments[1])
      target:SetNWString('cw_Title', arguments[2])
    else
      cw.player:Notify(player, L('Err_NPCTooFar'))
    end
  else
    cw.player:Notify(player, L('Err_MustLookAtNPC'))
  end
end

COMMAND:Register()
