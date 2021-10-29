--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PluginLoad")
COMMAND.tip = "#Command_Pluginload_Description"
COMMAND.text = "#Command_Pluginload_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local pluginTable = plugin.FindByID(arguments[1])

	if (!plugin) then
		cw.player:Notify(player, "This plugin is not valid!")
		return
	end

	local loadTable = cw.command:FindByID("PluginLoad")

	if (!plugin.IsDisabled(pluginTable.name)) then
		local bSuccess = plugin.SetUnloaded(pluginTable.name, false)
		local recipients = {}

		if (bSuccess) then
			cw.player:NotifyAll(player:Name().." has loaded the "..pluginTable.name.." plugin for the next restart.")

			for k, v in ipairs(_player.GetAll()) do
				if (v:HasInitialized()) then
					if (cw.player:HasFlags(v, loadTable.access)) then
						recipients[#recipients + 1] = v
					end
				end
			end

			if (#recipients > 0) then
				netstream.Start(recipients, "SystemPluginSet", {pluginTable.name, false})
			end
		else
			cw.player:Notify(player, "This plugin could not be loaded!")
		end
	else
		cw.player:Notify(player, "This plugin depends on another plugin!")
	end
end

COMMAND:Register();
