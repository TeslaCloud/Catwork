--- Registers the `doorparent` tool, which sets up door parenting from the tool gun.
--
-- Left click makes the door the active parent with `/DoorSetParent`, or a child of it with `/DoorSetChild` when a
-- parent is already active. Right click runs `/DoorUnparent` and reload runs `/DoorResetParent`.

local TOOL = cw.tool:New()

TOOL.Name = '#tool.doorparent.name'
TOOL.UniqueID = 'doorparent'
TOOL.Category = 'Clockwork'
TOOL.Desc = '#tool.doorparent.desc'
TOOL.HelpText = '#tool.doorparent.0'
TOOL.rightClickCMD = 'DoorUnparent'
TOOL.reloadCMD = 'DoorResetParent'
TOOL.reloadFire = false

TOOL.ClientConVar['description'] = ''

--- Makes the door being looked at the active parent with `DoorSetParent`, or a child of the active
-- parent with `DoorSetChild` when the player already has one.
function TOOL:LeftClick(tr)
  if CLIENT then return true end

  local player = self:GetOwner()
  local door = tr.Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    if IsValid(player.cwParentDoor) then
      player:RunClockworkCmd('DoorSetChild')
    else
      player:RunClockworkCmd('DoorSetParent')
    end
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

--- Builds the tool menu with the tool's description and usage help.
function TOOL.BuildCPanel(CPanel)
  -- HEADER
  CPanel:AddControl('Header', { Text = '#tool.doorparent.header', Description = '#tool.doorparent.desc' })
  CPanel:AddControl('Header', {
    Text = '#tool.doorparent.helpTitle',
    Description = '#tool.doorparent.help'
  })
end

TOOL:Register()
