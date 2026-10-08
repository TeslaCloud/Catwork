--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('PlyBan')
COMMAND.tip = '#Command_Plyban_Description'
COMMAND.text = '#Command_Plyban_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.alias = { 'Ban' }

--- Bans a player; arguments are the name, Steam ID or IP, the duration in minutes and an optional reason.
--
-- A duration of 0 bans permanently. Protected players cannot be banned.
function COMMAND:OnRun(player, arguments)
  local schemaFolder = cw.core:GetSchemaFolder()
  local duration = tonumber(arguments[2])
  local reason = table.concat(arguments, ' ', 3)

  if !reason or reason == '' then
    reason = nil
  end

  if !cw.player:IsProtected(arguments[1]) then
    if duration then
      cw.bans:Add(arguments[1], duration * 60, reason, function(steamName, duration, reason)
        if IsValid(player) then
          if steamName then
            if duration > 0 then
              local hours = math.Round(duration / 3600)

              if hours >= 1 then
                cw.player:NotifyAll(L('Command_Plyban_Hours', player:Name(), steamName, hours)..' '..reason)
              else
                cw.player:NotifyAll(
                  L('Command_Plyban_Minutes', player:Name(), steamName, math.Round(duration / 60))..' '..reason
                )
              end
            else
              cw.player:NotifyAll(L('Command_Plyban_Permanent', player:Name(), steamName)..' '..reason)
            end
          else
            cw.player:Notify(player, L('Command_Plyban_InvalidIdentifier'))
          end
        end
      end)
    else
      cw.player:Notify(player, L('Command_Plyban_InvalidDuration'))
    end
  else
    local target = _player.Find(arguments[1])

    if target then
      cw.player:Notify(player, L('Command_PlayerProtected', target:Name()))
    else
      cw.player:Notify(player, L('Command_ThisPlayerProtected'))
    end
  end
end

COMMAND:Register()
