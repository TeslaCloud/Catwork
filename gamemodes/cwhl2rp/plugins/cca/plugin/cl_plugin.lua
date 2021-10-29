--[[
	© 2017 TeslaCloud Studios.
	Do not share, re-distribute or sell.
--]]

function PLUGIN:MenuItemsAdd(menuItems)
	if (Schema:PlayerIsCombine(cw.client) or cw.client:GetFaction() == FACTION_CWU) then
		menuItems:Add("#Combine_PDA", "cwCombinePDA", "#Combine_PDA_Desc", {path = "fa-mobile", size = 10})
	end
end

function PLUGIN:HandleCitizenStatusButton(panel, id)
	netstream.Start("Application::PDA::Controller::CitizenStatus", panel.player, id)
end

function PLUGIN:HandleResidenceChangeButton(panel, input)
	netstream.Start("Application::PDA::Controller::Residence", panel.player, input)
end

function PLUGIN:HandleJobChangeButton(panel, input)
	netstream.Start("Application::PDA::Controller::Job", panel.player, input)
end

function PLUGIN:HandleLoyaltyPointsIssue(panel, value)
	netstream.Start("Application::PDA::Controller::LP", panel.player, value)
end

function PLUGIN:HandleCrimePointsIssue(panel, value)
	netstream.Start("Application::PDA::Controller::CP", panel.player, value)
end

function PLUGIN:HandleLoyaltyPointsSubstract(panel, value)
	netstream.Start("Application::PDA::Controller::LP", panel.player, value, true)
end

function PLUGIN:HandleCrimePointsSubstract(panel, value)
	netstream.Start("Application::PDA::Controller::CP", panel.player, value, true)
end

function PLUGIN:HandleJobPointsIssue(panel, value)
	netstream.Start("Application::PDA::Controller::WP", panel.player, value)
end

function PLUGIN:HandleJailButton(panel)
	netstream.Start("Application::PDA::Controller::Jail", panel.player)
end

function PLUGIN:HandleUnjailButton(panel)
	netstream.Start("Application::PDA::Controller::Unjail", panel.player)
end

function PLUGIN:AddCombinePDAButons(pda)
	pda:AddButton("status", "#PDA_ChangeCitizenStatus", false, function()
		if (Schema:PlayerIsCombine(cw.client)) then
			Derma_Query("#Status_Desc", "#Status_Title",
				"#Status_Unverified", 	function() plugin.Call("HandleCitizenStatusButton", pda, "Unverified") 	end,
				"#Status_Citizen", 		function() plugin.Call("HandleCitizenStatusButton", pda, "Citizen") 	end,
				"#Status_AntiCitizen", 	function() plugin.Call("HandleCitizenStatusButton", pda, "AntiCitizen") end,
				"#Status_NoData", 		function() plugin.Call("HandleCitizenStatusButton", pda, "NoData") 		end
			)
		else
			Derma_Query("#Status_Desc", "#Status_Title",
				"#Status_Unverified", 	function() plugin.Call("HandleCitizenStatusButton", pda, "Unverified") 	end,
				"#Status_Citizen", 		function() plugin.Call("HandleCitizenStatusButton", pda, "Citizen") 	end
			)
		end
	end)

	pda:AddButton("residence", "#PDA_ChangeResidence", false, function()
		Derma_StringRequest("#Residence_Title", "#Residence_Desc", Schema:GetResidence(pda.player),
		function(text) plugin.Call("HandleResidenceChangeButton", pda, text) end, nil, "#OK", "#Cancel")
	end)

	pda:AddButton("job", "#PDA_ChangeJob", false, function()
		Derma_StringRequest("#Job_Title", "#Job_Desc", Schema:GetResidence(pda.player),
		function(text) plugin.Call("HandleJobChangeButton", pda, text) end, nil, "#OK", "#Cancel")
	end)

	pda:AddButton("jobpoints", "#PDA_CWUPoints", false, function()
		Derma_NumRequest("#PDA_CWUPoints", "How many points do you want to issue?", 0, 0, 20, 0, 
		function(value) plugin.Call("HandleJobPointsIssue", pda, value) end, nil, "#OK", "#Cancel")
	end)

	pda:AddButton("loyalty", "#PDA_LP", true, function()
		Derma_NumRequest("#PDA_LP", "How many points do you want to issue?", 0, 0, 10, 0,
		function(value) plugin.Call("HandleLoyaltyPointsIssue", pda, value) end, nil, "#OK", "#Cancel")
	end)

	pda:AddButton("crime", "#PDA_CP", true, function()
		Derma_NumRequest("#PDA_CP", "How many points do you want to issue?", 0, 0, 20, 0,
		function(value) plugin.Call("HandleCrimePointsIssue", pda, value) end, nil, "#OK", "#Cancel")
	end)

	pda:AddButton("sub_loyalty", "Забрать Очки Лояльности", true, function()
		Derma_NumRequest("#PDA_LP", "How many points do you want to remove?", 0, 0, 10, 0, 
		function(value) plugin.Call("HandleLoyaltyPointsSubstract", pda, -value) end, nil, "#OK", "#Cancel")
	end)

	pda:AddButton("sub_crime", "Забрать Очки Нарушений", true, function()
		Derma_NumRequest("#PDA_CP", "How many points do you want to remove?", 0, 0, 20, 0, 
		function(value) plugin.Call("HandleCrimePointsSubstract", pda, -value) end, nil, "#OK", "#Cancel")
	end)

	pda:AddButton("jail", "#PDA_Jail", true, function()
		Derma_Query("Are you sure you want to isolate this citizen?", "#PDA_Jail",
			"#OK", function() plugin.Call("HandleJailButton", pda) end,
			"#Cancel", function() end
		)
	end)

	pda:AddButton("unjail", "#PDA_Unjail", true, function()
		Derma_Query("Are you sure you want to remove the isolation from this citizen?", "#PDA_Unjail",
			"#OK", function() plugin.Call("HandleUnjailButton", pda) end,
			"#Cancel", 	function() end
		)
	end)
end

netstream.Hook("CCA::Response::Update", function()
	if (IsValid(Schema.pdaPanel) and IsValid(Schema.pdaPanel.playerCard)) then
		Schema.pdaPanel.playerCard:Rebuild()
	end
end)