--- Shared entry point of the HL2RP schema, which includes the other schema files and sets up the city name, citizen
-- factions and states, loyalist tiers, animation models, options, shared config keys, quiz questions and flags.
--
-- It also defines the shared `Schema` helpers: loyalist tiers (`Schema:DefineLoyalistTier`,
-- `Schema:DetermineLoyalistTier`), custom business permits (`Schema:AddCustomPermit`), Combine ranks read from
-- character names (`Schema:IsPlayerCombineRank`, `Schema:GetPlayerCombineRank`) and getters for the citizen record net
-- vars such as `Schema:GetLP` and `Schema:GetCitizenStatus`. `Player:IsCombine` and `Player:IsCitizen` are added to
-- the player metatable here.

util.Include('cl_schema.lua')
util.Include('cl_hooks.lua')
util.Include('cl_theme.lua')
util.Include('sv_schema.lua')
util.Include('sv_hooks.lua')

Schema.customPermits = Schema.customPermits or {}

Schema.City = 'City-24'
Schema.City_cp = 'C24'
Schema.CitizenFactions = {
  '#Faction_Citizen',
  '#Faction_CWU',
  '#Faction_Rebel',
  '#Faction_Loyalist',
  '#Faction_Vort',
  '#Faction_Refugee',
  '#Faction_Admin'
}

Schema.CitizenStates = {
  Unverified = Color(150, 150, 150),
  Citizen = Color(70, 140, 70),
  AntiCitizen = Color(140, 70, 70),
  NoData = Color(70, 70, 140),
  Unknown = Color(170, 170, 0),
  Deceased = Color(40, 40, 40)
}

Schema.LoyalistTiers = {} -- has to go on refresh

for k, v in ipairs(_file.Find('models/humans/group17/*.mdl', 'GAME')) do
  cw.animation:AddMaleHumanModel('models/humans/group17/'..v)
end

cw.animation:AddCivilProtectionModel('models/eliteghostcp.mdl')
cw.animation:AddCivilProtectionModel('models/eliteshockcp.mdl')
cw.animation:AddCivilProtectionModel('models/leet_police2.mdl')
cw.animation:AddCivilProtectionModel('models/sect_police2.mdl')
cw.animation:AddCivilProtectionModel('models/policetrench.mdl')
cw.animation:AddCivilProtectionModel('models/metropolice/c08.mdl')
cw.animation:AddFemaleCivilProtectionModel('models/metropolice/c08_female.mdl')
cw.animation:AddFemaleCivilProtectionModel('models/metropolice/c08_female_2.mdl')

for i = 1, 24 do
  cw.animation:AddCivilProtectionModel('models/half_life2/jnstudio/cp_c08_'..i..'.mdl')
end

for i = 1, 7 do
  cw.animation:AddFemaleCivilProtectionModel('models/half_life2/jnstudio/cp_female_c08_'..i..'.mdl')
end

cw.animation:AddCombineOverwatchModel('models/city8_ow_elite.mdl')
cw.animation:AddCombineOverwatchModel('models/city8_overwatch.mdl')
cw.animation:AddCombineOverwatchModel('models/city8_overwatch_elite.mdl')
cw.animation:AddCombineOverwatchModel('models/city8ow.mdl')

cw.animation:AddVortigauntModel('models/vortigaunt_ozaxi.mdl')

cw.option:SetKey('default_date', { month = 1, year = 2016, day = 1 })
cw.option:SetKey('default_time', { minute = 0, hour = 0, day = 1 })
cw.option:SetKey('format_singular_cash', '%a')
cw.option:SetKey('model_shipment', 'models/items/item_item_crate.mdl')
cw.option:SetKey('intro_image', 'halfliferp/logo4')
cw.option:SetKey('schema_logo', 'halfliferp/logo4')
cw.option:SetKey('format_cash', '%a %n')
cw.option:SetKey('menu_music', '')
cw.option:SetKey('name_cash', '#HL2RP_CashName')
cw.option:SetKey('model_cash', 'models/props_lab/box01a.mdl')
cw.option:SetKey('gradient', 'halfliferp/bg_gradient')

config.ShareKey('intro_text_small')
config.ShareKey('intro_text_big')
config.ShareKey('business_cost')
config.ShareKey('permits')
config.ShareKey('sxbase_force_fov')

cw.quiz:SetEnabled(true)
cw.quiz:AddQuestion('#Quiz_RP1_Question', 3,
          '#Quiz_RP1_Answer1',
          '#Quiz_RP1_Answer2',
          '#Quiz_RP1_Answer3', --
          '#Quiz_RP1_Answer4',
          '#Quiz_RP1_Answer5')

cw.quiz:AddQuestion('#Quiz_RP2_Question', 2,
          '#Quiz_RP2_Answer1',
          '#Quiz_RP2_Answer2', --
          '#Quiz_RP2_Answer3',
          '#Quiz_RP2_Answer4')

cw.quiz:AddQuestion('#Quiz_RP3_Question', 2,
          '#Quiz_RP3_Answer1',
          '#Quiz_RP3_Answer2', --
          '#Quiz_RP3_Answer3')

cw.quiz:AddQuestion('#Quiz_RP4_Question', 3,
          '#Quiz_RP4_Answer1',
          '#Quiz_RP4_Answer2',
          '#Quiz_RP4_Answer3') --

cw.flag:Add('v', 'Light Blackmarket', 'Access to light blackmarket goods.')
cw.flag:Add('V', 'Heavy Blackmarket', 'Access to heavy blackmarket goods.')
cw.flag:Add('m', 'Resistance Manager', "Access to the resistance manager's goods.")
cw.flag:Add('d', 'Perma Death', "Disables permanent kill on the character's death.")

--- Adds a loyalist tier to `Schema.LoyalistTiers`.
--
-- Tiers are matched against a character's loyalty points by `Schema:DetermineLoyalistTier`; define them
-- in ascending order of points.
--
-- ```
-- Schema:DefineLoyalistTier('#Loyalist_Red', '#Loyalist_Red_Desc', Color(210, 100, 100), 150, -1)
-- ```
--
-- @param name [String Name or language key of the tier]
-- @param description [String Description or language key of the tier]
-- @param color [Color Colour the tier is shown in]
-- @param min [Number Lowest number of loyalty points in the tier]
-- @param max [Number Highest number of loyalty points in the tier, or `-1` for no limit]
function Schema:DefineLoyalistTier(name, description, color, min, max)
  return table.insert(self.LoyalistTiers, {
    name = name,
    description = description,
    color = color,
    min = min,
    max = max
  })
end

--- Returns the loyalist tier for a number of loyalty points.
--
-- When several tiers match, the last defined one wins.
-- @param num [Number The loyalty points]
-- @return [Map The tier (`name`, `description`, `color`, `min`, `max`); the first tier when none match,
-- or a magenta `ERROR` tier when none are defined]
function Schema:DetermineLoyalistTier(num)
  local tier = nil -- we do this to let it loop through everything and see if we've hit the limit.

  for k, v in ipairs(self.LoyalistTiers) do
    if num >= v.min and ((v.max == -1 and true) or num <= v.max) then
      tier = v
    end
  end

  return tier or self.LoyalistTiers[1] or {
    name = 'ERROR',
    description = 'ERROR',
    color = Color(255, 0, 255),
    min = -1,
    max = -1
  }
end

--- Returns whether the tier of a player's loyalty points has a name containing the given text.
--
-- The comparison is case-insensitive and uses the `LoyaltyPoints` character data. Tier names are
-- language keys such as `#Loyalist_Grey`, so `'grey'` matches the first tier.
-- @param player [Player The player to check]
-- @param tier [String Text to look for in the tier name, used as a Lua pattern]
-- @return [Number The position of the match, or `nil` when the name does not contain it]
function Schema:PlayerIsLoyalistTier(player, tier)
  local points = player:GetCharacterData('LoyaltyPoints', 0)
  local tierObj = self:DetermineLoyalistTier(points)

  if tierObj then
    return tierObj.name:utf8lower():find(tier:utf8lower())
  end

  return false
end

Schema:DefineLoyalistTier('#Loyalist_Grey', '#Loyalist_Grey_Desc', Color(150, 150, 150), 0, 10)
Schema:DefineLoyalistTier('#Loyalist_White', '#Loyalist_White_Desc', Color(255, 255, 255), 11, 30)
Schema:DefineLoyalistTier('#Loyalist_Green', '#Loyalist_Green_Desc', Color(120, 210, 120), 31, 60)
Schema:DefineLoyalistTier('#Loyalist_Blue', '#Loyalist_Blue_Desc', Color(100, 100, 210), 61, 100)
Schema:DefineLoyalistTier('#Loyalist_Orange', '#Loyalist_Orange_Desc', Color(210, 180, 50), 101, 149)
Schema:DefineLoyalistTier('#Loyalist_Red', '#Loyalist_Red_Desc', Color(210, 100, 100), 150, -1)

--- Returns whether a player may play a Civil Protection character.
--
-- Characters below rank 6 are marked as unavailable on the character screen when this is `false`;
-- the schema always allows it.
-- @param player [Player The player]
-- @return [Boolean Always `true`]
function Schema:CanUseCP(player)
  return true
end

--- Registers a custom business permit in `Schema.customPermits`.
--
-- Citizens can buy the permit from the business menu while permits are enabled, gaining the flag. The
-- permit is stored under its lowercased name without spaces or punctuation, which is also the argument
-- the `PermitBuy` command expects.
--
-- ```
-- Schema:AddCustomPermit('Literature', '3', 'models/props_lab/bindergreenlabel.mdl')
-- ```
--
-- @param name [String Display name of the permit]
-- @param flag [String The flag the permit grants]
-- @param model [String Model shown for the permit in the business menu]
function Schema:AddCustomPermit(name, flag, model)
  local formattedName = string.gsub(name, '[%s%p]', '')

  self.customPermits[string.lower(formattedName)] = {
    model = model,
    name = name,
    flag = flag,
    key = cw.core:SetCamelCase(formattedName, true)
  }
end

--- Returns whether a name contains a Combine rank.
--
-- Ranks appear in Combine names between punctuation, as in `C24.MPF-RCT.1234`. The rank `EpU` also
-- matches the `SeC`, `DvL` and `CmD` ranks.
-- @param text [String The name to search]
-- @param rank [String The rank, or a `List` of ranks of which any may match]
-- @return [Any A truthy value (`true` or the match position) when the rank is found, otherwise `nil`]
-- @see Schema:IsPlayerCombineRank
function Schema:IsStringCombineRank(text, rank)
  if type(rank) == 'table' then
    for k, v in ipairs(rank) do
      if self:IsStringCombineRank(text, v) then
        return true
      end
    end
  elseif rank == 'EpU' then
    if string.find(text, '%pSeC%p') or string.find(text, '%pDvL%p')
    or string.find(text, '%pEpU%p') or string.find(text, '%pCmD%p') then
      return true
    end
  else
    return string.find(text, '%p'..rank..'%p')
  end
end

--- Returns whether a Civil Protection or Overwatch player's name contains a Combine rank.
--
-- Works like `Schema:IsStringCombineRank` on the player's name, and is always `nil` for players outside
-- the Combine factions.
-- @param player [Player The player to check]
-- @param rank [String The rank, or a `List` of ranks of which any may match]
-- @param realRank=nil [Boolean When `true`, `EpU` matches only the literal `EpU` rank]
-- @return [Any A truthy value (`true` or the match position) when the player has the rank, otherwise `nil`]
function Schema:IsPlayerCombineRank(player, rank, realRank)
  local name = player:Name()
  local faction = player:GetFaction()

  if self:IsCombineFaction(faction) then
    if type(rank) == 'table' then
      for k, v in ipairs(rank) do
        if self:IsPlayerCombineRank(player, v, realRank) then
          return true
        end
      end
    elseif rank == 'EpU' and !realRank then
      if string.find(name, '%pSeC%p') or string.find(name, '%pDvL%p')
      or string.find(name, '%pEpU%p') or string.find(name, '%pCmD%p') then
        return true
      end
    else
      return string.find(name, '%p'..string.PatternSafe(rank)..'%p')
    end
  end
end

--- Returns a number for a player's Combine rank, used to sort and compare ranks.
--
-- Overwatch ranks are `0` (OWS) to `3` (other). Civil Protection ranks are `0` (RCT), `1`-`4` (04-01),
-- `5` (no rank found), `6` (GHOST), `7` (OfC), `8` (EpU), `9` (DvL), `10` (CmD), `11` (SCN) and `12`
-- (SYNTH scanner).
-- @param player [Player The player]
-- @return [Number The rank number; higher is more senior]
function Schema:GetPlayerCombineRank(player)
  local faction = player:GetFaction()

  if faction == FACTION_OTA then
    if self:IsPlayerCombineRank(player, 'OWS') then
      return 0
    elseif self:IsPlayerCombineRank(player, 'OWC') then
      return 1
    elseif self:IsPlayerCombineRank(player, 'EOW') then
      return 2
    else
      return 3
    end
  elseif self:IsPlayerCombineRank(player, 'RCT') then
    return 0
  elseif self:IsPlayerCombineRank(player, '04') then
    return 1
  elseif self:IsPlayerCombineRank(player, '03') then
    return 2
  elseif self:IsPlayerCombineRank(player, '02') then
    return 3
  elseif self:IsPlayerCombineRank(player, '01') then
    return 4
  elseif self:IsPlayerCombineRank(player, 'GHOST') then
    return 6
  elseif self:IsPlayerCombineRank(player, 'OfC') then
    return 7
  elseif self:IsPlayerCombineRank(player, 'EpU', true) then
    return 8
  elseif self:IsPlayerCombineRank(player, 'DvL') then
    return 9
  elseif self:IsPlayerCombineRank(player, 'CmD') then
    return 10
  elseif self:IsPlayerCombineRank(player, 'SCN') then
    if !self:IsPlayerCombineRank(player, 'SYNTH') then
      return 11
    else
      return 12
    end
  else
    return 5
  end
end

--- Returns whether a faction is Civil Protection or Overwatch.
-- @param faction [String The faction name]
-- @return [Boolean Whether the faction is `FACTION_MPF` or `FACTION_OTA`]
function Schema:IsCombineFaction(faction)
  return (faction == FACTION_MPF or faction == FACTION_OTA)
end

--- Returns a player's loyalty points, from their `LoyaltyPoints` net var.
-- @param player [Player The player]
-- @return [Number The loyalty points, `0` by default]
function Schema:GetLP(player)
  return player:GetNetVar('LoyaltyPoints', 0)
end

--- Returns a player's criminal points, from their `CriminalPoints` net var.
-- @param player [Player The player]
-- @return [Number The criminal points, `0` by default]
function Schema:GetCP(player)
  return player:GetNetVar('CriminalPoints', 0)
end

--- Returns a player's citizen status, from their `CitizenStatus` net var.
-- @param player [Player The player]
-- @return [String A key of `Schema.CitizenStates`, `'Unknown'` by default]
function Schema:GetCitizenStatus(player)
  return player:GetNetVar('CitizenStatus', 'Unknown')
end

--- Returns a player's residence, from their `Residence` net var.
-- @param player [Player The player]
-- @return [String The residence, `'Unknown'` by default]
function Schema:GetResidence(player)
  return player:GetNetVar('Residence', 'Unknown')
end

--- Returns whether a player is jailed, from their `Jailed` net var.
-- @param player [Player The player]
-- @return [Boolean Whether the player is jailed, `false` by default]
function Schema:GetJailed(player)
  return player:GetNetVar('Jailed', false)
end

--- Returns a player's job, from their `Job` net var.
-- @param player [Player The player]
-- @return [String The job, `'None'` by default]
function Schema:GetJob(player)
  return player:GetNetVar('Job', 'None')
end

--- Returns a player's work points, from their `WorkPoints` net var.
-- @param player [Player The player]
-- @return [Number The work points, `0` by default]
function Schema:GetWorkPoints(player)
  return player:GetNetVar('WorkPoints', 0)
end

--- Returns the colour of a player's citizen status from `Schema.CitizenStates`.
-- @param player [Player The player]
-- @return [Color The status colour, or white for an unknown status]
function Schema:GetCitizenStatusColor(player)
  return self.CitizenStates[self:GetCitizenStatus(player)] or Color(255, 255, 255)
end

do
  local playerMeta = FindMetaTable('Player')

  --- Returns whether the player belongs to Civil Protection, Overwatch or the administrator faction.
  --
  -- On the server the player must also have a character loaded.
  -- @return [Boolean `true` when the player is Combine, otherwise `nil`]
  function playerMeta:IsCombine()
    if SERVER then
      if self:GetCharacter() then
        local faction = self:GetFaction()

        if Schema:IsCombineFaction(faction) or faction == FACTION_ADMIN then
          return true
        end
      end
    else
      local faction = self:GetFaction()

      if Schema:IsCombineFaction(faction) or faction == FACTION_ADMIN then
        return true
      end
    end
  end

  --- Returns whether the player's faction is one of `Schema.CitizenFactions`.
  --
  -- The administrator faction counts as a citizen faction as well.
  -- @return [Boolean Whether the player is a citizen]
  function playerMeta:IsCitizen()
    return table.HasValue(Schema.CitizenFactions, self:GetFaction())
  end
end
