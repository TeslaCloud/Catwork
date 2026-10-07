--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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

function TOOL.BuildCPanel(CPanel)
  -- HEADER
  CPanel:AddControl('Header', { Text = '#tool.doorparent.header', Description = '#tool.doorparent.desc' })
  CPanel:AddControl('Header', {
    Text = '#tool.doorparent.helpTitle',
    Description = '#tool.doorparent.help'
  })
end

TOOL:Register()
