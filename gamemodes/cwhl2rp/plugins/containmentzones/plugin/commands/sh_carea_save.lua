--- Registers the `/ContainmentSave` superadmin command of the Radiation plugin, which saves the containment zones of
-- the current map with `cwRadSystem:SaveAreas`.

local COMMAND = cw.command:New('ContainmentSave')
COMMAND.tip = ''
COMMAND.text = ''
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 0

--- Saves the containment zones of the current map with `cwRadSystem:SaveAreas`.
function COMMAND:OnRun(player, arguments)
  cwRadSystem:SaveAreas()

  cw.player:Notify(player, L('Containment_Saved'))
end

COMMAND:Register()
