--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local GROUP_SUPER = 1
local GROUP_ADMIN = 2
local GROUP_OPER = 3
local GROUP_USER = 4

if (CLIENT) then
	local SYSTEM = cw.system:New("Manage Groups")
	SYSTEM.toolTip = "A way to manage all administration groups."
	SYSTEM.groupType = GROUP_USER
	SYSTEM.groupPage = 1
	SYSTEM.groupPlayers = nil
	SYSTEM.doesCreateForm = false

	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		if (!config.Get("use_own_group_system"):Get()) then
			local commandTable = cw.command:FindByID("PlySetGroup")

			if (commandTable and cw.player:HasFlags(cw.client, commandTable.access)) then
				return true
			end
		end
	end

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		if (self.groupType == GROUP_USER) then
			local label = vgui.Create("cwInfoText", systemPanel)
				label:SetText("Selecting a user group will bring up a list of users in that group.")
				label:SetInfoColor("blue")
				label:DockMargin(0, 0, 0, 8)
			systemPanel.panelList:AddItem(label)

			local userGroupsForm = vgui.Create("DForm", systemPanel)
				userGroupsForm:SetName("User Groups")
				userGroupsForm:SetPadding(4)
			systemPanel.panelList:AddItem(userGroupsForm)

			local userGroups = {"Super Admins", "Administrators", "Operators"}

			for k, v in pairs(userGroups) do
				local groupButton = vgui.Create("DButton", systemPanel)
					groupButton:SetTooltip("Manage users within the "..v.." user group.")
					groupButton:SetText(v)
					groupButton:SetWide(systemPanel:GetParent():GetWide())

					-- Called when the button is clicked.
					function groupButton.DoClick(button)
						self.groupPlayers = nil
						self.groupType = k
						self:Rebuild()
					end
				userGroupsForm:AddItem(groupButton)
			end
		else
			local backButton = vgui.Create("DButton", systemPanel)
				backButton:SetText("Back to User Groups")
				backButton:SetWide(systemPanel:GetParent():GetWide())

				-- Called when the button is clicked.
				function backButton.DoClick(button)
					self.groupType = GROUP_USER
					self:Rebuild()
				end
			systemPanel.navigationForm:AddItem(backButton)

			if (!self.noRefresh) then
				netstream.Start("SystemGroupGet", {self.groupType, self.groupPage})
			else
				self.noRefresh = nil
			end

			if (self.groupPlayers) then
				if (#self.groupPlayers > 0) then
					for k, v in pairs(self.groupPlayers) do
						local label = vgui.Create("cwInfoText", systemPanel)
							label:SetText(v.steamName)
							label:SetButton(true)
							label:SetTooltip("This player's Steam ID is "..v.steamID..".")
							label:SetInfoColor("blue")
						systemPanel.panelList:AddItem(label)

						-- Called when the button is clicked.
						function label.DoClick(button)
							local commandTable = cw.command:FindByID("PlyDemote")

							if (commandTable and cw.player:HasFlags(cw.client, commandTable.access)) then
								Derma_Query("Are you sure that you want to demote "..v.steamName.."?", "Demote "..v.steamName..".", "Yes", function()
									netstream.Start("SystemGroupDemote", {v.steamID, v.steamName, self.groupType})
								end, "No", function() end)
							end
						end
					end

					if (self.pageCount > 1) then
						local pageForm = vgui.Create("DForm", systemPanel)
							pageForm:SetName("Page "..self.groupPage.."/"..self.pageCount)
							pageForm:SetPadding(4)
						systemPanel.panelList:AddItem(pageForm)

						if (self.isNext) then
							local nextButton = pageForm:Button("Next")

							-- Called when the button is clicked.
							function nextButton.DoClick(button)
								netstream.Start("SystemGroupGet", {self.groupType, self.groupPage + 1})
							end
						end

						if (self.isBack) then
							local backButton = pageForm:Button("Back")

							-- Called when the button is clicked.
							function backButton.DoClick(button)
								netstream.Start("SystemGroupGet", {self.groupType, self.groupPage - 1})
							end
						end
					end
				else
					local label = vgui.Create("cwInfoText", systemPanel)
						label:SetText("There are no users to display in this group.")
						label:SetInfoColor("orange")
					systemPanel.panelList:AddItem(label)
				end
			else
				local label = vgui.Create("cwInfoText", systemPanel)
					label:SetText("Hold on while the group users are retrieved...")
					label:SetInfoColor("blue")
				systemPanel.panelList:AddItem(label)
			end
		end
	end

	SYSTEM:Register()

	netstream.Hook("SystemGroupRebuild", function(data)
		local systemTable = cw.system:FindByID("Manage Groups")

		if (systemTable and systemTable:IsActive()) then
			systemTable:Rebuild()
		end
	end)

	netstream.Hook("SystemGroupGet", function(data)
		if (type(data) == "table") then
			local systemTable = cw.system:FindByID("Manage Groups")

			if (systemTable) then
				systemTable.groupPlayers = data.players
				systemTable.groupPage = data.page
				systemTable.pageCount = data.pageCount
				systemTable.noRefresh = true
				systemTable.isBack = data.isBack
				systemTable.isNext = data.isNext
				systemTable:Rebuild()
			end
		else
			local systemTable = cw.system:FindByID("Manage Groups")

			if (systemTable) then
				systemTable.groupPlayers = {}
				systemTable.groupPage = 1
				systemTable.noRefresh = true

				if (systemTable:IsActive()) then
					systemTable:Rebuild()
				end
			end
		end
	end)
else
	netstream.Hook("SystemGroupDemote", function(player, data)
		local commandTable = cw.command:FindByID("PlyDemote")

		if (commandTable and type(data) == "table"
		and cw.player:HasFlags(player, commandTable.access)) then
			local target = _player.Find(data[1])

			if (target) then
				cw.player:RunClockworkCommand(player, "PlyDemote", data[1])

				timer.Simple(1, function()
					if (IsValid(player)) then
						netstream.Start(player, "SystemGroupRebuild", true)
					end
				end)
			else
				local schemaFolder = cw.core:GetSchemaFolder()
				local playersTable = config.Get("mysql_players_table"):Get()
				local cwUserGroup = "user"

				if (data[3] == GROUP_SUPER) then
					cwUserGroup = "superadmin"
				elseif (data[3] == GROUP_ADMIN) then
					cwUserGroup = "admin"
				elseif (data[3] == GROUP_OPER) then
					cwUserGroup = "operator"
				end

				local queryObj = cw.database:Update(playersTable)
					queryObj:Update("_UserGroup", "user")
					queryObj:Where("_Schema", schemaFolder)
					queryObj:Where("_SteamID", data[1])
					queryObj:Callback(function(result)
						netstream.Start(player, "SystemGroupRebuild", true)
					end)
				queryObj:Execute()

				cw.player:NotifyAll(player:Name().." has demoted "..data[2].." from "..cwUserGroup.." to user.")
			end
		end
	end)

	netstream.Hook("SystemGroupGet", function(player, data)
		if (type(data) != "table") then
			return
		end

		local groupType = tonumber(data[1])
		local groupPage = tonumber(data[2])

		if (groupPage) then
			local groupPlayers = {}
			local sendPlayers = {}
			local finishIndex = groupPage * 8
			local startIndex = finishIndex - 7
			local groupName = "user"
			local pageCount = 0

			if (groupType == GROUP_SUPER) then
				groupName = "superadmin"
			elseif (groupType == GROUP_ADMIN) then
				groupName = "admin"
			elseif (groupType == GROUP_OPER) then
				groupName = "operator"
			end

			local schemaFolder = cw.core:GetSchemaFolder()
			local playersTable = config.Get("mysql_players_table"):Get()
			local queryObj = cw.database:Select(playersTable)
				queryObj:Callback(function(result)
					if (cw.database:IsResult(result)) then
						for k, v in pairs(result) do
							groupPlayers[#groupPlayers + 1] = {
								steamName = v._SteamName,
								steamID = v._SteamID
							}
						end
					end

					table.sort(groupPlayers, function(a, b)
						return a.steamName < b.steamName
					end)

					pageCount = math.ceil(#groupPlayers / 8)

					for k, v in pairs(groupPlayers) do
						if (k >= startIndex and k <= finishIndex) then
							sendPlayers[#sendPlayers + 1] = v
						end
					end

					if (#sendPlayers > 0) then
						netstream.Start(player, "SystemGroupGet", {
							pageCount = pageCount,
							players = sendPlayers,
							isNext = (groupPlayers[finishIndex + 1] != nil),
							isBack = (groupPlayers[startIndex - 1] != nil),
							page = groupPage
						})
					else
						netstream.Start(player, "SystemGroupGet", false)
					end
				end)

				queryObj:Where("_Schema", schemaFolder)
				queryObj:Where("_UserGroup", groupName)
			queryObj:Execute()
		end
	end)
end
