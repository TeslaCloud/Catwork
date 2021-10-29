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
		cw.player:Notify(player, "You are not a Civil Worker's Union worker or the Combine!")

		return
	end

	if ((status == "AntiCitizen" or status == "NoData") and !isCombine) then
		cw.player:Notify(player, "You are not the Combine!")

		return
	end

	cw.core:ServerLog(player:Name().." has set "..target:Name().."'s citizen status to "..status..".")
	cca.AppendLog(player, target, "Citizen status changed: "..status, "citizen_status")

	Schema:SetCitizenStatus(target, status)

	cw.player:Notify(player, "You have set "..target:Name().."'s citizen status to #Status_"..status..":;.")
end)

netstream.Hook("Application::PDA::Controller::Residence", function(player, target, address)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine() or player:GetFaction() == FACTION_CWU) then
		cw.core:ServerLog(player:Name().." has set "..target:Name().."'s residence to "..address..".")
		cca.AppendLog(player, target, "Residence changed: "..address, "residence")

		Schema:SetResidence(target, address)

		cw.player:Notify(player, target:Name().."'s residential address was set to "..address)
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end)

netstream.Hook("Application::PDA::Controller::Job", function(player, target, job)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine() or player:GetFaction() == FACTION_CWU) then
		cw.core:ServerLog(player:Name().." has set "..target:Name().."'s job to "..job..".")
		cca.AppendLog(player, target, "Job changed: "..job, "job")

		Schema:SetJob(target, job)

		cw.player:Notify(player, target:Name().."'s job was set to "..job)
	else
		cw.player:Notify(player, "You are not the Combine!")
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
		cca.AppendLog(player, target, "Loyalty points changed: "..(translation[type] or "")..value, "loyalty_"..type)

		Schema:AddLP(target, value)

		cw.player:Notify(player, ((!bSubstract and "Issued ") or "Removed ")..math.abs(value).." loyalty points "..((!bSubstract and "to ") or "from ")..target:Name()..".")
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end)

netstream.Hook("Application::PDA::Controller::CP", function(player, target, value, bSubstract)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine()) then
		value = math.Round(math.Clamp(tonumber(value), (!bSubstract and 0) or -50, (!bSubstract and 50) or 0))

		cw.core:ServerLog(player:Name().." has "..((!bSubstract and "Issued ") or "Removed ").." "..tostring(math.abs(value)).." CP "..((!bSubstract and "to ") or "from ").." "..target:Name()..".")

		local type = ((!bSubstract and "add") or "remove")
		cca.AppendLog(player, target, "Crime points changed: "..(translation[type] or "")..value, "crime_"..type)

		Schema:AddCP(target, value)

		cw.player:Notify(player, ((!bSubstract and "Issued ") or "Removed ")..math.abs(value).." crime points "..((!bSubstract and "to ") or "from ")..target:Name()..".")
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end)

netstream.Hook("Application::PDA::Controller::WP", function(player, target, value)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine() or player:GetFaction() == FACTION_CWU) then
		value = math.Round(math.Clamp(tonumber(value), 0, 20))

		cw.core:ServerLog(player:Name().." has "..((!bSubstract and "Issued ") or "Removed ").." "..tostring(math.abs(value)).." WP "..((!bSubstract and "to ") or "from ").." "..target:Name()..".")

		local type = ((!bSubstract and "add") or "remove")
		cca.AppendLog(player, target, "Work points changed: "..(translation[type] or "")..value, "work_"..type)

		Schema:AddWorkPoints(target, value)

		cw.player:Notify(player, "Issued "..value.." work points to "..target:Name()..".")
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end)

netstream.Hook("Application::PDA::Controller::Jail", function(player, target)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine()) then
		cw.core:ServerLog(player:Name().." has jailed "..target:Name()..".")

		cca.AppendLog(player, target, "Isolation order issued!", "jail")

		Schema:SetJailed(target, true)

		cw.player:Notify(player, "Isolation order for "..target:Name().." has been successfully executed!")
		cw.player:Notify(target, "You are now under isolation!")
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end)

netstream.Hook("Application::PDA::Controller::Unjail", function(player, target)
	if (!util.Validate(player, target)) then return end

	if (player:IsCombine()) then
		cw.core:ServerLog(player:Name().." has unjailed "..target:Name()..".")
		cca.AppendLog(player, target, "Isolation order revoked!", "unjail")

		Schema:SetJailed(target, false)

		cw.player:Notify(player, "Isolation order for "..target:Name().." has been successfully removed!")
		cw.player:Notify(target, "You are no longer under isolation!")
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end)