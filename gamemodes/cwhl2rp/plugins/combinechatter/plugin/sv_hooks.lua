local PLUGIN = PLUGIN

local randomSounds = {
		"npc/overwatch/radiovoice/accomplicesoperating.wav",
		"npc/overwatch/radiovoice/airwatchcopiesnoactivity.wav",
		"npc/overwatch/radiovoice/airwatchreportspossiblemiscount.wav",
		"npc/overwatch/radiovoice/allteamsrespondcode3.wav",
		"npc/overwatch/radiovoice/allunitsreturntocode12.wav",
		"npc/overwatch/radiovoice/antifatigueration3mg.wav",
		"npc/overwatch/radiovoice/beginscanning10-0.wav",
		"npc/overwatch/radiovoice/failuretotreatoutbreak.wav",
		"npc/overwatch/radiovoice/finalverdictadministered.wav",
		"npc/overwatch/radiovoice/investigateandreport.wav",
		"npc/overwatch/radiovoice/leadersreportratios.wav",
		"npc/overwatch/radiovoice/officerclosingonsuspect.wav",
		"npc/overwatch/radiovoice/politistabilizationmarginal.wav",
		"npc/overwatch/radiovoice/prepareforfinalsentencing.wav",
		"npc/overwatch/radiovoice/preparetoreceiveverdict.wav",
		"npc/overwatch/radiovoice/recalibratesocioscan.wav",
		"npc/overwatch/radiovoice/recievingconflictingdata.wav",
		"npc/overwatch/radiovoice/reinforcementteamscode3.wav",
		"npc/overwatch/radiovoice/reminder100credits.wav",
		"npc/overwatch/radiovoice/remindermemoryreplacement.wav",
		"npc/overwatch/radiovoice/rewardnotice.wav",
		"npc/overwatch/radiovoice/upi.wav", --derp
		"npc/overwatch/radiovoice/youarejudgedguilty.wav"
}

-- A function to load the item spawns.
function PLUGIN:EmitRandomChatter(player)
	player:EmitSound(randomSounds[math.random(1, #randomSounds)], 60)
end

-- Called each second.
function PLUGIN:OneSecond()
	for k, v in ipairs(_player.GetAll()) do
		if (Schema:PlayerIsCombine(v)) then
			local curTime = CurTime()

			if (!self.nextChatterEmit) then
				self.nextChatterEmit = curTime + math.random(30, 50)
			end

			if ((curTime >= self.nextChatterEmit)) then
				self.nextChatterEmit = nil

				PLUGIN:EmitRandomChatter(v)
			end
		end
	end
end