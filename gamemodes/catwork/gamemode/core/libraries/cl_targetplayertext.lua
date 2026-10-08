--- Defines the client-side `cw.TargetPlayerText` library, the lines of text drawn under the name of the player the
-- local player is looking at.
--
-- The list is cleared every frame, so lines are added with `cw.TargetPlayerText:Add` from the `GetTargetPlayerText`
-- hook.

library.New('TargetPlayerText', cw)

cw.TargetPlayerText.stored = cw.TargetPlayerText.stored or {}

--- Adds a line of text under the name of the player the local player is looking at.
--
-- The list is cleared every frame, so call this from the `GetTargetPlayerText`
-- hook, which receives the target player.
--
-- ```
-- function PLUGIN:GetTargetPlayerText(player, targetPlayerText)
--   if player:GetNetVar('Tied') then
--     targetPlayerText:Add('TIED', 'They have been tied up.', Color(255, 100, 100))
--   end
-- end
-- ```
--
-- @param uniqueID [String Unique ID of the line]
-- @param text [String Text of the line]
-- @param color=nil [Color Color of the text; white when `nil`]
-- @param scale=nil [Number Scale of the text; drawn at normal size when `nil`]
function cw.TargetPlayerText:Add(uniqueID, text, color, scale)
  self.stored[#self.stored + 1] = {
    uniqueID = uniqueID,
    color = color,
    scale = scale,
    text = text
  }
end

--- Returns a line of target player text.
-- @param uniqueID [String Unique ID of the line]
-- @return [Map The line (`uniqueID`, `text`, `color`, `scale`), or `nil` if there is none]
function cw.TargetPlayerText:Get(uniqueID)
  for k, v in pairs(self.stored) do
    if v.uniqueID == uniqueID then
      return v
    end
  end
end

--- Removes a line of target player text.
--
-- Call this from the `DestroyTargetPlayerText` hook.
-- @param uniqueID [String Unique ID of the line]
function cw.TargetPlayerText:Destroy(uniqueID)
  -- Backwards, so that removing an entry does not skip the one after it.
  for k = #self.stored, 1, -1 do
    if self.stored[k].uniqueID == uniqueID then
      table.remove(self.stored, k)
    end
  end
end
