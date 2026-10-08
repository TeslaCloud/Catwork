--- Registers the `/StorageGiveCash` command, which moves some of the caller's cash into the storage they have open.

local COMMAND = cw.command:New('StorageGiveCash')
COMMAND.tip = '#Command_Storagegivecash_Description'
COMMAND.text = '#Command_Storagegivecash_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.cooldown = 5

--- Puts some of the caller's cash into the open storage; the argument is the amount.
--
-- For a player storage the cash goes to that player. Respects the storage's weight and space and its
-- `CanGiveCash`/`OnGiveCash` callbacks, and refuses one-sided storages.
function COMMAND:OnRun(player, arguments)
  local storageTable = player:GetStorageTable()

  if storageTable then
    local target = storageTable.entity
    local cash = math.floor(tonumber(arguments[1]) or 0)

    if (target and !IsValid(target)) or !config.GetVal('cash_enabled') then
      return
    end

    if storageTable.isOneSided then
      cw.player:Notify(player, L('StorageCannotGive'))
      return
    end

    if cash >= 1 and cw.player:CanAfford(player, cash) then
      if !storageTable.CanGiveCash
      or (storageTable.CanGiveCash(player, storageTable, cash) != false) then
        if !target or !target:IsPlayer() then
          local cashWeight = (storageTable.noCashWeight and 0) or config.GetVal('cash_weight')
          local cashSpace = (storageTable.noCashSpace and 0) or config.GetVal('cash_space')

          -- The callback below stores the cash, so it must not run for cash that did not fit.
          if cw.storage:GetWeight(player) + (cashWeight * cash) > storageTable.weight
          or cw.storage:GetSpace(player) + (cashSpace * cash) > storageTable.space then
            return
          end

          cw.player:GiveCash(player, -cash, nil, true)
          cw.storage:UpdateCash(player, storageTable.cash + cash)
        else
          cw.player:GiveCash(player, -cash, nil, true)
          cw.player:GiveCash(target, cash, nil, true)
          cw.storage:UpdateCash(player, target:GetCash())
        end

        if storageTable.OnGiveCash
        and storageTable.OnGiveCash(player, storageTable, cash) then
          cw.storage:Close(player)
        end
      end
    end
  else
    cw.player:Notify(player, L('StorageNotOpen'))
  end
end

COMMAND:Register()
