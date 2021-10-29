--[[
	© 2014 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local function adjustInCombineFavor(player, target, adjust1, adjust2)
	if (player:IsCombine() and !Schema:PlayerIsCombine(target)) then
		local strength = cw.attributes:Fraction(target, ATB_STRENGTH, 1, 1)

		if (strength) then
			adjust2 = adjust2 + 20 * strength
		end

		return adjust1, adjust2
	elseif (Schema:PlayerIsCombine(target) and !player:IsCombine()) then
		local strength = cw.attributes:Fraction(player, ATB_STRENGTH, 1, 1)

		if (strength) then
			adjust2 = adjust2 + 20 * strength
		end

		return adjust2, adjust1
	end
end

function PLUGIN:AdjustRollNumber(player, roll, max, target)
	if (IsValid(target)) then
		-- Battle against combine player.
		if ((player:IsCombine() and !Schema:PlayerIsCombine(target))
		or (Schema:PlayerIsCombine(target) and !player:IsCombine())) then
			if (roll <= 80) then
				local playerName

				if (player:IsCombine()) then
					playerName = player:Name()
				elseif (Schema:PlayerIsCombine(target)) then
					playerName = target:Name()
				end

				if (playerName:find(".CmD", 1, true)) then
					return adjustInCombineFavor(player, target, 20, -5)
				elseif (playerName:find(".SeC", 1, true)) then
					return adjustInCombineFavor(player, target, 20, -5)
				elseif (playerName:find(".DvL", 1, true)) then
					return adjustInCombineFavor(player, target, 20, -5)
				elseif (playerName:find(".OWS", 1, true)) then
					return adjustInCombineFavor(player, target, 20, -5)
				elseif (playerName:find(".OWC", 1, true)) then
					return adjustInCombineFavor(player, target, 25, -5)
				elseif (playerName:find(".EOW", 1, true)) then
					return adjustInCombineFavor(player, target, 40, -5)
				elseif (playerName:find(".InS", 1, true) or playerName:find(".INS", 1, true)) then
					return adjustInCombineFavor(player, target, 15, -5)
				elseif (playerName:find(".OfC", 1, true) or playerName:find(".OFC", 1, true)) then
					return adjustInCombineFavor(player, target, 15, -5)
				elseif (playerName:find(".GHOST", 1, true)) then
					return adjustInCombineFavor(player, target, 25, -5)
				elseif (playerName:find(".S-GU", 1, true)) then
					return adjustInCombineFavor(player, target, 10, -5)
				elseif (playerName:find(".GU", 1, true)) then
					return adjustInCombineFavor(player, target, 7, -2)
				elseif (playerName:find(".RCT", 1, true)) then
					return adjustInCombineFavor(player, target, 4, -2)
				end


				local rankPos, endRankPos = playerName:find(".0")

				if (rankPos) then
					local num = tonumber(playerName:utf8sub(endRankPos, endRankPos + 1))

					if (num) then
						return adjustInCombineFavor(player, target, math.abs(12 - (num * 2)), -5)
					end
				end
			end
		elseif (!player:IsCombine() and !Schema:PlayerIsCombine(target)) then
			local strength = cw.attributes:Fraction(player, ATB_STRENGTH, 1, 1)
			local strength2 = cw.attributes:Fraction(target, ATB_STRENGTH, 1, 1)

			if (strength and strength2) then
				local adjust = 20 * strength
				local adjust2 = 20 * strength2

				return adjust, adjust2
			end
		end
	end
end