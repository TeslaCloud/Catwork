--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("salesman", cw)

-- A function to get whether the salesman is open.
function cw.salesman:IsSalesmanOpen()
	local panel = self:GetPanel()

	if (IsValid(panel) and panel:IsVisible()) then
		return true
	end
end

-- A function to get whether the items are bought shipments.
function cw.salesman:BuyInShipments()
	return self.buyInShipments
end

-- A function to get the salesman price scale.
function cw.salesman:GetPriceScale()
	return self.priceScale or 1
end

-- A function to get whether the salesman's chat bubble is shown.
function cw.salesman:GetShowChatBubble()
	return self.showChatBubble
end

-- A function to get the salesman stock.
function cw.salesman:GetStock()
	return self.stock
end

-- A function to get the salesman cash.
function cw.salesman:GetCash()
	return self.cash
end

-- A function to get the salesman buy rate.
function cw.salesman:GetBuyRate()
	return self.buyRate
end

-- A function to get the salesman classes.
function cw.salesman:GetClasses()
	return self.classes
end

-- A function to get the salesman factions.
function cw.salesman:GetFactions()
	return self.factions
end

-- A function to get the salesman text.
function cw.salesman:GetText()
	return self.text
end

-- A function to get what the salesman sells.
function cw.salesman:GetSells()
	return self.sells
end

-- A function to get what the salesman buys.
function cw.salesman:GetBuys()
	return self.buys
end

-- A function to get the salesman items.
function cw.salesman:GetItems()
	return self.items
end

-- A function to get the salesman panel.
function cw.salesman:GetPanel()
	return self.panel
end

-- A function to get the salesman model.
function cw.salesman:GetModel()
	return self.model
end

-- A function to get the salesman name.
function cw.salesman:GetName()
	return self.name
end

-- A function to get the salesman flags.
function cw.salesman:GetFlags()
	return self.flags
end
