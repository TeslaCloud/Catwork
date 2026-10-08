--- Registers the `/StorageGiveItem` command, which moves an item instance from the caller's inventory into the storage
-- they have open.

local COMMAND = cw.command:New('StorageGiveItem')
COMMAND.tip = '#Command_Storagegiveitem_Description'
COMMAND.text = '#Command_Storagegiveitem_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2
COMMAND.cooldown = 2

--- Puts an item from the caller's inventory into the open storage; arguments are the item ID and instance ID.
function COMMAND:OnRun(player, arguments)
  local storageTable = player:GetStorageTable()
  local uniqueID = arguments[1]
  local itemID = tonumber(arguments[2])

  if storageTable and (!storageTable.entity or IsValid(storageTable.entity)) then
    local itemTable = player:FindItemByID(uniqueID, itemID)

    if !itemTable then
      cw.player:Notify(player, L('StoragePlayerNoInstance'))
      return
    end

    if storageTable.isOneSided then
      cw.player:Notify(player, L('StorageCannotGive'))
      return
    end

    cw.storage:GiveTo(player, itemTable)
  else
    cw.player:Notify(player, L('StorageNotOpen'))
  end
end

COMMAND:Register()
