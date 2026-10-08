--- Registers `/ObjectPhysDesc`, which lets the owner of the physics prop being looked at set its physical description.
--
-- The command only checks ownership and distance, then sends the `ObjectPhysDesc` netstream message so the client
-- prompts for the text.

local COMMAND = cw.command:New('ObjectPhysDesc')
COMMAND.tip = '#Command_Objectphysdesc_Description'
COMMAND.flags = CMD_DEFAULT

--- Asks the owner of the prop being looked at for its physical description; takes no arguments.
--
-- The client answers with the `ObjectPhysDesc` netstream message.
function COMMAND:OnRun(player, arguments)
  local target = player:GetEyeTraceNoCursor().Entity

  if IsValid(target) then
    if target:GetPos():Distance(player:GetShootPos()) <= 192 then
      if cw.entity:IsPhysicsEntity(target) then
        if player:QueryCharacter('key') == target:GetOwnerKey() then
          player.objectPhysDesc = target

          netstream.Start(player, 'ObjectPhysDesc', target)
        else
          cw.player:Notify(player, L('Err_NotEntityOwner'))
        end
      else
        cw.player:Notify(player, L('Err_NotPhysicsEntity'))
      end
    else
      cw.player:Notify(player, L('Err_EntityTooFar'))
    end
  else
    cw.player:Notify(player, L('Err_MustLookAtEntity'))
  end
end

COMMAND:Register()
