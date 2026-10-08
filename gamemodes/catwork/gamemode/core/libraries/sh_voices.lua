--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('voices', cw)

local groups = cw.voices.groups or {}
cw.voices.groups = groups

--- Returns every registered voice group.
--
-- @return [Map<Map> Voice groups keyed by name, each with `bGender`, `IsPlayerMember` and `voices` keys]
function cw.voices:GetAll()
  return groups
end

--- Returns a voice group.
--
-- @param id [String Name of the group]
-- @return [Map The group, or `nil` if it is not registered]
function cw.voices:FindByID(id)
  return groups[id]
end

--- Returns the voice lines of a group.
--
-- Errors if the group is not registered.
--
-- @param id [String Name of the group]
-- @return [Map<Map> Voice lines keyed by their lowercased command]
function cw.voices:GetVoices(id)
  return groups[id].voices
end

--- Registers a voice group.
--
-- Does nothing if the group already exists.
--
-- ```
-- voices:RegisterGroup('Combine', false, function(player)
--   return player:IsCombine()
-- end)
-- ```
--
-- @param group [String Name of the group]
-- @param bGender=false [Boolean Whether female characters get the female version of each sound]
-- @param callback [Function Called as `callback(player)`; returns whether the player can use the
-- group's voices]
function cw.voices:RegisterGroup(group, bGender, callback)
  if !bGender then
    bGender = false
  end

  groups[group] = groups[group] or {
    bGender = bGender,
    IsPlayerMember = callback,
    voices = {}
  }
end

--- Adds a voice line to a group.
--
-- A player in the group who says `command` in IC chat plays `sound` and shows `phrase` instead.
-- Prints an error if the group is not registered.
--
-- ```
-- voices:Add('Human', 'Figures', 'Figures.', 'vo/npc/male01/answer03.wav', 'vo/npc/female01/answer03.wav')
-- ```
--
-- @param groupName [String Name of the group]
-- @param command [String Text that triggers the line; matched case-insensitively]
-- @param phrase [String Text shown in chat; the message is hidden when empty or `nil`]
-- @param sound [String Sound file path]
-- @param female=nil [Any When set in a gender group, female characters play `sound` with `/male`
-- replaced by `/female`]
-- @param menu=nil [Any Stored with the line, unused by Catwork]
-- @param pitch=nil [Number Sound pitch]
-- @param volume=nil [Number Sound level; 80 when `nil`]
function cw.voices:Add(groupName, command, phrase, sound, female, menu, pitch, volume)
  if !isstring(command) then return end

  local group = groups[groupName]

  if group then
    group.hasVoices = true

    group.voices[command:utf8lower()] = {
      command = command,
      phrase = phrase,
      female = female,
      sound = sound,
      menu = menu,
      pitch = pitch,
      volume = volume
    }
  else
    ErrorNoHalt("Attempted to add voice for invalid group '"..groupName.."'.\n")
  end
end

--- Called when the framework initializes; registers a voice group per faction and collects voices.
--
-- Each faction gets a group its members can use. Then runs the `RegisterVoiceGroups`,
-- `RegisterVoices` and `AdjustVoices` hooks (via `hook.Run`), and on the client adds each group's
-- lines to the directory.
function cw.voices:ClockworkInitialized()
  for k, v in pairs(faction.GetAll()) do
    local FACTION = faction.FindByID(v.name)

    if IsValid(FACTION.models.female and FACTION.models.male) then
      self:RegisterGroup(v.name, true, function(ply)
        if ply:GetFaction() == v.name then
          return true
        else
          return false
        end
      end)
    else
      self:RegisterGroup(k, false, function(ply)
        if ply:GetFaction() == v.name then
          return true
        else
          return false
        end
      end)
    end
  end

  hook.Run('RegisterVoiceGroups', self)
  hook.Run('RegisterVoices', self)
  hook.Run('AdjustVoices', groups)

  if CLIENT then
    for k, v in pairs(groups) do
      if v.hasVoices then
        cw.directory:AddCategory(k, 'Voice Commands')

        for k2, v2 in SortedPairs(v.voices) do
          if !v2.phrase then v2.phrase = '' end

          cw.directory:AddCode(k, [[
						<div class="cwTitleSeperator">]]..string.upper(v2.command)..[[</div>
						<div class="cwContentText">]]..v2.phrase..[[</div>
						<br>
					]], true)
        end
      end
    end
  end
end

--- Called when chat box info should be adjusted; turns matching IC messages into voice lines.
--
-- When the message matches a voice line of a group the sender belongs to and the sender's voice
-- cooldown has passed (admins skip it), sets `info.voice`, replaces the text with the line's
-- phrase (or hides the message) and starts the `voice_cooldown`.
--
-- @param info [Map The chat message info, with `filter`, `sender`, `text` and `data` keys]
-- @return [Boolean `true` when the message became a voice line]
function cw.voices:ChatboxAdjustMessageInfo(info)
  if info.filter == 'ic' then
    if IsValid(info.sender) and info.sender:HasInitialized()
    and ((info.sender.voiceCooldown or 0) < CurTime() or info.sender:IsAdmin()) then
      info.text = string.utf8upper(string.utf8sub(info.text, 1, 1))..string.utf8sub(info.text, 2)

      for k, v in pairs(groups) do
        if v.IsPlayerMember(info.sender) then
          local voiceData = v.voices[info.text:Replace('"', ''):utf8lower()]

          if voiceData then
            local voice = {
              global = voiceData.global or false,
              volume = voiceData.volume or 80,
              sound = voiceData.sound,
              pitch = voiceData.pitch
            }

            if v.bGender then
              if voiceData.female and info.sender:QueryCharacter('Gender') == GENDER_FEMALE then
                voice.sound = string.Replace(voice.sound, '/male', '/female')
              end
            end

            info.voice = voice

            if voiceData.phrase == nil or voiceData.phrase == '' then
              info.visible = false

              if SERVER then
                cw.core:PrintLog(LOGTYPE_GENERIC, info.sender:Name()..' says: "'..info.text..'"')
              end
            else
              info.text = voiceData.phrase

              if info.data and
                 (info.data.radio or info.data.dispatch or info.data.broadcast or info.data.overwatch) then
                info.text = '"'..info.text..'"'
              end
            end

            info.sender.voiceCooldown = CurTime() + config.GetVal('voice_cooldown')

            return true
          end
        end
      end
    end
  end
end

--- Called when a chat box message has been sent; plays the voice line's sound.
--
-- The sender emits the sound. For global lines and radio messages, every listener except the
-- sender also hears it.
--
-- @param info [Map The chat message info, with `voice`, `sender`, `listeners` and `data` keys]
function cw.voices:ChatboxMessageSent(info)
  if info.voice then
    if IsValid(info.sender) and info.sender:HasInitialized() then
      info.sender:EmitSound(info.voice.sound, info.voice.volume, info.voice.pitch)
    end

    if info.voice.global or (info.data and info.data.radio) then
      for k, v in pairs(info.listeners) do
        if v != info.sender then
          cw.player:PlaySound(v, info.voice.sound)
        end
      end
    end
  end
end

plugin.Add('Voices', cw.voices)
