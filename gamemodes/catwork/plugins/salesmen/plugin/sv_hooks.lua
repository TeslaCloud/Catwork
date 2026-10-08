--- Server-side hooks of the Salesmen plugin that load and save the map's salesmen and handle a player using one.
--
-- `PlayerCanUseSalesman` enforces the salesman's faction, class and flag restrictions, and `PlayerUseSalesman` sends
-- its inventory to the player in the `Salesmenu` Cable message.

--- Called after Catwork has loaded all map entities; spawns the salesmen saved for the current map.
function cwSalesmen:ClockworkInitPostEntity()
  self:LoadSalesmen()
end

--- Called just after data is saved; saves the current map's salesmen.
function cwSalesmen:PostSaveData()
  self:SaveSalesmen()
end

--- Called when a player attempts to use a salesman.
--
-- The player is refused when the salesman restricts factions or classes and the player's faction or
-- class is not among them. When the salesman has flags set, having those flags (with `-` characters
-- stripped) always allows use, and a flag string containing `-` refuses players without them. A
-- refused player hears the salesman's `noSale` line. Return `false` to block the use.
-- @param player [Player The player using the salesman]
-- @param entity [Entity The `cw_salesman` entity]
-- @return [Boolean `false` when the player may not trade with the salesman, otherwise `nil`]
function cwSalesmen:PlayerCanUseSalesman(player, entity)
  local flags = entity.cwFlags
  local bDisallowed = nil

  if next(entity.cwFactions) != nil then
    if !entity.cwFactions[player:GetFaction()] then
      bDisallowed = true
    end
  end

  if next(entity.cwClasses) != nil then
    if !entity.cwClasses[_team.GetName(player:Team())] then
      bDisallowed = true
    end
  end

  if isstring(flags) and flags != '' then
    local hasFlags = cw.player:HasFlags(player, flags:Replace('-', ''))

    if flags:find('-') and !hasFlags then
      bDisallowed = true
    end

    if hasFlags then
      bDisallowed = false
    end
  end

  if bDisallowed then
    entity:TalkToPlayer(player, entity.cwTextTab.noSale, L('Salesman_Default_NoSale'))
    return false
  end
end

--- Called when a player uses a salesman; opens the trade menu on the player's client.
--
-- Sends the salesman's stock, prices, cash and restrictions with the `Salesmenu` Cable message and
-- makes the salesman say its `start` line.
-- @param player [Player The player using the salesman]
-- @param entity [Entity The `cw_salesman` entity]
function cwSalesmen:PlayerUseSalesman(player, entity)
  cable.send(player, 'Salesmenu', {
    buyInShipments = entity.cwBuyInShipments,
    priceScale = entity.cwPriceScale,
    factions = entity.cwFactions,
    buyRate = entity.cwBuyRate,
    classes = entity.cwClasses,
    entity = entity,
    stock = entity.cwStock,
    sells = entity.cwSellTab,
    cash = entity.cwCash,
    text = entity.cwTextTab,
    buys = entity.cwBuyTab,
    name = entity:GetNWString('Name'),
    flags = entity.cwFlags
  })

  entity:TalkToPlayer(player, entity.cwTextTab.start, L('Salesman_Default_Start'))
end
