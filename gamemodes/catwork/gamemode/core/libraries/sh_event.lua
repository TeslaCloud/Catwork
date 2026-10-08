--- Defines the `cw.event` library, a table of switches that turns named framework events on or off.
--
-- `cw.event:Hook` allows or disallows one event or a whole event class, and the framework asks `cw.event:CanRun`
-- before effects such as the screen blur and the damage view punch. Events that were never set are allowed.

library.New('event', cw)

local stored = cw.event.stored or {}
cw.event.stored = stored

--- Sets whether an event, or a whole class of events, is allowed to run.
--
-- With an `eventName`, only that event of the class is set, replacing a setting made for the
-- whole class. Without one, the whole class is set and its per-event settings are dropped.
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
    if !istable(stored[eventClass]) then
      stored[eventClass] = {}
    end

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
