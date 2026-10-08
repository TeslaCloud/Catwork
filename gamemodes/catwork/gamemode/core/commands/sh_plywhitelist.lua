--- Registers the superadmin command `/PlyWhitelist` (aliases `/Whitelist`, `/CharWhitelist`, `/GiveWhitelist`), which
-- adds the target player to a faction's whitelist.

local COMMAND = cw.command:New('PlyWhitelist')
COMMAND.tip = '#Command_Plywhitelist_Description'
COMMAND.text = '#Command_Plywhitelist_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'Whitelist', 'CharWhitelist', 'GiveWhitelist' }

--- Adds the target player to a faction whitelist; arguments are the player name and the faction.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    local factionTable = faction.FindByID(table.concat(arguments, ' ', 2))

    if factionTable then
      if factionTable.whitelist then
        if !cw.player:IsWhitelisted(target, factionTable.name) then
          cw.player:SetWhitelisted(target, factionTable.name, true)
          cw.player:SaveCharacter(target)

          cw.player:NotifyAll(L('Command_Plywhitelist_Added', player:Name(), target:Name(), factionTable.name))
        else
          cw.player:Notify(player, L('Command_Plywhitelist_AlreadyOn', target:Name(), factionTable.name))
        end
      else
        cw.player:Notify(player, L('Command_Whitelist_NoWhitelist', factionTable.name))
      end
    else
      cw.player:Notify(player, L('Command_NotValidFaction', table.concat(arguments, ' ', 2)))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
