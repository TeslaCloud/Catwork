--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('event', cw)

local stored = cw.event.stored or {}
cw.event.stored = stored

--- Sets whether an event, or a whole class of events, is allowed to run.
--
-- With an `eventName`, the class's entry is replaced by a table holding only that event, so
-- earlier per-event settings for the same class are lost. Without one, the whole class is set.
--
-- ```
-- cw.event:Hook('limb_damage', 'stumble', false)
-- cw.event:Hook('blur', nil, false)
-- ```
--
-- @param eventClass [String Event class]
-- @param eventName [String Event name within the class, or `nil` to set the whole class]
-- @param isAllowed [Boolean Whether the event may run]
-- @see cw.event:CanRun
function cw.event:Hook(eventClass, eventName, isAllowed)
  if eventName then
    stored[eventClass] = {}
    stored[eventClass][eventName] = isAllowed
  else
    stored[eventClass] = isAllowed
  end
end

--- Returns whether an event is allowed to run.
--
-- A Boolean set for the whole class takes precedence over per-event settings. Events that were
-- never hooked are allowed.
--
-- @param eventClass [String Event class]
-- @param eventName [String Event name within the class]
-- @return [Boolean Whether the event may run]
-- @see cw.event:Hook
function cw.event:CanRun(eventClass, eventName)
  local eventTable = stored[eventClass]

  if type(eventTable) == 'boolean' then
    return eventTable
  elseif eventTable != nil and type(eventTable[eventName]) == 'boolean' then
    return eventTable[eventName]
  end

  return true
end
