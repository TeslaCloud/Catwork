--- Server-side netstream receivers for the requests the client sends to the framework.
--
-- Handles `CreateCharacter`, `InteractCharacter`, `DoorManagement`, `EntityMenuOption`, `MenuOption`,
-- `RecogniseOption`, `GetTargetRecognises`, `UnequipItem`, the quiz messages (`GetQuizStatus`, `QuizAnswer`,
-- `QuizCompleted`) and the `LocalPlayerCreated` and `DataStreamInfoSent` steps of the join handshake.
--
-- Everything these receive comes from the client, so each receiver checks the shape of its payload before using it.

local MAX_FULL_NAME_LENGTH = 64
local MAX_CREATION_FIELD_LENGTH = 256

-- Fields of the `CreateCharacter` payload that have to be strings when they are sent.
local creationStringFields = { 'faction', 'gender', 'model', 'forename', 'surname', 'fullName', 'physDesc' }

--- Returns whether a value sent by a client is a valid entity.
-- @param entity [Any The value to check]
-- @return [Boolean Whether it is an entity that is still valid]
local function IsValidEntity(entity)
  return isentity(entity) and IsValid(entity)
end

--- Filters the custom fields a client sent with `CreateCharacter`.
--
-- The fields are written into the new character's data, so only the ones a server-side `GetPersuasionChoices` hook
-- declares are kept. That is the hook the client builds the fields from: `choices` is filled with tables that have
-- a `name` and, for numbers, `isNumber`, `min` and `max`.
-- @param fields [Any The `plugin` table of the payload]
-- @return [Map The accepted values by choice name]
local function GetCustomCreationFields(fields)
  local accepted = {}

  if !istable(fields) then
    return accepted
  end

  local choices = {}

  hook.Run('GetPersuasionChoices', choices)

  for k, v in pairs(choices) do
    local value = fields[v.name]

    if isstring(value) or isnumber(value) then
      if v.isNumber then
        local number = tonumber(value)

        if number and number == number and math.abs(number) != math.huge
        and (!v.min or number >= v.min) and (!v.max or number <= v.max) then
          accepted[v.name] = value
        end
      elseif isstring(value) and value != '' and string.utf8len(value) <= MAX_CREATION_FIELD_LENGTH then
        accepted[v.name] = value
      end
    end
  end

  return accepted
end

-- GetTargetRecognises datastream callback.
netstream.Hook('GetTargetRecognises', function(player, data)
  if IsValidEntity(data) and data:IsPlayer() then
    player:SetNetVar('TargetKnows', cw.player:DoesRecognise(data, player))
  end
end)

-- EntityMenuOption datastream callback.
netstream.Hook('EntityMenuOption', function(player, data)
  if !istable(data) or !player:HasInitialized() or !player:Alive() then
    return
  end

  local entity = data[1]
  local option = data[2]
  local arguments = data[3]

  -- An entity removed earlier in the tick stays valid until the tick ends; it must not be taken twice.
  if !IsValidEntity(entity) or entity:IsMarkedForDeletion() or !isstring(option) then
    return
  end

  local shootPos = player:GetShootPos()

  if entity:NearestPoint(shootPos):Distance(shootPos) > 80 or !hook.Run('PlayerUse', player, entity) then
    return
  end

  local curTime = CurTime()

  if player.nextEntityHandle and player.nextEntityHandle > curTime then
    cw.player:Notify(player, L(player, 'EntityOptionWaitTime'))

    return
  end

  player.nextEntityHandle = curTime + config.Get('entity_handle_time'):Get()

  hook.Run('EntityHandleMenuOption', player, entity, option, arguments)
end)

-- MenuOption datastream callback.
netstream.Hook('MenuOption', function(player, data)
  if !istable(data) or !isstring(data.option) or !player:HasInitialized() or !player:Alive() then
    return
  end

  local itemTable = item.FindInstance(data.item)

  if !itemTable or !itemTable:IsInstance() or !itemTable.HandleOptions then
    return
  end

  local option = data.option
  local entity = data.entity
  local optionData = data.data

  if !istable(optionData) then
    optionData = { optionData }
  end

  if player:HasItemInstance(itemTable) then
    itemTable:HandleOptions(option, player, optionData)
  elseif IsValidEntity(entity) and !entity:IsMarkedForDeletion() and entity:GetClass() == 'cw_item'
  and entity:GetItemTable() == itemTable then
    local shootPos = player:GetShootPos()

    if entity:NearestPoint(shootPos):Distance(shootPos) <= 80 then
      itemTable:HandleOptions(option, player, optionData, entity)
    end
  end
end)

-- DataStreamInfoSent datastream callback.
netstream.Hook('DataStreamInfoSent', function(player, data)
  if !player.cwDatastreamInfoSent then
    hook.Run('PlayerDataStreamInfoSent', player)

    timer.Simple(FrameTime() * 32, function()
      if IsValid(player) then
        netstream.Start(player, 'DataStreamed', true)
      end
    end)

    player.cwDatastreamInfoSent = true
  end
end)

-- LocalPlayerCreated datastream callback.
netstream.Hook('LocalPlayerCreated', function(player, data)
  if IsValid(player) and !player:HasConfigInitialized() then
    timer.Create('SendCfg'..player:UniqueID(), FrameTime(), 1, function()
      if IsValid(player) then
        config.Send(player)
      end
    end)
  end
end)

-- InteractCharacter datastream callback.
netstream.Hook('InteractCharacter', function(player, data)
  if !istable(data) or !isnumber(data.characterID) or (!isstring(data.action) and !isnumber(data.action)) then
    return
  end

  local characterID = data.characterID
  local action = data.action
  local characters = player:GetCharacters()
  local character = characters and characters[characterID]

  if !character then
    return
  end

  -- Using a character saves the old one and loads the new one, so it must not be spammed.
  local curTime = CurTime()

  if player.cwNextInteractCharacter and curTime < player.cwNextInteractCharacter then
    return
  end

  player.cwNextInteractCharacter = curTime + 1

  local fault = hook.Run('PlayerCanInteractCharacter', player, action, character)

  if fault == false or isstring(fault) then
    return cw.player:SetCreateFault(player, fault or L'CharFault_CannotInteract')
  elseif action == 'delete' then
    local bSuccess, deleteFault = cw.player:DeleteCharacter(player, characterID)

    if !bSuccess then
      cw.player:SetCreateFault(player, deleteFault)
    end
  elseif action == 'use' then
    local bSuccess, useFault = cw.player:UseCharacter(player, characterID)

    if !bSuccess then
      cw.player:SetCreateFault(player, useFault)
    end
  else
    hook.Run('PlayerSelectCustomCharacterOption', player, action, character)
  end
end)

-- GetQuizStatus datastream callback.
netstream.Hook('GetQuizStatus', function(player, data)
  if !cw.quiz:GetEnabled() or cw.quiz:GetCompleted(player) then
    netstream.Start(player, 'QuizCompleted', true)
  else
    netstream.Start(player, 'QuizCompleted', false)
  end
end)

-- DoorManagement datastream callback.
netstream.Hook('DoorManagement', function(player, data)
  if !istable(data) or !player:HasInitialized() or !player:Alive() then
    return
  end

  local door = data[1]
  local action = data[2]

  if !IsValidEntity(door) or !cw.entity:IsDoor(door) or player:GetEyeTraceNoCursor().Entity != door
  or door:GetPos():Distance(player:GetPos()) > 192 then
    return
  end

  if action == 'Purchase' then
    local doorParent = cw.entity:GetDoorParent(door)

    -- Buying a child door gives its parent, so the parent must be free too.
    if cw.entity:GetOwner(door) or (doorParent and cw.entity:GetOwner(doorParent))
    or hook.Run('PlayerCanOwnDoor', player, door) == false then
      return
    end

    if cw.player:GetDoorCount(player) >= config.Get('max_doors'):Get() then
      cw.player:Notify(player, L(player, 'CannotPurchaseAnotherDoor'))

      return
    end

    local doorCost = config.Get('door_cost'):Get()

    if doorCost > 0 and !cw.player:CanAfford(player, doorCost) then
      cw.player:Notify(player, L(player, 'YouNeedAnother',
        cw.core:FormatCash(doorCost - player:GetCash(), nil, true))
      )

      return
    end

    local doorName = cw.entity:GetDoorName(door)

    if doorName == 'false' or doorName == 'hidden' or doorName == '' then
      doorName = L'Doors_Name'
    end

    if doorCost > 0 then
      cw.player:GiveCash(player, -doorCost, doorName)
    end

    cw.player:GiveDoor(player, door)
  elseif action == 'Access' then
    local target = data[3]
    local access = data[4]

    if !IsValidEntity(target) or !target:IsPlayer() or !target:HasInitialized() or target == player
    or target == cw.entity:GetOwner(door) or !cw.player:HasDoorAccess(player, door, DOOR_ACCESS_COMPLETE) then
      return
    end

    if access == DOOR_ACCESS_COMPLETE then
      if cw.player:HasDoorAccess(target, door, DOOR_ACCESS_COMPLETE) then
        cw.player:GiveDoorAccess(target, door, DOOR_ACCESS_BASIC)
      else
        cw.player:GiveDoorAccess(target, door, DOOR_ACCESS_COMPLETE)
      end
    elseif access == DOOR_ACCESS_BASIC then
      if cw.player:HasDoorAccess(target, door, DOOR_ACCESS_BASIC) then
        cw.player:TakeDoorAccess(target, door)
      else
        cw.player:GiveDoorAccess(target, door, DOOR_ACCESS_BASIC)
      end
    end

    if cw.player:HasDoorAccess(target, door, DOOR_ACCESS_COMPLETE) then
      netstream.Start(player, 'DoorAccess', { target, DOOR_ACCESS_COMPLETE })
    elseif cw.player:HasDoorAccess(target, door, DOOR_ACCESS_BASIC) then
      netstream.Start(player, 'DoorAccess', { target, DOOR_ACCESS_BASIC })
    else
      netstream.Start(player, 'DoorAccess', { target })
    end
  elseif action == 'Share' or action == 'Unshare' then
    if !cw.entity:IsDoorParent(door) or !cw.player:HasDoorAccess(player, door, DOOR_ACCESS_COMPLETE) then
      return
    end

    local bShare = (action == 'Share')

    if data[3] == 'Text' then
      netstream.Start(player, 'SetSharedText', bShare)

      door.cwDoorSharedTxt = bShare or nil
    else
      netstream.Start(player, 'SetSharedAccess', bShare)

      door.cwDoorSharedAxs = bShare or nil
    end
  elseif action == 'Text' then
    local text = data[3]

    if !isstring(text) or text == '' or !cw.player:HasDoorAccess(player, door, DOOR_ACCESS_COMPLETE) then
      return
    end

    -- The text needs a letter or a digit; bytes above 127 are the letters of non-Latin alphabets.
    if !string.find(string.gsub(string.lower(text), '%s', ''), 'thisdoorcanbepurchased')
    and string.find(text, '[%w\128-\255]') then
      cw.entity:SetDoorText(door, string.utf8sub(text, 1, 32))
    end
  elseif action == 'Sell' then
    if cw.entity:GetOwner(door) == player and !cw.entity:IsDoorUnsellable(door) then
      cw.player:TakeDoor(player, door)
    end
  end
end)

-- CreateCharacter datastream callback.
netstream.Hook('CreateCharacter', function(player, data)
  if !istable(data) then
    return
  end

  -- Each request runs a database query, and a second one must not start while the first is still pending.
  local curTime = CurTime()

  if player.cwNextCreateCharacter and curTime < player.cwNextCreateCharacter then
    return
  end

  player.cwNextCreateCharacter = curTime + 2

  for k, v in ipairs(creationStringFields) do
    if data[v] != nil and !isstring(data[v]) then
      return cw.player:SetCreateFault(player, L('CharFault_CreationError'))
    end
  end

  -- An exact name only: looking a faction up by anything else matches it as a Lua pattern.
  if !data.faction or !faction.GetAll()[data.faction] then
    return cw.player:SetCreateFault(player, L('InvalidFaction'))
  end

  if data.class != nil and !isstring(data.class) and !isnumber(data.class) then
    return cw.player:SetCreateFault(player, L('InvalidClass'))
  end

  if data.fullName and string.utf8len(data.fullName) > MAX_FULL_NAME_LENGTH then
    return cw.player:SetCreateFault(player, L('CharCreation_Appearance_ErrorMessage1'))
  end

  if istable(data.attributes) then
    local attributes = {}
    local attributesTable = cw.attribute:GetAll()

    for k, v in pairs(data.attributes) do
      if isstring(k) and attributesTable[k] and isnumber(v) and v == v then
        attributes[k] = v
      end
    end

    data.attributes = attributes
  end

  data.plugin = GetCustomCreationFields(data.plugin)

  cw.player:CreateCharacterFromData(player, data)
end)

-- RecogniseOption datastream callback.
netstream.Hook('RecogniseOption', function(player, data)
  if !isstring(data) or !config.Get('recognise_system'):Get() or !player:HasInitialized() or !player:Alive() then
    return
  end

  local curTime = CurTime()

  if player.cwNextRecogniseOption and curTime < player.cwNextRecogniseOption then
    return
  end

  player.cwNextRecogniseOption = curTime + 1

  local playSound = false

  if data == 'look' then
    local target = player:GetEyeTraceNoCursor().Entity

    if IsValid(target) and target:IsPlayer() and target:HasInitialized()
    and !cw.player:IsNoClipping(target) and target != player then
      cw.player:SetRecognises(target, player, RECOGNISE_SAVE)

      playSound = true
    end
  else
    local talkRadius = config.Get('talk_radius'):Get()
    local radius

    if data == 'whisper' then
      radius = math.min(talkRadius / 3, 80)
    elseif data == 'yell' then
      radius = talkRadius * 2
    elseif data == 'talk' then
      radius = talkRadius
    else
      return
    end

    local position = player:GetPos()

    for k, v in ipairs(_player.GetAll()) do
      if v != player and v:HasInitialized() and !cw.player:IsNoClipping(v)
      and v:GetPos():Distance(position) <= radius then
        cw.player:SetRecognises(v, player, RECOGNISE_SAVE)

        playSound = true
      end
    end
  end

  if playSound then
    cw.player:PlaySound(player, 'buttons/button17.wav')
  end
end)

-- QuizCompleted datastream callback.
netstream.Hook('QuizCompleted', function(player, data)
  if player.cwQuizAnswers and !cw.quiz:GetCompleted(player) then
    local questionsAmount = cw.quiz:GetQuestionsAmount()
    local correctAnswers = 0
    local quizQuestions = cw.quiz:GetQuestions()

    for k, v in pairs(quizQuestions) do
      if player.cwQuizAnswers[k] then
        if cw.quiz:IsAnswerCorrect(k, player.cwQuizAnswers[k]) then
          correctAnswers = correctAnswers + 1
        end
      end
    end

    if correctAnswers < math.Round(questionsAmount * (cw.quiz:GetPercentage() / 100)) then
      cw.quiz:CallKickCallback(player, correctAnswers)
    else
      cw.quiz:SetCompleted(player, true)
    end
  end
end)

-- UnequipItem datastream callback.
netstream.Hook('UnequipItem', function(player, data)
  if !istable(data) or !player:HasInitialized() or !player:Alive() or player:IsRagdolled() then
    return
  end

  local uniqueID = data[1]
  local itemID = data[2]
  local arguments = data[3]

  -- An exact unique ID only: looking an item up by anything else matches its name as a Lua pattern.
  if !isstring(uniqueID) or !item.GetAll()[uniqueID] or !isnumber(itemID) or istable(arguments) then
    return
  end

  local itemTable = player:FindItemByID(uniqueID, itemID)

  if !itemTable then
    itemTable = player:FindWeaponItemByID(uniqueID, itemID)
  end

  itemTable = item.Validate(itemTable)

  if itemTable and itemTable.OnPlayerUnequipped and itemTable.HasPlayerEquipped then
    if itemTable:HasPlayerEquipped(player, arguments) then
      itemTable:OnPlayerUnequipped(player, arguments)

      player:RebuildInventory()
    end
  end
end)

-- QuizAnswer datastream callback.
netstream.Hook('QuizAnswer', function(player, data)
  if !istable(data) then
    return
  end

  local question = data[1]
  local answer = data[2]

  if question == nil or (!isnumber(answer) and !isstring(answer)) or !cw.quiz:GetQuestion(question) then
    return
  end

  player.cwQuizAnswers = player.cwQuizAnswers or {}
  player.cwQuizAnswers[question] = answer
end)
