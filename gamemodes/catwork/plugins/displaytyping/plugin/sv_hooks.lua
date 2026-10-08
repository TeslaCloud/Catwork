--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called when a player starts typing; plays their rank's or faction's `startChatNoise`.
--
-- Only plays for talking, yelling, whispering and radio codes, once per message, and not while
-- noclipping.
--
-- @param player [Player The player who started typing]
-- @param code [String Typing mode code sent by the client: `n`, `y`, `w`, `r`, `p` or `o`]
function PLUGIN:PlayerStartTypingDisplay(player, code)
  if !player:IsNoClipping() then
    if code == 'n' or code == 'y' or code == 'w' or code == 'r' then
      if !player.typingBeep then
        local rankName, rank = player:GetFactionRank()
        local faction = faction.FindByID(player:GetFaction())

        player.typingBeep = true

        if rank and rank.startChatNoise then
          player:EmitSound(rank.startChatNoise)
        elseif faction and faction.startChatNoise then
          player:EmitSound(faction.startChatNoise)
        end
      end
    end
  end
end

--- Called when a player stops typing; plays their rank's or faction's `endChatNoise` if a message was sent.
--
-- @param player [Player The player who stopped typing]
-- @param textTyped=nil [Boolean True when the player sent the message instead of cancelling it]
function PLUGIN:PlayerFinishTypingDisplay(player, textTyped)
  if textTyped then
    if player.typingBeep then
      local rankName, rank = player:GetFactionRank()
      local faction = faction.FindByID(player:GetFaction())

      if rank and rank.endChatNoise then
        player:EmitSound(rank.endChatNoise)
      elseif faction and faction.endChatNoise then
        player:EmitSound(faction.endChatNoise)
      end
    end
  end

  player.typingBeep = nil
end
