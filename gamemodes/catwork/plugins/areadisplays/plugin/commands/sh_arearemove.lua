--- Registers the `/AreaRemove` command, which removes every area display with the given name.

local COMMAND = cw.command:New('AreaRemove')
COMMAND.tip = '#Command_Arearemove_Description'
COMMAND.text = '#Command_Arearemove_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1

--- Removes every area with the given name, ignoring case, from the server and all clients.
function COMMAND:OnRun(player, arguments)
  local position = player:GetEyeTraceNoCursor().HitPos
  local removed = 0
  local name = string.lower(arguments[1])

  for k, v in pairs(cwAreaDisplays.storedList) do
    if string.lower(v.name) == name then
      cable.send(nil, 'AreaRemove', {
        name = v.name,
        minimum = v.minimum,
        maximum = v.maximum
      })

      cwAreaDisplays.storedList[k] = nil
      removed = removed + 1
    end
  end

  if removed > 0 then
    if removed == 1 then
      cw.player:Notify(player, L('AreaDisplays_RemovedOne', removed))
    else
      cw.player:Notify(player, L('AreaDisplays_RemovedMany', removed))
    end
  else
    cw.player:Notify(player, L('AreaDisplays_NoneFound'))
  end

  cwAreaDisplays:SaveAreaDisplays()
end

COMMAND:Register()
