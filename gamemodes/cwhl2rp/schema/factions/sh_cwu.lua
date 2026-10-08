--- Defines the whitelisted Civil Worker's Union faction (`FACTION_CWU`), with the `group02` human models and a rule
-- that Combine characters transferred into it need a new name.

local FACTION = faction.New('#Faction_CWU')

FACTION.useFullName = true
FACTION.whitelist = true
FACTION.material = 'halfliferp/factions/citizen'
FACTION.giveCard = 'union_card'
FACTION.maximumAttributePoints = 35
FACTION.models = {
  female = {
    'models/humans/group02/female_01.mdl',
    'models/humans/group02/female_02.mdl',
    'models/humans/group02/female_03.mdl',
    'models/humans/group02/female_04.mdl',
    'models/humans/group02/female_06.mdl',
    'models/humans/group02/female_07.mdl'
  },
  male = {
    'models/humans/group02/male_01.mdl',
    'models/humans/group02/male_02.mdl',
    'models/humans/group02/male_03.mdl',
    'models/humans/group02/male_04.mdl',
    'models/humans/group02/male_05.mdl',
    'models/humans/group02/male_06.mdl',
    'models/humans/group02/male_07.mdl',
    'models/humans/group02/male_08.mdl',
    'models/humans/group02/male_09.mdl'
  }
}

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

FACTION_CWU = FACTION:Register()
