--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("salesmenu", cw)

-- A function to get whether the salesmenu is open.
function cw.salesmenu:IsSalesmenuOpen()
	local panel = self:GetPanel()

	if (IsValid(panel) and panel:IsVisible()) then
		return true
	end
end

-- A function to get whether the items are bought shipments.
function cw.salesmenu:BuyInShipments()
	return self.buyInShipments
end

-- A function to get the salesmenu price scale.
function cw.salesmenu:GetPriceScale()
	return self.priceScale or 1
end

-- A function to get the salesmenu buy rate.
function cw.salesmenu:GetBuyRate()
	return self.buyRate
end

-- A function to get the salesmenu classes.
function cw.salesmenu:GetClasses()
	return self.classes
end

-- A function to get the salesmenu factions.
function cw.salesmenu:GetFactions()
	return self.factions
end

-- A function to get the salesmenu stock.
function cw.salesmenu:GetStock()
	return self.stock
end

-- A function to get the salesmenu cash.
function cw.salesmenu:GetCash()
	return self.cash
end

-- A function to get the salesmenu text.
function cw.salesmenu:GetText()
	return self.text
end

-- A function to get the salesmenu entity.
function cw.salesmenu:GetEntity()
	return self.entity
end

-- A function to get the salesmenu buys.
function cw.salesmenu:GetBuys()
	return self.buys
end

-- A function to get the salesmenu sels.
function cw.salesmenu:GetSells()
	return self.sells
end

-- A function to get the salesmenu panel.
function cw.salesmenu:GetPanel()
	return self.panel
end

-- A function to get the salesmenu name.
function cw.salesmenu:GetName()
	return self.name
end

-- A function to get the salesmenu flags.
function cw.salesmenu:GetFlags()
	return self.flags
end
