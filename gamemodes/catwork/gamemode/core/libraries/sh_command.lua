--- Defines the `cw.command` library, the registry of chat commands, and the `cwCmd` console command that runs them.
--
-- A command is created with `cw.command:New` and registered with its aliases; its `CMD_` flags name the states (dead,
-- ragdolled, in a vehicle and so on) in which it is refused. On the server `cw.command:ConsoleCommand` checks
-- cooldown, access and arguments before calling `COMMAND:OnRun`, and on the client each command is listed on the
-- Commands page of the directory.

library.New('command', cw)

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
local CLASS_TABLE = { __index = CLASS_TABLE }

--- Registers the command with `cw.command:Register` under its `name`.
--
-- @return [Command The registered command table]
function CLASS_TABLE:Register()
  return cw.command:Register(self, self.name)
end

--- Returns every registered, visible command keyed by unique ID.
--
-- @return [Map<Command> Commands keyed by their lowercased, space-less name]
function cw.command:GetAll()
  return stored
end

--- Creates a new, unregistered command object.
--
-- Set its fields and call `CLASS_TABLE:Register` on it. `text` is the syntax, `tip` the
-- description, `flags` a combination of `CMD_*` flags that block the command in some states,
-- `access` the flags a player needs, `arguments` the minimum argument count, and `alias`,
-- `cooldown` and `faction` are optional. `COMMAND:OnRun(player, arguments)` runs the command.
--
-- ```
-- local COMMAND = cw.command:New('SetCash')
-- COMMAND.tip = '#Command_Setcash_Description'
-- COMMAND.text = '#Command_Setcash_Syntax'
-- COMMAND.flags = CMD_DEFAULT
-- COMMAND.access = 's'
-- COMMAND.arguments = 2
--
-- function COMMAND:OnRun(player, arguments)
-- end
--
-- COMMAND:Register()
-- ```
--
-- @param name='Unknown' [String Name of the command, as typed after the command prefix]
-- @return [Command The new command object]
function cw.command:New(name)
  local object = cw.core:NewMetaTable(CLASS_TABLE)
    object.name = name or 'Unknown'
  return object
end

--- Removes a registered command.
--
-- Its aliases and help entry are left in place.
--
-- @param identifier [String Command name; case and whitespace are ignored]
function cw.command:RemoveByID(identifier)
  stored[string.lower(string.gsub(identifier, '%s', ''))] = nil
end

--- Hides a command from the command list, or shows a hidden one again.
--
-- Hidden commands are moved out of the stored commands, so they cannot be found or run. On the
-- server the change is sent to every client; on the client the command's help entry is removed
-- or added.
--
-- @param name [String Command name; case and whitespace are ignored]
-- @param bHidden [Boolean Whether the command should be hidden]
function cw.command:SetHidden(name, bHidden)
  local uniqueID = string.lower(string.gsub(name, '%s', ''))

  if !bHidden and hidden[uniqueID] then
    stored[uniqueID] = hidden[uniqueID]
    hidden[uniqueID] = nil
  elseif bHidden and stored[uniqueID] then
    hidden[uniqueID] = stored[uniqueID]
    stored[uniqueID] = nil
  end

  if SERVER then
    netstream.Start(nil, 'HideCommand', {
      index = cw.core:GetShortCRC(uniqueID), hidden = bHidden
    })
  elseif bHidden and hidden[uniqueID] then
    self:RemoveHelp(hidden[uniqueID])
  elseif !bHidden and stored[uniqueID] then
    self:AddHelp(stored[uniqueID])
  end
end

--- Registers a command and its aliases.
--
-- Fills in defaults: `text` becomes `#Command_NoSyntax`, `flags` 0, `access` `'b'` and
-- `arguments` 0. The unique ID is the name lowercased with whitespace removed. On the client the
-- command's help entry is (re)created.
--
-- @param data [Command The command object or table]
-- @param name [String Command name]
-- @return [Command The registered command table]
function cw.command:Register(data, name)
  local realName = string.gsub(name, '%s', '')
  local uniqueID = string.lower(realName)

  if CLIENT then
    if stored[uniqueID] then
      self:RemoveHelp(stored[uniqueID])
    end
  end

  -- We do that so the Command Interpreter can find the command
  -- if it's original, non-aliased name has been used.
  alias[uniqueID] = uniqueID

  if data.alias and type(data.alias) == 'table' then
    for k, v in pairs(data.alias) do
      alias[string.lower(tostring(v))] = uniqueID
    end
  end

  stored[uniqueID] = data
  stored[uniqueID].name = realName
  stored[uniqueID].text = data.text or '#Command_NoSyntax'
  stored[uniqueID].flags = data.flags or 0
  stored[uniqueID].access = data.access or 'b'
  stored[uniqueID].arguments = data.arguments or 0
  stored[uniqueID].uniqueID = uniqueID or 'ERROR'

  if CLIENT then
    self:AddHelp(stored[uniqueID])
  end

  return stored[uniqueID]
end

--- Finds a command by its name, ignoring aliases.
--
-- @param identifier [String Command name; case and whitespace are ignored]
-- @return [Command The command, or `nil` if none matches]
-- @see cw.command:FindByAlias
function cw.command:FindByID(identifier)
  return stored[string.lower(string.gsub(identifier, '%s', ''))]
end

--- Finds a command by its name or one of its aliases.
--
-- @param identifier [String Command name or alias; case and whitespace are ignored]
-- @return [Command The command, or `nil` if none matches]
-- @see cw.command:FindByID
function cw.command:FindByAlias(identifier)
  return stored[alias[string.lower(string.gsub(identifier, '%s', ''))]]
end

--- Returns the alias lookup table.
--
-- Every command's own unique ID is included as an alias of itself.
--
-- @return [Map<String> Command unique IDs keyed by lowercased alias]
function cw.command:GetAlias()
  return alias
end

if SERVER then
  --- Runs a command for a player, as typed through the `cwCmd` console command.
  --
  -- Checks, in order: the player has initialized, the command exists, the command's cooldown
  -- (skipped for admins), the `PlayerCanUseCommand` hook, the argument count, the player's access
  -- flags, faction or permission, and the command's `CMD_*` state flags. Then calls
  -- `COMMAND:OnRun` in protected mode, prints errors to the console, and on success logs the use
  -- and runs the `PostCommandUsed` hook. The player is notified when a check fails. Does nothing
  -- when run from the server console.
  --
  -- @param player [Player The player running the command]
  -- @param command [String Name of the console command, unused]
  -- @param arguments [List<String> The command name followed by its arguments; the name is removed
  -- from the list]
  -- @return [Any The value returned by `OnRun`, or `false` while the command is on cooldown]
  function cw.command:ConsoleCommand(player, command, arguments)
    if !IsValid(player) then return end

    if player:HasInitialized() then
      if arguments and arguments[1] then
        local realCommand = string.lower(arguments[1])
        local commandTable = self:FindByAlias(realCommand)
        local commandPrefix = config.GetVal('command_prefix')

        if commandTable then
          table.remove(arguments, 1)

          if commandTable.cooldown and !player:IsAdmin() then
            local curTime = CurTime()
            local cmdID = commandTable.uniqueID

            if !player.cmdCooldowns then
              player.cmdCooldowns = {}
            end

            local cmdCD = player.cmdCooldowns[cmdID]

            if cmdCD then
              if cmdCD > curTime then
                cw.player:Notify(player, L('Command_Cooldown', math.Round(cmdCD - curTime)))

                return false
              end
            end

            player.cmdCooldowns[cmdID] = curTime + commandTable.cooldown
          end

          -- Commands run from Lua can be handed values that are not strings.
          for k, v in pairs(arguments) do
            v = cw.core:Replace(tostring(v), " ' ", "'")
            arguments[k] = cw.core:Replace(v, ' : ', ':')
          end

          if hook.Run('PlayerCanUseCommand', player, commandTable, arguments) then
            if #arguments >= commandTable.arguments then
              if (cw.player:HasFlags(player, commandTable.access) and ((!commandTable.faction)
              or (commandTable.faction and (commandTable.faction == player:GetFaction())
              or (istable(commandTable.faction) and table.HasValue(commandTable.faction, player:GetFaction())))))
              or player:HasPermission(commandTable.uniqueID) then
                local flags = commandTable.flags

                if (bit.band(flags, CMD_DEAD) > 0 and !player:Alive())
                or (bit.band(flags, CMD_VEHICLE) > 0 and player:InVehicle())
                or (bit.band(flags, CMD_RAGDOLLED) > 0 and player:IsRagdolled())
                or (bit.band(flags, CMD_FALLENOVER) > 0 and player:GetRagdollState() == RAGDOLL_FALLENOVER)
                or (bit.band(flags, CMD_KNOCKEDOUT) > 0 and player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
                  if !player.cwDeathCodeAuth then
                    cw.player:Notify(player, L('CannotActionRightNow'))
                  end

                  return
                end

                if commandTable.OnRun then
                  local bSuccess, value = pcall(commandTable.OnRun, commandTable, player, arguments)

                  if bSuccess then
                    if cw.player:GetDeathCode(player, true) then
                      cw.player:UseDeathCode(player, commandTable.name, arguments)
                    end

                    local text = table.concat(arguments, ' ')

                    if text != '' then
                      text = ' '..text
                    end

                    cw.core:PrintLog(
                      LOGTYPE_GENERIC, player:Name(true).." has used '"..commandPrefix..commandTable.name..text.."'."
                    )

                    hook.Run('PostCommandUsed', player, commandTable, arguments)

                    return value
                  end

                  MsgC(
                    Color(255, 100, 0, 255),
                    "\n[CW:Command]\nThe '"..commandTable.name.."' command has failed to run.\n"..tostring(value)..'\n'
                  )
                end
              else
                cw.player:Notify(player, L('Commands_cwLua_accessDenied', player:Name()))
              end
            else
              cw.player:Notify(player, commandTable.name..' '..commandTable.text..'!')
            end
          end
        elseif !cw.player:GetDeathCode(player, true) then
          cw.player:Notify(player, L('Command_NotValid'))
        end
      elseif !cw.player:GetDeathCode(player, true) then
        cw.player:Notify(player, L('Command_NotValid'))
      end

      if cw.player:GetDeathCode(player) then
        cw.player:TakeDeathCode(player)
      end
    else
      cw.player:Notify(player, L('Command_CannotUseYet'))
    end
  end

  concommand.Add('cwCmd', function(player, command, arguments)
    cw.command:ConsoleCommand(player, command, arguments)
  end)

  hook.Add('PlayerInitialSpawn', 'cw.command:PlayerInitialSpawn', function(player)
    local hiddenCommands = {}

    for k, v in pairs(hidden) do
      hiddenCommands[#hiddenCommands + 1] = cw.core:GetShortCRC(k)
    end

    netstream.Start(player, 'HiddenCommands', hiddenCommands)
  end)
else
  --- Adds a command's syntax and tip to the Commands page of the directory.
  --
  -- Does nothing once the client has finished booting (so Lua refreshes add nothing) or when the
  -- command already has a help entry. The syntax and tip are translated when the page is shown.
  --
  -- @param commandTable [Command The command to add]
  function cw.command:AddHelp(commandTable)
    if _G['ClockworkClientsideBooted'] then return end

    if !commandTable.helpID then
      commandTable.helpID = cw.directory:AddCode('Commands', [[
				<div class="cwTitleSeperator">
					$command_prefix$]]..string.upper(commandTable.name)..[[
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">
						<i>[syntax]</i>
					</div>
					[tip]
				</div>
				<br>
			]], true, commandTable.name, function(htmlCode)
        -- The syntax and the tip are language phrases, so they are translated when the page is shown.
        local text = string.gsub(string.gsub(cw.lang:TranslateText(commandTable.text), '>', '&gt;'), '<', '&lt;')

        htmlCode = string.Replace(htmlCode, '[syntax]', text)

        return string.Replace(htmlCode, '[tip]', cw.lang:TranslateText(commandTable.tip or ''))
      end)
    end
  end

  --- Removes a command's entry from the Commands page of the directory.
  --
  -- @param commandTable [Command The command to remove]
  function cw.command:RemoveHelp(commandTable)
    if commandTable.helpID then
      cw.directory:RemoveCode('Commands', commandTable.helpID)
      commandTable.helpID = nil
    end
  end
end
