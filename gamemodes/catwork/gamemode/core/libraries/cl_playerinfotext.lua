--- Defines the client-side `cw.PlayerInfoText` library, the lines of text shown in the local player's information box.
--
-- The text is cleared every frame, so lines and sub text are added with `cw.PlayerInfoText:Add` and
-- `cw.PlayerInfoText:AddSub` from the `GetPlayerInfoText` hook.

library.New('PlayerInfoText', cw)
cw.PlayerInfoText.text = cw.PlayerInfoText.text or {}
cw.PlayerInfoText.width = cw.PlayerInfoText.width or {}
cw.PlayerInfoText.subText = cw.PlayerInfoText.subText or {}

--- Returns whether there is any text for the local player's information box.
-- @return [Boolean Whether any text or sub text has been added this frame]
function cw.PlayerInfoText:DoesAnyExist()
  return (#self.text > 0 or #self.subText > 0)
end

--- Adds a line of text to the local player's information box.
--
-- The text is cleared and rebuilt every frame, so call this from the
-- `GetPlayerInfoText` hook. Does nothing when `text` is `nil`.
--
-- ```
-- function PLUGIN:GetPlayerInfoText(playerInfoText)
--   playerInfoText:Add('CASH', 'Cash: '..cw.player:GetCash())
-- end
-- ```
--
-- @param uniqueID [String Unique ID of the line]
-- @param text [String Text of the line]
-- @see cw.PlayerInfoText:AddSub
function cw.PlayerInfoText:Add(uniqueID, text)
  if text then
    self.text[#self.text + 1] = {
      uniqueID = uniqueID,
      text = text
    }
  end
end

--- Returns a line of the local player's information box.
-- @param uniqueID [String Unique ID of the line]
-- @return [Map The line (`uniqueID`, `text`), or `nil` if there is none]
function cw.PlayerInfoText:Get(uniqueID)
  for k, v in pairs(self.text) do
    if v.uniqueID == uniqueID then
      return v
    end
  end
end

--- Adds a line of sub text, shown under the player's name, to the information box.
--
-- Call this from the `GetPlayerInfoText` hook. Lines with a higher priority are
-- drawn first. Does nothing when `text` is `nil`.
-- @param uniqueID [String Unique ID of the line]
-- @param text [String Text of the line]
-- @param priority=0 [Number Sort priority]
function cw.PlayerInfoText:AddSub(uniqueID, text, priority)
  if text then
    self.subText[#self.subText + 1] = {
      priority = priority or 0,
      uniqueID = uniqueID,
      text = text
    }
  end
end

--- Returns a line of sub text of the information box.
-- @param uniqueID [String Unique ID of the line]
-- @return [Map The line (`uniqueID`, `text`, `priority`), or `nil` if there is none]
function cw.PlayerInfoText:GetSub(uniqueID)
  for k, v in pairs(self.subText) do
    if v.uniqueID == uniqueID then
      return v
    end
  end
end

--- Removes a line from the information box.
--
-- Call this from the `DestroyPlayerInfoText` hook.
-- @param uniqueID [String Unique ID of the line]
function cw.PlayerInfoText:Destroy(uniqueID)
  for k, v in pairs(self.text) do
    if v.uniqueID == uniqueID then
      table.remove(self.text, k)
    end
  end
end

--- Removes a line of sub text from the information box.
--
-- Call this from the `DestroyPlayerInfoText` hook.
-- @param uniqueID [String Unique ID of the line]
function cw.PlayerInfoText:DestroySub(uniqueID)
  for k, v in pairs(self.subText) do
    if v.uniqueID == uniqueID then
      table.remove(self.subText, k)
    end
  end
end
