--- Registers the `/A` command (aliases `/AD`, `/OP`), which sends a message to every online operator, admin and
-- superadmin in the admin chat.

local COMMAND = cw.command:New('A')
COMMAND.tip = '#Command_A_Description'
COMMAND.text = '#Command_A_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.alias = { 'AD', 'OP' }

--- Sends a message to every operator, admin and superadmin in the admin chat; the arguments are the message.
function COMMAND:OnRun(player, arguments)
  local listeners = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:IsUserGroup('operator') or v:IsAdmin()
    or v:IsSuperAdmin() then
      listeners[#listeners + 1] = v
    end
  end

  chatbox.AddText(listeners, table.concat(arguments, ' '), { filter = 'admin', sender = player })
end

COMMAND:Register()
