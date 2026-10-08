--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('PlyUnwhitelist')
COMMAND.tip = '#Command_Plyunwhitelist_Description'
COMMAND.text = '#Command_Plyunwhitelist_Syntax'
COMMAND.access = 'sW'
COMMAND.arguments = 2
COMMAND.alias = { 'UnWhitelist', 'DeWhitelist' }

--- Removes the target player from a faction whitelist; arguments are the player name and the faction.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    local factionTable = faction.FindByID(table.concat(arguments, ' ', 2))

    if factionTable then
      if factionTable.whitelist then
        if cw.player:IsWhitelisted(target, factionTable.name) then
          cw.player:SetWhitelisted(target, factionTable.name, false)
          cw.player:SaveCharacter(target)

          cw.player:NotifyAll(L('Command_Plyunwhitelist_Removed', player:Name(), target:Name(), factionTable.name))
        else
          cw.player:Notify(player, L('Command_Plyunwhitelist_NotOnWhitelist', target:Name(), factionTable.name))
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
