--- Server-side hooks of the Diseases plugin, which keep a character's disease in the `diseases` character data, network
-- it, and run the symptoms, random infections and medicine rewards.
--
-- `OnePlayerSecond` plays the coughs and other symptoms, lets healthy characters catch a cough, fever, colour
-- blindness or diarrhea at random and drains the health of characters given a lethal injection until they are
-- perma-killed. `PlayerUseItem` can give an allergy, gastritis or insomnia from food and drink, and `PlayerHealed`
-- rewards the patient with an agility boost and the healer with medical attribute progress. `cwDiseases:FindPatient`
-- and `cwDiseases:SetDiseaseDelayed` are the helpers the medicine items share.

--- Finds the player an item is applied to: the living character its user looks at from up close.
--
-- Tells the user why when there is none. Custom item functions do not ask the `PlayerCanUseItem`
-- hook themselves, so pass them the item and the hook has to allow its use first.
--
-- ```
-- local patient = cwDiseases:FindPatient(player, self)
--
-- if !patient then return false end
-- ```
--
-- @param player [Player The player applying the item]
-- @param itemTable=nil [Item The item, when it is applied through one of its custom functions]
-- @param phrase='Diseases_MustLookAtPerson' [String Phrase the player is told when they look at nobody]
-- @return [Player The patient, or `nil` when there is none]
function cwDiseases:FindPatient(player, itemTable, phrase)
  if itemTable and hook.Run('PlayerCanUseItem', player, itemTable) == false then return end

  local entity = player:GetEyeTraceNoCursor().Entity
  local target = IsValid(entity) and cw.entity:GetPlayer(entity)

  if target and target:HasInitialized() and target:Alive()
  and entity:GetPos():Distance(player:GetShootPos()) <= 192 then
    return target
  end

  cw.player:Notify(player, L(phrase or 'Diseases_MustLookAtPerson'))
end

--- Changes a character's disease after a delay, provided it is still the expected one by then.
--
-- Does nothing when the player has left or switched character in the meantime.
--
-- @param player [Player The player whose character is affected]
-- @param delay [Number Seconds to wait]
-- @param expected [String The disease the character must still have]
-- @param disease [String The disease to set, `'none'` to cure]
function cwDiseases:SetDiseaseDelayed(player, delay, expected, disease)
  local key = player:GetCharacterKey()

  timer.Simple(delay, function()
    if IsValid(player) and player:HasInitialized() and player:GetCharacterKey() == key
    and player:GetCharacterData('diseases') == expected then
      player:SetCharacterData('diseases', disease)
    end
  end)
end

--- Called when a character data value changes; networks the `diseases` value to clients.
-- @param player [Player The player whose character data changed]
-- @param key [String Name of the changed value]
-- @param oldValue [Any The previous value]
-- @param value [Any The new value]
function PLUGIN:PlayerCharacterDataChanged(player, key, oldValue, value)
  if key == 'diseases' then
    player:SetNetVar('diseases', value)
  end
end

--- Called when a player's character data is restored; defaults a missing or unknown disease to `'none'`.
-- @param player [Player The player whose character is loaded]
-- @param data [Map The character data being restored]
function PLUGIN:PlayerRestoreCharacterData(player, data)
  if !cwDiseases.stored[data['diseases']] then
    data['diseases'] = 'none'
  end
end

local coughSounds = {
  'ambient/voices/cough1.wav',
  'ambient/voices/cough2.wav',
  'ambient/voices/cough3.wav',
  'ambient/voices/cough4.wav'
}

--- Sends a symptom emote of a player to the chat of those around them.
-- @param player [Player The player showing the symptom]
-- @param phrase [String Phrase of the emote, without the leading `#`]
local function Emote(player, phrase)
  chatbox.AddText(nil, L(phrase), {
    isPlayerMessage = true,
    sender = player,
    noStyling = true,
    fakeName = true,
    position = player:GetPos(),
    textColor = Color('#89D235'),
    filter = 'player_events',
    icon = false
  })
end

--- Called every second for each player; runs the disease symptoms and random infections.
--
-- Coughs (which can turn into pneumonia), fever and gastritis play emotes and sounds at random
-- intervals while the player is not noclipping. Healthy players have a chance every five to ten
-- minutes to catch a cough, a fever, colour blindness or, at a `Hunger` of 65 or more,
-- diarrhea. The death injections drain a point of health every few seconds
-- (`fast_deathinjection` every half second) and perma-kill the character once health drops
-- below 5. The `diseases` net var is kept in step with the character, which also covers a
-- character that has just been loaded.
--
-- @param player [Player The player being updated]
-- @param curTime [Number The current time]
-- @param infoTable [Map Per-second player info; unused]
function PLUGIN:OnePlayerSecond(player, curTime, infoTable)
  local disease = player:GetCharacterData('diseases')

  player:SetNetVar('diseases', disease)

  if !player:Alive() then return end

  if disease == 'cough' or disease == 'pneumonia' then
    if disease == 'cough' and math.random(1, 50) == 1 then
      disease = 'pneumonia'
      player:SetCharacterData('diseases', disease)
    end

    if (!player.nextCough or curTime > player.nextCough) and !player:IsNoClipping() then
      player:EmitSound(table.Random(coughSounds), 100, 100)

      if disease == 'cough' then
        Emote(player, 'Diseases_Emote_Cough')
      elseif math.random(1, 2) == 1 then
        Emote(player, 'Diseases_Emote_PneumoniaCough')
      else
        Emote(player, 'Diseases_Emote_Gasp')
      end

      player.nextCough = curTime + math.random(15, 45)
    end
  elseif disease == 'fever' then
    if (!player.nextFever or curTime > player.nextFever) and !player:IsNoClipping() then
      Emote(player, 'Diseases_Emote_Fever')

      player.nextFever = curTime + math.random(120, 300)
    end
  elseif disease == 'gastrits' then
    if (!player.nextStomach or curTime > player.nextStomach) and !player:IsNoClipping() then
      player:EmitSound(table.Random(coughSounds), 100, 100)
      Emote(player, 'Diseases_Emote_Stomach')

      player.nextStomach = curTime + math.random(60, 90)
    end
  elseif disease == 'none' then
    if !player.nextTrigger or curTime > player.nextTrigger then
      if math.random(1, 200) == 1 then
        player:SetCharacterData('diseases', 'cough')
      end

      if math.random(1, 600) == 1 then
        player:SetCharacterData('diseases', 'fever')
      end

      if math.random(1, 200) == 1 and (tonumber(player:GetCharacterData('Hunger')) or 0) >= 65 then
        player:SetCharacterData('diseases', 'diarrhea')
      end

      if math.random(1, 1000) == 1 then
        player:SetCharacterData('diseases', 'colorblindness')
      end

      player.nextTrigger = curTime + math.random(300, 600)
    end
  elseif disease == 'slow_deathinjection' or disease == 'fast_deathinjection' then
    if (!player.nextInject or curTime > player.nextInject) and !player:IsNoClipping() then
      if player:GetGender() == GENDER_FEMALE then
        player:EmitSound('vo/npc/female01/pain0'..math.random(1, 9)..'.wav', 30, 100)
      else
        player:EmitSound('vo/npc/male01/pain0'..math.random(1, 9)..'.wav', 30, 100)
      end

      if player:Health() >= 5 then
        player:SetHealth(player:Health() - 1)
      else
        Schema:PermaKillPlayer(player, player:GetRagdollEntity())
        cw.player:Notify(player, L('Diseases_PermaKilled'))
      end

      if disease == 'fast_deathinjection' then
        player.nextInject = curTime + 0.5
      else
        player.nextInject = curTime + math.random(4, 6)
      end
    end
  end
end

-- Agility boost of the patient and medical progress of the healer, by the unique ID of the medicine.
local healRewards = {
  special_ration = { boost = 1, progress = 20 },
  antibiotics = { boost = 1, progress = 25 },
  allergy_tablet = { boost = 2, progress = 15 },
  bandage = { boost = 1, progress = 5 },
  activated_coal = { boost = 1, progress = 5 },
  ingall = { boost = 3, progress = 15 },
  snot = { progress = 15 },
  snotbad = { progress = 10 },
  probiotics = { boost = 2, progress = 20 },
  sorbent = { boost = 1, progress = 15 }
}

--- Called when a player has been healed with an item; applies the medicine's rewards.
--
-- Most medicines boost the patient's agility for two minutes, and every one listed progresses
-- the healer's medical attribute by an amount that depends on the item.
--
-- @param player [Player The patient]
-- @param healer [Player The player who used the item; the patient themselves for self-treatment]
-- @param itemTable [Item The medicine used]
function PLUGIN:PlayerHealed(player, healer, itemTable)
  local reward = healRewards[itemTable.uniqueID]

  if !reward then return end

  if reward.boost then
    player:BoostAttribute(itemTable.name, ATB_AGILITY, reward.boost, 120)
  end

  healer:ProgressAttribute(ATB_MEDICAL, reward.progress, true)
end

-- Unique IDs of the food that can cause an allergy and of the junk food that can cause gastritis.
local allergyFood = {
  choko = true,
  orange = true,
  apple = true,
  bread = true
}
local lowQualityFood = {
  chips = true,
  chinese_takeout = true
}

--- Called when a player uses an item; can give a disease from food and triggers food symptoms.
--
-- A healthy player may get an allergy from some fruit and bread, gastritis from junk food or
-- insomnia from coffee. Allergic players take damage from those foods again, and players with
-- diarrhea vomit and take damage after eating or drinking anything. The delayed effects are
-- dropped when the player has left, died or switched character by then.
--
-- @param player [Player The player who used the item]
-- @param itemTable [Item The item used]
-- @param itemEntity [Entity The item's entity when used from the world, otherwise `nil`]
function PLUGIN:PlayerUseItem(player, itemTable, itemEntity)
  local uniqueID = itemTable.uniqueID
  local key = player:GetCharacterKey()

  local function Delayed(delay, Callback)
    timer.Simple(delay, function()
      if IsValid(player) and player:HasInitialized() and player:Alive() and player:GetCharacterKey() == key then
        Callback()
      end
    end)
  end

  if player:GetCharacterData('diseases') == 'none' then
    if allergyFood[uniqueID] and math.random(1, 10) == 1 then
      player:SetCharacterData('diseases', 'allergy')

      Delayed(math.random(60, 180), function()
        cw.player:Notify(player, L('Diseases_AllergyRash'))
      end)
    elseif lowQualityFood[uniqueID] and math.random(1, 4) == 1 then
      player:SetCharacterData('diseases', 'gastrits')

      Delayed(math.random(60, 180), function()
        cw.player:Notify(player, L('Diseases_StomachPain'))
      end)
    elseif uniqueID == 'coffee' and math.random(1, 5) == 1 then
      player:SetCharacterData('diseases', 'insomnia')
    end
  end

  local disease = player:GetCharacterData('diseases')

  if disease == 'allergy' and allergyFood[uniqueID] then
    Delayed(math.random(5, 15), function()
      cw.player:Notify(player, L('Diseases_AllergyReaction', itemTable.name))
      player:TakeDamage(math.random(5, 15))
    end)
  end

  if disease == 'diarrhea' and (itemTable.hunger or itemTable.thirst or itemTable.fatigue) then
    Delayed(math.random(5, 15), function()
      Emote(player, 'Diseases_Emote_Vomit')
      player:TakeDamage(math.random(5, 30))
    end)
  end
end
