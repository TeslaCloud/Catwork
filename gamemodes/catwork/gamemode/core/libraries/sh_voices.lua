--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("voices", cw)

local groups = cw.voices.groups or {}
cw.voices.groups = groups

-- A function to get the local stored voice groups.
function cw.voices:GetAll()
	return groups
end

-- A function to get a certain group by ID.
function cw.voices:FindByID(id)
	return groups[id]
end

-- A function to get the voices of a certain group by ID.
function cw.voices:GetVoices(id)
	return groups[id].voices
end

-- A function to add a voice group.
function cw.voices:RegisterGroup(group, bGender, callback)
	if (!bGender) then
		bGender = false
	end

	groups[group] = groups[group] or {
		bGender = bGender,
		IsPlayerMember = callback,
		voices = {}
	}
end

-- A function to add a voice.
function cw.voices:Add(groupName, command, phrase, sound, female, menu, pitch, volume)
	if (!isstring(command)) then return end

	local group = groups[groupName]

	if (group) then
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

-- Called when the framework initializes.
function cw.voices:ClockworkInitialized()
	for k, v in pairs(faction.GetAll()) do
		local FACTION = faction.FindByID(v.name)

		if (IsValid(FACTION.models.female and FACTION.models.male)) then
			self:RegisterGroup(v.name, true, function(ply)
				if (ply:GetFaction() == v.name) then
					return true
				else
					return false
				end
			end)
		else
			self:RegisterGroup(k, false, function(ply)
				if (ply:GetFaction() == v.name) then
					return true
				else
					return false
				end
			end)
		end
	end

	hook.Run("RegisterVoiceGroups", self)
	hook.Run("RegisterVoices", self)
	hook.Run("AdjustVoices", groups)

	if (CLIENT) then
		for k, v in pairs(groups) do
			if (v.hasVoices) then
				cw.directory:AddCategory(k, "Voice Commands")

				for k2, v2 in SortedPairs(v.voices) do
					if (!v2.phrase) then v2.phrase = ""; end

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

-- Called when chat box info should be adjusted.
function cw.voices:ChatboxAdjustMessageInfo(info)
	if (info.filter == "ic") then
		if (IsValid(info.sender) and info.sender:HasInitialized()
		and ((info.sender.voiceCooldown or 0) < CurTime() or info.sender:IsAdmin())) then
			info.text = string.utf8upper(string.utf8sub(info.text, 1, 1))..string.utf8sub(info.text, 2)

			for k, v in pairs(groups) do
				if (v.IsPlayerMember(info.sender)) then
					local voiceData = v.voices[info.text:Replace("\"", ""):utf8lower()]

					if (voiceData) then
						local voice = {
							global = voiceData.global or false,
							volume = voiceData.volume or 80,
							sound = voiceData.sound,
							pitch = voiceData.pitch
						}

						if (v.bGender) then
							if (voiceData.female and info.sender:QueryCharacter("Gender") == GENDER_FEMALE) then
								voice.sound = string.Replace(voice.sound, "/male", "/female")
							end
						end

						info.voice = voice

						if (voiceData.phrase == nil or voiceData.phrase == "") then
							info.visible = false

							if (SERVER) then
								cw.core:PrintLog(LOGTYPE_GENERIC, info.sender:Name().." says: \""..info.text.."\"")
							end
						else
							info.text = voiceData.phrase

							if (info.data and (info.data.radio or info.data.dispatch or info.data.broadcast or info.data.overwatch)) then
								info.text = "\""..info.text.."\""
							end
						end

						info.sender.voiceCooldown = CurTime() + config.GetVal("voice_cooldown")

						return true
					end
				end
			end
		end
	end
end

-- Called when a chat box message has been added.
function cw.voices:ChatboxMessageSent(info)
	if (info.voice) then
		if (IsValid(info.sender) and info.sender:HasInitialized()) then
			info.sender:EmitSound(info.voice.sound, info.voice.volume, info.voice.pitch)
		end

		if (info.voice.global or (info.data and info.data.radio)) then
			for k, v in pairs(info.listeners) do
				if (v != info.sender) then
					cw.player:PlaySound(v, info.voice.sound)
				end
			end
		end
	end
end

plugin.Add("Voices", cw.voices)
