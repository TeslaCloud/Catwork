--- Registers the `/DoorSetAllOwnable` command, which makes every door on the map ownable under the given name.

local COMMAND = cw.command:New('DoorSetAllOwnable')
COMMAND.tip = '#Command_Doorsetallownable_Description'
COMMAND.text = '#Command_Doorsetallownable_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Makes every door on the map ownable under the name given by the arguments and saves the door data.
function COMMAND:OnRun(player, arguments)
  local name = table.concat(arguments, ' ')
  local goodDoors = 0

  for k, v in pairs(ents.GetAll()) do
    if IsValid(v) and cw.entity:IsDoor(v) then
      cw.entity:SetDoorUnownable(v, false)
      cw.entity:SetDoorText(v, false)
      cw.entity:SetDoorName(v, name)

      cwDoorCmds.doorData[v] = {
        customName = true,
        position = v:GetPos(),
        entity = v,
        name = name
      }

      goodDoors = goodDoors + 1
    end
  end

  cwDoorCmds:SaveDoorData()

  cw.player:Notify(player, L('DoorCmds_AllSetOwnable', goodDoors))
  cw.player:Notify(player, L('DoorCmds_AllDoorsReminder'))
end

COMMAND:Register()
