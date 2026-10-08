--- Registers the superadmin command `/Su`, which sends a message to every online superadmin in the admin chat.

local COMMAND = cw.command:New('Su')
COMMAND.tip = '#Command_Su_Description'
COMMAND.text = '#Command_Su_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 1

--- Sends a message to every online superadmin; the arguments are the message.
function COMMAND:OnRun(player, arguments)
  local listeners = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:IsSuperAdmin() then
      listeners[#listeners + 1] = v
    end
  end

  chatbox.AddText(listeners, table.concat(arguments, ' '), {
    filter = 'admin',
    sender = player,
    prefix = '#Command_Su_Prefix '
  })
end

COMMAND:Register()
