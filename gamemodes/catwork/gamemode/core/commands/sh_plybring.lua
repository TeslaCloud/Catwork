--- Registers the operator command `/PlyBring` (alias `/Bring`), which teleports the target player to where the caller
-- is looking, optionally without announcing it.

local COMMAND = cw.command:New('PlyBring')

COMMAND.tip = '#Command_Plybring_Description'
COMMAND.text = '#Command_Plybring_Syntax'
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.access = 'o'
COMMAND.alias = { 'Bring' }

--- Teleports the target player to where the caller is looking; arguments are the name and an optional silent flag.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local trace = player:GetEyeTraceNoCursor()
  local isSilent = cw.core:ToBool(arguments[2])

  if target then
    cw.player:SetSafePosition(target, trace.HitPos)

    if !isSilent then
      cw.player:NotifyAll(L('Command_Plybring_Brought', player:Name(), target:Name()))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
