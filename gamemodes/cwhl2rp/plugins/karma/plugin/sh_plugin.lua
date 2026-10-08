--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

PLUGIN:SetGlobalAlias('cwKarma')

cw.flag:Add('k', 'Karma Manipulation', 'Access to karma commands.')

local stored = cwKarma.stored or {}
cwKarma.stored = stored

--- Registers a named karma level covering a range of karma values.
--
-- Levels are checked in the order they were added, and `playerMeta:GetKarmaLevel` returns the
-- phrase of the first one whose range contains the karma. Does nothing if an argument is missing.
--
-- ```
-- cwKarma:AddKarmaLevel(-9, 9, '#Karma_Neutral')
-- ```
--
-- @param bottom [Number Lowest karma value of the level, inclusive]
-- @param ceiling [Number Highest karma value of the level, inclusive]
-- @param phrase [String Language phrase naming the level]
function cwKarma:AddKarmaLevel(bottom, ceiling, phrase)
  if !bottom or !ceiling or !phrase then return end

  table.insert(stored, { phrase = phrase, bottom = bottom, ceiling = ceiling })
end

cwKarma:AddKarmaLevel(-100, -90, '#Karma_Monster')
cwKarma:AddKarmaLevel(-89, -70, '#Karma_Evil')
cwKarma:AddKarmaLevel(-69, -40, '#Karma_Criminal')
cwKarma:AddKarmaLevel(-39, -10, '#Karma_Hooligan')
cwKarma:AddKarmaLevel(-9, 9, '#Karma_Neutral')
cwKarma:AddKarmaLevel(10, 39, '#Karma_Decent')
cwKarma:AddKarmaLevel(40, 69, '#Karma_Kind')
cwKarma:AddKarmaLevel(70, 89, '#Karma_GoodSamaritan')
cwKarma:AddKarmaLevel(90, 100, '#Karma_Divine')

do
  local playerMeta = FindMetaTable('Player')

  --- Returns the player's karma, from -100 to 100.
  --
  -- Reads the `karma` character data and falls back to the networked `karma` variable, so it also
  -- works on the client.
  -- @return [Number The player's karma]
  -- @see Player:SetKarma
  function playerMeta:GetKarma()
    return self:GetCharacterData('karma', self:GetNetVar('karma', 0))
  end

  --- Returns the language phrase of the karma level the player's karma falls into.
  --
  -- The result is cached on the player until their karma changes.
  -- @return [String Phrase such as `#Karma_Neutral`, or `#Karma_Error` when no level matches]
  -- @see cwKarma:AddKarmaLevel
  function playerMeta:GetKarmaLevel()
    local karma = self:GetKarma()

    if self.cachedKarma != karma then
      self.cachedKarma = karma
      self.cachedKarmaString = '#Karma_Error'

      for k, v in ipairs(stored) do
        if karma >= v.bottom and karma <= v.ceiling then
          self.cachedKarmaString = v.phrase

          break
        end
      end
    end

    return self.cachedKarmaString
  end

  --- Sets the player's karma, clamped to -100 to 100, and saves and networks it.
  --
  -- Fades the player's screen red when karma goes down and blue otherwise. Server only, since it
  -- uses `ScreenFade` and `SetCharacterData`; the character must already have `karma` data.
  -- @param karma [Number The new karma value]
  -- @see Player:GetKarma
  function playerMeta:SetKarma(karma)
    local oldKarma = self:GetCharacterData('karma')
    local diff = oldKarma - tonumber(karma)
    local color

    karma = math.Clamp(karma, -100, 100)

    if diff > 0 then
      color = Color(255, 0, 0, 100)
    else
      color = Color(0, 0, 255, 100)
    end

    self:ScreenFade(1, color, 1, .4)
    self:SetCharacterData('karma', karma)
    self:SetNetVar('karma', karma)
  end
end

util.Include('cl_hooks.lua')
util.Include('sv_hooks.lua')
