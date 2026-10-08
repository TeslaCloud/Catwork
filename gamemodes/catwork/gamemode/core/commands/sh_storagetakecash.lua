--- Registers the `/StorageTakeCash` command, which takes cash out of the storage the caller has open.

local COMMAND = cw.command:New('StorageTakeCash')
COMMAND.tip = '#Command_Storagetakecash_Description'
COMMAND.text = '#Command_Storagetakecash_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.cooldown = 5

--- Takes cash out of the open storage; the argument is the amount.
--
-- Respects the storage's `CanTakeCash`/`OnTakeCash` callbacks.
function COMMAND:OnRun(player, arguments)
  local storageTable = player:GetStorageTable()

  if storageTable then
    local target = storageTable.entity
    local cash = math.floor(tonumber(arguments[1]) or 0)

    if (target and !IsValid(target)) or !config.GetVal('cash_enabled') then
      return
    end

    if cash >= 1 and cash <= storageTable.cash then
      if !storageTable.CanTakeCash
      or (storageTable.CanTakeCash(player, storageTable, cash) != false) then
        if !target or !target:IsPlayer() then
          cw.player:GiveCash(player, cash, nil, true)
          cw.storage:UpdateCash(player, storageTable.cash - cash)
        else
          cw.player:GiveCash(player, cash, nil, true)
          cw.player:GiveCash(target, -cash, nil, true)
          cw.storage:UpdateCash(player, target:GetCash())
        end

        if storageTable.OnTakeCash
        and storageTable.OnTakeCash(player, storageTable, cash) then
          cw.storage:Close(player)
        end
      end
    end
  else
    cw.player:Notify(player, L('StorageNotOpen'))
  end
end

COMMAND:Register()
