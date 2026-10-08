--- Server-side part of the Roll Gains plugin, whose `AdjustRollNumber` hook adds bonuses to both sides of a roll made
-- against another player.
--
-- Between two non-Combine players each side gets up to 20 points from their strength. When one side is Combine and the
-- roll is 80 or less, that side gets a bonus based on the rank in its name and the other side a small penalty offset
-- by their strength.

local function AdjustInCombineFavor(player, target, adjust1, adjust2)
  if player:IsCombine() and !Schema:PlayerIsCombine(target) then
    local strength = cw.attributes:Fraction(target, ATB_STRENGTH, 1, 1)

    if strength then
      adjust2 = adjust2 + 20 * strength
    end

    return adjust1, adjust2
  elseif Schema:PlayerIsCombine(target) and !player:IsCombine() then
    local strength = cw.attributes:Fraction(player, ATB_STRENGTH, 1, 1)

    if strength then
      adjust2 = adjust2 + 20 * strength
    end

    return adjust2, adjust1
  end
end

--- Called when a player rolls against another player; adds bonuses to both rolls.
--
-- Between two non-Combine players, each gets up to 20 points from their strength. When one side
-- is Combine and the caller's roll is 80 or less, the Combine side gets a bonus based on the rank
-- in its name (from 4 for `RCT` to 40 for `EOW`, or from the unit number), and the other side
-- takes a penalty of 2 or 5 offset by up to 20 points from their strength.
-- @param player [Player The player who rolled]
-- @param roll [Number The caller's unadjusted roll]
-- @param max [Number The highest possible roll]
-- @param target [Player The player being rolled against, or `nil` for a plain roll]
-- @return [Number Adjustment for the caller's roll, Number Adjustment for the target's roll]
function PLUGIN:AdjustRollNumber(player, roll, max, target)
  if IsValid(target) then
    -- Battle against combine player.
    if (player:IsCombine() and !Schema:PlayerIsCombine(target))
    or (Schema:PlayerIsCombine(target) and !player:IsCombine()) then
      if roll <= 80 then
        local playerName

        if player:IsCombine() then
          playerName = player:Name()
        elseif Schema:PlayerIsCombine(target) then
          playerName = target:Name()
        end

        if playerName:find('.CmD', 1, true) then
          return AdjustInCombineFavor(player, target, 20, -5)
        elseif playerName:find('.SeC', 1, true) then
          return AdjustInCombineFavor(player, target, 20, -5)
        elseif playerName:find('.DvL', 1, true) then
          return AdjustInCombineFavor(player, target, 20, -5)
        elseif playerName:find('.OWS', 1, true) then
          return AdjustInCombineFavor(player, target, 20, -5)
        elseif playerName:find('.OWC', 1, true) then
          return AdjustInCombineFavor(player, target, 25, -5)
        elseif playerName:find('.EOW', 1, true) then
          return AdjustInCombineFavor(player, target, 40, -5)
        elseif playerName:find('.InS', 1, true) or playerName:find('.INS', 1, true) then
          return AdjustInCombineFavor(player, target, 15, -5)
        elseif playerName:find('.OfC', 1, true) or playerName:find('.OFC', 1, true) then
          return AdjustInCombineFavor(player, target, 15, -5)
        elseif playerName:find('.GHOST', 1, true) then
          return AdjustInCombineFavor(player, target, 25, -5)
        elseif playerName:find('.S-GU', 1, true) then
          return AdjustInCombineFavor(player, target, 10, -5)
        elseif playerName:find('.GU', 1, true) then
          return AdjustInCombineFavor(player, target, 7, -2)
        elseif playerName:find('.RCT', 1, true) then
          return AdjustInCombineFavor(player, target, 4, -2)
        end

        local rankPos, endRankPos = playerName:find('.0')

        if rankPos then
          local num = tonumber(playerName:utf8sub(endRankPos, endRankPos + 1))

          if num then
            return AdjustInCombineFavor(player, target, math.abs(12 - (num * 2)), -5)
          end
        end
      end
    elseif !player:IsCombine() and !Schema:PlayerIsCombine(target) then
      local strength = cw.attributes:Fraction(player, ATB_STRENGTH, 1, 1)
      local strength2 = cw.attributes:Fraction(target, ATB_STRENGTH, 1, 1)

      if strength and strength2 then
        local adjust = 20 * strength
        local adjust2 = 20 * strength2

        return adjust, adjust2
      end
    end
  end
end
