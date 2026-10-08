--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

if cw.directory then return end

library.New('directory', cw)

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
-- proofreader-disable Layout/LineLength -- embedded CSS
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
-- proofreader-enable Layout/LineLength

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

--- Returns a directory category.
-- @param category [String Name of the category]
-- @return [Map The category table (`category`, `pageData`, `parent`...), Number Its index in
-- `cw.directory.stored`; both `nil` if the category does not exist]
function cw.directory:GetCategory(category)
  for k, v in pairs(self.stored) do
    if v.category == category then
      return v, k
    end
  end
end

--- Adds a text replacement applied to a category's HTML when it is shown.
--
-- ```
-- cw.directory:AddCategoryMatch('Flags', '[icon]', 'materials/icon16/flag_blue.png')
-- ```
--
-- @param category [String Name of the category]
-- @param sFind [String Text to look for, such as `'[icon]'`]
-- @param sReplace [String Text to put in its place]
-- @see cw.directory:ReplaceMatches
function cw.directory:AddCategoryMatch(category, sFind, sReplace)
  if !self.matches[category] then
    self.matches[category] = {}
  end

  self.matches[category][sFind] = sReplace
end

--- Applies a category's text replacements to some HTML.
-- @param category [String Name of the category]
-- @param htmlCode [String HTML to change]
-- @return [String The HTML with every match replaced]
-- @see cw.directory:AddCategoryMatch
function cw.directory:ReplaceMatches(category, htmlCode)
  if !self.matches[category] then return htmlCode end

  for k, v in pairs(self.matches[category]) do
    htmlCode = cw.core:Replace(htmlCode, k, v)
  end

  return htmlCode
end

--- Sets the tooltip shown on a category in the directory tree.
-- @param category [String Name of the category]
-- @param tip [String Tooltip text]
function cw.directory:SetCategoryTip(category, tip)
  self.tips[category] = tip
end

--- Returns the tooltip of a category.
-- @param category [String Name of the category]
-- @return [String The tooltip, or `nil` if none is set]
function cw.directory:GetCategoryTip(category)
  return self.tips[category]
end

--- Adds a category made of a single HTML page or website.
--
-- Combines `cw.directory:AddCategory` and `cw.directory:AddPage`.
-- @param category [String Name of the category]
-- @param parent [String Name of the parent category, or `nil` for a top level category]
-- @param htmlCode [String HTML of the page, or its URL when `isWebsite` is set]
-- @param isWebsite=nil [Boolean Whether `htmlCode` is a URL to open]
function cw.directory:AddCategoryPage(category, parent, htmlCode, isWebsite)
  self:AddCategory(category, parent)
  self:AddPage(category, htmlCode, isWebsite)
end

--- Sets the name a category is displayed with in the directory tree.
--
-- Category names are identifiers, so this is where language phrases go.
-- @param category [String Name of the category]
-- @param name [String Displayed name, or a language phrase]
function cw.directory:SetFriendlyName(category, name)
  self.friendlyNames[category] = name
end

--- Returns the name a category is displayed with.
-- @param category [String Name of the category]
-- @return [String The friendly name, or `category` if none is set]
function cw.directory:GetFriendlyName(category)
  return self.friendlyNames[category] or category
end

--- Sets the HTML every directory page is wrapped in.
--
-- `[information]` in it is replaced with the page's content.
-- @param htmlCode [String The master HTML, usually with the page's `<head>` and styles]
function cw.directory:SetMasterFormatting(htmlCode)
  self.formatMaster = htmlCode
end

--- Returns the HTML every directory page is wrapped in.
-- @return [String The master HTML]
function cw.directory:GetMasterFormatting()
  return self.formatMaster
end

--- Sets the HTML a category's content is wrapped in.
--
-- `[information]` in it is replaced with the joined pages, `[category]` with the
-- category name.
-- @param category [String Name of the category]
-- @param htmlCode [String The category HTML]
-- @param noLineBreaks=false [Boolean Whether pages are joined without `<br>` between them]
-- @param noMasterFormatting=false [Boolean Stored with the formatting as `noMasterFormatting`]
function cw.directory:SetCategoryFormatting(category, htmlCode, noLineBreaks, noMasterFormatting)
  self.formatting[category] = {
    noMasterFormatting = (noMasterFormatting == true),
    noLineBreaks = (noLineBreaks == true),
    htmlCode = htmlCode
  }
end

--- Returns the formatting of a category.
-- @param category [String Name of the category]
-- @return [Map The formatting (`htmlCode`, `noLineBreaks`, `noMasterFormatting`), or
-- `cw.directory.formatDefault` if none is set]
function cw.directory:GetCategoryFormatting(category)
  return self.formatting[category] or self.formatDefault
end

--- Sets how the pages of a category are sorted.
-- @param category [String Name of the category]
-- @param Callback [Function `table.sort` comparator called with two page data tables
-- (`htmlCode`, `sortData`...)]
function cw.directory:SetCategorySorting(category, Callback)
  self.sorting[category] = Callback
end

--- Returns the page comparator of a category.
-- @param category [String Name of the category]
-- @return [Function The comparator, or `nil` if the pages are not sorted]
function cw.directory:GetCategorySorting(category)
  return self.sorting[category]
end

--- Returns whether a directory category exists.
-- @param category [String Name of the category]
-- @return [Boolean `true` if it exists, `nil` otherwise]
function cw.directory:CategoryExists(category)
  for k, v in pairs(self.stored) do
    if v.category == category then
      return true
    end
  end
end

--- Adds a directory category, or moves an existing one under a new parent.
--
-- The parent category is created if it does not exist. Does nothing once the
-- client has finished booting.
-- @param category [String Name of the category]
-- @param parent=nil [String Name of the parent category; `false` adds the category without
-- changing the parent of an existing one]
-- @return [String The category name, String The parent name]
function cw.directory:AddCategory(category, parent)
  if _G['ClockworkClientsideBooted'] then return end

  if parent then
    self:AddCategory(parent, false)
  end

  if !self:CategoryExists(category) then
    if parent == false then parent = nil end

    self.stored[#self.stored + 1] = {
      category = category,
      pageData = {},
      parent = parent
    }
  elseif parent != false then
    for k, v in pairs(self.stored) do
      if v.category == category then
        v.parent = parent
      end
    end
  end

  return category, parent
end

--- Adds a page of HTML to a category, creating the category if needed.
--
-- Rebuilds the directory panel if it is open. Does nothing once the client has
-- finished booting.
--
-- ```
-- cw.directory:AddCode('Flags', '<tr><td>[details]</td></tr>', nil, flag, function(htmlCode, sortData)
--   return string.Replace(htmlCode, '[details]', L(details))
-- end)
-- ```
--
-- @param category [String Name of the category]
-- @param htmlCode [String HTML of the page]
-- @param noLineBreak=nil [Boolean Whether no `<br>` is put before this page]
-- @param sortData=nil [Any Value used by the category's sorting function and passed to `Callback`]
-- @param Callback=nil [Function Called with the HTML and `sortData` when the page is shown;
-- returns the HTML to show]
-- @return [Number ID of the page within the category, for `cw.directory:RemoveCode`]
function cw.directory:AddCode(category, htmlCode, noLineBreak, sortData, Callback)
  if _G['ClockworkClientsideBooted'] then return end

  self:AddCategory(category, false)

  local categoryTable = self:GetCategory(category)
  local uniqueID = nil
  local panel = self:GetPanel()

  if categoryTable then
    categoryTable.pageData[#categoryTable.pageData + 1] = {
      noLineBreak = noLineBreak,
      sortData = sortData,
      Callback = Callback,
      htmlCode = htmlCode
    }

    uniqueID = #categoryTable.pageData
  end

  if panel then
    panel:Rebuild()
  end

  return uniqueID
end

--- Removes a page from a category, or the whole category.
--
-- Removing the last page also removes the category. Rebuilds the directory
-- panel if it is open. Does nothing once the client has finished booting.
-- @param category [String Name of the category]
-- @param uniqueID=nil [Number ID returned by `cw.directory:AddCode`; when `nil` the category is removed]
-- @param forceRemove=nil [Boolean Whether to skip the check for child categories; the check does not
-- currently keep a category with children, so it is removed either way]
function cw.directory:RemoveCode(category, uniqueID, forceRemove)
  if _G['ClockworkClientsideBooted'] then return end

  local panel = self:GetPanel()

  if category then
    local categoryTable, categoryKey = self:GetCategory(category)

    if categoryTable then
      if uniqueID and !categoryTable.isHTML then
        if categoryTable.pageData[uniqueID] then
          categoryTable.pageData[uniqueID] = nil
        end

        if #categoryTable.pageData == 0 then
          self:RemoveCode(category)
        end
      else
        local removeCategory = true

        if !forceRemove and !categoryTable.isHTML then
          for k, v in pairs(self.stored) do
            if v.parent == category then
              removeCategory = true

              break
            end
          end
        end

        if removeCategory then
          self.stored[categoryKey] = nil
        end
      end
    end
  end

  if panel then
    panel:Rebuild()
  end
end

--- Sets a category's content to a single HTML page or website, creating the category if needed.
--
-- Rebuilds the directory panel if it is open. Does nothing once the client has
-- finished booting.
-- @param category [String Name of the category]
-- @param htmlCode [String HTML of the page, or its URL when `isWebsite` is set]
-- @param isWebsite=nil [Boolean Whether `htmlCode` is a URL to open]
function cw.directory:AddPage(category, htmlCode, isWebsite)
  if _G['ClockworkClientsideBooted'] then return end

  self:AddCategory(category, false)

  local categoryTable = self:GetCategory(category)
  local panel = self:GetPanel()

  if categoryTable then
    categoryTable.isWebsite = isWebsite
    categoryTable.pageData = htmlCode
    categoryTable.isHTML = true
  end

  if panel then
    panel:Rebuild()
  end
end

--- Returns the directory menu panel.
-- @return [Panel The panel, or `nil` if it has not been created]
function cw.directory:GetPanel()
  return self.panel
end

-- The category names are used as identifiers, so only their displayed names are language phrases.
cw.directory:SetFriendlyName('Commands', '#Directory_Commands')
cw.directory:SetFriendlyName('Plugins', '#Directory_Plugins')
cw.directory:SetFriendlyName('Flags', '#Directory_Flags')
cw.directory:SetFriendlyName('Voice Commands', '#Directory_VoiceCommands')

cw.directory:SetCategorySorting('Commands', function(a, b)
  return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode)
end)

cw.directory:SetCategorySorting('Plugins', function(a, b)
  return (a.sortData or a.htmlCode) < (b.sortData or b.htmlCode)
end)

cw.directory:SetCategorySorting('Flags', function(a, b)
  local hasA = cw.player:HasFlags(cw.client, a.sortData)
  local hasB = cw.player:HasFlags(cw.client, b.sortData)

  if hasA and hasB then
    return a.sortData < b.sortData
  elseif hasA then
    return true
  else
    return false
  end
end)

cw.directory:SetCategoryFormatting('Flags', [[
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
