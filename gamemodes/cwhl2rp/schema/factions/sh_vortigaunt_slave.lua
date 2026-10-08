--- Defines the whitelisted Vortigaunt Slave faction (`FACTION_VORT_SLAVE`), with the `vortigaunt_slave` model and a
-- rule that Combine characters transferred into it need a new name.

local FACTION = faction.New('#Faction_Vort_Slave')

FACTION.useFullName = true
FACTION.whitelist = true
FACTION.models = {
  female = { 'models/vortigaunt_slave.mdl' },
  male = { 'models/vortigaunt_slave.mdl' }
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

FACTION_VORT_SLAVE = FACTION:Register()
