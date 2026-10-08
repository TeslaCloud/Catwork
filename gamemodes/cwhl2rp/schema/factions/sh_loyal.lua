--- Defines the whitelisted Loyalist faction (`FACTION_LOYAL`), with the `tnb/citizens` models and a rule that Combine
-- characters transferred into it need a new name.

local FACTION = faction.New('#Faction_Loyalist')

FACTION.useFullName = true
FACTION.material = 'halfliferp/factions/citizen'
FACTION.whitelist = true
FACTION.maximumAttributePoints = 35
FACTION.models = {
  female = {},
  male = {}
}

do
  for i = 1, 18 do
    local num = i

    if i < 10 then
      num = '0'..i
    end

    if i != 17 then
      table.insert(FACTION.models.male, 'models/tnb/citizens/male_'..num..'.mdl')
    end

    if i < 12 then
      table.insert(FACTION.models.female, 'models/tnb/citizens/female_'..num..'.mdl')
    end
  end
end

--- Called when a player is transferred to the faction.
--
-- Combine players need a new name (the transfer's third argument) and get a random model of the
-- faction; other players keep their name and model.
-- @param player [Player The player]
-- @param faction [Faction The faction the player comes from]
-- @param name=nil [String The new name]
-- @return [Boolean `false` to refuse the transfer, String The reason]
function FACTION:OnTransferred(player, faction, name)
  if player:IsCombine() then
    if name then
      local models = self.models[string.lower(player:QueryCharacter('gender'))]

      if models then
        player:SetCharacterData('model', models[math.random(#models)], true)

        cw.player:SetName(player, name, true)
      end
    else
      return false, L('FactionTransfer_NeedName')
    end
  end
end

FACTION_LOYAL = FACTION:Register()
