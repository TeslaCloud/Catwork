--- Server-side part of the Combine Civil Authority plugin, which handles the Combine PDA requests to change a citizen's
-- status, residence, job, points and jail state.
--
-- Each `Application::PDA::Controller::` netstream receiver checks that the request is acceptable (a living sender with
-- a character, a non-Combine target with a character, no more than two requests a second) and that the sender is
-- Combine (or CWU where that is allowed), applies the change through the schema (`Schema:SetCitizenStatus`,
-- `Schema:AddLP`, `Schema:SetJailed` and so on), writes a server log line and appends an entry to the target's civil
-- record with `cca.AppendLog`.

-- Seconds a player has to wait between two PDA requests.
local requestDelay = 0.5

-- The statuses the PDA can set, mapped to whether only the Combine may set them.
local statusCombineOnly = {
  Unverified = false,
  Citizen = false,
  AntiCitizen = true,
  NoData = true
}

--- Returns whether a PDA request should be handled, and starts the sender's request cooldown when it should.
--
-- The sender has to be alive with a character loaded, and the target a player with a character who is not Combine:
-- the PDA shows no actions for Combine units. The target comes from the client and can be any value.
-- @param player [Player The player who sent the request]
-- @param target [Any The target of the request, as received]
-- @return [Boolean Whether the request should be handled]
local function CanRequest(player, target)
  if !player:HasInitialized() or !player:Alive() then return false end
  if !isentity(target) or !IsValid(target) or !target:IsPlayer() then return false end
  if !target:HasInitialized() or target:IsCombine() then return false end

  local curTime = CurTime()

  if player.cwNextPDARequest and curTime < player.cwNextPDARequest then return false end

  player.cwNextPDARequest = curTime + requestDelay

  return true
end

--- Called when a player's character has loaded; networks the character's civil record.
-- @param player [Player The player whose character loaded]
function PLUGIN:PlayerCharacterLoaded(player)
  local logs = player:GetCharacterData('CCA_Logs')

  if !istable(logs) then
    logs = {}
  end

  player:SetNetVar('CCA_Logs', cca.TrimLogs(logs))
end

netstream.Hook('Application::PDA::Controller::CitizenStatus', function(player, target, status)
  if !isstring(status) or statusCombineOnly[status] == nil then return end
  if !CanRequest(player, target) then return end

  local isCombine = player:IsCombine()
  local isCWU = (isCombine or (player:GetFaction() == FACTION_CWU))

  if !isCWU then
    cw.player:Notify(player, L('PDA_NotCWUOrCombine'))

    return
  end

  if statusCombineOnly[status] and !isCombine then
    cw.player:Notify(player, L('PDA_NotCombine'))

    return
  end

  cw.core:ServerLog(player:Name()..' has set '..target:Name().."'s citizen status to "..status..'.')
  cca.AppendLog(player, target, L('PDA_Log_CitizenStatus')..' #Status_'..status..':;', 'citizen_status')

  Schema:SetCitizenStatus(target, status)

  cw.player:Notify(player, L('PDA_CitizenStatusSet', target:Name())..' #Status_'..status..':;.')
end)

netstream.Hook('Application::PDA::Controller::Residence', function(player, target, address)
  if !isstring(address) then return end
  if !CanRequest(player, target) then return end

  address = string.utf8sub(string.gsub(address, '%c', ''), 1, 128)

  if player:IsCombine() or player:GetFaction() == FACTION_CWU then
    cw.core:ServerLog(player:Name()..' has set '..target:Name().."'s residence to "..address..'.')
    cca.AppendLog(player, target, L('PDA_Log_Residence')..' '..address, 'residence')

    Schema:SetResidence(target, address)

    cw.player:Notify(player, L('PDA_ResidenceSet', target:Name())..' '..address)
  else
    cw.player:Notify(player, L('PDA_NotCombine'))
  end
end)

netstream.Hook('Application::PDA::Controller::Job', function(player, target, job)
  if !isstring(job) then return end
  if !CanRequest(player, target) then return end

  job = string.utf8sub(string.gsub(job, '%c', ''), 1, 128)

  if player:IsCombine() or player:GetFaction() == FACTION_CWU then
    cw.core:ServerLog(player:Name()..' has set '..target:Name().."'s job to "..job..'.')
    cca.AppendLog(player, target, L('PDA_Log_Job')..' '..job, 'job')

    Schema:SetJob(target, job)

    cw.player:Notify(player, L('PDA_JobSet', target:Name())..' '..job)
  else
    cw.player:Notify(player, L('PDA_NotCombine'))
  end
end)

local translation = {
  ['add'] = '+',
  ['remove'] = ''
}

netstream.Hook('Application::PDA::Controller::LP', function(player, target, value, bSubstract)
  value = tonumber(value)

  -- NaN would end up in the character data and break every integer format after it.
  if !value or value != value then return end
  if !CanRequest(player, target) then return end

  if player:IsCombine() then
    value = math.Round(math.Clamp(value, (!bSubstract and 0) or -50, (!bSubstract and 50) or 0))

    if value == 0 then return end

    cw.core:ServerLog(
      player:Name()..' has '..((!bSubstract and 'Issued ') or 'Removed ')..' '..tostring(math.abs(value))..' LP '..
        ((!bSubstract and 'to ') or 'from ')..' '..target:Name()..'.'
    )

    local type = ((!bSubstract and 'add') or 'remove')
    cca.AppendLog(player, target, L('PDA_Log_LP')..' '..(translation[type] or '')..value, 'loyalty_'..type)

    Schema:AddLP(target, value)

    cw.player:Notify(player, L((!bSubstract and 'PDA_LPIssued') or 'PDA_LPRemoved', math.abs(value), target:Name()))
  else
    cw.player:Notify(player, L('PDA_NotCombine'))
  end
end)

netstream.Hook('Application::PDA::Controller::CP', function(player, target, value, bSubstract)
  value = tonumber(value)

  -- NaN would end up in the character data and break every integer format after it.
  if !value or value != value then return end
  if !CanRequest(player, target) then return end

  if player:IsCombine() then
    value = math.Round(math.Clamp(value, (!bSubstract and 0) or -50, (!bSubstract and 50) or 0))

    if value == 0 then return end

    cw.core:ServerLog(
      player:Name()..' has '..((!bSubstract and 'Issued ') or 'Removed ')..' '..tostring(math.abs(value))..' CP '..
        ((!bSubstract and 'to ') or 'from ')..' '..target:Name()..'.'
    )

    local type = ((!bSubstract and 'add') or 'remove')
    cca.AppendLog(player, target, L('PDA_Log_CP')..' '..(translation[type] or '')..value, 'crime_'..type)

    Schema:AddCP(target, value)

    cw.player:Notify(player, L((!bSubstract and 'PDA_CPIssued') or 'PDA_CPRemoved', math.abs(value), target:Name()))
  else
    cw.player:Notify(player, L('PDA_NotCombine'))
  end
end)

netstream.Hook('Application::PDA::Controller::WP', function(player, target, value)
  value = tonumber(value)

  -- NaN would end up in the character data and break every integer format after it.
  if !value or value != value then return end
  if !CanRequest(player, target) then return end

  if player:IsCombine() or player:GetFaction() == FACTION_CWU then
    value = math.Round(math.Clamp(value, 0, 20))

    if value == 0 then return end

    cw.core:ServerLog(player:Name()..' has Issued '..tostring(value)..' WP to '..target:Name()..'.')
    cca.AppendLog(player, target, L('PDA_Log_WP')..' '..translation['add']..value, 'work_add')

    Schema:AddWorkPoints(target, value)

    cw.player:Notify(player, L('PDA_WPIssued', value, target:Name()))
  else
    cw.player:Notify(player, L('PDA_NotCombine'))
  end
end)

netstream.Hook('Application::PDA::Controller::Jail', function(player, target)
  if !CanRequest(player, target) then return end

  if player:IsCombine() then
    cw.core:ServerLog(player:Name()..' has jailed '..target:Name()..'.')

    cca.AppendLog(player, target, L('PDA_Log_Jail'), 'jail')

    Schema:SetJailed(target, true)

    cw.player:Notify(player, L('PDA_JailDone', target:Name()))
    cw.player:Notify(target, L('PDA_Jailed'))
  else
    cw.player:Notify(player, L('PDA_NotCombine'))
  end
end)

netstream.Hook('Application::PDA::Controller::Unjail', function(player, target)
  if !CanRequest(player, target) then return end

  if player:IsCombine() then
    cw.core:ServerLog(player:Name()..' has unjailed '..target:Name()..'.')
    cca.AppendLog(player, target, L('PDA_Log_Unjail'), 'unjail')

    Schema:SetJailed(target, false)

    cw.player:Notify(player, L('PDA_UnjailDone', target:Name()))
    cw.player:Notify(target, L('PDA_Unjailed'))
  else
    cw.player:Notify(player, L('PDA_NotCombine'))
  end
end)
