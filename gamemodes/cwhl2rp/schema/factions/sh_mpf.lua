--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local FACTION = faction.New('#Faction_MPF')

FACTION.isCombineFaction = true
FACTION.whitelist = true
FACTION.material = 'halfliferp/factions/mpf'
FACTION.models = { male = {}, female = {} }
FACTION.maximumAttributePoints = 40

for i = 1, 24 do
  table.insert(FACTION.models.male, 'models/half_life2/jnstudio/cp_c08_'..i..'.mdl')
end

for i = 1, 7 do
  table.insert(FACTION.models.female, 'models/half_life2/jnstudio/cp_female_c08_'..i..'.mdl')
end

--- Returns a random recruit name for a new unit, such as `CP.C24.RCT:042`.
-- @param player [Player The player]
-- @param character [Character The character]
-- @return [String The name]
function FACTION:GetName(player, character)
  return 'CP.C24.RCT:'..cw.core:ZeroNumberToDigits(math.random(1, 999), 3)
end

--- Called when a player is transferred to the faction.
--
-- Characters coming from Overwatch need the transfer's third argument and have the part of their name
-- before its last five digits replaced with ` CP.C24.RCT:`; everyone else gets a new recruit name. The
-- character gets the first Civil Protection model of their gender.
-- @param player [Player The player]
-- @param faction [Faction The faction the player comes from]
-- @param name=nil [String Required when coming from Overwatch]
-- @return [Boolean `false` to refuse the transfer, String The reason]
function FACTION:OnTransferred(player, faction, name)
  if faction.name == FACTION_OTA then
    if name then
      cw.player:SetName(player, string.gsub(player:QueryCharacter('name'), '.+(%d%d%d%d%d)', ' CP.C24.RCT:%1'), true)
    else
      return false, L('FactionTransfer_NeedName')
    end
  else
    cw.player:SetName(player, self:GetName(player, player:GetCharacter()))
  end

  if player:QueryCharacter('gender') == GENDER_MALE then
    player:SetCharacterData('model', self.models.male[1], true)
  else
    player:SetCharacterData('model', self.models.female[1], true)
  end
end

FACTION_MPF = FACTION:Register()
