--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('CfgSetVar')
COMMAND.tip = '#Command_Cfgsetvar_Description'
COMMAND.text = '#Command_Cfgsetvar_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local key = arguments[1]
  local value = arguments[2] or ''
  local configObject = config.Get(key)

  if configObject:IsValid() then
    local keyPrefix = ''
    local useMap = arguments[3]

    if useMap == '' then
      useMap = nil
    end

    if useMap then
      useMap = string.lower(cw.core:Replace(useMap, '.bsp', ''))
      keyPrefix = '('..useMap..') '

      if !file.Exists('maps/'..useMap..'.bsp', 'GAME') then
        cw.player:Notify(player, L(player, 'NotValidMap', useMap))
        return
      end
    end

    if !configObject('isStatic') then
      value = configObject:Set(value, useMap)

      if value != nil then
        local printValue = tostring(value)

        if configObject('isPrivate') then
          if configObject('needsRestart') then
            cw.player:NotifyAll(
              L('Config_ValueSetRestart', player:Name(), keyPrefix..key).." '"..string.rep('*', string.utf8len(printValue))..
                "'"
            )
          else
            cw.player:NotifyAll(
              L('Config_ValueSet', player:Name(), keyPrefix..key).." '"..string.rep('*', string.utf8len(printValue)).."'"
            )
          end
        elseif configObject('needsRestart') then
          cw.player:NotifyAll(L('Config_ValueSetRestart', player:Name(), keyPrefix..key).." '"..printValue.."'")
        else
          cw.player:NotifyAll(L('Config_ValueSet', player:Name(), keyPrefix..key).." '"..printValue.."'")
        end
      else
        cw.player:Notify(player, L(player, 'ConfigUnableToSet', key))
      end
    else
      cw.player:Notify(player, L(player, 'ConfigIsStaticKey', key))
    end
  else
    cw.player:Notify(player, L(player, 'ConfigKeyNotValid', key))
  end
end

COMMAND:Register()
