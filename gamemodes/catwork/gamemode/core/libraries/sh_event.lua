--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("event", cw)

local stored = cw.event.stored or {}
cw.event.stored = stored

-- A function to hook into an event.
function cw.event:Hook(eventClass, eventName, isAllowed)
	if (eventName) then
		stored[eventClass] = {}
		stored[eventClass][eventName] = isAllowed
	else
		stored[eventClass] = isAllowed
	end
end

-- A function to get whether an event can run.
function cw.event:CanRun(eventClass, eventName)
	local eventTable = stored[eventClass]

	if (type(eventTable) == "boolean") then
		return eventTable
	elseif (eventTable != nil and type(eventTable[eventName]) == "boolean") then
		return eventTable[eventName]
	end

	return true
end
