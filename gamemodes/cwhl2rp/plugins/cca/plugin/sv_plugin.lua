--[[
	© 2017 TeslaCloud Studios.
	Do not share, re-distribute or sell.
--]]

function PLUGIN:PlayerCharacterLoaded(player)
	local logs = player:GetCharacterData("CCA_Logs") or {}
	player:SetNetVar("CCA_Logs", logs)
end

netstream.Hook("Application::PDA::Controller::CitizenStatus", function(player, target, status)
	if (!util.Validate(player, target)) then return end

	local isCombine = player:IsCombine()
	local isCWU = (isCombine or (player:GetFaction() == FACTION_CWU))

	if ((status == "Unverified" or status == "Citizen") and !isCWU) then
		cw.player:Notify(player, L("PDA_NotCWUOrCombine"))

		return
	end

	if ((status == "AntiCitizen" or status == "NoData") and !isCombine) then
		cw.player:Notify(player, L("PDA_NotCombine"))

		return
	end

	cw.core:ServerLog(player:Name().." has set "..target:Name().."'s citizen status to "..status..".")
	cca.AppendLog(player, target, L("PDA_Log_CitizenStatus").." #Status_"..status..":;", "citizen_status")

	Schema:SetCitizenStatus(target, status)

	cw.player:Notify(player, L("PDA_CitizenStatusSet", target:Name()).." #Status_"..status..":;.")
end)

netstream.Hook("Application::PDA::Controller::Residence", function(player, target, address)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine() or player:GetFaction() == FACTION_CWU) then
		cw.core:ServerLog(player:Name().." has set "..target:Name().."'s residence to "..address..".")
		cca.AppendLog(player, target, L("PDA_Log_Residence").." "..address, "residence")

		Schema:SetResidence(target, address)

		cw.player:Notify(player, L("PDA_ResidenceSet", target:Name()).." "..address)
	else
		cw.player:Notify(player, L("PDA_NotCombine"))
	end
end)

netstream.Hook("Application::PDA::Controller::Job", function(player, target, job)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine() or player:GetFaction() == FACTION_CWU) then
		cw.core:ServerLog(player:Name().." has set "..target:Name().."'s job to "..job..".")
		cca.AppendLog(player, target, L("PDA_Log_Job").." "..job, "job")

		Schema:SetJob(target, job)

		cw.player:Notify(player, L("PDA_JobSet", target:Name()).." "..job)
	else
		cw.player:Notify(player, L("PDA_NotCombine"))
	end
end)

local translation = {
	["add"] = "+",
	["remove"] = ""
}

netstream.Hook("Application::PDA::Controller::LP", function(player, target, value, bSubstract)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine()) then
		value = math.Round(math.Clamp(tonumber(value), (!bSubstract and 0) or -50, (!bSubstract and 50) or 0))

		cw.core:ServerLog(player:Name().." has "..((!bSubstract and "Issued ") or "Removed ").." "..tostring(math.abs(value)).." LP "..((!bSubstract and "to ") or "from ").." "..target:Name()..".")

		local type = ((!bSubstract and "add") or "remove")
		cca.AppendLog(player, target, L("PDA_Log_LP").." "..(translation[type] or "")..value, "loyalty_"..type)

		Schema:AddLP(target, value)

		cw.player:Notify(player, L((!bSubstract and "PDA_LPIssued") or "PDA_LPRemoved", math.abs(value), target:Name()))
	else
		cw.player:Notify(player, L("PDA_NotCombine"))
	end
end)

netstream.Hook("Application::PDA::Controller::CP", function(player, target, value, bSubstract)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine()) then
		value = math.Round(math.Clamp(tonumber(value), (!bSubstract and 0) or -50, (!bSubstract and 50) or 0))

		cw.core:ServerLog(player:Name().." has "..((!bSubstract and "Issued ") or "Removed ").." "..tostring(math.abs(value)).." CP "..((!bSubstract and "to ") or "from ").." "..target:Name()..".")

		local type = ((!bSubstract and "add") or "remove")
		cca.AppendLog(player, target, L("PDA_Log_CP").." "..(translation[type] or "")..value, "crime_"..type)

		Schema:AddCP(target, value)

		cw.player:Notify(player, L((!bSubstract and "PDA_CPIssued") or "PDA_CPRemoved", math.abs(value), target:Name()))
	else
		cw.player:Notify(player, L("PDA_NotCombine"))
	end
end)

netstream.Hook("Application::PDA::Controller::WP", function(player, target, value)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine() or player:GetFaction() == FACTION_CWU) then
		value = math.Round(math.Clamp(tonumber(value), 0, 20))

		cw.core:ServerLog(player:Name().." has "..((!bSubstract and "Issued ") or "Removed ").." "..tostring(math.abs(value)).." WP "..((!bSubstract and "to ") or "from ").." "..target:Name()..".")

		local type = ((!bSubstract and "add") or "remove")
		cca.AppendLog(player, target, L("PDA_Log_WP").." "..(translation[type] or "")..value, "work_"..type)

		Schema:AddWorkPoints(target, value)

		cw.player:Notify(player, L("PDA_WPIssued", value, target:Name()))
	else
		cw.player:Notify(player, L("PDA_NotCombine"))
	end
end)

netstream.Hook("Application::PDA::Controller::Jail", function(player, target)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine()) then
		cw.core:ServerLog(player:Name().." has jailed "..target:Name()..".")

		cca.AppendLog(player, target, L("PDA_Log_Jail"), "jail")

		Schema:SetJailed(target, true)

		cw.player:Notify(player, L("PDA_JailDone", target:Name()))
		cw.player:Notify(target, L("PDA_Jailed"))
	else
		cw.player:Notify(player, L("PDA_NotCombine"))
	end
end)

netstream.Hook("Application::PDA::Controller::Unjail", function(player, target)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine()) then
		cw.core:ServerLog(player:Name().." has unjailed "..target:Name()..".")
		cca.AppendLog(player, target, L("PDA_Log_Unjail"), "unjail")

		Schema:SetJailed(target, false)

		cw.player:Notify(player, L("PDA_UnjailDone", target:Name()))
		cw.player:Notify(target, L("PDA_Unjailed"))
	else
		cw.player:Notify(player, L("PDA_NotCombine"))
	end
end)
