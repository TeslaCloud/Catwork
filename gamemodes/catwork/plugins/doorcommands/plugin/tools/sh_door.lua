--- Registers the `doortool` tool, which locks and unlocks doors and sets them ownable or unownable from the tool gun.
--
-- Left click runs `/DoorLock`, `/DoorSetOwnable` or `/DoorSetUnownable` depending on the selected mode, and right
-- click runs `/DoorUnlock` in lock mode. The tool menu picks the mode and the door name and text.

local TOOL = cw.tool:New()

TOOL.Name = '#tool.doortool.name'
TOOL.UniqueID = 'doortool'
TOOL.Desc = '#tool.doortool.desc'
TOOL.HelpText = '#tool.doortool.0'

-- Create the convars for the client.
TOOL.ClientConVar['mode'] = '1'
TOOL.ClientConVar['doorname']	= 'A Door'
TOOL.ClientConVar['doordesc']	= 'It seems to have a handle.'

--- Runs the command for the selected mode on the door being looked at: `DoorLock` (mode 1),
-- `DoorSetOwnable` with the name (mode 2) or `DoorSetUnownable` with the name and text (mode 3).
function TOOL:LeftClick(trace)
  if CLIENT then return true end

  local mode = self:GetClientNumber('mode')
  local player = self:GetOwner()

  if mode == 1 then
    player:RunClockworkCmd('DoorLock')
  elseif mode == 2 then
    player:RunClockworkCmd('DoorSetOwnable', self:GetClientInfo('doorname'))
  elseif mode == 3 then
    player:RunClockworkCmd('DoorSetUnownable', self:GetClientInfo('doorname'), self:GetClientInfo('doordesc'))
  end
end

--- Runs `DoorUnlock` on the door being looked at when the tool is in lock mode (mode 1).
function TOOL:RightClick(trace)
  if CLIENT then return true end

  local mode = self:GetClientNumber('mode')
  local player = self:GetOwner()

  if mode == 1 then
    player:RunClockworkCmd('DoorUnlock')
  end
end

if CLIENT then
  -- A function to add the controls for the tool in the tool menu.
  local function AddDefControls(panel)
    panel:ClearControls()

    local mode = cw.client:GetInfoNum('doortool_mode', 0)
    local list = vgui.Create('DListView')
    local height = 90

    list:SetSize(30, height)
    list:AddColumn(L('#tool.doortool.mode'))
    list:SetMultiSelect(false)

    function list:OnRowSelected(LineID, line)
      if mode != LineID then
        RunConsoleCommand('door_setmode', LineID)
      end
    end

    if mode == 1 then
      list:AddLine(' 1 **'..L('#tool.doortool.mode1')..'**')
    else
      list:AddLine(' 1   '..L('#tool.doortool.mode1'))
    end

    if mode == 2 then
      list:AddLine(' 2 **'..L('#tool.doortool.mode2')..'**')
    else
      list:AddLine(' 2   '..L('#tool.doortool.mode2')..'  ')
    end

    if mode == 3 then
      list:AddLine(' 3 **'..L('#tool.doortool.mode3')..'**')
    else
      list:AddLine(' 3   '..L('#tool.doortool.mode3')..'  ')
    end

    list:SortByColumn(1)

    panel:AddItem(list)

    if mode == 1 then
      panel:AddControl('Header', { Text = '#tool.doortool.mode1', Description = '#tool.doortool.mode1desc' })
    elseif mode == 2 then
      panel:AddControl('TextBox', {
        Label = '#tool.doortool.doorname',
        MaxLenth = '20',
        Command = 'doortool_doorname'
      })
    elseif mode == 3 then
      panel:AddControl('TextBox', {
        Label = '#tool.doortool.doorname',
        MaxLenth = '20',
        Command = 'doortool_doorname'
      })

      panel:AddControl('TextBox', {
        Label = '#tool.doortool.doordesc',
        MaxLenth = '20',
        Command = 'doortool_doordesc'
      })
    end
  end

  --- Builds the tool menu controls: the mode list and the fields the selected mode uses.
  function TOOL.BuildCPanel(panel)
    AddDefControls(panel)
  end

  local function DoorUpdatePanel()
    local panel = controlpanel.Get('doortool')

    if !panel then return end

    AddDefControls(panel)
  end

  -- A concommand that is called to set the mode of the tool, called from the controls in the tool menu.
  concommand.Add('door_setmode', function(player, tool, args)
    if cw.client:GetInfoNum('doortool_mode', 2) != args[1] then
      RunConsoleCommand('doortool_mode', args[1])

      timer.Simple(0.05, function()
        DoorUpdatePanel()
      end)
    end
  end)

  -- A concommand that is called to rebuild the control panel for the tool, to show any new changes or selections.
  concommand.Add('door_updatepanel', DoorUpdatePanel)
end

TOOL:Register()
