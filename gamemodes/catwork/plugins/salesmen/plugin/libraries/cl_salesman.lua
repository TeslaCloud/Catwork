--- Defines the client-side `cw.salesman` library, which holds the state of the salesman being created or edited in the
-- `cwSalesman` editor.
--
-- The netstream receivers and the editor write the fields straight into the library table; its getters expose the
-- name, model, sells and buys lists, stock, cash, price scale, buy rate, responses and the factions, classes and flags
-- allowed to trade.

library.New('salesman', cw)

--- Returns whether the salesman editor panel exists and is visible.
-- @return [Boolean `true` when the editor is open, otherwise `nil`]
function cw.salesman:IsSalesmanOpen()
  local panel = self:GetPanel()

  if IsValid(panel) and panel:IsVisible() then
    return true
  end
end

--- Returns whether the salesman being edited sells items in whole shipments (the item's `batch` size).
-- @return [Boolean Whether items are sold in shipments]
function cw.salesman:BuyInShipments()
  return self.buyInShipments
end

--- Returns the multiplier applied to item costs when the salesman being edited sells.
-- @return [Number The price scale, `1` when unset]
function cw.salesman:GetPriceScale()
  return self.priceScale or 1
end

--- Returns whether the salesman being edited shows a chat bubble above its head.
-- @return [Boolean Whether the chat bubble is shown]
function cw.salesman:GetShowChatBubble()
  return self.showChatBubble
end

--- Returns the starting stock of each item the salesman being edited sells.
-- @return [Number Stock per item, `-1` for unlimited]
function cw.salesman:GetStock()
  return self.stock
end

--- Returns the cash the salesman being edited has to buy items with.
-- @return [Number The salesman's cash, `-1` for unlimited]
function cw.salesman:GetCash()
  return self.cash
end

--- Returns the percentage of an item's cost the salesman being edited pays when buying it.
-- @return [Number The buy rate, from 1 to 100]
function cw.salesman:GetBuyRate()
  return self.buyRate
end

--- Returns the classes allowed to trade with the salesman being edited.
-- @return [Map Class names mapped to `true`; empty for no restriction]
function cw.salesman:GetClasses()
  return self.classes
end

--- Returns the factions allowed to trade with the salesman being edited.
-- @return [Map Faction names mapped to `true`; empty for no restriction]
function cw.salesman:GetFactions()
  return self.factions
end

--- Returns the responses of the salesman being edited.
--
-- The keys are `start`, `noSale`, `noStock`, `needMore`, `cannotAfford` and `doneBusiness`; each value
-- is a `Map` with `text`, `sound` and `bHideName`.
-- @return [Map The salesman's responses]
function cw.salesman:GetText()
  return self.text
end

--- Returns the items the salesman being edited sells.
-- @return [Map Item unique IDs mapped to a price override, or `true` to use the item's cost]
function cw.salesman:GetSells()
  return self.sells
end

--- Returns the items the salesman being edited buys.
-- @return [Map Item unique IDs mapped to a price override, or `true` to use the item's cost]
function cw.salesman:GetBuys()
  return self.buys
end

--- Returns every non-base item that can be added to the salesman being edited.
-- @return [Map<Item> Item tables keyed by unique ID]
function cw.salesman:GetItems()
  return self.items
end

--- Returns the salesman editor panel.
-- @return [Panel The `cwSalesman` panel, or `nil` if it was never created]
function cw.salesman:GetPanel()
  return self.panel
end

--- Returns the model of the salesman being edited.
-- @return [String The model path]
function cw.salesman:GetModel()
  return self.model
end

--- Returns the name of the salesman being edited.
-- @return [String The salesman's name]
function cw.salesman:GetName()
  return self.name
end

--- Returns the flags required to trade with the salesman being edited.
-- @return [String The flags; a `-` in the string refuses players without them]
function cw.salesman:GetFlags()
  return self.flags
end
