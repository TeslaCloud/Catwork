--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

Schema.stunEffects = Schema.stunEffects or {}
Schema.combineOverlay = Material('effects/combine_binocoverlay')
Schema.randomDisplayLines = {
  '#DisplayLines_1',
  '#DisplayLines_2',
  '#DisplayLines_3',
  '#DisplayLines_4',
  '#DisplayLines_5',
  '#DisplayLines_6',
  '#DisplayLines_7',
  '#DisplayLines_8',
  '#DisplayLines_9',
  '#DisplayLines_10',
  '#DisplayLines_11',
  '#DisplayLines_12',
  '#DisplayLines_13',
  '#DisplayLines_14',
  '#DisplayLines_15'
}

config.AddToSystem('#ServerWhitelistIdentity', 'server_whitelist_identity', '#ServerWhitelistIdentityDesc')
config.AddToSystem('#CombineLockOverrides', 'combine_lock_overrides', '#CombineLockOverridesDesc')
config.AddToSystem('#SmallIntroText', 'intro_text_small', '#SmallIntroTextDesc')
config.AddToSystem('#BigIntroText', 'intro_text_big', '#BigIntroTextDesc')
config.AddToSystem('#KnockoutTime', 'knockout_time', '#KnockoutTimeDesc', 0, 7200)
config.AddToSystem('#BusinessCost', 'business_cost', '#BusinessCostDesc')
config.AddToSystem('#CWUPropsEnabled', 'cwu_props', '#CWUPropsEnabledDesc')
config.AddToSystem('#PermitsEnabled', 'permits', '#PermitsEnabledDesc')
config.AddToSystem('#VoiceCommandsCooldown', 'voice_cooldown', '#VoiceCommandsCooldownDesc', 0, 360)
config.AddToSystem('#SXBaseForcedFOV', 'sxbase_force_fov', '#SXBaseForcedFOVDesc', 0, 130)
config.AddToSystem('#PermakillEnabled', 'enable_permakill', '#PermakillEnabledDesc')

--[[ Это бекдоры что дают супер убер овнерку вот этим людям ]] --
cw.icon:PlayerSet('STEAM_0:1:14196407', 'Mr. Meow', 'data/catwork/icon_mrmeow.png')
cw.icon:PlayerSet('STEAM_0:1:44952839', 'AleXXX_007', 'icon16/tag.png')
cw.icon:PlayerSet('STEAM_0:0:26343107', 'Helly', 'data/catwork/icon_luna.png')
--[[  (нет)  ]] --

netstream.Hook('PlayerSetCustomIcon', function(player, iconData, bReset)
  if IsValid(player) and player:IsPlayer() then
    local icon = iconData.icon
    local path = iconData.path

    if icon:find('^http[s]?://') then
      if bReset then
        if file.Exists(path, 'DATA') then
          file.Delete(path)
        end
      end

      Schema:DownloadMaterial(icon, path)

      path = 'data/'..path
    end

    cw.icon:PlayerSet(player:SteamID(), player:SteamName(), path)
  end
end)

netstream.Hook('RebuildBusiness', function(data)
  if cw.menu:GetOpen() and IsValid(Schema.businessPanel) then
    if cw.menu:GetActivePanel() == Schema.businessPanel then
      Schema.businessPanel:Rebuild()
    end
  end
end)

netstream.Hook('ObjectPhysDesc', function(data)
  local entity = data

  if IsValid(entity) then
    Derma_StringRequest('#ObjectPhysDesc_Title', '#ObjectPhysDesc_Request', nil, function(text)
      netstream.Start('ObjectPhysDesc', { text, entity })
    end)
  end
end)

netstream.Hook('Frequency', function(data)
  Derma_StringRequest('#Radio_Frequency_Title', '#Radio_Frequency_Request', data, function(text)
    cw.core:RunCommand('SetFreq', text)

    if !cw.menu:GetOpen() then
      gui.EnableScreenClicker(false)
    end
  end)

  if !cw.menu:GetOpen() then
    gui.EnableScreenClicker(true)
  end
end)

netstream.Hook('EditObjectives', function(data)
  if Schema.objectivesPanel and Schema.objectivesPanel:IsValid() then
    Schema.objectivesPanel:Close()
    Schema.objectivesPanel:Remove()
  end

  Schema.objectivesPanel = vgui.Create('cwObjectives')
  Schema.objectivesPanel:Populate(data or '')
  Schema.objectivesPanel:MakePopup()

  gui.EnableScreenClicker(true)
end)

netstream.Hook('EditData', function(data)
  if IsValid(data[1]) then
    if Schema.dataPanel and Schema.dataPanel:IsValid() then
      Schema.dataPanel:Close()
      Schema.dataPanel:Remove()
    end

    Schema.dataPanel = vgui.Create('cwData')
    Schema.dataPanel:Populate(data[1], data[2] or '')
    Schema.dataPanel:MakePopup()

    gui.EnableScreenClicker(true)
  end
end)

netstream.Hook('Stunned', function(data)
  Schema:AddStunEffect(data)
end)

netstream.Hook('Flashed', function(data)
  Schema:AddFlashEffect()
end)

--- Downloads a file over HTTP into the data folder, unless it already exists there.
--
-- The download is asynchronous and the response body is written as is. Used for scoreboard icons, which
-- are then referenced as `data/<path>`.
-- @param url [String The URL to download]
-- @param path [String The destination, relative to the `DATA` folder]
function Schema:DownloadMaterial(url, path)
  if !file.Exists(path, 'DATA') then
    http.Fetch(url, function(result)
      if result then
        file.Write(path, result)
      end
    end)
  end
end

--- Starts a flash effect on the local player.
--
-- Adds a ten second white-out (see `Schema:HUDPaintForeground`), a twenty second colour shift and motion
-- blur (see `Schema:RenderScreenspaceEffects`) and plays a flatline sound. Triggered by the `Flashed`
-- netstream message.
function Schema:AddFlashEffect()
  local curTime = CurTime()

  self.stunEffects[#self.stunEffects + 1] = { curTime + 10, 10 }
  self.flashEffect = { curTime + 20, 20 }

  surface.PlaySound('hl1/fvox/flatline.wav')
end

--- Starts a stun effect on the local player.
--
-- Adds a white-out lasting `duration` seconds and a flash blur lasting twice as long. Triggered by the
-- `Stunned` netstream message.
-- @param duration=1 [Number Length of the white-out in seconds; `0` also means one second]
function Schema:AddStunEffect(duration)
  local curTime = CurTime()

  if !duration or duration == 0 then
    duration = 1
  end

  self.stunEffects[#self.stunEffects + 1] = { curTime + duration, duration }
  self.flashEffect = { curTime + (duration * 2), duration * 2, true }
end

netstream.Hook('ClearEffects', function(data)
  Schema.stunEffects = {}
  Schema.flashEffect = nil
end)

netstream.Hook('CombineDisplayLine', function(data)
  Schema:AddCombineDisplayLine(data[1], data[2])
end)

--- Returns the scanner a player controls, from their `scanner` net var.
-- @param player [Player The player]
-- @return [Entity The scanner, or `nil` when the player controls no valid scanner]
function Schema:GetScannerEntity(player)
  if player:GetNetVar('scanner') == nil then return end

  local scannerEntity = Entity(player:GetNetVar('scanner'))

  if IsValid(scannerEntity) then
    return scannerEntity
  end
end

--- Returns whether a text entry has focus and is visible.
--
-- The entry is tracked by `Schema:OnTextEntryGetFocus` and `Schema:OnTextEntryLoseFocus`.
-- @return [Boolean `true` when one is in use, otherwise `nil`]
function Schema:IsTextEntryBeingUsed()
  if self.textEntryFocused then
    if self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible() then
      return true
    end
  end
end

--- Adds a line to the local player's Combine display; does nothing for non-Combine players.
--
-- The text is translated and shown for eight seconds by `Schema:HUDPaintTopScreen`. Uncoloured lines are
-- suppressed while the player's biosignal is gone, and also refresh the biosignal locations of the
-- `cwCTO` plugin. Sent from the server with the `CombineDisplayLine` netstream message.
-- @param text [String The text or language key to show]
-- @param color=nil [Color Colour of the line; white when `nil`]
function Schema:AddCombineDisplayLine(text, color)
  if self:PlayerIsCombine(cw.client) then
    if !self.combineDisplayLines then
      self.combineDisplayLines = {}
    end

    if color or !cw.client:GetSharedVar('IsBiosignalGone') then
      table.insert(self.combineDisplayLines, { '<:: '..cw.lang:TranslateText(text)..' ::>', CurTime() + 8, 5, color })
    end

    if color == nil then
      cwCTO:UpdateBiosignalLocations()
    end
  end
end

--- Returns whether a player is Combine, using `Player:IsCombine`.
-- @param player [Player The player to check]
-- @param bHuman=nil [Boolean Unused]
-- @return [Boolean Whether the player is Combine, or `nil` for an invalid player]
function Schema:PlayerIsCombine(player, bHuman)
  if IsValid(player) then
    return player:IsCombine()
  end
end
