--- Registers `/SetFreq`, which tunes the `cw_radio` being looked at, or otherwise the character's own `frequency` data,
-- to a given radio frequency.
--
-- The frequency must have the form `1X1.X` to `1X9.X` with a non-zero decimal, such as `101.1`. Combine characters
-- cannot change it.

local COMMAND = cw.command:New('SetFreq')
COMMAND.tip = '#Command_Setfreq_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

--- Sets the radio frequency given as the first argument, in the `1X1.X` format.
--
-- Tunes the stationary radio being looked at, or else the player's handheld radio. Combine players cannot change it.
function COMMAND:OnRun(player, arguments)
  if player:IsCombine() then
    cw.player:Notify(player, L('Radio_CannotChangeFrequency'))

    return
  end

  local trace = player:GetEyeTraceNoCursor()
  local radio

  if IsValid(trace.Entity) and trace.Entity:GetClass() == 'cw_radio' then
    if trace.HitPos:Distance(player:GetShootPos()) <= 192 then
      radio = trace.Entity
    else
      cw.player:Notify(player, L('Radio_StationaryTooFar'))

      return
    end
  end

  local frequency = arguments[1]

  if string.find(frequency, '^%d%d%d%.%d$') then
    local start, finish, decimal = string.match(frequency, '(%d)%d(%d)%.(%d)')

    start = tonumber(start)
    finish = tonumber(finish)
    decimal = tonumber(decimal)

    if start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10 then
      if radio then
        trace.Entity:SetFrequency(frequency)

        cw.player:Notify(player, L('Radio_FrequencySetStationary', frequency))
      else
        player:SetCharacterData('frequency', frequency)

        cw.player:Notify(player, L('Radio_FrequencySet', frequency))
      end
    else
      cw.player:Notify(player, L('Radio_FrequencyRange'))
    end
  else
    cw.player:Notify(player, L('Radio_FrequencyFormat'))
  end
end

COMMAND:Register()
