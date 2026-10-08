--- Defines the character menu (`cw.characterMenu`) and every panel of character selection and creation.
--
-- Holds the character carousel (`cw.characterList`, `cw.characterPanel`, `cw.characterModel`) and the four creation
-- steps `cw.characterStageOne` to `cw.characterStageFour` (faction and gender, name and description, class,
-- attributes), which are registered with `cw.character:RegisterCreationPanel`. Also handles the `CharacterMenu`,
-- `CharacterOpen`, `CharacterAdd`, `CharacterRemove`, `CharacterFinish` and `SetWhitelisted` netstreams; the character
-- cards send `InteractCharacter` to use or delete a character.

-- Reused every frame by the paint functions below instead of allocating new colors.
local barColor = Color(0, 0, 0, 100)
local progressBarColor = Color(0, 0, 0, 100)
local stepTextColor = Color(255, 255, 255, 200)
local attributeBarColor = Color(75, 75, 75, 255)
local modelAngles = Angle(0, 45, 0)

local PANEL = {}

--- Builds the full-screen character menu: schema title or logo, credits, the New, Load and Leave buttons,
-- the creation navigation buttons and the model preview.
--
-- Skipped when the theme's `PreCharacterMenuInit` hook returns `true`; `PostCharacterMenuInit` runs
-- afterwards.
function PANEL:Init()
  if !cw.theme:Call('PreCharacterMenuInit', self) then
    local smallTextFont = cw.option:GetFont('menu_text_small')
    local tinyTextFont = cw.option:GetFont('menu_text_tiny')
    local hugeTextFont = cw.option:GetFont('menu_text_huge')
    local scrH = ScrH()
    local scrW = ScrW()

    self:SetPos(0, 0)
    self:SetSize(scrW, scrH)
    self:SetDrawOnTop(false)
    self:SetFocusTopLevel(true)
    self:SetPaintBackground(false)
    self:SetMouseInputEnabled(true)

    self.titleLabel = vgui.Create('cwLabelButton', self)
    self.titleLabel:SetDisabled(true)
    self.titleLabel:SetFont(hugeTextFont)
    self.titleLabel:SetText(string.upper(Schema:GetName()))

    local schemaLogo = cw.option:GetKey('schema_logo')

    self.subLabel = vgui.Create('cwLabelButton', self)
    self.subLabel:SetDisabled(true)
    self.subLabel:SetFont(smallTextFont)
    self.subLabel:SetText(string.upper(Schema:GetDescription()))
    self.subLabel:SizeToContents()

    if schemaLogo == '' then
      self.titleLabel:SetVisible(true)
      self.titleLabel:SizeToContents()
      self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.4)
      self.subLabel:SetPos(
        (scrW / 2) - (self.subLabel:GetWide() / 2),
        self.titleLabel.y + self.titleLabel:GetTall() + 8
      )
    else
      self.titleLabel:SetVisible(false)
      self.titleLabel:SetSize(512, 256)
      self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.4 - 128)
      self.subLabel:SetPos(
        self.titleLabel.x + (self.titleLabel:GetWide() / 2) - (self.subLabel:GetWide() / 2),
        self.titleLabel.y + self.titleLabel:GetTall() + 8
      )
    end

    self.authorLabel = vgui.Create('cwLabelButton', self)
    self.authorLabel:SetDisabled(true)
    self.authorLabel:SetFont(tinyTextFont)
    self.authorLabel:SetText('#MainMenu_DevelopedBy:'..string.upper(Schema:GetAuthor())..';')
    self.authorLabel:SizeToContents()
    self.authorLabel:SetPos(
      self.subLabel.x + (self.subLabel:GetWide() - self.authorLabel:GetWide()),
      self.subLabel.y + self.subLabel:GetTall() + 4
    )

    self.lmaoCopyright = vgui.Create('cwLabelButton', self)
    self.lmaoCopyright:SetDisabled(true)
    self.lmaoCopyright:SetFont(tinyTextFont)
    self.lmaoCopyright:SetText('CATWORK '..cw.KernelVersion:upper())
    self.lmaoCopyright:SizeToContents()
    self.lmaoCopyright:SetPos(
      self.authorLabel.x + (self.authorLabel:GetWide() - self.lmaoCopyright:GetWide()),
      self.authorLabel.y + self.authorLabel:GetTall() + 4
    )

    self.createButton = vgui.Create('cwLabelButton', self)
    self.createButton:SetFont(smallTextFont)
    self.createButton:SetText('#MainMenu_New')
    self.createButton:SetContentAlignment(4)
    self.createButton:FadeIn(0.5)
    self.createButton:SetCallback(function(panel)
      if table.Count(cw.character:GetAll()) >= cw.player:GetMaximumCharacters() then
        return cw.character:SetFault('#CharCreation_CannotCreateMoreChars')
      end

      cw.character:ResetCreationInfo()
      cw.character:OpenNextCreationPanel()
    end)

    self.createButton:SizeToContents()
    self.createButton:SetMouseInputEnabled(true)
    self.createButton:SetPos(scrW * 0.25 - (self.createButton:GetWide() / 2), 16)

    self.loadButton = vgui.Create('cwLabelButton', self)
    self.loadButton:SetFont(smallTextFont)
    self.loadButton:SetText('#MainMenu_Load')
    self.loadButton:SetContentAlignment(6)
    self.loadButton:FadeIn(0.5)
    self.loadButton:SetCallback(function(panel)
      self:OpenPanel('cw.characterList', nil, function(panel)
        cw.character:RefreshPanelList()
      end)
    end)

    self.loadButton:SizeToContents()
    self.loadButton:SetMouseInputEnabled(true)
    self.loadButton:SetPos(scrW * 0.75 - (self.loadButton:GetWide() / 2), 16)

    self.disconnectButton = vgui.Create('cwLabelButton', self)
    self.disconnectButton:SetFont(smallTextFont)
    self.disconnectButton:SetText('#MainMenu_Leave')
    self.disconnectButton:SetContentAlignment(5)
    self.disconnectButton:FadeIn(0.5)
    self.disconnectButton:SetCallback(function(panel)
      if cw.client:HasInitialized() and !cw.character:IsMenuReset() then
        cw.character:SetPanelMainMenu()
        cw.character:SetPanelOpen(false)
      else
        RunConsoleCommand('disconnect')
      end
    end)

    self.disconnectButton:SizeToContents()
    self.disconnectButton:SetPos((scrW / 2) - (self.disconnectButton:GetWide() / 2), 16)
    self.disconnectButton:SetMouseInputEnabled(true)

    self.previousButton = vgui.Create('cwLabelButton', self)
    self.previousButton:SetFont(tinyTextFont)
    self.previousButton:SetText('#CharCreation_Previous')
    self.previousButton:SetCallback(function(panel)
      if IsValid(self.fadingPanel) then
        return
      end

      if !cw.character:IsCreationProcessActive() then
        local activePanel = cw.character:GetActivePanel()

        if activePanel and activePanel.OnPrevious then
          activePanel:OnPrevious()
        end
      else
        cw.character:OpenPreviousCreationPanel()
      end
    end)

    self.previousButton:SizeToContents()
    self.previousButton:SetMouseInputEnabled(true)
    self.previousButton:SetPos((scrW * 0.2) - (self.previousButton:GetWide() / 2), scrH * 0.9)

    self.nextButton = vgui.Create('cwLabelButton', self)
    self.nextButton:SetFont(tinyTextFont)
    self.nextButton:SetText('#CharCreation_Next')
    self.nextButton:SetCallback(function(panel)
      if IsValid(self.fadingPanel) then
        return
      end

      if !cw.character:IsCreationProcessActive() then
        local activePanel = cw.character:GetActivePanel()

        if activePanel and activePanel.OnNext then
          activePanel:OnNext()
        end
      else
        cw.character:OpenNextCreationPanel()
      end
    end)

    self.nextButton:SizeToContents()
    self.nextButton:SetMouseInputEnabled(true)
    self.nextButton:SetPos((scrW * 0.8) - (self.nextButton:GetWide() / 2), scrH * 0.9)

    self.cancelButton = vgui.Create('cwLabelButton', self)
    self.cancelButton:SetFont(tinyTextFont)
    self.cancelButton:SetText('#CharCreation_Cancel')
    self.cancelButton:SetCallback(function(panel)
      self:ReturnToMainMenu()
    end)

    self.cancelButton:SizeToContents()
    self.cancelButton:SetMouseInputEnabled(true)
    self.cancelButton:SetPos((scrW * 0.5) - (self.cancelButton:GetWide() / 2), scrH * 0.9)

    local modelSize = math.min(ScrW() * 0.25, ScrH() * 0.9)

    self.characterModel = vgui.Create('cw.characterModel', self)
    self.characterModel:SetSize(modelSize, modelSize)
    self.characterModel:SetAlpha(0)
    self.characterModel:SetModel('models/error.mdl')
    self.createTime = SysTime()

    cw.theme:Call('PostCharacterMenuInit', self)
  end
end

--- Moves the model preview next to the active panel, fades it in and shows a model in it.
--
-- Does nothing on screens shorter than 768 pixels.
--
-- @param model [String Model to show once the preview is fading in]
-- @return [Boolean `true` when the screen is too small or the fade started, `false` otherwise]
function PANEL:FadeInModelPanel(model)
  if ScrH() < 768 then
    return true
  end

  local panel = cw.character:GetActivePanel()
  local x, y = ScrW() - self.characterModel:GetWide() - 8, 16

  if panel then
    x, y = panel.x + panel:GetWide() - 16, panel.y - 80
  end

  self.characterModel:SetPos(x, y)

  if self.characterModel:FadeIn(0.5) then
    self:SetModelPanelModel(model)
    return true
  else
    return false
  end
end

--- Fades out the model preview.
function PANEL:FadeOutModelPanel()
  self.characterModel:FadeOut(0.5)
end

--- Sets the model shown in the model preview and applies the weapon model and sequence from hooks.
--
-- The weapon model comes from the `GetModelSelectWeaponModel` hook and the animation from the
-- `GetModelSelectSequence` hook.
--
-- @param model [String Model path to show]
function PANEL:SetModelPanelModel(model)
  if self.characterModel.currentModel != model then
    self.characterModel.currentModel = model
    self.characterModel:SetModel(model)
  end

  local modelPanel = self.characterModel
  local weaponModel = hook.Run(
    'GetModelSelectWeaponModel', model
  )
  local sequence = hook.Run(
    'GetModelSelectSequence', modelPanel.Entity, model
  )

  if weaponModel then
    self.characterModel:SetWeaponModel(weaponModel)
  else
    self.characterModel:SetWeaponModel(false)
  end

  if sequence then
    modelPanel.Entity:ResetSequence(sequence)
  end
end

--- Fades out and removes the active panel, then brings back the title, and hides the model preview and
-- navigation.
function PANEL:ReturnToMainMenu()
  local panel = cw.character:GetActivePanel()

  if panel then
    panel:FadeOut(0.5, function()
      cw.character.activePanel = nil
      panel:Remove()
      self:FadeInTitle()
    end)
  else
    self:FadeInTitle()
  end

  self:FadeOutModelPanel()
  self:FadeOutNavigation()
end

--- Fades out the Previous, Cancel and Next buttons unless the theme's `PreCharacterFadeOutNavigation`
-- hook returns `true`.
function PANEL:FadeOutNavigation()
  if !cw.theme:Call('PreCharacterFadeOutNavigation', self) then
    self.previousButton:FadeOut(0.5)
    self.cancelButton:FadeOut(0.5)
    self.nextButton:FadeOut(0.5)
  end
end

--- Fades in the Previous, Cancel and Next buttons unless the theme's `PreCharacterFadeInNavigation`
-- hook returns `true`.
function PANEL:FadeInNavigation()
  if !cw.theme:Call('PreCharacterFadeInNavigation', self) then
    self.previousButton:FadeIn(0.5)
    self.cancelButton:FadeIn(0.5)
    self.nextButton:FadeIn(0.5)
  end
end

--- Fades out the schema title, description and credits unless the theme's `PreCharacterFadeOutTitle`
-- hook returns `true`.
function PANEL:FadeOutTitle()
  if !cw.theme:Call('PreCharacterFadeOutTitle', self) then
    self.subLabel:FadeOut(0.5)
    self.titleLabel:FadeOut(0.5)
    self.authorLabel:FadeOut(0.5)
    self.lmaoCopyright:FadeOut(0.5)
  end
end

--- Fades in the schema title, description and credits unless the theme's `PreCharacterFadeInTitle`
-- hook returns `true`.
function PANEL:FadeInTitle()
  if !cw.theme:Call('PreCharacterFadeInTitle', self) then
    self.subLabel:FadeIn(0.5)
    self.titleLabel:FadeIn(0.5)
    self.authorLabel:FadeIn(0.5)
    self.lmaoCopyright:FadeIn(0.5)
  end
end

--- Replaces the active panel of the character menu with a new panel.
--
-- The current active panel fades out and is removed first; with no active panel the title fades out
-- instead. The new panel becomes `cw.character.activePanel`, fades in and gets popup focus. When
-- `childData` is given the panel is marked as part of the creation process and the navigation buttons
-- fade in. Skipped when the theme's `PreCharacterMenuOpenPanel` hook returns `true`;
-- `PostCharacterMenuOpenPanel` runs afterwards.
--
-- ```
-- cw.character:GetPanel():OpenPanel('cw.characterList', nil, function(panel)
--   cw.character:RefreshPanelList()
-- end)
-- ```
--
-- @param vguiName [String Registered name of the panel to create]
-- @param childData=nil [Any Data stored as `self.childData` for the new panel to read; marks a creation step]
-- @param Callback=nil [Function Called with the new panel once it has been created]
function PANEL:OpenPanel(vguiName, childData, Callback)
  if !cw.theme:Call('PreCharacterMenuOpenPanel', self, vguiName, childData, Callback) then
    local panel = cw.character:GetActivePanel()

    local y = ScrH() * 0.275

    if ScrH() < 768 then
      y = ScrH() * 0.11
    end

    local function ShowPanel()
      self.childData = childData

      local activePanel = vgui.Create(vguiName, self)

      cw.character.activePanel = activePanel

      activePanel:SetAlpha(0)
      activePanel:FadeIn(0.5)
      activePanel:MakePopup()
      activePanel:SetPos(ScrW() * 0.2, y)

      if Callback then
        Callback(activePanel)
      end

      if childData then
        activePanel.bIsCreationProcess = true
        cw.character:FadeInNavigation()
      end
    end

    if panel then
      -- The navigation buttons ignore clicks until the old panel is gone, or a second click would skip a step.
      self.fadingPanel = panel

      panel:FadeOut(0.5, function()
        self.fadingPanel = nil
        panel:Remove()

        ShowPanel()
      end)
    else
      self:FadeOutTitle()

      ShowPanel()
    end

    --[[ Fade out the model panel, we probably don't need it now! --]]
    self:FadeOutModelPanel()

    cw.theme:Call('PostCharacterMenuOpenPanel', self)
  end
end

--- Draws the schema logo, the top bar and, during character creation, the step progress bar.
--
-- Skipped when the theme's `PreCharacterMenuPaint` hook returns `true`; `PostCharacterMenuPaint` runs
-- afterwards.
function PANEL:Paint(w, h)
  if !cw.theme:Call('PreCharacterMenuPaint', self) then
    local schemaLogo = cw.option:GetKey('schema_logo')
    local subLabelAlpha = self.subLabel:GetAlpha()

    if schemaLogo != '' and subLabelAlpha > 0 then
      if !self.logoTextureID then
        self.logoTextureID = Material(schemaLogo..'.png')
      end

      self.logoTextureID:SetFloat('$alpha', subLabelAlpha)

      surface.SetDrawColor(255, 255, 255, subLabelAlpha)
      surface.SetMaterial(self.logoTextureID)
      surface.DrawTexturedRect(self.titleLabel.x, self.titleLabel.y - 64, 512, 256)
    end

    local backgroundColor = cw.option:GetColor('background')
    local foregroundColor = cw.option:GetColor('foreground')
    local colorTargetID = cw.option:GetColor('target_id')
    local colorWhite = cw.option:GetColor('white')
    local scrW = ScrW()
    local height = (self.createButton.y * 2) + self.createButton:GetTall()
    local y = 0

    barColor.r, barColor.g, barColor.b = backgroundColor.r, backgroundColor.g, backgroundColor.b

    cw.core:DrawSimpleGradientBox(0, 0, y, scrW, height, barColor)

    surface.SetDrawColor(
      foregroundColor.r, foregroundColor.g, foregroundColor.b, 200
    )
    surface.DrawRect(0, y + height, scrW, 1)

    if cw.character:IsCreationProcessActive() then
      local creationPanels = cw.character:GetCreationPanels()
      local numCreationPanels = #creationPanels
      local creationProgress = cw.character:GetCreationProgress()
      local progressHeight = 20
      local creationInfo = cw.character:GetCreationInfo()
      local progressY = y + height + 1

      progressBarColor.r = math.min(backgroundColor.r + 50, 255)
      progressBarColor.g = math.min(backgroundColor.g + 50, 255)
      progressBarColor.b = math.min(backgroundColor.b + 50, 255)

      cw.core:DrawSimpleGradientBox(0, 0, progressY, scrW, progressHeight, progressBarColor)

      surface.SetDrawColor(
        foregroundColor.r, foregroundColor.g, foregroundColor.b, 150
      )

      for i = 1, numCreationPanels do
        surface.DrawRect((scrW / numCreationPanels) * i, progressY, 1, progressHeight)
      end

      cw.core:DrawSimpleGradientBox(
        0, 0, progressY, (scrW / 100) * creationProgress, progressHeight, colorTargetID
      )

      if creationProgress > 0 and creationProgress < 100 then
        surface.SetDrawColor(
          foregroundColor.r, foregroundColor.g, foregroundColor.b, 200
        )
        surface.DrawRect((scrW / 100) * creationProgress, progressY, 1, progressHeight)
      end

      stepTextColor.r, stepTextColor.g, stepTextColor.b = colorWhite.r, colorWhite.g, colorWhite.b

      for i = 1, numCreationPanels do
        local Condition = creationPanels[i].Condition
        local textX = (scrW / numCreationPanels) * (i - 0.5)
        local textY = progressY + (progressHeight / 2)

        if Condition and !Condition(creationInfo) then
          stepTextColor.a = 100
        else
          stepTextColor.a = 200
        end

        cw.core:DrawSimpleText(creationPanels[i].friendlyName, textX, textY - 1, stepTextColor, 1, 1)
      end

      surface.SetDrawColor(
        foregroundColor.r, foregroundColor.g, foregroundColor.b, 200
      )
      surface.DrawRect(0, progressY + progressHeight, scrW, 1)
    end

    cw.theme:Call('PostCharacterMenuPaint', self)
  end

  return true
end

--- Updates the background blur and enables or disables the menu buttons each frame.
--
-- Skipped when the theme's `PreCharacterMenuThink` hook returns `true`; `PostCharacterMenuThink` runs
-- afterwards.
function PANEL:Think()
  if !cw.theme:Call('PreCharacterMenuThink', self) then
    local characters = table.Count(cw.character:GetAll())
    local bIsLoading = cw.character:IsPanelLoading()
    local schemaLogo = cw.option:GetKey('schema_logo')
    local activePanel = cw.character:GetActivePanel()

    if hook.Run('ShouldDrawCharacterBackgroundBlur') then
      cw.core:RegisterBackgroundBlur(self, self.createTime)
    else
      cw.core:RemoveBackgroundBlur(self)
    end

    if self.characterModel then
      if !self.characterModel.currentModel
      or self.characterModel.currentModel == 'models/error.mdl' then
        self.characterModel:SetAlpha(0)
      end
    end

    if !cw.character:IsCreationProcessActive() then
      if activePanel then
        if activePanel.GetNextDisabled
        and activePanel:GetNextDisabled() then
          self.nextButton:SetDisabled(true)
        else
          self.nextButton:SetDisabled(false)
        end

        if activePanel.GetPreviousDisabled
        and activePanel:GetPreviousDisabled() then
          self.previousButton:SetDisabled(true)
        else
          self.previousButton:SetDisabled(false)
        end
      end
    else
      local previousPanelInfo = cw.character:GetPreviousCreationPanel()

      if previousPanelInfo then
        self.previousButton:SetDisabled(false)
      else
        self.previousButton:SetDisabled(true)
      end

      self.nextButton:SetDisabled(false)
    end

    if schemaLogo == '' then
      self.titleLabel:SetVisible(true)
    else
      self.titleLabel:SetVisible(false)
    end

    if characters == 0 or bIsLoading then
      self.loadButton:SetDisabled(true)
    else
      self.loadButton:SetDisabled(false)
    end

    if characters >= cw.player:GetMaximumCharacters()
    or cw.character:IsPanelLoading() then
      self.createButton:SetDisabled(true)
    else
      self.createButton:SetDisabled(false)
    end

    local disconnectText = '#MainMenu_Leave'

    if cw.client:HasInitialized() and !cw.character:IsMenuReset() then
      disconnectText = '#CharCreation_Cancel'
    end

    if self.disconnectText != disconnectText then
      self.disconnectText = disconnectText
      self.disconnectButton:SetText(disconnectText)
      self.disconnectButton:SizeToContents()
    end

    if self.animation then
      self.animation:Run()
    end

    self:SetSize(ScrW(), ScrH())

    cw.theme:Call('PostCharacterMenuThink', self)
  end
end

vgui.Register('cw.characterMenu', PANEL, 'DPanel')

--[[
  Add a hook to control clicking outside of the active panel.
--]]

hook.Add('VGUIMousePressed', 'cw.character:VGUIMousePressed', function(panel, code)
  local characterPanel = cw.character:GetPanel()
  local activePanel = cw.character:GetActivePanel()

  if cw.character:IsPanelOpen() and activePanel
  and characterPanel == panel then
    activePanel:MakePopup()
  end
end)

--- Fades a panel out and hides it, playing the rollover sound.
--
-- When the panel is already transparent or animating, it is hidden at once. Shared by the character list and
-- the creation steps.
--
-- @param self [Panel The panel to fade out]
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the panel is hidden]
local function FadeOutPanel(self, speed, Callback)
  if self:GetAlpha() > 0 and (!self.animation or !self.animation:Active()) then
    self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
      panel:SetAlpha(255 - (delta * 255))

      if animation.Finished then
        panel:SetVisible(false)
      end

      if animation.Finished and Callback then
        Callback()
      end
    end)

    if self.animation then
      self.animation:Start(speed)
    end

    cw.option:PlaySound('rollover')
  else
    self:SetVisible(false)
    self:SetAlpha(0)

    if Callback then
      Callback()
    end
  end
end

--- Shows a panel and fades it in, playing the click sound.
--
-- When the panel is already visible or animating, it is made fully visible at once. Shared by the character
-- list and the creation steps.
--
-- @param self [Panel The panel to fade in]
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the panel is fully visible]
local function FadeInPanel(self, speed, Callback)
  if self:GetAlpha() == 0 and (!self.animation or !self.animation:Active()) then
    self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
      panel:SetVisible(true)
      panel:SetAlpha(delta * 255)

      if animation.Finished then
        self.animation = nil
      end

      if animation.Finished and Callback then
        Callback()
      end
    end)

    if self.animation then
      self.animation:Start(speed)
    end

    cw.option:PlaySound('click_release')
  else
    self:SetVisible(true)
    self:SetAlpha(255)

    if Callback then
      Callback()
    end
  end
end

local PANEL = {}

--- Sets up the character list (`cw.characterList`) and shows the navigation buttons.
function PANEL:Init()
  self.selectedIdx = 1
  self.characterPanels = {}
  self.isCharacterList = true

  cw.character:FadeInNavigation()
end

--- Draws nothing.
function PANEL:Paint(w, h) end

--- Fades the character list out and hides it, playing the rollover sound.
--
-- When the list is already invisible or animating, it is hidden at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the list is hidden]
function PANEL:FadeOut(speed, Callback)
  FadeOutPanel(self, speed, Callback)
end

--- Shows the character list and fades it in, playing the click sound.
--
-- When the list is already visible or animating, it is made fully visible at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the list is fully visible]
function PANEL:FadeIn(speed, Callback)
  FadeInPanel(self, speed, Callback)
end

--- Removes every character panel from the list.
function PANEL:Clear()
  for k, v in pairs(self.characterPanels) do
    v:Remove()
  end

  self.characterPanels = {}
end

--- Adds a character panel to the end of the list.
-- @param panel [Panel The `cw.characterPanel` to add]
function PANEL:AddPanel(panel)
  self.characterPanels[#self.characterPanels + 1] = panel
end

--- Returns whether the Previous button should be disabled.
-- @return [Boolean `true` when the first character is selected]
function PANEL:GetPreviousDisabled()
  return (self.characterPanels[self.selectedIdx - 1] == nil)
end

--- Returns whether the Next button should be disabled.
-- @return [Boolean `true` when the last character is selected]
function PANEL:GetNextDisabled()
  return (self.characterPanels[self.selectedIdx + 1] == nil)
end

--- Returns the character panels in the list.
-- @return [List<Panel> The `cw.characterPanel` panels in order]
function PANEL:GetCharacterPanels()
  return self.characterPanels
end

--- Returns the selected character panel.
-- @return [Panel The selected `cw.characterPanel`, or `nil` when the list is empty]
function PANEL:GetSelectedModel()
  return self.characterPanels[self.selectedIdx]
end

--- Moves a character panel a step closer to its target position and alpha.
-- @param panel [Panel The character panel to move]
-- @param position [Number Target x position]
-- @param alpha [Number Target alpha, from 0 to 255]
function PANEL:ManageTargets(panel, position, alpha)
  if !panel.TargetPosition then
    panel.TargetPosition = position
  end

  if !panel.TargetAlpha then
    panel.TargetAlpha = alpha
  end

  local interval = 64 * math.EaseInOut(self.easingValue, 0.2, 0.2)

  panel.TargetPosition = math.Approach(panel.TargetPosition, position, interval)
  panel.TargetAlpha = math.Approach(panel.TargetAlpha, alpha, interval)
  panel:SetAlpha(panel.TargetAlpha)
  panel:SetPos(panel.TargetPosition, 0)
end

--- Selects a character by index and restarts the slide animation.
-- @param index [Number Index of the character panel to select]
function PANEL:SetSelectedIdx(index)
  self.selectedIdx = index
  self.easingValue = 0
end

--- Selects the previous character.
function PANEL:OnPrevious()
  self.selectedIdx = math.max(self.selectedIdx - 1, 1)
  self.easingValue = 0
  self:MakePopup()
end

--- Selects the next character.
function PANEL:OnNext()
  self.selectedIdx = math.min(self.selectedIdx + 1, #self.characterPanels)
  self.easingValue = 0
  self:MakePopup()
end

--- Slides the selected character to the centre and lays the others out to each side, fading them with
-- distance.
function PANEL:Think()
  self:InvalidateLayout(true)

  if !self.easingValue then
    self.easingValue = 0
  end

  self.easingValue = math.Approach(self.easingValue, 1, FrameTime())

  if self.animation then self.animation:Run() end

  local numPanels = #self.characterPanels

  self.selectedIdx = math.max(math.min(self.selectedIdx, numPanels), 1)

  local selectedIdx = self.selectedIdx
  local centerPanel = self.characterPanels[selectedIdx]

  if centerPanel then
    centerPanel:SetActive(true)
    self:ManageTargets(centerPanel, (self:GetWide() / 2) - (centerPanel:GetWide() / 2), 255)

    local rightX = centerPanel.x + centerPanel:GetWide() + 16
    local leftX = centerPanel.x - 16

    for i = selectedIdx - 1, 1, -1 do
      local previousPanel = self.characterPanels[i]

      previousPanel:SetActive(false)
      self:ManageTargets(previousPanel, leftX - previousPanel:GetWide(), (255 / selectedIdx) * i)
      leftX = previousPanel.x - 16
    end

    -- In order, since each panel is placed to the right of the one before it.
    for i = selectedIdx + 1, numPanels do
      local nextPanel = self.characterPanels[i]

      nextPanel:SetActive(false)
      self:ManageTargets(nextPanel, rightX, (255 / ((numPanels + 1) - selectedIdx)) * ((numPanels + 1) - i))
      rightX = nextPanel.x + nextPanel:GetWide() + 16
    end
  end
end

--- Fills the screen below the top bar and above the navigation buttons.
function PANEL:PerformLayout(w, h)
  self:SetPos(0, 96)
  self:SetSize(ScrW(), ScrH() - (96 * 2))
end

vgui.Register('cw.characterList', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds a character card (`cw.characterPanel`) from the parent's `customData`: name, faction, model,
-- the Use and Delete buttons and any extra buttons and labels from hooks.
--
-- Extra buttons come from the `GetCustomCharacterButtons` hook, extra labels from
-- `GetCharacterPanelLabels` and the model's animation from `GetCharacterPanelSequence`. Clicking the
-- model of the selected card opens a menu with the options from `GetCustomCharacterOptions`; clicking
-- another card selects it. Every action is sent to the server with the `InteractCharacter` netstream.
function PANEL:Init()
  local smallTextFont = cw.option:GetFont('menu_text_small')
  local tinyTextFont = cw.option:GetFont('menu_text_tiny')
  local buttonsList = {}
  local buttonX = 20
  local buttonY = 0
  local labels = {}

  self.customData = self:GetParent().customData
  self.buttonPanels = {}

  -- Kept in a local for the menu callbacks, which can run after the list has been rebuilt and this card removed.
  local characterID = self.customData.characterID

  self:SetPaintBackground(false)

  hook.Run('GetCharacterPanelLabels', labels, self.customData)

  self.nameLabel = vgui.Create('cwLabelButton', self)
  self.nameLabel:SetDisabled(true)
  self.nameLabel:SetFont(smallTextFont)
  self.nameLabel:SetText(string.upper(self.customData.name))
  self.nameLabel:SizeToContents()
  self.nameLabel:SetPos(0, 80)

  self.factionLabel = vgui.Create('cwLabelButton', self)
  self.factionLabel:SetDisabled(true)
  self.factionLabel:SetFont(tinyTextFont)

  local text = cw.lang:GetString(cw.lang:GetLanguage(), self.customData.faction)

  self.factionLabel:SetText(text:utf8upper())
  self.factionLabel:SizeToContents()
  self.factionLabel:SetPos(0, self.nameLabel.y + self.nameLabel:GetTall() + 4)

  local color = Color(255, 255, 255, 255)

  for k, class in pairs(cw.class:GetAll()) do
    if class.factions[1] == self.customData.faction then
      color = class.color
    end
  end

  self.factionLabel:OverrideTextColor(color)

  self.characterModel = vgui.Create('cw.characterModel', self)
  self.characterModel:SetModel(self.customData.model)
  self.characterModel:SetSize(512, 512)
  self.characterModel:SetMouseInputEnabled(true)

  buttonY = self.factionLabel.y + self.factionLabel:GetTall() + 4

  self.characterModel:SetPos(0, buttonY + 24)

  local modelPanel = self.characterModel
  local sequence = hook.Run(
    'GetCharacterPanelSequence', modelPanel.Entity, self.customData.charTable
  )

  if sequence then
    modelPanel.Entity:ResetSequence(sequence)
  end

  self.useButton = vgui.Create('DImageButton', self)
  self.useButton:SetTooltip(L('Use this character.'))
  self.useButton:SetImage('icon16/tick.png')
  self.useButton:SetSize(16, 16)
  self.useButton:SetPos(0, buttonY)
  self.useButton:SetMouseInputEnabled(true)

  self.deleteButton = vgui.Create('DImageButton', self)
  self.deleteButton:SetTooltip(L('Delete this character.'))
  self.deleteButton:SetImage('icon16/cross.png')
  self.deleteButton:SetSize(16, 16)
  self.deleteButton:SetPos(20, buttonY)
  self.deleteButton:SetMouseInputEnabled(true)

  hook.Run(
    'GetCustomCharacterButtons', self.customData.charTable, buttonsList
  )

  for k, v in pairs(buttonsList) do
    local button = vgui.Create('DImageButton', self)
      buttonX = buttonX + 20
      button:SetTooltip(v.toolTip)
      button:SetImage(v.image)
      button:SetSize(16, 16)
      button:SetPos(buttonX, buttonY)
      button:SetMouseInputEnabled(true)
    self.buttonPanels[#self.buttonPanels + 1] = button

    -- Called when the button is clicked.
    function button.DoClick(button)
      local function Callback()
        netstream.Start('InteractCharacter', {
          characterID = characterID, action = k
        })
      end

      if !v.OnClick or v.OnClick(Callback) != false then
        Callback()
      end
    end
  end

  -- Called when the button is clicked.
  function self.useButton.DoClick(spawnIcon)
    netstream.Start('InteractCharacter', {
      characterID = characterID, action = 'use' }
    )
  end

  -- Called when the button is clicked.
  function self.deleteButton.DoClick(spawnIcon)
    cw.core:AddMenuFromData(nil, {
      [L('Yes')] = function()
        netstream.Start('InteractCharacter', {
          characterID = characterID, action = 'delete' }
        )
      end,
      [L('No')] = function() end
    })
  end

  local modelPanel = self.characterModel

  -- Called when the character model is clicked.
  function modelPanel.DoClick(modelPanel)
    local activePanel = cw.character:GetPanelList()

    if !activePanel then
      return
    end

    if activePanel:GetSelectedModel() == self then
      local options = {}

      options[L('Use')] = function()
        netstream.Start('InteractCharacter', {
          characterID = characterID, action = 'use' }
        )
      end

      options[L('Delete')] = {}
      options[L('Delete')][L('No')] = function() end
      options[L('Delete')][L('Yes')] = function()
        netstream.Start('InteractCharacter', {
          characterID = characterID, action = 'delete' }
        )
      end

      hook.Run(
        'GetCustomCharacterOptions', self.customData.charTable, options
      )

      cw.core:AddMenuFromData(nil, options, function(menu, key, value)
        menu:AddOption(key, function()
          netstream.Start('InteractCharacter', {
            characterID = characterID, action = value }
          )
        end)
      end)
    else
      for k, v in pairs(activePanel:GetCharacterPanels()) do
        if v == self then
          activePanel:SetSelectedIdx(k)
        end
      end
    end
  end

  local maxWidth = math.max(buttonX, 200)

  if self.nameLabel:GetWide() > maxWidth then
    maxWidth = self.nameLabel:GetWide()
  end

  if self.factionLabel:GetWide() > maxWidth then
    maxWidth = self.factionLabel:GetWide()
  end

  local labelY = self.characterModel.y + self.characterModel:GetTall() + 4

  for k, v in pairs(labels) do
    local label = vgui.Create('cwLabelButton', self)
    label:SetDisabled(true)
    label:SetFont(tinyTextFont)
    label:SetText(string.upper(v.text))
    label:OverrideTextColor(v.color)
    label:SizeToContents()
    label:SetPos((maxWidth / 2) - (label:GetWide() / 2), labelY)
    labelY = labelY + label:GetTall() + 4
  end

  self.characterModel.x = (maxWidth / 2) - 256
  self.nameLabel:SetPos((maxWidth / 2) - (self.nameLabel:GetWide() / 2), self.nameLabel.y)
  self.factionLabel:SetPos((maxWidth / 2) - (self.factionLabel:GetWide() / 2), self.factionLabel.y)
  self:SetSize(maxWidth, ScrH())

  local buttonAddX = ((maxWidth / 2) - (buttonX / 2)) - 10

  self.useButton:SetPos(self.useButton.x + buttonAddX, self.useButton.y)
  self.deleteButton:SetPos(self.deleteButton.x + buttonAddX, self.deleteButton.y)

  for k, v in pairs(self.buttonPanels) do
    v:SetPos(v.x + buttonAddX, v.y)
  end
end

--- Highlights the character's name when it is the selected one.
-- @param bActive [Boolean Whether this card is selected]
function PANEL:SetActive(bActive)
  if self.bActive == bActive then
    return
  end

  self.bActive = bActive

  if bActive then
    self.nameLabel:OverrideTextColor(
      cw.option:GetColor('information')
    )
  else
    self.nameLabel:OverrideTextColor(false)
  end
end

--- Updates the card's model tooltip and weapon model from the `GetCharacterPanelToolTip` and
-- `GetCharacterPanelWeaponModel` hooks, once a second.
function PANEL:Think()
  local realTime = RealTime()

  if self.nextUpdateDetails and realTime < self.nextUpdateDetails then
    return
  end

  self.nextUpdateDetails = realTime + 1

  local markupObject = cw.theme:GetMarkupObject()
  local weaponModel = hook.Run(
    'GetCharacterPanelWeaponModel', self, self.customData.charTable
  )
  local toolTip = hook.Run(
    'GetCharacterPanelToolTip', self, self.customData.charTable
  )

  markupObject:Title(L('Details'))

  markupObject:Add(
    self.customData.details or L('This character has no details to display.')
  )

  if toolTip and toolTip != '' then
    markupObject:Title(self.customData.name)
    markupObject:Add(toolTip)
  end

  self.characterModel:SetWeaponModel(weaponModel or false)
  self.characterModel:SetDetails(markupObject:GetText())
end

vgui.Register('cw.characterPanel', PANEL, 'DPanel')

local PANEL = {}

--- Fades the model panel out and hides it, playing the rollover sound.
--
-- When the panel is already transparent or animating, it is hidden at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the panel is hidden]
-- @return [Boolean `true` when the fade started, otherwise `nil`]
function PANEL:FadeOut(speed, Callback)
  if self:GetAlpha() > 0 and (!self.animation or !self.animation:Active()) then
    self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
      panel:SetAlpha(255 - (delta * 255))

      if animation.Finished then
        panel:SetVisible(false)
      end

      if animation.Finished and Callback then
        Callback()
      end
    end)

    if self.animation then
      self.animation:Start(speed)
    end

    cw.option:PlaySound('rollover')

    return true
  else
    self:SetAlpha(0)
    self:SetVisible(false)

    if Callback then
      Callback()
    end
  end
end

--- Shows the model panel and fades it in, playing the click sound.
--
-- When the panel is already visible or animating, it is made fully visible at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the panel is fully visible]
-- @return [Boolean `true` when the fade started, otherwise `nil`]
function PANEL:FadeIn(speed, Callback)
  if self:GetAlpha() == 0 and (!self.animation or !self.animation:Active()) then
    self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
      panel:SetAlpha(delta * 255)

      if animation.Finished then
        self.animation = nil
      end

      if animation.Finished and Callback then
        Callback()
      end
    end)

    if self.animation then
      self.animation:Start(speed)
    end

    cw.option:PlaySound('click_release')
    self:SetVisible(true)

    return true
  else
    self:SetVisible(true)
    self:SetAlpha(255)

    if Callback then
      Callback()
    end
  end
end

--- Sets the model panel's alpha by changing the alpha of its model color.
-- @param alpha [Number Alpha from 0 to 255]
function PANEL:SetAlpha(alpha)
  local color = self:GetColor()

  if color.a != alpha then
    self:SetColor(Color(color.r, color.g, color.b, alpha))
  end
end

--- Returns the model panel's alpha, taken from its model color.
-- @param alpha [Any Unused]
-- @return [Number Alpha from 0 to 255]
function PANEL:GetAlpha(alpha)
  local color = self:GetColor()

  return color.a
end

--- Runs the fade animation and keeps the panel at `forceX` when it is set.
function PANEL:Think()
  if self.animation then
    self.animation:Run()
  end

  if self.forceX then
    self.x = self.forceX
  end
end

--- Sets the markup tooltip shown when hovering the model.
-- @param details [String Markup text of the tooltip]
function PANEL:SetDetails(details)
  self:SetMarkupToolTip(details)
end

--- Bonemerges a weapon model onto the displayed model, or removes it.
--
-- Does nothing when the same weapon model is already shown.
--
-- @param weaponModel [String Weapon model path, or `false` to remove the current weapon]
function PANEL:SetWeaponModel(weaponModel)
  if !weaponModel and IsValid(self.weaponEntity) then
    self.weaponEntity:Remove()
    return
  end

  if !weaponModel and !IsValid(self.weaponEntity)
  or IsValid(self.weaponEntity) and self.weaponEntity:GetModel() == weaponModel then
    return
  end

  if IsValid(self.weaponEntity) then
    self.weaponEntity:Remove()
  end

  self.weaponEntity = ClientsideModel(weaponModel, RENDER_GROUP_OPAQUE_ENTITY)
  self.weaponEntity:SetParent(self.Entity)
  self.weaponEntity:AddEffects(EF_BONEMERGE)
end

--- Removes the displayed model and its weapon model when the panel is removed.
function PANEL:OnRemove()
  if IsValid(self.weaponEntity) then
    self.weaponEntity:Remove()
  end

  if IsValid(self.Entity) then
    self.Entity:Remove()
  end
end

--- Calls the panel's `DoClick` field, when set, on any mouse press.
function PANEL:OnMousePressed()
  if self.DoClick then
    self:DoClick()
  end
end

--- Turns the model's head towards the cursor, faces it at a fixed angle and runs its animation.
function PANEL:LayoutEntity()
  local screenW = ScrW()
  local screenH = ScrH()

  local fractionMX = gui.MouseX() / screenW
  local fractionMY = gui.MouseY() / screenH

  local entity = self.Entity
  local x, y = self:LocalToScreen(self:GetWide() / 2)
  local fx = x / screenW

  entity:SetPoseParameter('head_pitch', fractionMY * 80 - 30)
  entity:SetPoseParameter('head_yaw', (fractionMX - fx) * 70)
  entity:SetAngles(modelAngles)
  entity:SetIK(false)

  self:RunAnimation()
end

--- Sets up the model panel (`cw.characterModel`): hides the cursor, adds a markup tooltip and wraps
-- `SetModel` to pick an idle animation.
--
-- The wrapped `SetModel` plays the model's menu sequence from `cw.animation:GetMenuSequence` when it has
-- one, otherwise one of the `LineIdle` sequences or an idle or walk sequence. The original `SetModel` is
-- kept as `ClockworkSetModel`.
function PANEL:Init()
  self:SetCursor('none')
  self.ClockworkSetModel = self.SetModel

  self.SetModel = function(panel, model)
    panel:ClockworkSetModel(model)

    local entity = panel.Entity

    if !IsValid(entity) then
      return
    end

    -- The base panel creates a new entity for each model, so move the weapon model over to it.
    if IsValid(panel.weaponEntity) then
      panel.weaponEntity:SetParent(entity)
    end

    local sequence = entity:LookupSequence('idle')
    local menuSequence = cw.animation:GetMenuSequence(model, true)
    local leanBackAnims = { 'LineIdle01', 'LineIdle02', 'LineIdle03' }

    local leanBackAnim = entity:LookupSequence(
      leanBackAnims[math.random(1, #leanBackAnims)]
    )

    if leanBackAnim > 0 then
      sequence = leanBackAnim
    end

    if menuSequence then
      menuSequence = entity:LookupSequence(menuSequence)

      if menuSequence > 0 then
        sequence = menuSequence
      end
    end

    if sequence <= 0 then
      sequence = entity:LookupSequence('idle_unarmed')
    end

    if sequence <= 0 then
      sequence = entity:LookupSequence('idle1')
    end

    if sequence <= 0 then
      sequence = entity:LookupSequence('walk_all')
    end

    if sequence > 0 then
      entity:ResetSequence(sequence)
    end
  end

  cw.core:CreateMarkupToolTip(self)
end

vgui.Register('cw.characterModel', PANEL, 'DModelPanel')

local PANEL = {}

--- Builds an attribute row for character creation (`cw.characterAttribute`) with a points bar and add
-- and remove buttons.
function PANEL:Init()
  local colorWhite = cw.option:GetColor('white')
  local colorTargetID = cw.option:GetColor('target_id')

  self:SetSize(self:GetWide(), 16)
  self.totalPoints = 0
  self.maximumPoints = 0
  self.attributeTable = nil
  self.attributePanels = {}
  self:SetPaintBackground(false)

  cw.core:CreateMarkupToolTip(self)

  self.addButton = vgui.Create('DImageButton', self)
  self.addButton:SetMaterial('icon16/add.png')
  self.addButton:SizeToContents()

  -- Called when the button is clicked.
  function self.addButton.DoClick(imageButton)
    self:AddPoint()
  end

  self.removeButton = vgui.Create('DImageButton', self)
  self.removeButton:SetMaterial('icon16/exclamation.png')
  self.removeButton:SizeToContents()

  -- Called when the button is clicked.
  function self.removeButton.DoClick(imageButton)
    self:RemovePoint()
  end

  self.pointsUsed = vgui.Create('DPanel', self)
  self.pointsUsed:SetPos(self.addButton:GetWide() + 8, 0)
  cw.core:CreateMarkupToolTip(self.pointsUsed)

  self.pointsLabel = vgui.Create('DLabel', self)
  self.pointsLabel:SetText('N/A')
  self.pointsLabel:SetTextColor(colorWhite)
  self.pointsLabel:SizeToContents()
  self.pointsLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))
  cw.core:CreateMarkupToolTip(self.pointsLabel)

  -- Called when the panel should be painted.
  function self.pointsUsed.Paint(pointsUsed)
    local width =
      math.Clamp((pointsUsed:GetWide() / self.attributeTable.maximum) * self.totalPoints, 0, pointsUsed:GetWide())

    cw.core:DrawSimpleGradientBox(2, 0, 0, pointsUsed:GetWide(), pointsUsed:GetTall(), attributeBarColor)

    if self.totalPoints > 0 and self.totalPoints < self.attributeTable.maximum then
      cw.core:DrawSimpleGradientBox(0, 2, 2, width - 4, pointsUsed:GetTall() - 4, colorTargetID)
        surface.SetDrawColor(255, 255, 255, 200)
      surface.DrawRect(width, 0, 1, pointsUsed:GetTall())
    end
  end
end

--- Lays out the attribute row and refreshes its tooltip with the attribute's points and description when the
-- points change.
function PANEL:Think()
  if self.shownPoints != self.totalPoints then
    self.shownPoints = self.totalPoints

    self.pointsLabel:SetText(self.attributeTable.name)
    self.pointsLabel:SizeToContents()

    local markupObject = cw.theme:GetMarkupObject()
    local attributeName = cw.lang:TranslateText(self.attributeTable.name)
    local attributeMax = self.totalPoints..'/'..self.attributeTable.maximum

    markupObject:Title(attributeName..', '..attributeMax)
    markupObject:Add(self.attributeTable.description)

    local toolTip = markupObject:GetText()

    self:SetMarkupToolTip(toolTip)
    self.pointsUsed:SetMarkupToolTip(toolTip)
    self.pointsLabel:SetMarkupToolTip(toolTip)
  end

  self.pointsUsed:SetSize(self:GetWide() - (self.pointsUsed.x * 2), 16)
  self.pointsLabel:SetPos(
    self:GetWide() / 2 - self.pointsLabel:GetWide() / 2,
    self:GetTall() / 2 - self.pointsLabel:GetTall() / 2
  )
  self.addButton:SetPos(self.pointsUsed.x + self.pointsUsed:GetWide() + 8, 0)
end

--- Adds a point to the attribute when the shared point budget allows it.
function PANEL:AddPoint()
  local pointsUsed = self:GetPointsUsed()

  if pointsUsed + 1 <= self.maximumPoints then
    self.totalPoints = self.totalPoints + 1
  end
end

--- Removes a point from the attribute, never going below zero.
function PANEL:RemovePoint()
  self.totalPoints = math.max(self.totalPoints - 1, 0)
end

--- Returns the points given to this attribute.
-- @return [Number Points given to this attribute]
function PANEL:GetTotalPoints()
  return self.totalPoints
end

--- Returns the points spent on every attribute row in the group.
-- @return [Number Sum of the points of the panels set with `SetAttributePanels`]
function PANEL:GetPointsUsed()
  local pointsUsed = 0

  for k, v in pairs(self.attributePanels) do
    pointsUsed = pointsUsed + v:GetTotalPoints()
  end

  return pointsUsed
end

--- Returns the unique ID of the row's attribute.
-- @return [String The attribute's `uniqueID`]
function PANEL:GetAttributeID()
  return self.attributeTable.uniqueID
end

--- Sets the group of attribute rows that share the point budget.
-- @param attributePanels [List<Panel> The `cw.characterAttribute` rows of the creation step]
function PANEL:SetAttributePanels(attributePanels)
  self.attributePanels = attributePanels
end

--- Sets the attribute the row is for.
-- @param attributeTable [Attribute The attribute table]
function PANEL:SetAttributeTable(attributeTable)
  self.attributeTable = attributeTable
end

--- Sets the point budget shared by the group of attribute rows.
-- @param maximumPoints [Number Number of points that can be spent in total]
function PANEL:SetMaximumPoints(maximumPoints)
  self.maximumPoints = maximumPoints
end

vgui.Register('cw.characterAttribute', PANEL, 'DPanel')

local PANEL = {}

--- Builds the attributes creation step (`cw.characterStageFour`) with a row for each attribute shown on the
-- character screen.
--
-- The point budget is the `default_attribute_points` config value, scaled by the faction's
-- `attributePointsScale` or replaced by its `maximumAttributePoints`.
function PANEL:Init()
  self.info = cw.character:GetCreationInfo()

  local maximumPoints = config.GetVal('default_attribute_points')
  local smallTextFont = cw.option:GetFont('menu_text_small')
  local factionTable = faction.FindByID(self.info.faction)
  local attributes = {}

  if factionTable.attributePointsScale then
    maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale)
  end

  if factionTable.maximumAttributePoints then
    maximumPoints = factionTable.maximumAttributePoints
  end

  self.attributesForm = vgui.Create('DForm')
  self.attributesForm:SetName('#CharCreation_Attributes')
  self.attributesForm:SetPadding(4)

  self.categoryList = vgui.Create('DCategoryList', self)
  self.categoryList:SetPadding(2)
  self.categoryList:SizeToContents()

  for k, v in pairs(cw.attribute:GetAll()) do
    attributes[#attributes + 1] = v
  end

  table.sort(attributes, function(a, b)
    return a.name < b.name
  end)

  self.attributePanels = {}
  self.info.attributes = {}
  self.helpText = self.attributesForm:Help('#CharCreation_AttributesHelp:'..maximumPoints..';')

  for k, v in pairs(attributes) do
    if v.isOnCharScreen then
      local characterAttribute = vgui.Create('cw.characterAttribute', self.attributesForm)
        characterAttribute:SetAttributeTable(v)
        characterAttribute:SetMaximumPoints(maximumPoints)
        characterAttribute:SetAttributePanels(self.attributePanels)
      self.attributesForm:AddItem(characterAttribute)

      self.attributePanels[#self.attributePanels + 1] = characterAttribute
    end
  end

  self.maximumPoints = maximumPoints
  self.categoryList:AddItem(self.attributesForm)
end

--- Stores the points of each attribute in the creation info.
function PANEL:OnNext()
  for k, v in pairs(self.attributePanels) do
    self.info.attributes[v:GetAttributeID()] = v:GetTotalPoints()
  end
end

--- Draws nothing.
function PANEL:Paint(w, h) end

--- Fades the step out and hides it, playing the rollover sound.
--
-- When the step is already transparent or animating, it is hidden at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is hidden]
function PANEL:FadeOut(speed, Callback)
  FadeOutPanel(self, speed, Callback)
end

--- Shows the step and fades it in, playing the click sound.
--
-- When the step is already visible or animating, it is made fully visible at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is fully visible]
function PANEL:FadeIn(speed, Callback)
  FadeInPanel(self, speed, Callback)
end

--- Updates the remaining points text and runs the fade animation.
function PANEL:Think()
  self:InvalidateLayout(true)

  if self.helpText then
    local pointsLeft = self.maximumPoints

    for k, v in pairs(self.attributePanels) do
      pointsLeft = pointsLeft - v:GetTotalPoints()
    end

    if self.pointsLeft != pointsLeft then
      self.pointsLeft = pointsLeft
      self.helpText:SetText('#CharCreation_AttributesHelp:'..pointsLeft..';')
    end
  end

  if self.animation then
    self.animation:Run()
  end
end

--- Sizes the step to fit its attribute list, up to 60% of the screen height.
function PANEL:PerformLayout(w, h)
  self.categoryList:StretchToParent(0, 0, 0, 0)
  self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6))
end

vgui.Register('cw.characterStageFour', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds the class creation step (`cw.characterStageThree`) with a `cwClassesItem` for each class of the
-- chosen faction that is shown on the character screen.
--
-- Clicking a class stores its index as the creation info's `class`.
function PANEL:Init()
  self.info = cw.character:GetCreationInfo()

  self.classesForm = vgui.Create('DForm')
  self.classesForm:SetName('#CharCreation_Classes')
  self.classesForm:SetPadding(4)

  self.categoryList = vgui.Create('DCategoryList', self)
  self.categoryList:SetPadding(2)
  self.categoryList:SizeToContents()

  for k, v in pairs(cw.class:GetAll()) do
    if v.isOnCharScreen and (v.factions and table.HasValue(v.factions, self.info.faction)) then
      self.classTable = v
      self.overrideData = {
        information = '#CharCreation_ClassesHelp',
        Callback = function()
          self.info.class = v.index
        end
      }
      self.classesForm:AddItem(vgui.Create('cwClassesItem', self))
    end
  end

  self.categoryList:AddItem(self.classesForm)
end

--- Draws nothing.
function PANEL:Paint(w, h) end

--- Fades the step out and hides it, playing the rollover sound.
--
-- When the step is already transparent or animating, it is hidden at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is hidden]
function PANEL:FadeOut(speed, Callback)
  FadeOutPanel(self, speed, Callback)
end

--- Shows the step and fades it in, playing the click sound.
--
-- When the step is already visible or animating, it is made fully visible at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is fully visible]
function PANEL:FadeIn(speed, Callback)
  FadeInPanel(self, speed, Callback)
end

--- Runs the step's fade animation.
function PANEL:Think()
  self:InvalidateLayout(true)

  if self.animation then
    self.animation:Run()
  end
end

--- Checks that a valid class was picked, showing an error otherwise.
-- @return [Boolean `false` to stay on the step when no valid class is selected]
function PANEL:OnNext()
  if !self.info.class or !cw.class:FindByID(self.info.class) then
    cw.character:SetFault('#CharCreation_Classes_ErrorMessage')
    return false
  end
end

--- Sizes the step to fit its class list, up to 60% of the screen height.
function PANEL:PerformLayout(w, h)
  self.categoryList:StretchToParent(0, 0, 0, 0)
  self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6))
end

vgui.Register('cw.characterStageThree', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds the description creation step (`cw.characterStageTwo`): name entries, physical description and
-- model selection, depending on the chosen faction.
--
-- The name entries are left out when the faction has a `GetName` function, and use a single full name
-- entry when it sets `useFullName`. A model list is shown when the faction has no `GetModel` function and
-- more than one model for the chosen gender; with a single model, that model is used. The physical
-- description entry is shown when the `CharPhysDesc` command exists.
function PANEL:Init()
  local smallTextFont = cw.option:GetFont('menu_text_small')
  local panel = cw.character:GetPanel()

  self.categoryList = vgui.Create('DCategoryList', self)
  self.categoryList:SetPadding(2)
  self.categoryList:SizeToContents()

  self.overrideModel = nil
  self.bSelectModel = nil
  self.bPhysDesc = (cw.command:FindByID('CharPhysDesc') != nil)
  self.info = cw.character:GetCreationInfo()

  if !_faction.GetStored()[self.info.faction].GetModel then
    self.bSelectModel = true
  end

  local genderModels = faction.GetStored()[self.info.faction].models[string.lower(self.info.gender)]

  if genderModels and #genderModels == 1 then
    self.bSelectModel = false
    self.overrideModel = genderModels[1]

    if !panel:FadeInModelPanel(self.overrideModel) then
      panel:SetModelPanelModel(self.overrideModel)
    end
  end

  if !_faction.GetStored()[self.info.faction].GetName then
    self.nameForm = vgui.Create('DForm', self)
    self.nameForm:SetPadding(4)
    self.nameForm:SetName('#CharCreation_Name')

    if faction.GetStored()[self.info.faction].useFullName then
      self.fullNameTextEntry = self.nameForm:TextEntry('#CharCreation_FullName')
      self.fullNameTextEntry:SetAllowNonAsciiCharacters(true)
    else
      self.forenameTextEntry = self.nameForm:TextEntry('#CharCreation_Forename')
      self.forenameTextEntry:SetAllowNonAsciiCharacters(true)

      self.surnameTextEntry = self.nameForm:TextEntry('#CharCreation_Surname')
      self.surnameTextEntry:SetAllowNonAsciiCharacters(true)
    end
  end

  if self.bSelectModel or self.bPhysDesc then
    self.appearanceForm = vgui.Create('DForm')
    self.appearanceForm:SetPadding(4)
    self.appearanceForm:SetName('#CharCreation_Appearance')

    if self.bPhysDesc and self.bSelectModel then
      self.appearanceForm:Help('#CharCreation_AppearanceHelp1')
    elseif self.bPhysDesc then
      self.appearanceForm:Help('#CharCreation_AppearanceHelp2')
    end

    if self.bPhysDesc then
      self.physDescTextEntry = self.appearanceForm:TextEntry('#CharCreation_Description')
      self.physDescTextEntry:SetAllowNonAsciiCharacters(true)
    end

    if self.bSelectModel then
      self.modelItemsList = vgui.Create('DPanelList', self)
        self.modelItemsList:SetPadding(4)
        self.modelItemsList:SetSpacing(16)
        self.modelItemsList:EnableHorizontal(true)
        self.modelItemsList:EnableVerticalScrollbar(true)
      self.appearanceForm:AddItem(self.modelItemsList)
    end
  end

  if self.nameForm then
    self.categoryList:AddItem(self.nameForm)
  end

  if self.appearanceForm then
    self.categoryList:AddItem(self.appearanceForm)
  end

  local informationColor = cw.option:GetColor('information')
  local lowerGender = string.lower(self.info.gender)
  local spawnIcon = nil

  for k, v in pairs(faction.GetStored()) do
    if v.name == self.info.faction then
      if self.modelItemsList and v.models[lowerGender] then
        for k2, v2 in pairs(v.models[lowerGender]) do
          spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create('cwSpawnIcon', self))
          spawnIcon:SetModel(v2)

          -- Called when the spawn icon is clicked.
          function spawnIcon.DoClick(spawnIcon)
            if self.selectedSpawnIcon then
              self.selectedSpawnIcon:SetColor(nil)
            end

            spawnIcon:SetColor(informationColor)

            if !panel:FadeInModelPanel(v2) then
              panel:SetModelPanelModel(v2)
            end

            self.selectedSpawnIcon = spawnIcon
            self.selectedModel = v2
          end

          self.modelItemsList:AddItem(spawnIcon)
        end
      end
    end
  end
end

--- Validates the name, model and physical description and stores them in the creation info.
--
-- Forenames and surnames must be 2 to 16 characters long, contain a vowel and no punctuation, spaces or
-- digits. The physical description must be at least `minimum_physdesc` characters long. Shows the matching
-- error when a check fails.
--
-- @return [Boolean `false` to stay on the step when a check fails]
function PANEL:OnNext()
  if self.overrideModel then
    self.info.model = self.overrideModel
  else
    self.info.model = self.selectedModel
  end

  if !faction.GetStored()[self.info.faction].GetName then
    if IsValid(self.fullNameTextEntry) then
      self.info.fullName = self.fullNameTextEntry:GetValue()

      if self.info.fullName == '' then
        cw.character:SetFault('#CharCreation_Appearance_ErrorMessage1')
        return false
      end
    else
      self.info.forename = self.forenameTextEntry:GetValue()
      self.info.surname = self.surnameTextEntry:GetValue()

      if self.info.forename == '' or self.info.surname == '' then
        cw.character:SetFault('#CharCreation_Appearance_ErrorMessage1')
        return false
      end

      if string.find(self.info.forename, '[%p%s%d]') or string.find(self.info.surname, '[%p%s%d]') then
        cw.character:SetFault('#CharCreation_Appearance_ErrorMessage2')
        return false
      end

      if !string.find(self.info.forename, '[aeiou]') or !string.find(self.info.surname, '[aeiou]') then
        cw.character:SetFault('#CharCreation_Appearance_ErrorMessage3')
        return false
      end

      if string.utf8len(self.info.forename) < 2 or string.utf8len(self.info.surname) < 2 then
        cw.character:SetFault('#CharCreation_Appearance_ErrorMessage4')
        return false
      end

      if string.utf8len(self.info.forename) > 16 or string.utf8len(self.info.surname) > 16 then
        cw.character:SetFault('#CharCreation_Appearance_ErrorMessage5')
        return false
      end
    end
  end

  if self.bSelectModel and !self.info.model then
    cw.character:SetFault('#CharCreation_Appearance_ErrorMessage6')
    return false
  end

  if self.bPhysDesc then
    local minimumPhysDesc = config.GetVal('minimum_physdesc')
      self.info.physDesc = self.physDescTextEntry:GetValue()

    if string.utf8len(self.info.physDesc) < minimumPhysDesc then
      cw.character:SetFault('#CharCreation_Appearance_ErrorMessage7:'..minimumPhysDesc..';')
      return false
    end
  end
end

--- Draws nothing.
function PANEL:Paint(w, h) end

--- Fades the step out and hides it, playing the rollover sound.
--
-- When the step is already transparent or animating, it is hidden at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is hidden]
function PANEL:FadeOut(speed, Callback)
  FadeOutPanel(self, speed, Callback)
end

--- Shows the step and fades it in, playing the click sound.
--
-- When the step is already visible or animating, it is made fully visible at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is fully visible]
function PANEL:FadeIn(speed, Callback)
  FadeInPanel(self, speed, Callback)
end

--- Runs the step's fade animation.
function PANEL:Think()
  self:InvalidateLayout(true)

  if self.animation then
    self.animation:Run()
  end
end

--- Sizes the step to fit its forms, up to 60% of the screen height, with a 256 pixel tall model list.
function PANEL:PerformLayout(w, h)
  self.categoryList:StretchToParent(0, 0, 0, 0)

  if IsValid(self.modelItemsList) then
    self.modelItemsList:SetTall(256)
  end

  self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6))
end

vgui.Register('cw.characterStageTwo', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds the persuasion creation step (`cw.characterStageOne`) with faction and gender choices and the
-- custom choices from the `GetPersuasionChoices` hook.
--
-- Only factions the player is whitelisted for and that have not reached their maximum are offered. With
-- a single faction, that faction is used and only the gender is asked. Custom choices are combo boxes or,
-- when their `type` is `'textentry'`, text entries.
function PANEL:Init()
  local smallTextFont = cw.option:GetFont('menu_text_small')
  local factions = {}

  for k, v in pairs(faction.GetStored()) do
    if !v.whitelist or cw.character:IsWhitelisted(v.name) then
      if !faction.HasReachedMaximum(k) then
        factions[#factions + 1] = v.name
      end
    end
  end

  table.sort(factions, function(a, b)
    return a < b
  end)

  self.forcedFaction = nil
  self.info = cw.character:GetCreationInfo()

  self.categoryList = vgui.Create('DCategoryList', self)
  self.categoryList:SetPadding(2)
  self.categoryList:SizeToContents()

  self.settingsForm = vgui.Create('DForm')
  self.settingsForm:SetName('#CharCreation_Persuasion')
  self.settingsForm:SetPadding(4)

  if #factions > 1 then
    self.settingsForm:Help('#CharCreation_FactionHelp')
    self.factionMultiChoice = self.settingsForm:ComboBox('#CharCreation_Faction')

    -- Called when an option is selected.
    self.factionMultiChoice.OnSelect = function(multiChoice, index, value, data)
      for k, v in pairs(faction.GetStored()) do
        if v.name == data.__PhraseName then
          if IsValid(self.genderMultiChoice) then
            self.genderMultiChoice:Clear()
          else
            self.genderMultiChoice = self.settingsForm:ComboBox('#CharCreation_Gender')
            self.settingsForm:Rebuild()
          end

          if v.singleGender then
            self.genderMultiChoice:AddChoice(v.singleGender)
          else
            self.genderMultiChoice:AddChoice(L'#Gender_Female')
            self.genderMultiChoice:AddChoice(L'#Gender_Male')
          end

          cw.CurrentFactionSelected = { self, value }

          break
        end
      end
    end
  elseif #factions == 1 then
    for k, v in pairs(faction.GetStored()) do
      if v.name == factions[1] then
        self.genderMultiChoice = self.settingsForm:ComboBox('#CharCreation_Gender')

        if v.singleGender then
          self.genderMultiChoice:AddChoice(v.singleGender)
        else
          self.genderMultiChoice:AddChoice(L'#Gender_Female')
          self.genderMultiChoice:AddChoice(L'#Gender_Male')
        end

        cw.CurrentFactionSelected = { self, v.name }
        self.forcedFaction = v.name

        break
      end
    end
  end

  if self.factionMultiChoice then
    for k, v in pairs(factions) do
      self.factionMultiChoice:AddChoice(v, { __PhraseName = v })
    end
  end

  self.customChoices = {}
  hook.Run('GetPersuasionChoices', self.customChoices)

  if self.customChoices then
    self.customPanels = {}

    for k2, v2 in pairs(self.customChoices) do
      if !v2.type or string.lower(v2.type) == 'combobox' then
        table.insert(self.customPanels, { v2, self.settingsForm:ComboBox(v2.name) })

        for k3, v3 in ipairs(v2.choices) do
          self.customPanels[#self.customPanels][2]:AddChoice(v3)
        end
      elseif string.lower(v2.type) == 'textentry' then
        table.insert(self.customPanels, { v2, self.settingsForm:TextEntry(v2.name) })
      end
    end
  end

  self.categoryList:AddItem(self.settingsForm)
end

--- Validates the custom choices, faction and gender and stores them in the creation info.
--
-- Custom choice values are stored in the creation info's `plugin` table by choice name; choices with
-- `isNumber` must be numbers within their `min` and `max`. Shows the matching error when a check fails.
--
-- @return [Boolean `true` when the faction and gender are valid, `false` to stay on the step]
function PANEL:OnNext()
  self.info.plugin = {}

  if self.customPanels then
    for k, v in pairs(self.customPanels) do
      local value = v[2]:GetValue()

      if value == '' then
        cw.character:SetFault(L('#CharCreation_DidntFill:'..v[1].name..';'))
        return false
      elseif v[1].isNumber then
        local max = v[1].max
        local min = v[1].min

        if !tonumber(value) then
          cw.character:SetFault(L('#CharCreation_DidntFillWithNumber:'..v[1].name..';'))
          return false
        end

        if max and max < tonumber(value) then
          cw.character:SetFault(L('#CharCreation_CantGoHigh:'..tostring(max)..','..v[1].name..';'))
          return false
        end

        if min and min > tonumber(value) then
          cw.character:SetFault(L('#CharCreation_CantGoLow:'..tostring(min)..','..v[1].name..';'))
          return false
        end
      end

      self.info.plugin[v[1].name] = value
    end
  end

  if IsValid(self.genderMultiChoice) then
    local faction = self.forcedFaction
    local data = {}
    -- Single-gender factions list the gender untranslated, so both spellings are accepted.
    local translate = {
      [GENDER_FEMALE] = GENDER_FEMALE,
      [GENDER_MALE] = GENDER_MALE,
      [cw.lang:TranslateText('#Gender_Female')] = GENDER_FEMALE,
      [cw.lang:TranslateText('#Gender_Male')] = GENDER_MALE
    }

    local gender = translate[self.genderMultiChoice:GetValue()]

    if !faction and self.factionMultiChoice then
      faction, data = self.factionMultiChoice:GetSelected()
    end

    for k, v in pairs(_faction.GetStored()) do
      if v.name == data.__PhraseName or v.name == faction then
        if _faction.IsGenderValid(faction, gender) then
          self.info.faction = faction
          self.info.gender = gender

          return true
        end
      end
    end
  end

  cw.character:SetFault('#CharCreation_Persuasion_ErrorMessage')

  return false
end

--- Draws nothing.
function PANEL:Paint(w, h) end

--- Fades the step out and hides it, playing the rollover sound.
--
-- When the step is already transparent or animating, it is hidden at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is hidden]
function PANEL:FadeOut(speed, Callback)
  FadeOutPanel(self, speed, Callback)
end

--- Shows the step and fades it in, playing the click sound.
--
-- When the step is already visible or animating, it is made fully visible at once.
--
-- @param speed [Number Length of the fade in seconds]
-- @param Callback=nil [Function Called once the step is fully visible]
function PANEL:FadeIn(speed, Callback)
  FadeInPanel(self, speed, Callback)
end

--- Runs the step's fade animation.
function PANEL:Think()
  self:InvalidateLayout(true)

  if self.animation then
    self.animation:Run()
  end
end

--- Sizes the step to fit its form, up to 60% of the screen height.
function PANEL:PerformLayout(w, h)
  self.categoryList:StretchToParent(0, 0, 0, 0)
  self:SetSize(512, math.min(self.categoryList.pnlCanvas:GetTall() + 8, ScrH() * 0.6))
end

vgui.Register('cw.characterStageOne', PANEL, 'EditablePanel')

netstream.Hook('CharacterRemove', function(data)
  local characters = cw.character:GetAll()
  local characterID = data

  if table.Count(characters) == 0 then
    return
  end

  if !characters[characterID] then
    return
  end

  characters[characterID] = nil

  if !cw.character:IsPanelLoading() then
    cw.character:RefreshPanelList()
  end

  if cw.character:GetPanelList() then
    if table.Count(characters) == 0 then
      cw.character:GetPanel():ReturnToMainMenu()
    end
  end
end)

netstream.Hook('SetWhitelisted', function(data)
  local whitelisted = cw.character:GetWhitelisted()

  for k, v in pairs(whitelisted) do
    if v == data[1] then
      if !data[2] then
        table.remove(whitelisted, k)
      end

      return
    end
  end

  if data[2] then
    whitelisted[#whitelisted + 1] = data[1]
  end
end)

netstream.Hook('CharacterAdd', function(data)
  cw.character:Add(data.characterID, data)

  if !cw.character:IsPanelLoading() then
    cw.character:RefreshPanelList()
  end
end)

netstream.Hook('CharacterMenu', function(data)
  local menuState = data

  if menuState == CHARACTER_MENU_LOADED then
    if cw.character:GetPanel() then
      cw.character:SetPanelLoading(false)
      cw.character:RefreshPanelList()

      local numCharacters = table.Count(cw.character:GetAll())

      if numCharacters == 0 then
        cw.character:ResetCreationInfo()
        cw.character:OpenNextCreationPanel()
      end
    end
  elseif menuState == CHARACTER_MENU_CLOSE then
    cw.character:SetPanelOpen(false)
  elseif menuState == CHARACTER_MENU_OPEN then
    cw.character:SetPanelOpen(true)
  end
end)

netstream.Hook('CharacterOpen', function(data)
  cw.character:SetPanelOpen(true)

  if data then
    cw.character.isMenuReset = true
  end
end)

netstream.Hook('CharacterFinish', function(data)
  if data.bSuccess then
    cw.character:SetPanelMainMenu()
    cw.character:SetPanelOpen(false, true)
    cw.character:SetFault(nil)
  else
    cw.character:SetFault(data.fault)
  end
end)

cw.character:RegisterCreationPanel('#CharCreation_Persuasion', 'cw.characterStageOne')
cw.character:RegisterCreationPanel('#CharCreation_Description', 'cw.characterStageTwo')

cw.character:RegisterCreationPanel('#CharCreation_DefaultClass', 'cw.characterStageThree', nil,
  function(info)
    local classTable = cw.class:GetAll()

    if table.Count(classTable) > 0 then
      for k, v in pairs(classTable) do
        if v.isOnCharScreen and (v.factions
        and table.HasValue(v.factions, info.faction)) then
          return true
        end
      end
    end

    return false
  end
)

cw.character:RegisterCreationPanel(
  cw.option:GetKey('name_attributes'), 'cw.characterStageFour', nil,
  function(info)
    local attributeTable = cw.attribute:GetAll()

    if table.Count(attributeTable) > 0 then
      for k, v in pairs(attributeTable) do
        if v.isOnCharScreen then
          return true
        end
      end
    end

    return false
  end
)
