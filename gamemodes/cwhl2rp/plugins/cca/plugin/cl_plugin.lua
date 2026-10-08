--- Client-side part of the Combine Civil Authority plugin, which adds the Combine PDA to the main menu and the action
-- buttons to its player card.
--
-- `AddCombinePDAButons` adds the citizen status, residence, job, points and jail buttons to a `cwCombinePlayerCard`
-- panel. Each one prompts for a value and passes it to a `Handle...` hook, which sends the request to the server over
-- an `Application::PDA::Controller::` netstream.

--- Called when the main menu items are added; adds the Combine PDA for Combine and CWU players.
-- @param menuItems [Map The menu item list, with an `Add` method]
function PLUGIN:MenuItemsAdd(menuItems)
  if Schema:PlayerIsCombine(cw.client) or cw.client:GetFaction() == FACTION_CWU then
    menuItems:Add('#Combine_PDA', 'cwCombinePDA', '#Combine_PDA_Desc', { path = 'fa-mobile', size = 10 })
  end
end

--- Called when a citizen status is picked on a PDA player card; asks the server to set it.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param id [String The status: `Unverified`, `Citizen`, `AntiCitizen` or `NoData`]
function PLUGIN:HandleCitizenStatusButton(panel, id)
  netstream.Start('Application::PDA::Controller::CitizenStatus', panel.player, id)
end

--- Called when a new residence is entered on a PDA player card; asks the server to set it.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param value [String The new residence address]
function PLUGIN:HandleResidenceChangeButton(panel, value)
  netstream.Start('Application::PDA::Controller::Residence', panel.player, value)
end

--- Called when a new job is entered on a PDA player card; asks the server to set it.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param value [String The new job]
function PLUGIN:HandleJobChangeButton(panel, value)
  netstream.Start('Application::PDA::Controller::Job', panel.player, value)
end

--- Called when loyalty points are issued on a PDA player card; asks the server to add them.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param value [Number The points to add]
function PLUGIN:HandleLoyaltyPointsIssue(panel, value)
  netstream.Start('Application::PDA::Controller::LP', panel.player, value)
end

--- Called when crime points are issued on a PDA player card; asks the server to add them.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param value [Number The points to add]
function PLUGIN:HandleCrimePointsIssue(panel, value)
  netstream.Start('Application::PDA::Controller::CP', panel.player, value)
end

--- Called when loyalty points are removed on a PDA player card; asks the server to remove them.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param value [Number The change, as a negative number]
function PLUGIN:HandleLoyaltyPointsSubstract(panel, value)
  netstream.Start('Application::PDA::Controller::LP', panel.player, value, true)
end

--- Called when crime points are removed on a PDA player card; asks the server to remove them.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param value [Number The change, as a negative number]
function PLUGIN:HandleCrimePointsSubstract(panel, value)
  netstream.Start('Application::PDA::Controller::CP', panel.player, value, true)
end

--- Called when work points are issued on a PDA player card; asks the server to add them.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
-- @param value [Number The points to add]
function PLUGIN:HandleJobPointsIssue(panel, value)
  netstream.Start('Application::PDA::Controller::WP', panel.player, value)
end

--- Called when jailing is confirmed on a PDA player card; asks the server to jail the target.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
function PLUGIN:HandleJailButton(panel)
  netstream.Start('Application::PDA::Controller::Jail', panel.player)
end

--- Called when unjailing is confirmed on a PDA player card; asks the server to release the target.
-- @param panel [Panel The `cwCombinePlayerCard` panel; its `player` field is the target]
function PLUGIN:HandleUnjailButton(panel)
  netstream.Start('Application::PDA::Controller::Unjail', panel.player)
end

--- Called when a PDA player card is created; adds the status, residence, job, points and jail buttons.
--
-- Each button opens a prompt and passes the answer to the matching `Handle...` hook through
-- `plugin.Call`. Points and jail buttons are flagged Combine only, and CWU players can only pick
-- the `Unverified` and `Citizen` statuses.
--
-- @param pda [Panel The `cwCombinePlayerCard` panel]
function PLUGIN:AddCombinePDAButons(pda)
  pda:AddButton('status', '#PDA_ChangeCitizenStatus', false, function()
    if Schema:PlayerIsCombine(cw.client) then
      Derma_Query('#Status_Desc', '#Status_Title',
        '#Status_Unverified', function() plugin.Call('HandleCitizenStatusButton', pda, 'Unverified') end,
        '#Status_Citizen', function() plugin.Call('HandleCitizenStatusButton', pda, 'Citizen') end,
        '#Status_AntiCitizen', function() plugin.Call('HandleCitizenStatusButton', pda, 'AntiCitizen') end,
        '#Status_NoData', function() plugin.Call('HandleCitizenStatusButton', pda, 'NoData') end
      )
    else
      Derma_Query('#Status_Desc', '#Status_Title',
        '#Status_Unverified', function() plugin.Call('HandleCitizenStatusButton', pda, 'Unverified') end,
        '#Status_Citizen', function() plugin.Call('HandleCitizenStatusButton', pda, 'Citizen') end
      )
    end
  end)

  pda:AddButton('residence', '#PDA_ChangeResidence', false, function()
    Derma_StringRequest('#Residence_Title', '#Residence_Desc', Schema:GetResidence(pda.player),
    function(text) plugin.Call('HandleResidenceChangeButton', pda, text) end, nil, '#OK', '#Cancel')
  end)

  pda:AddButton('job', '#PDA_ChangeJob', false, function()
    Derma_StringRequest('#Job_Title', '#Job_Desc', Schema:GetJob(pda.player),
    function(text) plugin.Call('HandleJobChangeButton', pda, text) end, nil, '#OK', '#Cancel')
  end)

  pda:AddButton('jobpoints', '#PDA_CWUPoints', false, function()
    Derma_NumRequest('#PDA_CWUPoints', '#PDA_IssuePointsDesc', 0, 0, 20, 0,
    function(value) plugin.Call('HandleJobPointsIssue', pda, value) end, nil, '#OK', '#Cancel')
  end)

  pda:AddButton('loyalty', '#PDA_LP', true, function()
    Derma_NumRequest('#PDA_LP', '#PDA_IssuePointsDesc', 0, 0, 10, 0,
    function(value) plugin.Call('HandleLoyaltyPointsIssue', pda, value) end, nil, '#OK', '#Cancel')
  end)

  pda:AddButton('crime', '#PDA_CP', true, function()
    Derma_NumRequest('#PDA_CP', '#PDA_IssuePointsDesc', 0, 0, 20, 0,
    function(value) plugin.Call('HandleCrimePointsIssue', pda, value) end, nil, '#OK', '#Cancel')
  end)

  pda:AddButton('sub_loyalty', '#PDA_SubLP', true, function()
    Derma_NumRequest('#PDA_SubLP', '#PDA_RemovePointsDesc', 0, 0, 10, 0,
    function(value) plugin.Call('HandleLoyaltyPointsSubstract', pda, -value) end, nil, '#OK', '#Cancel')
  end)

  pda:AddButton('sub_crime', '#PDA_SubCP', true, function()
    Derma_NumRequest('#PDA_SubCP', '#PDA_RemovePointsDesc', 0, 0, 20, 0,
    function(value) plugin.Call('HandleCrimePointsSubstract', pda, -value) end, nil, '#OK', '#Cancel')
  end)

  pda:AddButton('jail', '#PDA_Jail', true, function()
    Derma_Query('#PDA_JailConfirm', '#PDA_Jail',
      '#OK', function() plugin.Call('HandleJailButton', pda) end,
      '#Cancel', function() end
    )
  end)

  pda:AddButton('unjail', '#PDA_Unjail', true, function()
    Derma_Query('#PDA_UnjailConfirm', '#PDA_Unjail',
      '#OK', function() plugin.Call('HandleUnjailButton', pda) end,
      '#Cancel', function() end
    )
  end)
end

netstream.Hook('CCA::Response::Update', function()
  if IsValid(Schema.pdaPanel) and IsValid(Schema.pdaPanel.playerCard) then
    Schema.pdaPanel.playerCard:Rebuild()
  end
end)
