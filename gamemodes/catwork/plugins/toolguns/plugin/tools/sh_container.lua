--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local TOOL = cw.tool:New()

TOOL.Name = '#tool.containertool.name'
TOOL.UniqueID = 'containertool'
TOOL.Desc = '#tool.containertool.desc'
TOOL.HelpText = '#tool.containertool.0'

TOOL.ClientConVar['mode'] = '1'
TOOL.ClientConVar['contfillscale']	= '1'
TOOL.ClientConVar['fillcategory']		= 'Consumables'
TOOL.ClientConVar['contname'] = 'A Container'
TOOL.ClientConVar['contmessage'] = 'A Message'
TOOL.ClientConVar['contpassword'] = 'password'

--- Fills the container a trace hit with random items from the tool's fill category.
--
-- Only works on props whose model is in `cwStorage.containerList`; props without an inventory are made
-- into storage first. Items from `cwStorage:GetRandomItem` are added until the inventory weighs at least
-- the container's capacity divided by `6 - scale`, where the `contfillscale` setting (1-5) is the scale.
-- The owner is notified of the result. Does nothing on the client.
--
-- @param entity [Map The trace result whose `Entity` is the container]
-- @return [Boolean True on the client, otherwise nil]
function TOOL:AddItems(entity)
  local trace = entity
  local scale = self:GetClientNumber('contfillscale', 1)
  local category = self:GetClientInfo('fillcategory')
  local player = self:GetOwner()

  if CLIENT then return true end

  if scale then
    scale = math.Clamp(math.Round(scale), 1, 5)

    if IsValid(trace.Entity) then
      if cw.entity:IsPhysicsEntity(trace.Entity) then
        local model = string.lower(trace.Entity:GetModel())

        if cwStorage.containerList[model] then
          if !trace.Entity.cwInventory then
            cwStorage.storage[trace.Entity] = trace.Entity

            trace.Entity.cwInventory = {}
          end

          local containerWeight = cwStorage.containerList[model][1] / (6 - scale)
          local weight = cw.inventory:CalculateWeight(trace.Entity.cwInventory)

          if !category or cwStorage:CategoryExists(category) then
            while weight < containerWeight do
              local randomItem = cwStorage:GetRandomItem(category)

              if randomItem then
                cw.inventory:AddInstance(
                  trace.Entity.cwInventory, item.CreateInstance(randomItem[1])
                )

                weight = weight + randomItem[2]
              end
            end

            cw.player:Notify(player, L('Container_Filled'))
            return
          else
            cw.player:Notify(player, L('Container_CategoryNotExist'))
            return
          end
        end

        cw.player:Notify(player, L('Container_NotValid'))
      else
        cw.player:Notify(player, L('Container_NotValid'))
      end
    else
      cw.player:Notify(player, L('Container_NotValid'))
    end
  else
    cw.player:Notify(player, L('Container_NotValidScale'))
  end
end

--- Sets the message of the prop a trace hit to the tool's `contmessage` setting.
--
-- Stored in the entity's `cwMessage` field. Works on any physics prop; the owner is notified of the
-- result. Does nothing on the client.
--
-- @param entity [Map The trace result whose `Entity` is the container]
-- @return [Boolean True on the client, otherwise nil]
function TOOL:SetMessage(entity)
  local trace = entity
  local player = self:GetOwner()

  if CLIENT then return true end

  if IsValid(trace.Entity) then
    if cw.entity:IsPhysicsEntity(trace.Entity) then
      trace.Entity.cwMessage = self:GetClientInfo('contmessage')

      cw.player:Notify(player, L('Container_MessageSet'))
    else
      cw.player:Notify(player, L('Container_NotValid'))
    end
  else
    cw.player:Notify(player, L('Container_NotValid'))
  end
end

--- Sets the name of the container a trace hit to the tool's `contname` setting.
--
-- Only works on props whose model is in `cwStorage.containerList`; props without an inventory are made
-- into storage first. The name is stored in the entity's `Name` networked string. Does nothing on the
-- client.
--
-- @param entity [Map The trace result whose `Entity` is the container]
-- @return [Boolean True on the client, otherwise nil]
function TOOL:SetName(entity)
  local trace = entity
  local player = self:GetOwner()
  local name = self:GetClientInfo('contname')

  if CLIENT then return true end

  if IsValid(trace.Entity) then
    if cw.entity:IsPhysicsEntity(trace.Entity) then
      local model = string.lower(trace.Entity:GetModel())

      if cwStorage.containerList[model] then
        if !trace.Entity.cwInventory then
          cwStorage.storage[trace.Entity] = trace.Entity

          trace.Entity.cwInventory = {}
        end

        trace.Entity:SetNWString('Name', name)
      else
        cw.player:Notify(player, L('Container_NotValid'))
      end
    else
      cw.player:Notify(player, L('Container_NotValid'))
    end
  else
    cw.player:Notify(player, L('Container_NotValid'))
  end
end

--- Sets the password of the container a trace hit to the tool's `contpassword` setting.
--
-- Only works on props whose model is in `cwStorage.containerList`; props without an inventory are made
-- into storage first. The password is stored in the entity's `cwPassword` field and shown to the owner.
-- Does nothing on the client.
--
-- @param entity [Map The trace result whose `Entity` is the container]
-- @return [Boolean True on the client, otherwise nil]
function TOOL:SetPassword(entity)
  local trace = entity
  local player = self:GetOwner()
  local password = self:GetClientInfo('contpassword')

  if CLIENT then return true end

  if IsValid(trace.Entity) then
    if cw.entity:IsPhysicsEntity(trace.Entity) then
      local model = string.lower(trace.Entity:GetModel())

      if cwStorage.containerList[model] then
        if !trace.Entity.cwInventory then
          cwStorage.storage[trace.Entity] = trace.Entity
          trace.Entity.cwInventory = {}
        end

        trace.Entity.cwPassword = password

        cw.player:Notify(player, L('Container_PasswordSet').." '"..trace.Entity.cwPassword.."'.")
      else
        cw.player:Notify(player, L('Container_NotValid'))
      end
    else
      cw.player:Notify(player, L('Container_NotValid'))
    end
  else
    cw.player:Notify(player, L('Container_NotValid'))
  end
end

--- Runs the selected mode on the container the owner is looking at: fill, set message, name or password.
--
-- Admins only.
function TOOL:LeftClick(trace)
  local mode = self:GetClientNumber('mode')
  local player = self:GetOwner()
  local container = player:GetEyeTraceNoCursor()

  if !player:IsAdmin() then
    return false
  end

  if IsValid(container.Entity) then
    if mode == 1 then
      self:AddItems(container)
    end

    if mode == 2 then
      self:SetMessage(container)
    end

    if mode == 3 then
      self:SetName(container)
    end

    if mode == 4 then
      self:SetPassword(container)
    end
  end
end

if CLIENT then
  local function AddDefControls(Panel)
    Panel:ClearControls()

    local mode = LocalPlayer():GetInfoNum('containertool_mode', 0)

    local list = vgui.Create('DListView')

    local height = 90

    list:SetSize(30, height)
    -- list:SizeToContents()
    list:AddColumn(L('#tool.containertool.mode'))
    list:SetMultiSelect(false)

    function list:OnRowSelected(LineID, line)
      if !(mode == LineID) then
        RunConsoleCommand('cont_setmode', LineID)
      end
    end

    if mode == 1 then
      list:AddLine(' 1 **'..L('#tool.containertool.mode1')..'**')
    else
      list:AddLine(' 1   '..L('#tool.containertool.mode1'))
    end

    if mode == 2 then
      list:AddLine(' 2 **'..L('#tool.containertool.mode2')..'**')
    else
      list:AddLine(' 2   '..L('#tool.containertool.mode2'))
    end

    if mode == 3 then
      list:AddLine(' 3 **'..L('#tool.containertool.mode3')..'**')
    else
      list:AddLine(' 3   '..L('#tool.containertool.mode3')..'  ')
    end

    if mode == 4 then
      list:AddLine(' 4 **'..L('#tool.containertool.mode4')..'**')
    else
      list:AddLine(' 4   '..L('#tool.containertool.mode4')..'  ')
    end

    list:SortByColumn(1)

    Panel:AddItem(list)

    if mode == 1 then
      Panel:AddControl('Slider',  {
        Label = '#tool.containertool.fillscale',
        Type	= 'Interger',
        Min		= 1,
        Max		= 5,
        Command = 'containertool_contfillscale',
        Description = '#tool.containertool.fillscaledesc' })

      Panel:AddControl('TextBox', {
        Label = '#tool.containertool.category',
        MaxLenth = '20',
        Command = 'containertool_fillcategory' })
    end

    if mode == 2 then
      Panel:AddControl('TextBox', {
        Label = '#tool.containertool.message',
        MaxLenth = '20',
        Command = 'containertool_contmessage' })
    end

    if mode == 3 then
      Panel:AddControl('TextBox', {
        Label = '#tool.containertool.contname',
        MaxLenth = '20',
        Command = 'containertool_contname' })
    end

    if mode == 4 then
      Panel:AddControl('TextBox', {
        Label = '#tool.containertool.password',
        MaxLenth = '20',
        Command = 'containertool_contpassword' })
    end
  end

  --- Switches the container tool to another mode and rebuilds its control panel.
  --
  -- Registered as the `cont_setmode` console command and run when a mode is picked in the panel.
  --
  -- @param player [Player The local player]
  -- @param tool [String The console command name]
  -- @param args [List<String> Command arguments; the first is the mode number (1-4)]
  function cont_setmode(player, tool, args)
    if LocalPlayer():GetInfoNum('containertool_mode', 3) != args[1] then
      RunConsoleCommand('containertool_mode', args[1])
      timer.Simple(0.05, function() cont_updatepanel() end)
    end
  end

  concommand.Add('cont_setmode', cont_setmode)

  --- Rebuilds the container tool's control panel for the current mode.
  --
  -- Registered as the `cont_updatepanel` console command. Does nothing when the panel does not exist.
  function cont_updatepanel()
    local Panel = controlpanel.Get('containertool')
    if !Panel then return end

    AddDefControls(Panel)
  end

  concommand.Add('cont_updatepanel', cont_updatepanel)

  --- Builds the tool's control panel: the mode list and the settings for the current mode.
  --
  -- @param Panel [Panel The tool's control panel]
  function TOOL.BuildCPanel(Panel)
    AddDefControls(Panel)
  end
end

local pluginTable = plugin.FindByID('Storage')

if pluginTable then
  if plugin.IsDisabled(pluginTable.name) or plugin.IsUnloaded(pluginTable.name) then
  else
    TOOL:Register()
  end
end
