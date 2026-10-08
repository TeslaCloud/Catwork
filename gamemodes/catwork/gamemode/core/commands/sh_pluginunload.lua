--- Registers the superadmin command `/PluginUnload`, which unloads a plugin and sends its new state to the players who
-- can manage plugins.

local COMMAND = cw.command:New('PluginUnload')
COMMAND.tip = '#Command_Pluginunload_Description'
COMMAND.text = '#Command_Pluginunload_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1

--- Unloads a plugin; the argument is the plugin name or ID.
--
-- Players who may use this command are sent the new plugin state.
function COMMAND:OnRun(player, arguments)
  local plugin = plugin.FindByID(arguments[1])

  if !plugin then
    cw.player:Notify(player, L('PluginManage_NotValid'))
    return
  end

  local unloadTable = cw.command:FindByID('PluginLoad')
  local loadTable = cw.command:FindByID('PluginLoad')

  if !plugin.IsDisabled(plugin.name) then
    local bSuccess = plugin.SetUnloaded(plugin.name, true)
    local recipients = {}

    if bSuccess then
      cw.player:NotifyAll(L('PluginManage_Unloaded', player:Name(), plugin.name))

      for k, v in ipairs(_player.GetAll()) do
        if v:HasInitialized() then
          if cw.player:HasFlags(v, loadTable.access)
          or cw.player:HasFlags(v, unloadTable.access) then
            recipients[#recipients + 1] = v
          end
        end
      end

      if #recipients > 0 then
        netstream.Start(recipients, 'SystemPluginSet', { plugin.name, true })
      end
    else
      cw.player:Notify(player, L('PluginManage_CouldNotUnload'))
    end
  else
    cw.player:Notify(player, L('PluginManage_Depends'))
  end
end

COMMAND:Register()
