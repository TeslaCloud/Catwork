--- Registers the `/StorageTakeItem` command, which takes an item instance out of the storage the caller has open into
-- their inventory.

local COMMAND = cw.command:New('StorageTakeItem')
COMMAND.tip = '#Command_Storagetakeitem_Description'
COMMAND.text = '#Command_Storagetakeitem_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2
COMMAND.cooldown = 2

--- Takes an item from the open storage into the caller's inventory; arguments are the item and instance IDs.
function COMMAND:OnRun(player, arguments)
  local storageTable = player:GetStorageTable()
  local uniqueID = arguments[1]
  local itemID = tonumber(arguments[2])

  if storageTable and (!storageTable.entity or IsValid(storageTable.entity)) then
    local itemTable = cw.inventory:FindItemByID(
      storageTable.inventory, uniqueID, itemID
    )

    if !itemTable then
      cw.player:Notify(player, L('StorageNoInstance'))
      return
    end

    cw.storage:TakeFrom(player, itemTable)
  else
    cw.player:Notify(player, L('StorageNotOpen'))
  end
end

COMMAND:Register()
