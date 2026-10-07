--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('hint', cw)

local stored = cw.hint.stored or {}
cw.hint.stored = stored

--[[
  @codebase Server
  @details Add a new hint to the list.
  @param String A unique identifier.
  @param String The body of the hint.
  @param Function A callback with the player as an argument, return false to hide.
--]]

function cw.hint:Add(name, text, Callback)
  stored[name] = {
    Callback = Callback,
    text = text
  }
end

--[[
  @codebase Server
  @details Remove an existing hint from the list.
  @param String A unique identifier.
--]]

function cw.hint:Remove(name)
  stored[name] = nil
end

--[[
  @codebase Server
  @details Find a hint by its identifier.
  @param String A unique identifier.
  @returns Table The hint table matching the identifier.
--]]

function cw.hint:Find(name)
  return stored[name]
end

--[[
  @codebase Server
  @details Distribute a hint to each player.
--]]

function cw.hint:Distribute()
  local hintText, Callback = self:Get()
  local hintInterval = config.Get('hint_interval'):Get()

  if !hintText then return end

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() and v:GetInfoNum('cwShowHints', 1) == 1
    and !v:IsViewingStarterHints() then
      if !Callback or Callback(v) != false then
        self:Send(v, hintText, 6, nil, true)
      end
    end
  end
end

--[[
  @codebase Server
  @details Send customized and centered hint text to a player.
  @param Player The recipient(s).
  @param String The hint text to send.
  @param Float The delay before it fades.
  @param Color The color of the hint text.
  @option Bool:String Specify a custom sound or false for no sound.
  @option Bool Specify wether to display duplicates of this hint.
--]]

function cw.hint:SendCenter(player, text, delay, color, bNoSound, showDuplicated)
  netstream.Start(player, 'Hint', {
    text = cw.core:ParseData(text),
    delay = delay,
    color = color,
    center = true,
    noSound = bNoSound,
    showDuplicates = showDuplicated
  })
end

--[[
  @codebase Server
  @details Send customized and centered hint text to all players.
  @param String The hint text to send.
  @param Float The delay before it fades.
  @param Color The color of the hint text.
--]]

function cw.hint:SendCenterAll(text, delay, color)
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      self:SendCenter(v, text, delay, color)
    end
  end
end

--[[
  @codebase Server
  @details Send customized hint text to a player.
  @param Player The recipient(s).
  @param String The hint text to send.
  @param Float The delay before it fades.
  @param Color The color of the hint text.
  @option Bool:String Specify a custom sound or false for no sound.
  @option Bool Specify wether to display duplicates of this hint.
--]]

function cw.hint:Send(player, text, delay, color, bNoSound, showDuplicated)
  netstream.Start(player, 'Hint', {
    text = cw.core:ParseData(text), delay = delay, color = color, noSound = bNoSound, showDuplicates = showDuplicated
  })
end

--[[
  @codebase Server
  @details Send customized hint text to all players.
  @param String The hint text to send.
  @param Float The delay before it fades.
  @param Color The color of the hint text.
--]]

function cw.hint:SendAll(text, delay, color)
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      self:Send(v, text, delay, color)
    end
  end
end

--[[
  @codebase Server
  @details Pick a random hint from the list.
  @returns String The random hint text.
  @returns Function The random hint callback.
--]]

function cw.hint:Get()
  local hints = {}

  for k, v in pairs(stored) do
    if !v.Callback or v.Callback() != false then
      hints[#hints + 1] = v
    end
  end

  if #hints > 0 then
    local hint = hints[math.random(1, #hints)]

    if hint then
      return hint.text, hint.Callback
    end
  end
end

cw.hint:Add('OOC', '#Hints_OOC')
cw.hint:Add('LOOC', '#Hints_LOOC')
cw.hint:Add('Ducking', '#Hints_Ducking')
cw.hint:Add('Directory', '#Hints_Directory')
cw.hint:Add('F1 Hotkey', '#Hints_F1_Hotkey')
cw.hint:Add('F2 Hotkey', '#Hints_F2_Hotkey')
cw.hint:Add('Tab Hotkey', '#Hints_Tab_Hotkey')

cw.hint:Add('Context Menu', '#Hints_Context_Menu', function(player)
  return !config.Get('use_opens_entity_menus'):Get()
end)

cw.hint:Add('Entity Menu', '#Hints_Entity_Menu', function(player)
  return config.Get('use_opens_entity_menus'):Get()
end)

cw.hint:Add('Phys Desc', '#Hints_Phys_Desc', function(player)
  return cw.command:FindByID('CharPhysDesc') != nil
end)

cw.hint:Add('Give Name', '#Hints_Give_Name', function(player)
  return config.Get('recognise_system'):Get()
end)

cw.hint:Add('Raise Weapon', '#Hint_Raise_Weapon', function(player)
  return config.Get('raised_weapon_system'):Get()
end)

cw.hint:Add('Target Recognises', '#Hint_Target_Recognises', function(player)
  return config.Get('recognise_system'):Get()
end)
