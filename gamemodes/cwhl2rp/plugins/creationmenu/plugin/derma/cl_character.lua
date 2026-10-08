--- Defines the `cw.characterMenu` panel of the Left-Side Menu plugin, a replacement for the framework's main character
-- menu with its buttons stacked on the left side of the screen.
--
-- It registers under the same name as the core panel, so it overrides it. The panel holds the schema title and logo,
-- the new, load, community, forum and leave buttons, the previous, cancel and next navigation of character creation
-- with a progress bar of the creation steps, and the `cw.characterModel` preview; `OpenPanel` swaps the active
-- sub-panel such as `cw.characterList`. The community and forum buttons are driven by the `community_*` and `forum_*`
-- config keys, and most steps can be overridden by theme hooks like `PreCharacterMenuInit`.

-- Reused every frame by `PANEL:Paint` instead of allocating new colors.
local barColor = Color(0, 0, 0, 100)
local progressBarColor = Color(0, 0, 0, 100)
local stepTextColor = Color(255, 255, 255, 200)

local PANEL = {}

--- Builds the main menu with its title, buttons and character model preview.
--
-- Creates the schema title and credits, the community, new, load, forum and leave buttons, the
-- creation navigation buttons and the model preview.
-- Skipped when the theme's `PreCharacterMenuInit` returns true; calls `PostCharacterMenuInit` after.
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
    self.subLabel:SetFont(tinyTextFont)
    self.subLabel:SetText(cw.lang:TranslateText('#HL2RP_Description'):utf8upper())
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

    self.communityButton = vgui.Create('cwLabelButton', self)
    self.communityButton:SetFont(smallTextFont)
    self.communityButton:SetText(cw.lang:TranslateText('#MainMenu_Forum'):utf8upper())
    self.communityButton:SetContentAlignment(4)
    self.communityButton:FadeIn(0.5)
    self.communityButton:SetCallback(function(panel)
      gui.OpenURL('https://iron-wall.com/')
    end)

    self.communityButton:SizeToContents()
    self.communityButton:SetMouseInputEnabled(true)
    self.communityButton:SetPos(scrW * 0.1, scrH * 0.65)

    self.createButton = vgui.Create('cwLabelButton', self)
    self.createButton:SetFont(smallTextFont)
    self.createButton:SetText(cw.lang:TranslateText('#MainMenu_New'):utf8upper())
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
    self.createButton:SetPos(scrW * 0.1, scrH * 0.72)

    self.loadButton = vgui.Create('cwLabelButton', self)
    self.loadButton:SetFont(smallTextFont)
    self.loadButton:SetText(cw.lang:TranslateText('#MainMenu_Load'):utf8upper())
    self.loadButton:SetContentAlignment(4)
    self.loadButton:FadeIn(0.5)
    self.loadButton:SetCallback(function(panel)
      self:OpenPanel('cw.characterList', nil, function(panel)
        cw.character:RefreshPanelList()
      end)
    end)

    self.loadButton:SizeToContents()
    self.loadButton:SetMouseInputEnabled(true)
    self.loadButton:SetPos(scrW * 0.1, scrH * 0.79)

    self.forumButton = vgui.Create('cwLabelButton', self)
    self.forumButton:SetFont(smallTextFont)
    self.forumButton:SetText(cw.lang:TranslateText('#MainMenu_Forum'):utf8upper())
    self.forumButton:SetContentAlignment(4)
    self.forumButton:FadeIn(0.5)
    self.forumButton:SetCallback(function(panel)
      gui.OpenURL('http://404')
    end)

    self.forumButton:SizeToContents()
    self.forumButton:SetMouseInputEnabled(true)
    self.forumButton:SetPos(scrW * 0.1, scrH * 0.86)

    self.disconnectButton = vgui.Create('cwLabelButton', self)
    self.disconnectButton:SetFont(smallTextFont)
    self.disconnectButton:SetText(cw.lang:TranslateText('#MainMenu_Leave'):utf8upper())
    self.disconnectButton:SetContentAlignment(4)
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
    self.disconnectButton:SetMouseInputEnabled(true)
    self.disconnectButton:SetPos(scrW * 0.1, self.forumButton.y + (scrH * 0.07))

    self.previousButton = vgui.Create('cwLabelButton', self)
    self.previousButton:SetFont(tinyTextFont)
    self.previousButton:SetText(cw.lang:TranslateText('#CharCreation_Previous'):utf8upper())
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
    self.nextButton:SetText(cw.lang:TranslateText('#CharCreation_Next'):utf8upper())
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
    self.cancelButton:SetText(cw.lang:TranslateText('#CharCreation_Cancel'):utf8upper())
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

--- Moves the character model preview next to the active panel and fades it in with a model.
--
-- Does nothing on screens shorter than 768 pixels.
-- @param model [String Model path to show]
-- @return [Boolean `true` when the screen is too small or the fade started, `false` if the preview was
--   already visible or fading]
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

--- Fades out the character model preview.
function PANEL:FadeOutModelPanel()
  self.characterModel:FadeOut(0.5)
end

--- Sets the model shown in the character model preview.
--
-- Also applies the weapon model from the `GetModelSelectWeaponModel` hook and the sequence
-- from the `GetModelSelectSequence` hook, when they return one.
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

--- Closes the active panel and returns to the title screen.
--
-- Fades out and removes the active panel, then fades the title back in and hides the model
-- preview and the creation navigation.
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

--- Fades out the previous, cancel and next buttons, unless the theme's `PreCharacterFadeOutNavigation` returns true.
function PANEL:FadeOutNavigation()
  if !cw.theme:Call('PreCharacterFadeOutNavigation', self) then
    self.previousButton:FadeOut(0.5)
    self.cancelButton:FadeOut(0.5)
    self.nextButton:FadeOut(0.5)
  end
end

--- Fades in the previous, cancel and next buttons, unless the theme's `PreCharacterFadeInNavigation` returns true.
function PANEL:FadeInNavigation()
  if !cw.theme:Call('PreCharacterFadeInNavigation', self) then
    self.previousButton:FadeIn(0.5)
    self.cancelButton:FadeIn(0.5)
    self.nextButton:FadeIn(0.5)
  end
end

--- Fades out the title, credits and main menu buttons, unless the theme's `PreCharacterFadeOutTitle` returns true.
function PANEL:FadeOutTitle()
  if !cw.theme:Call('PreCharacterFadeOutTitle', self) then
    self.subLabel:FadeOut(0.5)
    self.titleLabel:FadeOut(0.5)
    self.authorLabel:FadeOut(0.5)
    self.lmaoCopyright:FadeOut(0.5)
    self.communityButton:FadeOut(0.5)
    self.createButton:FadeOut(0.5)
    self.loadButton:FadeOut(0.5)
    self.forumButton:FadeOut(0.5)
    self.disconnectButton:FadeOut(0.5)

    self.bTitleHidden = true
  end
end

--- Fades in the title, credits and main menu buttons, unless the theme's `PreCharacterFadeInTitle` returns true.
function PANEL:FadeInTitle()
  if !cw.theme:Call('PreCharacterFadeInTitle', self) then
    self.subLabel:FadeIn(0.5)
    self.titleLabel:FadeIn(0.5)
    self.authorLabel:FadeIn(0.5)
    self.lmaoCopyright:FadeIn(0.5)
    self.communityButton:FadeIn(0.5)
    self.createButton:FadeIn(0.5)
    self.loadButton:FadeIn(0.5)
    self.forumButton:FadeIn(0.5)
    self.disconnectButton:FadeIn(0.5)

    self.bTitleHidden = false
  end
end

--- Opens a panel inside the character menu, replacing the active one.
--
-- The previous active panel fades out and is removed first; otherwise the title fades out.
-- The new panel becomes `cw.character.activePanel`. Passing `childData` marks it as part of the
-- creation process and shows the navigation buttons. Skipped when the theme's
-- `PreCharacterMenuOpenPanel` returns true.
--
-- ```
-- self:OpenPanel('cw.characterList', nil, function(panel)
--   cw.character:RefreshPanelList()
-- end)
-- ```
--
-- @param vguiName [String Registered name of the panel to create]
-- @param childData=nil [Any Creation step data; stored as `self.childData`]
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

--- Draws the schema logo, the header bar and, during character creation, the progress bar with each step's name.
-- @return [Boolean Always `true`, so Derma skips its default painting]
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

--- Updates the menu every frame: background blur, button visibility, disabled states and labels.
--
-- Buttons follow the `community_button_enable` and `forum_button_enable` configs, and the new
-- and load buttons are disabled when the character limit is reached or characters are loading.
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

    local bCommunityEnabled = config.GetVal('community_button_enable') and true or false
    local bForumEnabled = config.GetVal('forum_button_enable') and true or false
    local communityButton = self.communityButton
    local forumButton = self.forumButton

    -- Once the title has faded out these two stay hidden, or they would be invisible but still clickable.
    communityButton:SetVisible(bCommunityEnabled and (!self.bTitleHidden or communityButton:GetAlpha() > 0))
    forumButton:SetVisible(bForumEnabled and (!self.bTitleHidden or forumButton:GetAlpha() > 0))

    -- The leave button takes the forum button's place while that one is disabled.
    if self.bForumEnabled != bForumEnabled then
      self.bForumEnabled = bForumEnabled

      if bForumEnabled then
        self.disconnectButton:SetPos(ScrW() * 0.1, forumButton.y + (ScrH() * 0.07))
      else
        self.disconnectButton:SetPos(ScrW() * 0.1, forumButton.y)
      end
    end

    local communityName = config.GetVal('community_name')

    if isstring(communityName) and self.communityName != communityName then
      self.communityName = communityName

      communityButton:SetText(string.utf8upper(communityName))
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
