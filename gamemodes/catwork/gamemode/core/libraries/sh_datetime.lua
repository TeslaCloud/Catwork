--- Defines the `cw.time` and `cw.date` libraries, accessors for the in-game clock and calendar.
--
-- The server holds the values and exports them for saving with `GetSaveData`. The client reads the networked minute,
-- hour, day and date and formats the time with a 12 or 24 hour clock.

library.New('time', cw)
library.New('date', cw)

--- Returns the in-game minute.
--
-- On the client this reads the `minute` global net variable.
--
-- @return [Number The minute, 0 when unknown]
function cw.time:GetMinute()
  if CLIENT then
    return netvars.GetNetVar('minute', 0)
  else
    return self.minute or 0
  end
end

--- Returns the in-game hour, from 0 to 23.
--
-- On the client this reads the `hour` global net variable.
--
-- @return [Number The hour, 0 when unknown]
function cw.time:GetHour()
  if CLIENT then
    return netvars.GetNetVar('hour', 0)
  else
    return self.hour or 0
  end
end

--- Returns the in-game day of the week.
--
-- On the client this reads the `day` global net variable.
--
-- @return [Number The day index, 1 when unknown]
function cw.time:GetDay()
  if CLIENT then
    return netvars.GetNetVar('day', 1)
  else
    return self.day or 1
  end
end

--- Returns the name of the in-game day of the week.
--
-- Names come from the `default_days` option.
--
-- @return [String The day name (often a language phrase), `#UnknownDay` for an unnamed day, or `nil`
-- if the option is not set]
function cw.time:GetDayName()
  local defaultDays = cw.option:GetKey('default_days')

  if defaultDays then
    return defaultDays[self:GetDay()] or '#UnknownDay'
  end
end

if SERVER then
  --- Returns the in-game time as a table for saving.
  --
  -- @return [Map Table with `minute`, `hour` and `day` keys]
  function cw.time:GetSaveData()
    return {
      minute = self:GetMinute(),
      hour = self:GetHour(),
      day = self:GetDay()
    }
  end

  --- Returns the in-game date as a table for saving.
  --
  -- @return [Map Table with `month`, `year` and `day` keys]
  function cw.date:GetSaveData()
    return {
      month = self:GetMonth(),
      year = self:GetYear(),
      day = self:GetDay()
    }
  end

  --- Returns the in-game year.
  --
  -- @return [Number The year]
  function cw.date:GetYear()
    return self.year
  end

  --- Returns the in-game month.
  --
  -- @return [Number The month]
  function cw.date:GetMonth()
    return self.month
  end

  --- Returns the in-game day of the month.
  --
  -- @return [Number The day]
  function cw.date:GetDay()
    return self.day
  end
else
  --- Returns the in-game date as networked by the server.
  --
  -- @return [String The formatted date, or `nil` before it has been received]
  function cw.date:GetString()
    return netvars.GetNetVar('date')
  end

  --- Returns the in-game time formatted for display.
  --
  -- Uses a 12-hour clock with an `am`/`pm` suffix when the player's twelve-hour clock setting is
  -- on, otherwise `HH:MM`.
  --
  -- @return [String The formatted time]
  function cw.time:GetString()
    local minute = cw.core:ZeroNumberToDigits(self:GetMinute(), 2)
    local hour = cw.core:ZeroNumberToDigits(self:GetHour(), 2)

    if CW_CONVAR_TWELVEHOURCLOCK:GetInt() == 1 then
      hour = tonumber(hour)

      if hour >= 12 then
        if hour > 12 then
          hour = hour - 12
        end

        return cw.core:ZeroNumberToDigits(hour, 2)..':'..minute..'pm'
      else
        return cw.core:ZeroNumberToDigits(hour, 2)..':'..minute..'am'
      end
    else
      return hour..':'..minute
    end
  end
end
