--- Client-side Cable receivers for the framework's core messages.
--
-- Handles shared variables and tables (`SharedVar`, `SharedTables`), `Notification`, `Hint`, `CinematicText`, sounds
-- (`StartSound`, `StopSound`, `PlaySound`), the recognition and quiz messages, accessories, `Log`, `CfgListVars`, the
-- `ClockworkIntro` and the `DataStreaming` and `DataStreamed` steps of the join handshake.

cable.receive('RunCommand', function(data)
  -- Never let network data reach the cwLua (RunString) developer command.
  if !istable(data) or string.lower(tostring(data[1])) == 'cwlua' then return end

  RunConsoleCommand(unpack(data))
end)

cable.receive('SharedTables', function(data)
  if istable(data) then
    cw.SharedTables = data
  end
end)

cable.receive('SetSharedTableVar', function(data)
  if !istable(data) or data.sharedTable == nil or data.key == nil then return end

  cw.SharedTables = cw.SharedTables or {}
  cw.SharedTables[data.sharedTable] = cw.SharedTables[data.sharedTable] or {}
  cw.SharedTables[data.sharedTable][data.key] = data.value
end)

cable.receive('HiddenCommands', function(data)
  if !istable(data) then return end

  -- The checksum of every command is worked out once, instead of once for each hidden command.
  local namesByCRC = {}

  for k, v in pairs(cw.command:GetAll()) do
    local shortCRC = cw.core:GetShortCRC(k)

    namesByCRC[shortCRC] = namesByCRC[shortCRC] or {}
    table.insert(namesByCRC[shortCRC], k)
  end

  for k, v in pairs(data) do
    local names = namesByCRC[v]

    if names and #names > 0 then
      cw.command:SetHidden(table.remove(names), true)
    end
  end
end)

cable.receive('OrderTime', function(data)
  cw.OrderCooldown = data

  local activePanel = cw.menu:GetActivePanel()

  if activePanel and activePanel:GetPanelName() == cw.option:GetKey('name_business') then
    activePanel:Rebuild()
  end
end)

cable.receive('CharacterInit', function(data)
  hook.Run('PlayerCharacterInitialized', data)
end)

cable.receive('Log', function(data)
  if !istable(data) or data.text == nil then return end

  cw.core:PrintColoredText(cw.core:GetLogTypeColor(data.logType), tostring(data.text))
end)

cable.receive('StartSound', function(data)
  if !istable(data) or data.uniqueID == nil or !isstring(data.sound) then return end

  if IsValid(cw.client) then
    local uniqueID = data.uniqueID
    local sound = data.sound
    local volume = tonumber(data.volume) or 1

    if !cw.clientSounds then
      cw.clientSounds = {}
    end

    if cw.clientSounds[uniqueID] then
      cw.clientSounds[uniqueID]:Stop()
    end

    cw.clientSounds[uniqueID] = CreateSound(cw.client, sound)
    cw.clientSounds[uniqueID]:PlayEx(volume, 100)
  end
end)

cable.receive('StopSound', function(data)
  if !istable(data) or data.uniqueID == nil then return end

  local uniqueID = data.uniqueID
  local fadeOut = tonumber(data.fadeOut) or 0

  if !cw.clientSounds then
    cw.clientSounds = {}
  end

  if cw.clientSounds[uniqueID] then
    if fadeOut != 0 then
      cw.clientSounds[uniqueID]:FadeOut(fadeOut)
    else
      cw.clientSounds[uniqueID]:Stop()
    end

    cw.clientSounds[uniqueID] = nil
  end
end)

cable.receive('InfoToggle', function(data)
  if IsValid(cw.client) and cw.client:HasInitialized() then
    if !cw.InfoMenuOpen then
      cw.InfoMenuOpen = true
      cw.core:RegisterBackgroundBlur('InfoMenu', SysTime())
    else
      cw.core:RemoveBackgroundBlur('InfoMenu')
      cw.core:CloseActiveDermaMenus()
      cw.InfoMenuOpen = false
    end
  end
end)

cable.receive('PlaySound', function(data)
  if isstring(data) then
    surface.PlaySound(data)
  end
end)

cable.receive('DataStreaming', function(data)
  cable.send('DataStreamInfoSent', true)
end)

cable.receive('DataStreamed', function(data)
  cw.DataHasStreamed = true
end)

cable.receive('QuizCompleted', function(data)
  if !data then
    if !cw.quiz:GetCompleted() then
      gui.EnableScreenClicker(true)

      cw.quiz.panel = vgui.Create('cw.quiz')
      cw.quiz.panel:Populate()
      cw.quiz.panel:MakePopup()
    end
  else
    local quizPanel = cw.quiz:GetPanel()

    cw.quiz:SetCompleted(true)

    if IsValid(quizPanel) then
      quizPanel:Remove()
    end
  end
end)

cable.receive('RecogniseMenu', function(data)
  local menuPanel = cw.core:AddMenuFromData(nil, {
    ['#RecogniseMenu_whisper'] = function()
      cable.send('RecogniseOption', 'whisper')
    end,
    ['#RecogniseMenu_yell'] = function()
      cable.send('RecogniseOption', 'yell')
    end,
    ['#RecogniseMenu_talk'] = function()
      cable.send('RecogniseOption', 'talk')
    end,
    ['#RecogniseMenu_look'] = function()
      cable.send('RecogniseOption', 'look')
    end
  })

  if IsValid(menuPanel) then
    menuPanel:SetPos(
      (ScrW() / 2) - (menuPanel:GetWide() / 2), (ScrH() / 2) - (menuPanel:GetTall() / 2)
    )
  end

  cw.core:SetRecogniseMenu(menuPanel)
end)

cable.receive('ClockworkIntro', function(data)
  if !cw.ClockworkIntroFadeOut then
    local introImage = cw.option:GetKey('intro_image')
    local introSound = cw.option:GetKey('intro_sound')
    local duration = 8
    local curTime = UnPredictedCurTime()

    if introImage != '' then
      duration = 16
    end

    cw.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8)
    cw.ClockworkIntroFadeOut = curTime + duration

    if IsValid(cw.client) and isstring(introSound) and introSound != '' then
      local introSoundPatch = CreateSound(cw.client, introSound)

      cw.ClockworkIntroSound = introSoundPatch
      introSoundPatch:PlayEx(0.75, 100)

      timer.Simple(duration - 4, function()
        introSoundPatch:FadeOut(4)

        if cw.ClockworkIntroSound == introSoundPatch then
          cw.ClockworkIntroSound = nil
        end
      end)
    end

    surface.PlaySound('buttons/button1.wav')
  end
end)

cable.receive('SharedVar', function(data)
  if !istable(data) or data.key == nil then return end

  local sharedVars = cw.core:GetSharedVars():Player()
  local sharedVarData = sharedVars and sharedVars[data.key]

  if sharedVarData then
    sharedVarData.value = data.value
  end
end)

cable.receive('HideCommand', function(data)
  if !istable(data) then return end

  local index = data.index

  for k, v in pairs(cw.command:GetAll()) do
    if cw.core:GetShortCRC(k) == index then
      cw.command:SetHidden(k, data.hidden)

      break
    end
  end
end)

cable.receive('CfgListVars', function(data)
  cw.client:PrintMessage(2, '######## [Catwork] Config ########\n')
    local sSearchData = nil
    local tConfigRes = {}

    if isstring(data) and data != '' then
      sSearchData = string.lower(data)
    end

    for k, v in pairs(config.GetStored()) do
      -- The search text is what the player typed, so it is matched as plain text and not as a pattern.
      if type(v.value) != 'table' and (!sSearchData
      or string.find(string.lower(k), sSearchData, 1, true)) and !v.isStatic then
        if v.isPrivate then
          tConfigRes[#tConfigRes + 1] = {
            k, string.rep('*', string.utf8len(tostring(v.value)))
          }
        else
          tConfigRes[#tConfigRes + 1] = {
            k, tostring(v.value)
          }
        end
      end
    end

    table.sort(tConfigRes, function(a, b)
      return a[1] < b[1]
    end)

    for k, v in pairs(tConfigRes) do
      local systemValues = config.GetFromSystem(v[1])

      if systemValues then
        cw.client:PrintMessage(2, '// '..systemValues.help..'\n')
      end

      cw.client:PrintMessage(2, v[1]..' = "'..v[2]..'";\n')
    end

  cw.client:PrintMessage(2, '######## [Catwork] Config ########\n')
end)

cable.receive('ClearRecognisedNames', function(data)
  cw.RecognisedNames = {}
end)

cable.receive('RecognisedName', function(data)
  if !istable(data) or data.key == nil then return end

  local key = data.key
  local status = tonumber(data.status) or 0

  if status > 0 then
    cw.RecognisedNames[key] = status
  else
    cw.RecognisedNames[key] = nil
  end
end)

cable.receive('Hint', function(data)
  if istable(data) and isstring(data.text) then
    if data.center then
      cw.core:AddCenterHint(
        cw.core:ParseData(cw.lang:TranslateText(data.text)), data.delay, data.color, data.noSound, data.showDuplicates
      )
    else
      cw.core:AddTopHint(
        cw.core:ParseData(cw.lang:TranslateText(data.text)), data.delay, data.color, data.noSound, data.showDuplicates
      )
    end
  end
end)

cable.receive('WeaponItemData', function(data)
  if !istable(data) or !isnumber(data.weapon) or !istable(data.definition) then return end

  local weapon = Entity(data.weapon)

  if IsValid(weapon) then
    weapon.cwItemTable = item.CreateInstance(
      data.definition.index, data.definition.itemID, data.definition.data
    )
  end
end)

cable.receive('CinematicText', function(data)
  if istable(data) and data.text != nil then
    cw.core:AddCinematicText(data.text, data.color, data.barLength, data.hangTime)
  end
end)

cable.receive('AddAccessory', function(data)
  if istable(data) and data.itemID != nil then
    cw.AccessoryData[data.itemID] = data.uniqueID
  end
end)

cable.receive('RemoveAccessory', function(data)
  if istable(data) and data.itemID != nil then
    cw.AccessoryData[data.itemID] = nil
  end
end)

cable.receive('AllAccessories', function(data)
  cw.AccessoryData = {}

  if !istable(data) then return end

  for k, v in pairs(data) do
    cw.AccessoryData[k] = v
  end
end)

cable.receive('Notification', function(data)
  if !istable(data) or data.text == nil then return end

  local text = tostring(data.text)
  local class = data.class
  local sound = 'ambient/water/drip2.wav'

  if class == 1 then
    sound = 'buttons/button10.wav'
  elseif class == 2 then
    sound = 'buttons/button17.wav'
  elseif class == 3 then
    sound = 'buttons/bell1.wav'
  elseif class == 4 then
    sound = 'buttons/button15.wav'
  end

  local info = {
    class = class,
    sound = sound,
    text = text
  }

  if hook.Run('NotificationAdjustInfo', info) then
    hook.Run('AddNotify', info.text, info.class, 10)

    if isstring(info.sound) then
      surface.PlaySound(info.sound)
    end

    print(info.text)
  end
end)
