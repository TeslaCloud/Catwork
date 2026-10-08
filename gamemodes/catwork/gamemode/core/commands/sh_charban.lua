--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('CharBan')
COMMAND.tip = '#Command_Charban_Description'
COMMAND.text = '#Command_Charban_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o8'
COMMAND.arguments = 1

--- Bans the target player's current character and kills them; the arguments are the character name.
--
-- Protected players cannot be banned.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(table.concat(arguments, ' '))

  if target then
    if !cw.player:IsProtected(target) then
      cw.player:SetBanned(target, true)
      cw.player:NotifyAll(L('Command_Charban_Banned', player:Name(), target:Name()))

      target:KillSilent()
    else
      cw.player:Notify(player, L('Command_PlayerProtected', target:Name()))
    end
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
