--- Registers the superadmin command `/PluginLoad`, which loads a previously unloaded plugin and sends its new state to
-- the players who can manage plugins.

local COMMAND = cw.command:New('PluginLoad')
COMMAND.tip = '#Command_Pluginload_Description'
COMMAND.text = '#Command_Pluginload_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1

--- Loads a previously unloaded plugin; the argument is the plugin name or ID.
--
-- Players who may use this command are sent the new plugin state.
function COMMAND:OnRun(player, arguments)
  local pluginTable = plugin.FindByID(arguments[1])

  if !pluginTable then
    cw.player:Notify(player, L('PluginManage_NotValid'))
    return
  end

  local loadTable = cw.command:FindByID('PluginLoad')

  if !plugin.IsDisabled(pluginTable.name) then
    local bSuccess = plugin.SetUnloaded(pluginTable.name, false)
    local recipients = {}

    if bSuccess then
      cw.player:NotifyAll(L('PluginManage_Loaded', player:Name(), pluginTable.name))

      for k, v in ipairs(_player.GetAll()) do
        if v:HasInitialized() then
          if cw.player:HasFlags(v, loadTable.access) then
            recipients[#recipients + 1] = v
          end
        end
      end

      if #recipients > 0 then
        netstream.Start(recipients, 'SystemPluginSet', { pluginTable.name, false })
      end
    else
      cw.player:Notify(player, L('PluginManage_CouldNotLoad'))
    end
  else
    cw.player:Notify(player, L('PluginManage_Depends'))
  end
end

COMMAND:Register()
