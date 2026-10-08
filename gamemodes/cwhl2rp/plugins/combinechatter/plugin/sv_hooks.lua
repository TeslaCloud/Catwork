--- Server-side hooks of the Combine Chatter plugin that play a random Overwatch radio voice line from a Combine player
-- every 30 to 50 seconds.
--
-- `OneSecond` runs a single timer shared by all Combine players and picks one living Combine player at random per
-- interval, and `PLUGIN:EmitRandomChatter` picks the sound from the local `randomSounds` list.

local PLUGIN = PLUGIN

local randomSounds = {
  'npc/overwatch/radiovoice/accomplicesoperating.wav',
  'npc/overwatch/radiovoice/airwatchcopiesnoactivity.wav',
  'npc/overwatch/radiovoice/airwatchreportspossiblemiscount.wav',
  'npc/overwatch/radiovoice/allteamsrespondcode3.wav',
  'npc/overwatch/radiovoice/allunitsreturntocode12.wav',
  'npc/overwatch/radiovoice/antifatigueration3mg.wav',
  'npc/overwatch/radiovoice/beginscanning10-0.wav',
  'npc/overwatch/radiovoice/failuretotreatoutbreak.wav',
  'npc/overwatch/radiovoice/finalverdictadministered.wav',
  'npc/overwatch/radiovoice/investigateandreport.wav',
  'npc/overwatch/radiovoice/leadersreportratios.wav',
  'npc/overwatch/radiovoice/officerclosingonsuspect.wav',
  'npc/overwatch/radiovoice/politistabilizationmarginal.wav',
  'npc/overwatch/radiovoice/prepareforfinalsentencing.wav',
  'npc/overwatch/radiovoice/preparetoreceiveverdict.wav',
  'npc/overwatch/radiovoice/recalibratesocioscan.wav',
  'npc/overwatch/radiovoice/recievingconflictingdata.wav',
  'npc/overwatch/radiovoice/reinforcementteamscode3.wav',
  'npc/overwatch/radiovoice/reminder100credits.wav',
  'npc/overwatch/radiovoice/remindermemoryreplacement.wav',
  'npc/overwatch/radiovoice/rewardnotice.wav',
  'npc/overwatch/radiovoice/upi.wav', -- derp
  'npc/overwatch/radiovoice/youarejudgedguilty.wav'
}

--- Plays a random Overwatch radio line from the player.
-- @param player [Player The player the sound is emitted from]
function PLUGIN:EmitRandomChatter(player)
  player:EmitSound(randomSounds[math.random(1, #randomSounds)], 60)
end

--- Called every second; plays random radio chatter from a Combine player every 30 to 50 seconds.
--
-- A single timer is shared by all Combine players, and one living Combine player is picked at random
-- each time it runs out.
function PLUGIN:OneSecond()
  local curTime = CurTime()

  if !self.nextChatterEmit then
    self.nextChatterEmit = curTime + math.random(30, 50)
  end

  if curTime < self.nextChatterEmit then return end

  self.nextChatterEmit = nil

  local combine = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:Alive() and Schema:PlayerIsCombine(v) then
      combine[#combine + 1] = v
    end
  end

  if #combine > 0 then
    self:EmitRandomChatter(combine[math.random(#combine)])
  end
end
