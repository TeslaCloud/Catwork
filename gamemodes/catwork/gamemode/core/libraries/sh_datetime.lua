--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("time", cw)
library.New("date", cw)

-- A function to get the time minute.
function cw.time:GetMinute()
	if (CLIENT) then
		return netvars.GetNetVar("minute", 0)
	else
		return self.minute or 0
	end
end

-- A function to get the time hour.
function cw.time:GetHour()
	if (CLIENT) then
		return netvars.GetNetVar("hour", 0)
	else
		return self.hour or 0
	end
end

-- A function to get the time day.
function cw.time:GetDay()
	if (CLIENT) then
		return netvars.GetNetVar("day", 1)
	else
		return self.day or 1
	end
end

-- A function to get the day name.
function cw.time:GetDayName()
	local defaultDays = cw.option:GetKey("default_days")

	if (defaultDays) then
		return defaultDays[self:GetDay()] or "Unknown"
	end
end

if (SERVER) then
	function cw.time:GetSaveData()
		return {
			minute = self:GetMinute(),
			hour = self:GetHour(),
			day = self:GetDay()
		}
	end

	-- A function to get the date save data.
	function cw.date:GetSaveData()
		return {
			month = self:GetMonth(),
			year = self:GetYear(),
			day = self:GetDay()
		}
	end

	-- A function to get the date year.
	function cw.date:GetYear()
		return self.year
	end

	-- A function to get the date month.
	function cw.date:GetMonth()
		return self.month
	end

	-- A function to get the date day.
	function cw.date:GetDay()
		return self.day
	end
else
	function cw.date:GetString()
		return netvars.GetNetVar("date")
	end

	-- A function to get the time as a string.
	function cw.time:GetString()
		local minute = cw.core:ZeroNumberToDigits(self:GetMinute(), 2)
		local hour = cw.core:ZeroNumberToDigits(self:GetHour(), 2)

		if (CW_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
			hour = tonumber(hour)

			if (hour >= 12) then
				if (hour > 12) then
					hour = hour - 12
				end

				return cw.core:ZeroNumberToDigits(hour, 2)..":"..minute.."pm"
			else
				return cw.core:ZeroNumberToDigits(hour, 2)..":"..minute.."am"
			end
		else
			return hour..":"..minute
		end
	end
end
