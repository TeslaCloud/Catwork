--- Registers `/PlyRemoveSeverWhitelist` (spelled that way), an admin command that removes an identity from a player's
-- `serverwhitelist` player data.

local COMMAND = cw.command:New('PlyRemoveSeverWhitelist')
COMMAND.tip = '#Command_Plyremoveseverwhitelist_Description'
COMMAND.text = '#Command_Plyremoveseverwhitelist_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 2

--- Removes the player named in the first argument from the server whitelist named in the second argument.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local identity = string.lower(arguments[2])

  if target then
    if target:GetData('serverwhitelist') then
      if !target:GetData('serverwhitelist')[identity] then
        cw.player:Notify(player, L('ServerWhitelist_NotOn', target:Name(), identity))

        return
      else
        target:GetData('serverwhitelist')[identity] = nil
      end
    end

    cw.player:SaveCharacter(target)

    cw.player:NotifyAll(L('ServerWhitelist_Removed', player:Name(), target:Name(), identity))
  else
    cw.player:Notify(player, L('NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
