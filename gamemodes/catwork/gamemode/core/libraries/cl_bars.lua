--- Defines the client-side `cw.bars` library, the list of bars drawn at the top of the HUD.
--
-- The list is cleared and rebuilt every frame, so bars are added with `cw.bars:Add` from the `GetBars` hook.

library.New('bars', cw)

cw.bars.x = 0
cw.bars.y = 0
cw.bars.width = 0
cw.bars.height = 16
cw.bars.padding = 18
cw.bars.stored = cw.bars.stored or {}

--- Returns the top bar registered under a unique ID.
-- @param uniqueID [String Unique ID the bar was added with]
-- @return [Map The bar's data table, or `nil` if no bar has that ID]
-- @see cw.bars:Add
function cw.bars:FindByID(uniqueID)
  for k, v in ipairs(self.stored) do
    if v.uniqueID == uniqueID then
      return v
    end
  end
end

--- Adds a bar to the list drawn at the top of the HUD.
--
-- The list is cleared and rebuilt every frame, so call this from the `GetBars`
-- hook rather than once. Bars with a higher priority are drawn first.
--
-- ```
-- function PLUGIN:GetBars(bars)
--   bars:Add('#Bars_Hunger', Color(100, 175, 175), '', hunger, 100, hunger < 10)
-- end
-- ```
--
-- @param uniqueID [String Unique ID of the bar, usually a language phrase such as `'#Bars_Health'`]
-- @param color [Color Fill color of the bar]
-- @param text [String Text drawn in the middle of the bar; `''` draws none]
-- @param value [Number Current value of the bar]
-- @param maximum [Number Value at which the bar is full]
-- @param flash=nil [Boolean Whether the bar pulses to draw attention]
-- @param priority=0 [Number Sort priority; higher values are drawn first]
-- @param maxValue=nil [Number Current upper limit; when it is more than 5 below `maximum`, the rest of
-- the bar is drawn as a limit marker]
-- @param limitText=nil [String Text, or a language phrase, drawn on the limit marker]
-- @see cw.bars:Destroy
function cw.bars:Add(uniqueID, color, text, value, maximum, flash, priority, maxValue, limitText)
  table.insert(self.stored, {
    uniqueID = uniqueID,
    priority = priority or 0,
    maximum = maximum,
    color = color,
    class = class,
    value = value,
    maxValue = maxValue,
    limitText = limitText,
    flash = flash,
    text = text
  })
end

--- Removes every top bar with a unique ID from the list.
-- @param uniqueID [String Unique ID the bar was added with]
-- @see cw.bars:Add
function cw.bars:Destroy(uniqueID)
  for k, v in ipairs(self.stored) do
    if v.uniqueID == uniqueID then
      table.remove(self.stored, k)
    end
  end
end
