--- Defines the client-side `cw.character` library, which runs the character menu and the character creation process.
--
-- It holds the local player's characters and faction whitelists as sent by the server and the creation steps
-- registered with `cw.character:RegisterCreationPanel`. The rest opens, closes and navigates the character menu panel,
-- and the last creation step sends the `CreateCharacter` message.

library.New('character', cw)

cw.character.stored = cw.character.stored or {}
cw.character.whitelisted = cw.character.whitelisted or {}
cw.character.creationPanels = cw.character.creationPanels or {}

--- Registers a step of the character creation process.
--
-- A step whose friendly name is already registered is ignored, so the call is
-- safe on auto-refresh. When `index` is given, the steps at or after it move down one place.
--
-- ```
-- cw.character:RegisterCreationPanel('#CharCreation_DefaultClass', 'cw.characterStageThree', nil,
--   function(info)
--     return info.faction == 'Citizen'
--   end
-- )
-- ```
--
-- @param friendlyName [String Name of the step, usually a language phrase]
-- @param vguiName [String Name of the VGUI panel class opened for the step]
-- @param index=nil [Number Position of the step; appended to the end when `nil`]
-- @param Condition=nil [Function Called with the creation info `Map` when moving between steps;
-- return `false` to skip the step]
-- @see cw.character:RemoveCreationPanel
function cw.character:RegisterCreationPanel(friendlyName, vguiName, index, Condition)
  -- Prevent duplicates from being created on AutoRefresh.
  for k, v in ipairs(cw.character.creationPanels) do
    if v.friendlyName == friendlyName then
      return
    end
  end

  if index then
    for k, v in pairs(cw.character.creationPanels) do
      if v.index >= index then
        v.index = v.index + 1
      end
    end
  end

  table.insert(cw.character.creationPanels, index or #cw.character.creationPanels + 1, {
    index = index or #cw.character.creationPanels + 1,
    vguiName = vguiName,
    Condition = Condition,
    friendlyName = friendlyName
  })
end

--- Removes a step from the character creation process.
--
-- The steps after it move up one place.
-- @param name [String VGUI panel class or friendly name of the step]
-- @see cw.character:RegisterCreationPanel
function cw.character:RemoveCreationPanel(name)
  local removed = false

  -- Backwards, so that removing a step does not skip the one after it.
  for k = #self.creationPanels, 1, -1 do
    local v = self.creationPanels[k]

    if name == v.vguiName or name == v.friendlyName then
      removed = true

      table.remove(self.creationPanels, k)
    end
  end

  if removed then
    -- A step's index is its place in the list.
    for k, v in ipairs(self.creationPanels) do
      v.index = k
    end
  end
end

--- Returns the closest earlier creation step whose condition passes.
-- @return [Map The step's info table (`index`, `vguiName`, `friendlyName`, `Condition`), or `nil`
-- if there is none]
function cw.character:GetPreviousCreationPanel()
  local info = self:GetCreationInfo()
  local index = info.index - 1

  while self.creationPanels[index] do
    local panelInfo = self.creationPanels[index]

    if !panelInfo.Condition
    or panelInfo.Condition(info) then
      return panelInfo
    end

    index = index - 1
  end
end

--- Returns the closest later creation step whose condition passes.
-- @return [Map The step's info table (`index`, `vguiName`, `friendlyName`, `Condition`), or `nil`
-- if the current step is the last]
function cw.character:GetNextCreationPanel()
  local info = self:GetCreationInfo()
  local index = info.index + 1

  while self.creationPanels[index] do
    local panelInfo = self.creationPanels[index]

    if !panelInfo.Condition
    or panelInfo.Condition(info) then
      return panelInfo
    end

    index = index + 1
  end
end

--- Clears the creation info on the character panel, starting a new creation at step 0.
function cw.character:ResetCreationInfo()
  self:GetPanel().info = { index = 0 }
end

--- Returns the creation info of the character being created.
--
-- The `index` key holds the current step; the steps fill in the other keys
-- (`faction`, `name`, `model`...), which are sent to the server when creation finishes.
-- @return [Map The creation info stored on the character panel]
function cw.character:GetCreationInfo()
  return self:GetPanel().info
end

--- Returns how far the character creation process is.
-- @return [Number Percentage of the registered steps reached, from 0 to 100]
function cw.character:GetCreationProgress()
  return (100 / #self.creationPanels) * self:GetCreationInfo().index
end

--- Returns whether the active character menu panel is a creation step.
-- @return [Boolean Whether character creation is in progress]
function cw.character:IsCreationProcessActive()
  local activePanel = self:GetActivePanel()

  if activePanel and activePanel.bIsCreationProcess then
    return true
  else
    return false
  end
end

--- Goes back to the previous creation step.
--
-- The active step's `OnPrevious` method can return `false` to stay on it.
-- Does nothing on the first step.
-- @see cw.character:OpenNextCreationPanel
function cw.character:OpenPreviousCreationPanel()
  local previousPanel = self:GetPreviousCreationPanel()
  local activePanel = self:GetActivePanel()
  local panel = self:GetPanel()
  local info = self:GetCreationInfo()

  if info.index > 0 and activePanel and activePanel.OnPrevious
  and activePanel:OnPrevious() == false then
    return
  end

  if previousPanel then
    info.index = previousPanel.index
    panel:OpenPanel(previousPanel.vguiName, info)
  end
end

--- Moves on to the next creation step, or finishes character creation.
--
-- The active step's `OnNext` method can return `false` to stay on it. After the
-- last step it runs the `PlayerAdjustCharacterCreationInfo` hook and sends the
-- creation info to the server to create the character.
-- @see cw.character:OpenPreviousCreationPanel
function cw.character:OpenNextCreationPanel()
  local activePanel = self:GetActivePanel()
  local nextPanel = self:GetNextCreationPanel()
  local panel = self:GetPanel()
  local info = self:GetCreationInfo()

  if info.index > 0 and activePanel and activePanel.OnNext
  and activePanel:OnNext() == false then
    return
  end

  if !nextPanel then
    hook.Run(
      'PlayerAdjustCharacterCreationInfo', self:GetActivePanel(), info
    )

    netstream.Start('CreateCharacter', info)
  else
    info.index = nextPanel.index
    panel:OpenPanel(nextPanel.vguiName, info)
  end
end

--- Returns the registered character creation steps.
-- @return [List<Map> The step info tables, in order]
function cw.character:GetCreationPanels()
  return self.creationPanels
end

--- Returns the panel currently shown inside the character menu.
-- @return [Panel The active panel, or `nil` if there is none or it was removed]
function cw.character:GetActivePanel()
  if IsValid(self.activePanel) then
    return self.activePanel
  end
end

--- Sets whether the character menu is waiting for the character list.
-- @param loading [Boolean Whether the menu is loading]
function cw.character:SetPanelLoading(loading)
  self.isLoading = loading
end

--- Returns whether the character menu is waiting for the character list.
-- @return [Boolean Whether the menu is loading]
function cw.character:IsPanelLoading()
  return self.isLoading
end

--- Returns the active panel if it is the character list.
-- @return [Panel The character list panel, or `nil` if another panel is shown]
function cw.character:GetPanelList()
  local panel = self:GetActivePanel()

  if panel and panel.isCharacterList then
    return panel
  end
end

--- Returns the factions the local player is whitelisted for.
-- @return [List<String> Faction names, kept up to date by the server]
function cw.character:GetWhitelisted()
  return self.whitelisted
end

--- Returns whether the local player is whitelisted for a faction.
-- @param faction [String Name of the faction]
-- @return [Boolean Whether the player is whitelisted]
function cw.character:IsWhitelisted(faction)
  return table.HasValue(self:GetWhitelisted(), faction)
end

--- Returns the local player's characters as sent by the server.
-- @return [Map<Character> Character data tables keyed by character ID]
function cw.character:GetAll()
  return self.stored
end

--- Returns the last character creation or loading error.
-- @return [String The error message, or `nil` if there is none]
function cw.character:GetFault()
  return self.fault
end

--- Sets the character error and shows it as cinematic text if it is a string.
-- @param fault [String The error message, or a language phrase; `nil` clears it]
function cw.character:SetFault(fault)
  if type(fault) == 'string' then
    cw.core:AddCinematicText(
      fault, Color(255, 255, 255, 255), 32, 6, cw.option:GetFont('menu_text_tiny'), true
    )
  end

  self.fault = fault
end

--- Returns the character menu panel.
-- @return [Panel The character menu, or `nil` if it has not been created]
function cw.character:GetPanel()
  return self.panel
end

--- Fades in the navigation buttons of the character menu, if it exists.
function cw.character:FadeInNavigation()
  if IsValid(self.panel) then
    self.panel:FadeInNavigation()
  end
end

--- Rebuilds the character list with the local player's characters.
--
-- Characters are grouped with the `GetPlayerCharacterScreenFaction` hook,
-- sorted within a group with `CharacterScreenSortFactionCharacters` and the
-- groups are sorted by name. Does nothing when the character list is not shown.
function cw.character:RefreshPanelList()
  local factionScreens = {}
  local factionList = {}
  local panelList = self:GetPanelList()

  if panelList then
    panelList:Clear()

    for k, v in pairs(self:GetAll()) do
      local faction = hook.Run('GetPlayerCharacterScreenFaction', v)
      if !factionScreens[faction] then factionScreens[faction] = {} end

      factionScreens[faction][#factionScreens[faction] + 1] = v
    end

    for k, v in pairs(factionScreens) do
      table.sort(v, function(a, b)
        return hook.Run('CharacterScreenSortFactionCharacters', k, a, b)
      end)

      factionList[#factionList + 1] = { name = k, characters = v }
    end

    table.sort(factionList, function(a, b)
      return a.name < b.name
    end)

    for k, v in pairs(factionList) do
      for k2, v2 in pairs(v.characters) do
        panelList.customData = {
          name = v2.name,
          model = v2.model,
          banned = v2.banned,
          faction = v.name,
          details = v2.details,
          charTable = v2,
          characterID = v2.characterID
        }

        v2.panel = vgui.Create('cw.characterPanel', panelList)

        if IsValid(v2.panel) then
          panelList:AddPanel(v2.panel)
        end
      end
    end
  end
end

--- Returns whether the character menu is open.
-- @return [Boolean Whether the menu is open]
function cw.character:IsPanelOpen()
  return self.isOpen
end

--- Returns the character menu to its main screen.
function cw.character:SetPanelMainMenu()
  local panel = self:GetPanel()

  if panel then
    panel:ReturnToMainMenu()
  end
end

--- Sets whether the character menu should be opened once it has been created.
-- @param polling [Boolean Whether the menu is waiting to open]
function cw.character:SetPanelPolling(polling)
  self.isPolling = polling
end

--- Returns whether the character menu is waiting to open once it has been created.
-- @return [Boolean Whether the menu is waiting to open]
function cw.character:IsPanelPolling()
  return self.isPolling
end

--- Returns whether the server reopened the character menu to reset it.
-- @return [Boolean Whether the menu was reset, or `nil` if it never was]
function cw.character:IsMenuReset()
  return self.isMenuReset
end

--- Opens or closes the character menu and toggles the mouse cursor to match.
--
-- When the menu does not exist yet, opening it marks it as polling so it opens
-- once it has been created.
-- @param open [Boolean Whether to open the menu]
-- @param bReset=nil [Boolean When closing, keep the menu marked open and visible]
function cw.character:SetPanelOpen(open, bReset)
  local panel = self:GetPanel()

  if !open then
    if !bReset then
      self.isOpen = false
    else
      self.isOpen = true
    end

    if panel then
      panel:SetVisible(self:IsPanelOpen())
    end
  elseif panel then
    panel:SetVisible(true)
    panel.createTime = SysTime()
    self.isOpen = true
  else
    self:SetPanelPolling(true)
  end

  gui.EnableScreenClicker(self:IsPanelOpen())
end

--- Stores a character of the local player.
-- @param characterID [Number ID of the character]
-- @param data [Character The character data sent by the server]
function cw.character:Add(characterID, data)
  self.stored[characterID] = data
end
