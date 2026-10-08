--- Registers the `/SetClass` command (aliases `/CharSetClass`, `/ChangeClass`), which moves the caller, or for
-- operators another player, into a class when the class limit and the `PlayerCanChangeClass` hook allow it.

local COMMAND = cw.command:New('SetClass')
COMMAND.tip = '#Command_Setclass_Description'
COMMAND.text = '#Command_Setclass_Syntax'
COMMAND.flags = CMD_HEAVY
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.alias = { 'CharSetClass', 'ChangeClass' }

--- Moves a player into a class.
--
-- With one argument, the class name or ID, the caller changes their own class, which they need access to (see
-- `cw.core:HasObjectAccess`); the classes menu uses this form. With two arguments, a player name and the class,
-- an operator, or a player given access to this command, sets that player's class. Respects the class limit
-- unless `PlayerCanBypassClassLimit` allows it, and runs `PlayerCanChangeClass`.
function COMMAND:OnRun(player, arguments)
  local bOwnClass = (arguments[2] == nil)
  local target = player
  local class

  if !bOwnClass then
    if !cw.player:HasFlags(player, 'o') and !player:HasPermission(self.uniqueID) then
      cw.player:Notify(player, L('Commands_cwLua_accessDenied', player:Name()))
      return
    end

    target = _player.Find(arguments[1])
    class = cw.class:FindByID(arguments[2])

    if !target then
      cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
      return
    end
  else
    class = cw.class:FindByID(arguments[1])
  end

  if target:InVehicle() then
    cw.player:Notify(player, L('CannotActionRightNow'))
    return
  end

  if !class then
    cw.player:Notify(player, L('ClassNotValid'))
    return
  end

  if bOwnClass and !cw.core:HasObjectAccess(player, class) then
    cw.player:Notify(player, L('ClassNoAccessSelf'))
    return
  end

  local limit = cw.class:GetLimit(class.name)

  if hook.Run('PlayerCanBypassClassLimit', target, class.index) then
    limit = game.MaxPlayers()
  end

  if _team.NumPlayers(class.index) >= limit then
    cw.player:Notify(player, L('ClassTooMany'))
    return
  end

  if target:Team() == class.index then
    cw.player:Notify(player, L((bOwnClass and 'ClassNoAccessSelf') or 'ClassNoAccess'))
    return
  end

  if hook.Run('PlayerCanChangeClass', target, class) then
    local bSuccess, fault = cw.class:Set(target, class.index, nil, true)

    if !bSuccess then
      cw.player:Notify(player, fault)
    elseif !bOwnClass then
      cw.player:Notify(target, L('ClassSetTarget', class.name, player:Name()))
      cw.player:Notify(player, L('ClassSetPlayer', class.name, target:Name()))
    end
  end
end

COMMAND:Register()
