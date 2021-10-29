--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("command", cw)

local stored = cw.command.stored or {}
cw.command.stored = stored

local hidden = {}
local alias = {}

CMD_KNOCKEDOUT = 2
CMD_FALLENOVER = 4
CMD_DEATHCODE = 8
CMD_RAGDOLLED = 16
CMD_VEHICLE = 32
CMD_DEAD = 64

CMD_DEFAULT = bit.bor(CMD_DEAD, CMD_KNOCKEDOUT)
CMD_HEAVY = bit.bor(CMD_DEAD, CMD_RAGDOLLED)
CMD_ALL = bit.bor(CMD_DEAD, CMD_VEHICLE, CMD_RAGDOLLED)

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE}

-- A function to register a new command.
function CLASS_TABLE:Register()
	return cw.command:Register(self, self.name)
end

-- A function to get all stored commands.
function cw.command:GetAll()
	return stored
end

-- A function to get a new command.
function cw.command:New(name)
	local object = cw.core:NewMetaTable(CLASS_TABLE)
		object.name = name or "Unknown"
	return object
end

-- A function to remove a command.
function cw.command:RemoveByID(identifier)
	stored[string.lower(string.gsub(identifier, "%s", ""))] = nil
end

-- A function to set whether a command is hidden.
function cw.command:SetHidden(name, bHidden)
	local uniqueID = string.lower(string.gsub(name, "%s", ""))

	if (!bHidden and hidden[uniqueID]) then
		stored[uniqueID] = hidden[uniqueID]
		hidden[uniqueID] = nil
	elseif (hidden and stored[uniqueID]) then
		hidden[uniqueID] = stored[uniqueID]
		stored[uniqueID] = nil
	end

	if (SERVER) then
		netstream.Start(nil, "HideCommand", {
			index = cw.core:GetShortCRC(uniqueID), hidden = bHidden
		})
	elseif (bHidden and hidden[uniqueID]) then
		self:RemoveHelp(hidden[uniqueID])
	elseif (!bHidden and stored[uniqueID]) then
		self:AddHelp(stored[uniqueID])
	end
end

-- A function to register a new command.
function cw.command:Register(data, name)
	local realName = string.gsub(name, "%s", "")
	local uniqueID = string.lower(realName)

	if (CLIENT) then
		if (stored[uniqueID]) then
			self:RemoveHelp(stored[uniqueID])
		end
	end

	-- We do that so the Command Interpreter can find the command
 	-- if it's original, non-aliased name has been used.
 	alias[uniqueID] = uniqueID

 	if (data.alias and type(data.alias) == "table") then
 		for k, v in pairs(data.alias) do
 			alias[string.lower(tostring(v))] = uniqueID
 		end
 	end

	stored[uniqueID] = data
	stored[uniqueID].name = realName
	stored[uniqueID].text = data.text or "<none>"
	stored[uniqueID].flags = data.flags or 0
	stored[uniqueID].access = data.access or "b"
	stored[uniqueID].arguments = data.arguments or 0
	stored[uniqueID].uniqueID = uniqueID or "ERROR"

	if (CLIENT) then
		self:AddHelp(stored[uniqueID])
	end

	return stored[uniqueID]
end

-- A function to find a command by an identifier.
function cw.command:FindByID(identifier)
	return stored[string.lower(string.gsub(identifier, "%s", ""))]
end

--[[
 	@codebase Shared
 	@details Returns command's table by alias or unique id.
	@param ID Identifier of the command to find. Can be alias or original command name.
--]]
function cw.command:FindByAlias(identifier)
	return stored[alias[string.lower(string.gsub(identifier, "%s", ""))]]
end

--[[
	@codebase Shared
	@details Returns table of all command alias indexed by alias' names.
--]]
function cw.command:GetAlias()
	return alias
end

if (SERVER) then
	function cw.command:ConsoleCommand(player, command, arguments)
		if (IsValid(player) and player:HasInitialized()) then
			if (arguments and arguments[1]) then
				local realCommand = string.lower(arguments[1])
				local commandTable = self:FindByAlias(realCommand)
				local commandPrefix = config.GetVal("command_prefix")

				if (commandTable) then
					table.remove(arguments, 1)

					if (commandTable.cooldown and !player:IsAdmin()) then
						local curTime = CurTime()
						local cmdID = commandTable.uniqueID

						if (!player.cmdCooldowns) then
							player.cmdCooldowns = {}
						end

						local cmdCD = player.cmdCooldowns[cmdID]

						if (cmdCD) then
							if (cmdCD > curTime) then
								cw.player:Notify(player, "Вы не сможете использовать эту команду еще "..math.Round(cmdCD - curTime).." секунд.")

								return false
							end
						end

						player.cmdCooldowns[cmdID] = curTime + commandTable.cooldown
					end

					for k, v in pairs(arguments) do
						arguments[k] = cw.core:Replace(arguments[k], " ' ", "'")
						arguments[k] = cw.core:Replace(arguments[k], " : ", ":")
					end

					if (hook.Run("PlayerCanUseCommand", player, commandTable, arguments)) then
						if (#arguments >= commandTable.arguments) then
							if ((cw.player:HasFlags(player, commandTable.access) and ((!commandTable.faction)
							or (commandTable.faction and (commandTable.faction == player:GetFaction())
							or (istable(commandTable.faction) and table.HasValue(commandTable.faction, player:GetFaction())))))
							or player:HasPermission(commandTable.uniqueID)) then
								local flags = commandTable.flags

								if (cw.player:GetDeathCode(player, true)) then
									if (flags == 0 and CMD_DEATHCODE == 0) then
										cw.player:TakeDeathCode(player)
									end
								end

								if (bit.band(flags, CMD_DEAD) > 0 and !player:Alive()) then
									if (!player.cwDeathCodeAuth) then
										cw.player:Notify(player, "You cannot do this action at the moment!")
									end return
								elseif (bit.band(flags, CMD_VEHICLE) > 0 and player:InVehicle()) then
									if (!player.cwDeathCodeAuth) then
										cw.player:Notify(player, "You cannot do this action at the moment!")
									end return
								elseif (bit.band(flags, CMD_RAGDOLLED) > 0 and player:IsRagdolled()) then
									if (!player.cwDeathCodeAuth) then
										cw.player:Notify(player, "You cannot do this action at the moment!")
									end return
								elseif (bit.band(flags, CMD_FALLENOVER) > 0 and player:GetRagdollState() == RAGDOLL_FALLENOVER) then
									if (!player.cwDeathCodeAuth) then
										cw.player:Notify(player, "You cannot do this action at the moment!")
									end return
								elseif (bit.band(flags, CMD_KNOCKEDOUT) > 0 and player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
									if (!player.cwDeathCodeAuth) then
										cw.player:Notify(player, "You cannot do this action at the moment!")
									end return
								end

								if (commandTable.OnRun) then
									local bSuccess, value = pcall(commandTable.OnRun, commandTable, player, arguments)

									if (!bSuccess) then
										MsgC(Color(255, 100, 0, 255), "\n[CW:Command]\nThe '"..commandTable.name.."' command has failed to run.\n"..value.."\n")
									elseif (cw.player:GetDeathCode(player, true)) then
										cw.player:UseDeathCode(player, commandTable.name, arguments)
									end

									if (bSuccess) then
										if (table.concat(arguments, " ") != "") then
											cw.core:PrintLog(LOGTYPE_GENERIC, player:Name(true).." has used '"..commandPrefix..commandTable.name.." "..table.concat(arguments, " ").."'.")
										else
											cw.core:PrintLog(LOGTYPE_GENERIC, player:Name(true).." has used '"..commandPrefix..commandTable.name.."'.")
										end

										return value
									end

									hook.Run("PostCommandUsed", player, commandTable, arguments)
								end
							else
								cw.player:Notify(player, "You do not have access to this command, "..player:Name()..".")
							end
						else
							cw.player:Notify(player, commandTable.name.." "..commandTable.text.."!")
						end
					end
				elseif (!cw.player:GetDeathCode(player, true)) then
					cw.player:Notify(player, "This is not a valid command or alias!")
				end
			elseif (!cw.player:GetDeathCode(player, true)) then
				cw.player:Notify(player, "This is not a valid command or alias!")
			end

			if (cw.player:GetDeathCode(player)) then
				cw.player:TakeDeathCode(player)
			end
		else
			cw.player:Notify(player, "You cannot use commands yet!")
		end
	end

	concommand.Add("cwCmd", function(player, command, arguments)
		cw.command:ConsoleCommand(player, command, arguments)
	end)

	hook.Add("PlayerInitialSpawn", "cw.command:PlayerInitialSpawn", function(player)
		local hiddenCommands = {}

		for k, v in pairs(hidden) do
			hiddenCommands[#hiddenCommands + 1] = cw.core:GetShortCRC(k)
		end

		netstream.Start(player, "HiddenCommands", hiddenCommands)
	end)
else
	function cw.command:AddHelp(commandTable)
		if (_G["ClockworkClientsideBooted"]) then return end

		local text = string.gsub(string.gsub(commandTable.text, ">", "&gt;"), "<", "&lt;")

		if (!commandTable.helpID) then
			commandTable.helpID = cw.directory:AddCode("Commands", [[
				<div class="cwTitleSeperator">
					$command_prefix$]]..string.upper(commandTable.name)..[[
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">
						<i>]]..text..[[</i>
					</div>
					]]..commandTable.tip..[[
				</div>
				<br>
			]], true, commandTable.name)
		end
	end

	-- A function to remove a command's help.
	function cw.command:RemoveHelp(commandTable)
		if (commandTable.helpID) then
			cw.directory:RemoveCode("Commands", commandTable.helpID)
			commandTable.helpID = nil
		end
	end
end
