--- Server-side hooks of the Display Typing plugin that play a rank's or faction's chat noises when a player starts and
-- finishes typing.
--
-- `PlayerStartTypingDisplay` plays `startChatNoise` and `PlayerFinishTypingDisplay` plays `endChatNoise` when the
-- message was sent.

-- Plays the chat noise stored under `key` in the player's rank or faction, at most once a second for each key, as the
-- typing console commands can be run as fast as a client likes.
local function PlayChatNoise(player, key)
  local curTime = CurTime()

  player.cwNextChatNoise = player.cwNextChatNoise or {}

  if (player.cwNextChatNoise[key] or 0) > curTime then return end

  local rankName, rank = player:GetFactionRank()
  local factionTable = faction.FindByID(player:GetFaction())
  local noise = (rank and rank[key]) or (factionTable and factionTable[key])

  if noise then
    player.cwNextChatNoise[key] = curTime + 1
    player:EmitSound(noise)
  end
end

--- Called when a player starts typing; plays their rank's or faction's `startChatNoise`.
--
-- Only plays for talking, yelling, whispering and radio codes, once per message and at most once a
-- second, and not while noclipping.
--
-- @param player [Player The player who started typing]
-- @param code [String Typing mode code sent by the client: `n`, `y`, `w`, `r`, `p` or `o`]
function PLUGIN:PlayerStartTypingDisplay(player, code)
  if !player:IsNoClipping() then
    if code == 'n' or code == 'y' or code == 'w' or code == 'r' then
      if !player.typingBeep then
        player.typingBeep = true

        PlayChatNoise(player, 'startChatNoise')
      end
    end
  end
end

--- Called when a player stops typing; plays their rank's or faction's `endChatNoise` if a message was sent.
--
-- The noise plays at most once a second.
--
-- @param player [Player The player who stopped typing]
-- @param textTyped=nil [Boolean True when the player sent the message instead of cancelling it]
function PLUGIN:PlayerFinishTypingDisplay(player, textTyped)
  if textTyped and player.typingBeep then
    PlayChatNoise(player, 'endChatNoise')
  end

  player.typingBeep = nil
end
