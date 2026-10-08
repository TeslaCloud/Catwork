--- Registers the `/DoorSetAllOwnable` command, which makes every door on the map ownable under the given name.

local COMMAND = cw.command:New('DoorSetAllOwnable')
COMMAND.tip = '#Command_Doorsetallownable_Description'
COMMAND.text = '#Command_Doorsetallownable_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Makes every door on the map ownable under the name given by the arguments and saves the door data.
function COMMAND:OnRun(player, arguments)
  good_doors = 0

  for k, v in pairs(ents.GetAll()) do
    if IsValid(v) and cw.entity:IsDoor(v) then
      local data = {
        customName = true,
        position = v:GetPos(),
        entity = v,
        name = table.concat(arguments or {}, ' ') or ''
      }
      cw.entity:SetDoorUnownable(data.entity, false)
      cw.entity:SetDoorText(data.entity, false)
      cw.entity:SetDoorName(data.entity, data.name)

      cwDoorCmds.doorData[data.entity] = data
      cwDoorCmds:SaveDoorData()
      good_doors = good_doors + 1
    end
  end

  cw.player:Notify(player, L('DoorCmds_AllSetOwnable', good_doors))
  cw.player:Notify(player, L('DoorCmds_AllDoorsReminder'))
end

COMMAND:Register()
