--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

if (cw.directory) then return end

library.New("directory", cw)

cw.directory.friendlyNames = cw.directory.friendlyNames or {}
cw.directory.formatting = cw.directory.formatting or {}
cw.directory.sorting = cw.directory.sorting or {}
cw.directory.matches = cw.directory.matches or {}
cw.directory.stored = cw.directory.stored or {}
cw.directory.tips = cw.directory.tips or {}

--[[
	A good idea for the master formatting, is to ensure the existance of default CSS classes.
	You can still customize them for use, though.
--]]
local MASTER_FORMATTING = [[
	<head>
		<style type="text/css">
			@import (http://fonts.googleapis.com/css?family=Quicksand:400,300)

			body{font-family:Verdana, Arial, sans-serif;background:#222;font-size:14px;}
			.cwContentBox{transition:background 500ms;-o-transition:background 500ms;-moz-transition:background 500ms;-webkit-transition:background;-o-transition-timing-function:ease-out;-moz-transition-timing-function:ease-out;-webkit-transition-timing-function:ease-out;-webkit-transition-duration:500ms;-webkit-user-select:none;background:#222;font-family:Quicksand, Verdana, Arial, sans-serif;margin-bottom:32px;color:#FFF;padding:8px}
			.cwContentTitle{color:#9ed838;font-size:18px;margin:8px 0px 16px 0px;}
			.cwTitleSeperator{text-decoration:none;color:#f1aa2f;}
			.cwTableHeader{text-decoration:none;color:#f1aa2f;}
			.cwTableMain{color:#FFF;}
		</style>
	</head>
	<body>
		[information]
	</body>
]]

--[[ Set up the default formatting for directory pages. --]]
local DEFAULT_FORMATTING = [[
	<div class="cwContentBox">
		<div class="cwContentTitle">
			<img src="[icon]"/>[category]
		</div>
		[information]
	</div>
]]

cw.directory.formatMaster = cw.directory.formatMaster or MASTER_FORMATTING
cw.directory.formatDefault = {
	noMasterFormatting = false,
	noLineBreaks = false,
	htmlCode = DEFAULT_FORMATTING
}

-- A function to get a category.
function cw.directory:GetCategory(category)
	for k, v in pairs(self.stored) do
		if (v.category == category) then
			return v, k
		end
	end
end

-- A function to add a category match.
function cw.directory:AddCategoryMatch(category, sFind, sReplace)
	if (!self.matches[category]) then
		self.matches[category] = {}
	end

	self.matches[category][sFind] = sReplace
end

-- A function to replace a category's matches.
function cw.directory:ReplaceMatches(category, htmlCode)
	if (!self.matches[category]) then return htmlCode; end

	for k, v in pairs(self.matches[category]) do
		htmlCode = cw.core:Replace(htmlCode, k, v)
	end

	return htmlCode
end

-- A function to set a category tip.
function cw.directory:SetCategoryTip(category, tip)
	self.tips[category] = tip
end

-- A function to get a category tip.
function cw.directory:GetCategoryTip(category)
	return self.tips[category]
end

-- A function to add a category page.
function cw.directory:AddCategoryPage(category, parent, htmlCode, isWebsite)
	self:AddCategory(category, parent)
	self:AddPage(category, htmlCode, isWebsite)
end

-- A function to set a friendly name.
function cw.directory:SetFriendlyName(category, name)
	self.friendlyNames[category] = name
end

-- A function to get a friendly name.
function cw.directory:GetFriendlyName(category)
	return self.friendlyNames[category] or category
end

-- A function to set the master formatting.
function cw.directory:SetMasterFormatting(htmlCode)
	self.formatMaster = htmlCode
end

-- A function to get the master formatting.
function cw.directory:GetMasterFormatting()
	return self.formatMaster
end

-- A function to set category formatting.
function cw.directory:SetCategoryFormatting(category, htmlCode, noLineBreaks, noMasterFormatting)
	self.formatting[category] = {
		noMasterFormatting = (noMasterFormatting == true),
		noLineBreaks = (noLineBreaks == true),
		htmlCode = htmlCode
	}
end

-- A function to get category formatting.
function cw.directory:GetCategoryFormatting(category)
	return self.formatting[category] or self.formatDefault
end

-- A function to set category sorting.
function cw.directory:SetCategorySorting(category, Callback)
	self.sorting[category] = Callback
end

-- A function to get category sorting.
function cw.directory:GetCategorySorting(category)
	return self.sorting[category]
end

-- A function to get whether a category exists.
function cw.directory:CategoryExists(category)
	for k, v in pairs(self.stored) do
		if (v.category == category) then
			return true
		end
	end
end

-- A function to add a category.
function cw.directory:AddCategory(category, parent)
	if (_G["ClockworkClientsideBooted"]) then return end

	if (parent) then
		self:AddCategory(parent, false)
	end

	if (!self:CategoryExists(category)) then
		if (parent == false) then parent = nil; end

		self.stored[#self.stored + 1] = {
			category = category,
			pageData = {},
			parent = parent
		}
	elseif (parent != false) then
		for k, v in pairs(self.stored) do
			if (v.category == category) then
				v.parent = parent
			end
		end
	end

	return category, parent
end

-- A function to add some code.
function cw.directory:AddCode(category, htmlCode, noLineBreak, sortData, Callback)
	if (_G["ClockworkClientsideBooted"]) then return end

	self:AddCategory(category, false)

	local categoryTable = self:GetCategory(category)
	local uniqueID = nil
	local panel = self:GetPanel()

	if (categoryTable) then
		categoryTable.pageData[#categoryTable.pageData + 1] = {
			noLineBreak = noLineBreak,
			sortData = sortData,
			Callback = Callback,
			htmlCode = htmlCode
		}

		uniqueID = #categoryTable.pageData
	end

	if (panel) then
		panel:Rebuild()
	end

	return uniqueID
end

-- A function to remove some code.
function cw.directory:RemoveCode(category, uniqueID, forceRemove)
	if (_G["ClockworkClientsideBooted"]) then return end

	local panel = self:GetPanel()

	if (category) then
		local categoryTable, categoryKey = self:GetCategory(category)

		if (categoryTable) then
			if (uniqueID and !categoryTable.isHTML) then
				if (categoryTable.pageData[uniqueID]) then
					categoryTable.pageData[uniqueID] = nil
				end

				if (#categoryTable.pageData == 0) then
					self:RemoveCode(category)
				end
			else
				local removeCategory = true

				if (!forceRemove and !categoryTable.isHTML) then
					for k, v in pairs(self.stored) do
						if (v.parent == category) then
							removeCategory = true

							break
						end
					end
				end

				if (removeCategory) then
					self.stored[categoryKey] = nil
				end
			end
		end
	end

	if (panel) then
		panel:Rebuild()
	end
end

-- A function to add a page.
function cw.directory:AddPage(category, htmlCode, isWebsite)
	if (_G["ClockworkClientsideBooted"]) then return end

	self:AddCategory(category, false)

	local categoryTable = self:GetCategory(category)
	local panel = self:GetPanel()

	if (categoryTable) then
		categoryTable.isWebsite = isWebsite
		categoryTable.pageData = htmlCode
		categoryTable.isHTML = true
	end

	if (panel) then
		panel:Rebuild()
	end
end

-- A function to get the directory panel.
function cw.directory:GetPanel()
	return self.panel
end

cw.directory:SetCategorySorting("Commands", function(a, b)
	return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode)
end)

cw.directory:SetCategorySorting("Plugins", function(a, b)
	return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode)
end)

cw.directory:SetCategorySorting("Flags", function(a, b)
	local hasA = cw.player:HasFlags(cw.client, a.sortData)
	local hasB = cw.player:HasFlags(cw.client, b.sortData)

	if (hasA and hasB) then
		return a.sortData < b.sortData
	elseif (hasA) then
		return true
	else
		return false
	end
end)

cw.directory:SetCategoryFormatting("Flags", [[
	<div class="cwContentBox">
		<div class="cwContentTitle">
			<img src="[icon]"/>Flags
		</div>
		<table class="cwTableMain">
			<tr>
				<td class="cwTableHeader">Flag</td>
				<td class="cwTableHeader">Details</td>
			</tr>
			[information]
		</table>
	</div>
]], true)
