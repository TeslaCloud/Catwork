--- Registers the `/StorageClose` command, which closes the storage the caller has open and is sent by the storage
-- window.

local COMMAND = cw.command:New('StorageClose')
COMMAND.tip = '#Command_Storageclose_Description'
COMMAND.flags = CMD_DEFAULT

--- Closes the caller's open storage; takes no arguments.
function COMMAND:OnRun(player, arguments)
  local storageTable = player:GetStorageTable()

  if storageTable then
    cw.storage:Close(player, true)
  else
    cw.player:Notify(player, L('StorageNotOpen'))
  end
end

COMMAND:Register()
