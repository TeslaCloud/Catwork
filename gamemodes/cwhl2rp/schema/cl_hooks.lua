--- Client-side hooks of the HL2RP schema, defined on `Schema`.
--
-- They draw the Combine display lines, overlay and the stun and flash screen effects, build the permits form of the
-- business menu, and adjust the scoreboard, target IDs, class menu and entity menu options for the Combine, citizen
-- and scanner roles. `Schema:Initialize` also creates the `catwork` data folder and downloads the developer scoreboard
-- icons into it.

--- Called when the gamemode initializes on the client.
--
-- Creates the `catwork` data folder and downloads the developer scoreboard icons into it with
-- `Schema:DownloadMaterial`.
function Schema:Initialize()
  if !file.Exists('catwork', 'DATA') then
    file.CreateDir('catwork')
  end

  self:DownloadMaterial('http://teslacdn.net/files/meow/icon_mrmeow.png', 'catwork/icon_mrmeow.png')
  self:DownloadMaterial('http://teslacdn.net/files/meow/icon_luna.png', 'catwork/icon_luna.png')
end

--- Called when the local player's business menu is rebuilt.
--
-- Remembers the panel in `Schema.businessPanel` and, when permits are enabled and the local player is a
-- citizen, adds a permits form listing the total cost of each permit they lack (general goods and
-- `Schema.customPermits`). Players without the `x` flag see a single entry for creating a business.
-- @param panel [Panel The business menu panel]
-- @param categories [List<Map> The orderable item categories, each with `category` and `itemsList`]
function Schema:PlayerBusinessRebuilt(panel, categories)
  local businessName = cw.option:GetKey('name_business', true)

  if !self.businessPanel then
    self.businessPanel = panel
  end

  if config.Get('permits'):Get() and cw.client:GetFaction() == FACTION_CITIZEN then
    local permits = {}

    for k, v in pairs(item.GetAll()) do
      if v.cost and v.access and !cw.core:HasObjectAccess(cw.client, v) then
        if string.find(v.access, '1') then
          permits.generalGoods = (permits.generalGoods or 0) + (v.cost * v.batch)
        else
          for k2, v2 in pairs(Schema.customPermits) do
            if string.find(v.access, v2.flag) then
              permits[v2.key] = (permits[v2.key] or 0) + (v.cost * v.batch)

              break
            end
          end
        end
      end
    end

    if table.Count(permits) > 0 then
      local panelList = vgui.Create('DPanelList', panel)

      panel.permitsForm = vgui.Create('DForm')
      panel.permitsForm:SetName('#Business_Permits')
      panel.permitsForm:SetPadding(4)

      panelList:SetAutoSize(true)
      panelList:SetPadding(4)
      panelList:SetSpacing(4)

      if cw.player:HasFlags(cw.client, 'x') then
        for k, v in pairs(permits) do
          panel.customData = { information = v }

          if k == 'generalGoods' then
            panel.customData.description = L('#Business_GeneralGoodsDesc')
            panel.customData.Callback = function()
              cw.core:RunCommand('PermitBuy', 'generalgoods')
            end

            panel.customData.model = 'models/props_junk/cardboard_box004a.mdl'
            panel.customData.name = '#Business_GeneralGoods'
          else
            for k2, v2 in pairs(Schema.customPermits) do
              if v2.key == k then
                panel.customData.description = L('#Business_CustomPermitDesc:'..string.lower(v2.name)..';')
                panel.customData.Callback = function()
                  cw.core:RunCommand('PermitBuy', k2)
                end

                panel.customData.model = v2.model
                panel.customData.name = v2.name

                break
              end
            end
          end

          panelList:AddItem(vgui.Create('cwBusinessCustom', panel))
        end
      else
        panel.customData = {
          description = L('#Business_CreateDesc'),
          information = config.Get('business_cost'):Get(),
          Callback = function()
            cw.core:RunCommand('PermitBuy', 'business')
          end,
          model = 'models/props_c17/briefcase001a.mdl',
          name = '#Business_Create'
        }

        panelList:AddItem(vgui.Create('cwBusinessCustom', panel))
      end

      panel.permitsForm:AddItem(panelList)
      panel.panelList:AddItem(panel.permitsForm)
    end
  end
end

--- Called when the fade distance of a player's target ID is needed.
--
-- Returns `512` while the local player controls a scanner, so targets stay visible from further away.
-- @param player [Player The player being looked at]
-- @return [Number The fade distance, or `nil` for the default]
function Schema:GetTargetPlayerFadeDistance(player)
  if IsValid(self:GetScannerEntity(cw.client)) then
    return 512
  end
end

--- Called when an entity's menu options are needed.
--
-- Adds the Loot option to corpses, Open to belongings, Charge to breaches and turn on/off, set
-- frequency and take options to stationary radios.
-- @param entity [Entity The entity the menu is for]
-- @param options [Map Option names mapped to a menu option string or a callback, filled in place]
function Schema:GetEntityMenuOptions(entity, options)
  if entity:GetClass() == 'prop_ragdoll' then
    local player = cw.entity:GetPlayer(entity)

    if !player or !player:Alive() then
      options[L'Loot'] = 'cw_corpseLoot'
    end
  elseif entity:GetClass() == 'cw_belongings' then
    options[L'Open'] = 'cw_belongingsOpen'
  elseif entity:GetClass() == 'cw_breach' then
    options[L'Charge'] = 'cw_breachCharge'
  elseif entity:GetClass() == 'cw_radio' then
    if !entity:IsOff() then
      options[L'Turn Off'] = 'cw_radioToggle'
    else
      options[L'Turn On'] = 'cw_radioToggle'
    end

    options[L'Set Frequency'] = function()
      Derma_StringRequest('#Radio_Frequency_Title', '#Radio_Frequency_Request', frequency, function(text)
        if IsValid(entity) then
          cw.entity:ForceMenuOption(entity, 'Set Frequency', text)
        end
      end)
    end

    options['#EntityMenuOptions_Take'] = 'cw_radioTake'
  end
end

--- Called when the position of a player's typing display is needed.
--
-- Places the display above the body bone of the player's scanner when they control one.
-- @param player [Player The player who is typing]
-- @return [Vector The display position, or `nil` for the default]
function Schema:GetPlayerTypingDisplayPosition(player)
  local scannerEntity = self:GetScannerEntity(player)

  if IsValid(scannerEntity) then
    local position = nil
    local physBone = scannerEntity:LookupBone('Scanner.Body')
    local curTime = CurTime()

    if physBone then
      position = scannerEntity:GetBonePosition(physBone)
    end

    if !position then
      return scannerEntity:GetPos() + Vector(0, 0, 8)
    else
      return position
    end
  end
end

--- Called when an entity's target ID should be painted.
--
-- Draws the physical description of props and the name and title of named NPCs.
-- @param entity [Entity The entity being looked at]
-- @param info [Map Drawing state with `x`, `y` and `alpha`; `y` is advanced past each drawn line]
function Schema:HUDPaintEntityTargetID(entity, info)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')

  if entity:GetClass() == 'prop_physics' then
    local physDesc = entity:GetNWString('physDesc')

    if physDesc != '' then
      info.y = cw.core:DrawInfo(physDesc, info.x, info.y, colorWhite, info.alpha)
    end
  elseif entity:IsNPC() then
    local name = entity:GetNWString('cw_Name')
    local title = entity:GetNWString('cw_Title')

    if name != '' and title != '' then
      info.y = cw.core:DrawInfo(name, info.x, info.y, Color(255, 255, 100, 255), info.alpha)
      info.y = cw.core:DrawInfo(title, info.x, info.y, Color(255, 255, 255, 255), info.alpha)
    end
  end
end

--- Called when a text entry gains focus; remembers it for `Schema:IsTextEntryBeingUsed`.
-- @param panel [Panel The focused text entry]
function Schema:OnTextEntryGetFocus(panel)
  self.textEntryFocused = panel
end

--- Called when a text entry loses focus; clears the entry remembered by `Schema:OnTextEntryGetFocus`.
-- @param panel [Panel The text entry that lost focus]
function Schema:OnTextEntryLoseFocus(panel)
  self.textEntryFocused = nil
end

--- Called when screen space effects should be rendered.
--
-- Draws the colour shift and motion blur of an active flash effect and the Combine visor overlay
-- for Combine players, unless the screen is faded to black.
function Schema:RenderScreenspaceEffects()
  if !cw.core:IsScreenFadedBlack() then
    local curTime = CurTime()

    if self.flashEffect then
      local timeLeft = math.Clamp(self.flashEffect[1] - curTime, 0, self.flashEffect[2])
      local incrementer = 1 / self.flashEffect[2]

      if timeLeft > 0 then
        modify = {}

        modify['$pp_colour_brightness'] = 0
        modify['$pp_colour_contrast'] = 1 + (timeLeft * incrementer)
        modify['$pp_colour_colour'] = 1 - (incrementer * timeLeft)
        modify['$pp_colour_addr'] = incrementer * timeLeft
        modify['$pp_colour_addg'] = 0
        modify['$pp_colour_addb'] = 0
        modify['$pp_colour_mulr'] = 1
        modify['$pp_colour_mulg'] = 0
        modify['$pp_colour_mulb'] = 0

        DrawColorModify(modify)

        if !self.flashEffect[3] then
          DrawMotionBlur(1 - (incrementer * timeLeft), incrementer * timeLeft, self.flashEffect[2])
        end
      end
    end

    if self:PlayerIsCombine(cw.client) then
      render.UpdateScreenEffectTexture()

      self.combineOverlay:SetFloat('$refractamount', 0.3)
      self.combineOverlay:SetFloat('$envmaptint', 0)
      self.combineOverlay:SetFloat('$envmap', 0)
      self.combineOverlay:SetFloat('$alpha', 0.5)
      self.combineOverlay:SetInt('$ignorez', 1)

      render.SetMaterial(self.combineOverlay)
      render.DrawScreenQuad()
    end
  end
end

--- Called when the local player's motion blurs should be adjusted.
--
-- Adds the `flash` blur while a stun-style flash effect (see `Schema:AddStunEffect`) is active.
-- @param motionBlurs [Map Motion blur state; its `blurTable` maps blur names to amounts]
function Schema:PlayerAdjustMotionBlurs(motionBlurs)
  if !cw.core:IsScreenFadedBlack() then
    local curTime = CurTime()

    if self.flashEffect and self.flashEffect[3] then
      local timeLeft = math.Clamp(self.flashEffect[1] - curTime, 0, self.flashEffect[2])
      local incrementer = 1 / self.flashEffect[2]

      if timeLeft > 0 then
        motionBlurs.blurTable['flash'] = 1 - (incrementer * timeLeft)
      end
    end
  end
end

--- Called when the cinematic intro info is needed.
-- @return [Map The intro's `credits`, `title` and `text`, taken from the `intro_text_big` and
-- `intro_text_small` config values]
function Schema:GetCinematicIntroInfo()
  return {
    credits = '#HL2RP_Credits:'..self:GetAuthor()..';',
    title = config.Get('intro_text_big'):Get(),
    text = config.Get('intro_text_small'):Get()
  }
end

--- Called when the players of a scoreboard class should be sorted.
--
-- Sorts Civil Protection and Overwatch players by Combine rank, then by name.
-- @param class [String The scoreboard class name]
-- @param a [Player The first player to compare]
-- @param b [Player The second player to compare]
-- @return [Boolean Whether `a` comes before `b`, or `nil` for other classes]
function Schema:ScoreboardSortClassPlayers(class, a, b)
  if class == '#Faction_MPF' or class == '#Faction_OTA' then
    local rankA = self:GetPlayerCombineRank(a)
    local rankB = self:GetPlayerCombineRank(b)

    if rankA == rankB then
      return a:Name() < b:Name()
    else
      return rankA > rankB
    end
  end
end

--- Called when a player's scoreboard class is needed.
--
-- Uses the player's custom class when set, and groups Civil Protection and Overwatch under their faction.
-- @param player [Player The player on the scoreboard]
-- @return [String The scoreboard class name, or `nil` for the default]
function Schema:GetPlayerScoreboardClass(player)
  local customClass = player:GetNetVar('customClass')
  local faction = player:GetFaction()

  if customClass != '' then
    return customClass
  end

  if faction == FACTION_MPF then
    return '#Faction_MPF'
  elseif faction == FACTION_OTA then
    return '#Faction_OTA'
  end
end

--- Called when the faction shown for a character on the character screen is needed.
-- @param character [Character The character's data]
-- @return [String The character's custom class, or `nil` when it has none]
function Schema:GetPlayerCharacterScreenFaction(character)
  if character.customClass and character.customClass != '' then
    return character.customClass
  end
end

--- Called when the local player attempts to zoom; only Combine players may zoom.
-- @return [Boolean `false` to block the zoom]
function Schema:PlayerCanZoom()
  if !self:PlayerIsCombine(cw.client) then
    return false
  end
end

--- Called when a player's scoreboard options are needed.
--
-- Adds server whitelist, custom class and permakill options, each only when the command exists and the
-- local player has its access flags. The options run the matching commands.
-- @param player [Player The player the options are for]
-- @param options [Map Option names mapped to callbacks or sub-option maps, filled in place]
-- @param menu [Panel The scoreboard menu]
function Schema:GetPlayerScoreboardOptions(player, options, menu)
  if cw.command:FindByID('PlyAddServerWhitelist')
  or cw.command:FindByID('PlyRemoveServerWhitelist') then
    if cw.player:HasFlags(cw.client, cw.command:FindByID('PlyAddServerWhitelist').access) then
      options['#ScoreboardOptions_ServerWhitelist'] = {}

      if cw.command:FindByID('PlyAddServerWhitelist') then
        options['#ScoreboardOptions_ServerWhitelist']['#ScoreboardOptions_ServerWhitelist_Add'] = function()
          Derma_StringRequest(player:Name(), '#ScoreboardOptions_ServerWhitelist_Add_StringRequest', '', function(text)
            cw.core:RunCommand('PlyAddServerWhitelist', player:Name(), text)
          end)
        end
      end

      if cw.command:FindByID('PlyRemoveServerWhitelist') then
        options['#ScoreboardOptions_ServerWhitelist']['#ScoreboardOptions_ServerWhitelist_Remove'] = function()
          Derma_StringRequest(
            player:Name(),
            '#ScoreboardOptions_ServerWhitelist_Remove_StringRequest',
            '',
            function(text)
              cw.core:RunCommand('PlyRemoveServerWhitelist', player:Name(), text)
            end
          )
        end
      end
    end
  end

  if cw.command:FindByID('CharSetCustomClass') then
    if cw.player:HasFlags(cw.client, cw.command:FindByID('CharSetCustomClass').access) then
      options['#ScoreboardOptions_CustomClass'] = {}
      options['#ScoreboardOptions_CustomClass']['#ScoreboardOptions_CustomClass_Set'] = function()
        Derma_StringRequest(
          player:Name(),
          '#ScoreboardOptions_CustomClass_Set_StringRequest',
          player:GetNetVar('customClass'),
          function(text)
            cw.core:RunCommand('CharSetCustomClass', player:Name(), text)
          end
        )
      end

      if player:GetNetVar('customClass') != '' then
        options['#ScoreboardOptions_CustomClass']['#ScoreboardOptions_CustomClass_Take'] = function()
          cw.core:RunCommand('CharTakeCustomClass', player:Name())
        end
      end
    end
  end

  if cw.command:FindByID('CharPermaKill') then
    if cw.player:HasFlags(cw.client, cw.command:FindByID('CharPermaKill').access) then
      options['#ScoreboardOptions_CharPermaKill'] = function()
        cw.core:RunCommand('CharPermaKill', player:Name())
      end
    end
  end
end

--- Called when a player's scoreboard info should be adjusted.
--
-- Shows scanner units with the scanner or shield scanner model.
-- @param info [Map The scoreboard entry; `player` is the player and `model` may be replaced]
function Schema:ScoreboardAdjustPlayerInfo(info)
  if self:IsPlayerCombineRank(info.player, 'SCN') then
    if self:IsPlayerCombineRank(info.player, 'SYNTH') then
      info.model = 'models/shield_scanner.mdl'
    else
      info.model = 'models/combine_scanner.mdl'
    end
  end
end

--- Called when the model shown for a class in the class menu should be adjusted.
--
-- Shows the scanner class with the scanner or shield scanner model.
-- @param class [Number The class index, compared against `CLASS_MPS`]
-- @param info [Map The model info; `model` may be replaced]
function Schema:PlayerAdjustClassModelInfo(class, info)
  if class == CLASS_MPS then
    if self:IsPlayerCombineRank(cw.client, 'SCN')
    and self:IsPlayerCombineRank(cw.client, 'SYNTH') then
      info.model = 'models/shield_scanner.mdl'
    else
      info.model = 'models/combine_scanner.mdl'
    end
  end
end

--- Called when the local player's default colour modification should be set.
--
-- Darkens and desaturates the screen for the schema's look.
-- @param colorModify [Map `$pp_colour_*` values, set in place]
function Schema:PlayerSetDefaultColorModify(colorModify)
  colorModify['$pp_colour_brightness'] = -0.02
  colorModify['$pp_colour_contrast'] = 1.2
  colorModify['$pp_colour_colour'] = 0.5
end

--- Called when the local player's colour modification should be adjusted.
--
-- While antidepressants are active the colours fade towards normal, and back to the default afterwards.
-- @param colorModify [Map `$pp_colour_*` values, adjusted in place]
function Schema:PlayerAdjustColorModify(colorModify)
  local antiDepressants = cw.client:GetNetVar('antidepressants')
  local frameTime = FrameTime()
  local interval = FrameTime() / 10
  local curTime = CurTime()

  if !self.colorModify then
    self.colorModify = {
      brightness = colorModify['$pp_colour_brightness'],
      contrast = colorModify['$pp_colour_contrast'],
      color = colorModify['$pp_colour_colour']
    }
  end

  if antiDepressants then
    if antiDepressants > curTime then
      self.colorModify.brightness = math.Approach(self.colorModify.brightness, 0, interval)
      self.colorModify.contrast = math.Approach(self.colorModify.contrast, 1, interval)
      self.colorModify.color = math.Approach(self.colorModify.color, 1, interval)
    else
      self.colorModify.brightness =
        math.Approach(self.colorModify.brightness, colorModify['$pp_colour_brightness'], interval)
      self.colorModify.contrast = math.Approach(self.colorModify.contrast, colorModify['$pp_colour_contrast'], interval)
      self.colorModify.color = math.Approach(self.colorModify.color, colorModify['$pp_colour_colour'], interval)
    end
  end

  colorModify['$pp_colour_brightness'] = self.colorModify.brightness
  colorModify['$pp_colour_contrast'] = self.colorModify.contrast
  colorModify['$pp_colour_colour'] = self.colorModify.color
end

--- Called when the local player attempts to see a class in the class menu.
--
-- Hides the Combine classes whose rank the local player does not hold.
-- @param class [Class The class]
-- @return [Boolean `false` to hide the class]
function Schema:PlayerCanSeeClass(class)
  if class.index == CLASS_MPS and !self:IsPlayerCombineRank(cw.client, 'SCN') then
    return false
  elseif class.index == CLASS_MPR and !self:IsPlayerCombineRank(cw.client, 'RCT') then
    return false
  elseif class.index == CLASS_EMP and !self:IsPlayerCombineRank(cw.client, 'EpU') then
    return false
  elseif class.index == CLASS_OWS and !self:IsPlayerCombineRank(cw.client, 'OWS') then
    return false
  elseif class.index == CLASS_OWC and !self:IsPlayerCombineRank(cw.client, 'OWC') then
    return false
  elseif class.index == CLASS_EOW and !self:IsPlayerCombineRank(cw.client, 'EOW') then
    return false
  elseif class.index == CLASS_MPU then
    if self:IsPlayerCombineRank(cw.client, 'SCN') or self:IsPlayerCombineRank(cw.client, 'EpU')
    or self:IsPlayerCombineRank(cw.client, 'RCT') then
      return false
    end
  end
end

--- Called when the status of a player under the crosshair should be drawn.
--
-- Draws whether the target is in critical condition, unconscious, tied or being tied or untied, with an
-- untie prompt when the local player is close enough.
-- @param target [Player The player being looked at]
-- @param alpha [Number The alpha to draw with]
-- @param x [Number The X position to draw at]
-- @param y [Number The Y position to draw at]
-- @return [Number The Y position after the drawn text, or `nil` when the target is dead]
function Schema:DrawTargetPlayerStatus(target, alpha, x, y)
  local informationColor = cw.option:GetColor('information')
  local thirdPerson = L('#TargetStatus_Him')
  local mainStatus
  local untieText
  local gender = L('#TargetStatus_He')
  local action = cw.player:GetAction(target)

  if target:GetGender() == GENDER_FEMALE then
    thirdPerson = L('#TargetStatus_Her')
    gender = L('#TargetStatus_She')
  end

  if target:Alive() then
    if action == 'die' then
      mainStatus = L('#TargetStatus_Critical:'..gender..';')
    end

    if target:GetRagdollState() == RAGDOLL_KNOCKEDOUT then
      mainStatus = L('#TargetStatus_Unconscious:'..gender..';')
    end

    if target:GetNetVar('tied') != 0 then
      if cw.player:GetAction(cw.client) == 'untie' then
        mainStatus = L('#TargetStatus_BeingUntied:'..gender..';')
      else
        local untieText

        if target:GetShootPos():Distance(cw.client:GetShootPos()) <= 192 then
          if cw.client:GetNetVar('tied') == 0 then
            mainStatus = L('#TargetStatus_PressToUntie:'..thirdPerson..';')

            untieText = true
          end
        end

        if !untieText then
          mainStatus = L('#TargetStatus_Tied:'..gender..';')
        end
      end
    elseif cw.player:GetAction(cw.client) == 'tie' then
      mainStatus = L('#TargetStatus_BeingTied:'..gender..';')
    end

    if mainStatus then
      y = cw.core:DrawInfo(cw.core:ParseData(mainStatus), x, y, informationColor, alpha)
    end

    return y
  end
end

--- Called when the player info text is needed; adds the citizen ID line for citizens.
-- @param playerInfoText [Map The info text object, with an `Add(id, text)` method]
function Schema:GetPlayerInfoText(playerInfoText)
  local citizenID = cw.client:GetNetVar('citizenID') or 'ERROR'

  if citizenID then
    if cw.client:GetFaction() == FACTION_CITIZEN then
      playerInfoText:Add('CITIZEN_ID', 'CID: #'..citizenID)
    end
  end
end

--- Called to check whether a player has a flag.
--
-- When permits are disabled, denies the business flag `x`, the general goods flag `1` and every custom
-- permit flag.
-- @param player [Player The player to check]
-- @param flag [String The flag]
-- @return [Boolean `false` to deny the flag, or `nil` to leave it to the flag system]
function Schema:PlayerDoesHaveFlag(player, flag)
  if !config.GetVal('permits') then
    if flag == 'x' or flag == '1' then
      return false
    end

    for k, v in pairs(self.customPermits) do
      if v.flag == flag then
        return false
      end
    end
  end
end

--- Called to check whether the local player recognises another player.
--
-- Combine players and administrators are always recognised.
-- @param player [Player The player to be recognised]
-- @param status [Number The `RECOGNISE_*` level being checked]
-- @param isAccurate [Boolean Whether the level must match exactly]
-- @param realValue [Boolean The result of the recognition system]
-- @return [Boolean `true` to recognise the player, or `nil` to keep `realValue`]
function Schema:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
  if self:PlayerIsCombine(player) or player:GetFaction() == FACTION_ADMIN then
    return true
  end
end

--- Called every tick.
--
-- For Combine players, adds Combine display lines when health or armour changes and a random display
-- line every three seconds.
function Schema:Tick()
  if IsValid(cw.client) then
    if self:PlayerIsCombine(cw.client) then
      local curTime = CurTime()
      local health = cw.client:Health()
      local armor = cw.client:Armor()

      if !self.nextHealthWarning or curTime >= self.nextHealthWarning then
        if self.lastHealth then
          if health < self.lastHealth then
            if health == 0 then
              self:AddCombineDisplayLine('#CombineDisplay_Shutdown', Color(255, 0, 0, 255))
            else
              self:AddCombineDisplayLine('#CombineDisplay_BodilyHarm', Color(255, 0, 0, 255))
            end

            self.nextHealthWarning = curTime + 2
          elseif health > self.lastHealth then
            if health == 100 then
              self:AddCombineDisplayLine('#CombineDisplay_HealthRestored', Color(0, 255, 0, 255))
            else
              self:AddCombineDisplayLine('#CombineDisplay_HealthRegaining', Color(0, 0, 255, 255))
            end

            self.nextHealthWarning = curTime + 2
          end
        end

        if self.lastArmor then
          if armor < self.lastArmor then
            if armor == 0 then
              self:AddCombineDisplayLine('#CombineDisplay_ArmorExhausted', Color(255, 0, 0, 255))
            else
              self:AddCombineDisplayLine('#CombineDisplay_ArmorDamaged', Color(255, 0, 0, 255))
            end

            self.nextHealthWarning = curTime + 2
          elseif armor > self.lastArmor then
            if armor == 100 then
              self:AddCombineDisplayLine('#CombineDisplay_ArmorRestored', Color(0, 255, 0, 255))
            else
              self:AddCombineDisplayLine('#CombineDisplay_ArmorRegaining', Color(0, 0, 255, 255))
            end

            self.nextHealthWarning = curTime + 2
          end
        end
      end

      if !self.nextRandomLine or curTime >= self.nextRandomLine then
        local text = self.randomDisplayLines[math.random(1, #self.randomDisplayLines)]

        if text and self.lastRandomDisplayLine != text then
          self:AddCombineDisplayLine(text)

          self.lastRandomDisplayLine = text
        end

        self.nextRandomLine = curTime + 3
      end

      self.lastHealth = health
      self.lastArmor = armor
    end
  end
end

--- Called when the foreground HUD should be painted; draws the white flash of active stun effects.
function Schema:HUDPaintForeground()
  local curTime = CurTime()

  if cw.client:Alive() then
    if self.stunEffects then
      for k, v in pairs(self.stunEffects) do
        local alpha = math.Clamp((255 / v[2]) * (v[1] - curTime), 0, 255)

        if alpha != 0 then
          draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha))
        else
          table.remove(self.stunEffects, k)
        end
      end
    end
  end
end

--- Called when the top of the screen HUD should be painted.
--
-- Draws the Combine display lines for Combine players, typing each line out a character per frame and
-- removing it when it expires.
-- @param info [Map Drawing state with `x` and `y`; `y` is advanced past each line]
function Schema:HUDPaintTopScreen(info)
  local blackFadeAlpha = cw.core:GetBlackFadeAlpha()
  local colorWhite = cw.option:GetColor('white')
  local curTime = CurTime()

  if self:PlayerIsCombine(cw.client) and self.combineDisplayLines then
    local height = draw.GetFontHeight('BudgetLabel')

    for k, v in ipairs(self.combineDisplayLines) do
      if curTime >= v[2] then
        table.remove(self.combineDisplayLines, k)
      else
        local color = v[4] or colorWhite
        local textColor = Color(color.r, color.g, color.b, 255 - blackFadeAlpha)

        draw.SimpleText(string.sub(v[1], 1, v[3]), 'BudgetLabel', info.x, info.y, textColor)

        if v[3] < string.len(v[1]) then
          v[3] = v[3] + 1
        end

        info.y = info.y + height
      end
    end
  end
end

--- Called when the full screen text info is needed.
--
-- Shows a message while the local player's character is permakilled, being tied or tied.
-- @return [Map The text's `alpha`, `title` and optional `text`, or `nil` for none]
function Schema:GetScreenTextInfo()
  local blackFadeAlpha = cw.core:GetBlackFadeAlpha()

  if cw.client:GetNetVar('permaKilled') then
    return {
      alpha = blackFadeAlpha,
      title = '#ScreenTextInfo_PermaKilled_title',
      text = '#ScreenTextInfo_CharBanned_text'
    }
  elseif cw.client:GetNetVar('beingTied') then
    return {
      alpha = 255 - blackFadeAlpha,
      title = '#ScreenTextInfo_BeingTied_title'
    }
  elseif cw.client:GetNetVar('tied') != 0 then
    return {
      alpha = 255 - blackFadeAlpha,
      title = '#ScreenTextInfo_Tied_title'
    }
  end
end

--- Called when the info of a chat box message should be adjusted.
--
-- Hides the speaker's name for anonymous messages and shows scanner units as Dispatch on the radio.
-- @param info [Map The message info: `speaker`, `class`, `data` and `name`, which may be replaced]
function Schema:ChatBoxAdjustInfo(info)
  if IsValid(info.speaker) then
    if info.data.anon then
      info.name = 'Кто-то'
    end

    if self:PlayerIsCombine(info.speaker) then
      if self:IsPlayerCombineRank(info.speaker, 'SCN') then
        if info.class == 'radio' or info.class == 'radio_eavesdrop' then
          info.name = 'Dispatch'
        end
      end
    end
  end
end
