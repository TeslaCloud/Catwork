--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when a player's typing display has started.
function PLUGIN:PlayerStartTypingDisplay(player, code)
	if (!player:IsNoClipping()) then
		if (code == "n" or code == "y" or code == "w" or code == "r") then
			if (!player.typingBeep) then
				local rankName, rank = player:GetFactionRank()
				local faction = faction.FindByID(player:GetFaction())

				player.typingBeep = true

				if (rank and rank.startChatNoise) then
					player:EmitSound(rank.startChatNoise)
				elseif (faction and faction.startChatNoise) then
					player:EmitSound(faction.startChatNoise)
				end
			end
		end
	end
end

-- Called when a player's typing display has finished.
function PLUGIN:PlayerFinishTypingDisplay(player, textTyped)
	if (textTyped) then
		if (player.typingBeep) then
			local rankName, rank = player:GetFactionRank()
			local faction = faction.FindByID(player:GetFaction())

			if (rank and rank.endChatNoise) then
				player:EmitSound(rank.endChatNoise)
			elseif (faction and faction.endChatNoise) then
				player:EmitSound(faction.endChatNoise)
			end
		end
	end

	player.typingBeep = nil
end
