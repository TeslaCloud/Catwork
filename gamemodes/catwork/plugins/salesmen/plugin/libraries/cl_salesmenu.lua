--- Defines the client-side `cw.salesmenu` library, which holds the data of the salesman whose trade menu is open.
--
-- The data arrives in the `Salesmenu` netstream message; the getters expose the salesman entity, its sells and buys
-- lists, stock, cash, prices and trade restrictions to the `cwSalesmenu` panel.

library.New('salesmenu', cw)

--- Returns whether the salesman trade menu exists and is visible.
-- @return [Boolean `true` when the menu is open, otherwise `nil`]
function cw.salesmenu:IsSalesmenuOpen()
  local panel = self:GetPanel()

  if IsValid(panel) and panel:IsVisible() then
    return true
  end
end

--- Returns whether the open salesman sells items in whole shipments (the item's `batch` size).
-- @return [Boolean Whether items are sold in shipments]
function cw.salesmenu:BuyInShipments()
  return self.buyInShipments
end

--- Returns the multiplier the open salesman applies to item costs when selling.
-- @return [Number The price scale, `1` when unset]
function cw.salesmenu:GetPriceScale()
  return self.priceScale or 1
end

--- Returns the percentage of an item's cost the open salesman pays when buying it.
-- @return [Number The buy rate, from 1 to 100]
function cw.salesmenu:GetBuyRate()
  return self.buyRate
end

--- Returns the classes allowed to trade with the open salesman.
-- @return [Map Class names mapped to `true`; empty for no restriction]
function cw.salesmenu:GetClasses()
  return self.classes
end

--- Returns the factions allowed to trade with the open salesman.
-- @return [Map Faction names mapped to `true`; empty for no restriction]
function cw.salesmenu:GetFactions()
  return self.factions
end

--- Returns the remaining stock of the open salesman.
-- @return [Map Item unique IDs mapped to the amount left; items without an entry are unlimited]
function cw.salesmenu:GetStock()
  return self.stock
end

--- Returns the cash the open salesman has to buy items with.
-- @return [Number The salesman's cash, `-1` for unlimited]
function cw.salesmenu:GetCash()
  return self.cash
end

--- Returns the responses of the open salesman.
-- @return [Map Response names such as `start` or `noStock` mapped to `Map`s with `text`, `sound` and `bHideName`]
function cw.salesmenu:GetText()
  return self.text
end

--- Returns the salesman entity the trade menu was opened for.
-- @return [Entity The `cw_salesman` entity]
function cw.salesmenu:GetEntity()
  return self.entity
end

--- Returns the items the open salesman buys.
-- @return [Map Item unique IDs mapped to a price override, or `true` to use the item's cost]
function cw.salesmenu:GetBuys()
  return self.buys
end

--- Returns the items the open salesman sells.
-- @return [Map Item unique IDs mapped to a price override, or `true` to use the item's cost]
function cw.salesmenu:GetSells()
  return self.sells
end

--- Returns the salesman trade menu panel.
-- @return [Panel The `cwSalesmenu` panel, or `nil` if it was never created]
function cw.salesmenu:GetPanel()
  return self.panel
end

--- Returns the name of the open salesman.
-- @return [String The salesman's name]
function cw.salesmenu:GetName()
  return self.name
end

--- Returns the flags required to trade with the open salesman.
-- @return [String The flags]
function cw.salesmenu:GetFlags()
  return self.flags
end
