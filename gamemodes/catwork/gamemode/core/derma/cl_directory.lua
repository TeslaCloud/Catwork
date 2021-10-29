--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

	self.treeNode = vgui.Create("DTree", self)
	self.treeNode:SetPadding(2)
	self.htmlPanel = vgui.Create("HTML", self)

	cw.directory.panel = self
	cw.directory.panel.categoryHistory = {}

	self:Rebuild()
end

-- Called to by the menu to get the width of the panel.
function PANEL:GetMenuWidth()
	return ScrW() * 0.5
end

local PAGE_ICON = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAINSURBVBgZBcG/r55zGAfg6/4+z3va01NHlYgzEfE7MdCIGISFgS4Gk8ViYyM2Mdlsko4GSf8Do0FLRCIkghhYJA3aVBtEz3nP89wf11VJvPDepdd390+8Nso5nESBQoq0pfvXm9fzWf19453LF85vASqJlz748vInb517dIw6EyYBIIG49u+xi9/c9MdvR//99MPPZ7+4cP4IZhhTPbwzT2d+vGoaVRRp1rRliVvHq+cfvM3TD82+7mun0o/ceO7NT+/4/KOXjwZU1ekk0840bAZzMQ2mooqh0A72d5x/6sB9D5zYnff3PoYBoWBgFKPKqDKqjCpjKr//dcu9p489dra88cydps30KswACfNEKanSaxhlntjJ8Mv12Paie+vZ+0+oeSwwQ0Iw1xAR1CiFNJkGO4wu3ZMY1AAzBI0qSgmCNJsJUEOtJSMaCTBDLyQ0CknAGOgyTyFFiLI2awMzdEcSQgSAAKVUmAeNkxvWJWCGtVlDmgYQ0GFtgg4pNtOwbBcwQy/Rife/2yrRRVI0qYCEBly8Z+P4qMEMy7JaVw72N568e+iwhrXoECQkfH91kY7jwwXMsBx1L93ZruqrK6uuiAIdSnTIKKPLPFcvay8ww/Hh+ufeznTXu49v95IMoQG3784gYXdTqvRmqn/Wpa/ADFX58MW3L71SVU9ETgEIQQQIOOzub+fhIvwPRDgeVjWDahIAAAAASUVORK5CYII="

-- A function to show a directory category.
function PANEL:ShowCategory(category)
	if (!category) then
		local masterFormatting = cw.directory:GetMasterFormatting()
		local finalCode = [[
			<div class="cwContentBox">
				<div class="cwContentTitle">
					<img src="]]..PAGE_ICON..[["/>Select a Category
				</div>
				<div class="cwContentText">
					Some categories may only be available to users with special priviledges.
				</div>
			</div>
		]]

		if (masterFormatting) then
			finalCode = cw.core:Replace(masterFormatting, "[information]", finalCode)
		end

		finalCode = cw.core:Replace(
			finalCode, "[category]", cw.option:GetKey("name_directory")
		)

		finalCode = cw.core:Replace(
			finalCode, "{category}", cw.option:GetKey("name_directory"):upper()
		)

		finalCode = cw.core:ParseData(finalCode)
		self.htmlPanel:SetHTML(finalCode)
	else
		local categoryTable = cw.directory:GetCategory(category)

		if (categoryTable) then
			if (!categoryTable.isHTML) then
				local newPageData = {}

				for k, v in pairs(categoryTable.pageData) do
					newPageData[#newPageData + 1] = v
				end

				local sorting = cw.directory:GetCategorySorting(category)

				if (sorting) then
					table.sort(newPageData, sorting)
				end

				if (table.Count(newPageData) > 0) then
					local masterFormatting = cw.directory:GetMasterFormatting()
					local formatting = cw.directory:GetCategoryFormatting(category)
					local bFirstKey = true
					local finalCode = ""

					for k, v in pairs(newPageData) do
						local htmlCode = v.htmlCode

						if (type(v.Callback) == "function") then
							htmlCode = v.Callback(htmlCode, v.sortData)
						end

						if (htmlCode and htmlCode != "") then
							if (!bFirstKey) then
								if ((!formatting or !formatting.noLineBreaks)
								and !v.noLineBreak) then
									finalCode = finalCode.."<br>"..htmlCode
								else
									finalCode = finalCode..htmlCode
								end
							else
								finalCode = htmlCode
							end

							bFirstKey = false
						end
					end

					if (formatting) then
						finalCode = cw.core:Replace(formatting.htmlCode, "[information]", finalCode)
					end

					if (masterFormatting) then
						finalCode = cw.core:Replace(masterFormatting, "[information]", finalCode)
					end

					finalCode = cw.directory:ReplaceMatches(category, finalCode)
						finalCode = cw.core:Replace(finalCode, "[category]", category)
						finalCode = cw.core:Replace(finalCode, "{category}", string.upper(category))
					finalCode = cw.core:ParseData(finalCode)

					self.htmlPanel:SetHTML(finalCode)
				end
			elseif (!categoryTable.isWebsite) then
				local masterFormatting = cw.directory:GetMasterFormatting()
				local formatting = cw.directory:GetCategoryFormatting(category)
				local finalCode = categoryTable.pageData

				if (formatting) then
					finalCode = cw.core:Replace(formatting.htmlCode, "[information]", finalCode)
				end

				if (masterFormatting) then
					finalCode = cw.core:Replace(masterFormatting, "[information]", finalCode)
				end

				finalCode = cw.directory:ReplaceMatches(category, finalCode)
					finalCode = cw.core:Replace(finalCode, "[category]", category)
					finalCode = cw.core:Replace(finalCode, "{category}", string.upper(category))
				finalCode = cw.core:ParseData(finalCode)

				self.htmlPanel:SetHTML(finalCode)
			else
				self.htmlPanel:OpenURL(categoryTable.pageData)
			end
		end
	end
end

-- A function to clear the nodes.
function PANEL:ClearNodes()
	if (self.treeNode.Items) then
		for k, v in pairs(self.treeNode.Items) do
			if (IsValid(v)) then v:Remove(); end
		end
	end

	self.treeNode.m_pSelectedItem = nil
	self.treeNode.Items = {}
end

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if (!CW_REBUILDING_DIRECTORY) then
		self:ClearNodes()

		CW_REBUILDING_DIRECTORY = true
			hook.Run("ClockworkDirectoryRebuilt", self)
		CW_REBUILDING_DIRECTORY = nil

		cw.core:ValidateTableKeys(cw.directory.stored)

		table.sort(cw.directory.stored, function(a, b)
			return a.category < b.category
		end)

		local nodeTable = {}

		for k, v in pairs(cw.directory.stored) do
			if (!v.parent) then
				nodeTable[v.category] = self.treeNode:AddNode(v.category)
			end
		end

		for k, v in pairs(cw.directory.stored) do
			if (v.parent and nodeTable[v.parent]) then
				nodeTable[v.category] = nodeTable[v.parent]:AddNode(v.category)
			elseif (!nodeTable[v.category]) then
				nodeTable[v.category] = self.treeNode:AddNode(v.category)
			end

			if (!nodeTable[v.category].Initialized) then
				local friendlyName = cw.directory:GetFriendlyName(v.category)
				local tip = cw.directory:GetCategoryTip(v.category)

				if (tip) then
					nodeTable[v.category]:SetTooltip(tip)
				end

				nodeTable[v.category].Initialized = true
				nodeTable[v.category]:SetText(friendlyName)
				nodeTable[v.category].DoClick = function(node)
					for k2, v2 in pairs(cw.directory.stored) do
						if (v2.category == v.category and (v2.isWebsite
						or v2.isHTML or #v2.pageData > 0)) then
							self.currentCategory = v.category
							self:ShowCategory(self.currentCategory)

							break
						end
					end
				end
			end
		end

		self:ShowCategory(self.currentCategory)
	end
end

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self:SetSize(w, ScrH() * 0.75)
	self.treeNode:SetPos(4, 4)
	self.treeNode:SetSize(w * 0.25, h - 8)
	self.htmlPanel:SetPos((w * 0.25) + 8, 4)
	self.htmlPanel:SetSize((w * 0.75) - 16, h - 8)
end

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	cdraw.DrawBox(0, 0, w, h, COLOR_WHITE)
	return true
end

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true)
end

vgui.Register("cwDirectory", PANEL, "EditablePanel");
