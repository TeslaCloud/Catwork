--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when the salesman's target ID is painted.
function cwSalesmen:SalesmanTargetID(entity, x, y, alpha) end

netstream.Hook("Salesmenu", function(data)
	cw.salesmenu.buyInShipments = data.buyInShipments
	cw.salesmenu.priceScale = data.priceScale
	cw.salesmenu.factions = data.factions
	cw.salesmenu.buyRate = data.buyRate
	cw.salesmenu.classes = data.classes
	cw.salesmenu.entity = data.entity
	cw.salesmenu.sells = data.sells
	cw.salesmenu.stock = data.stock
	cw.salesmenu.cash = data.cash
	cw.salesmenu.text = data.text
	cw.salesmenu.buys = data.buys
	cw.salesmenu.name = data.name
	cw.salesmenu.flags = data.flags

	cw.salesmenu.panel = vgui.Create("cwSalesmenu")
	cw.salesmenu.panel:Rebuild()
	cw.salesmenu.panel:MakePopup()
end)

netstream.Hook("SalesmenuRebuild", function(data)
	local cash = data

	if (cw.salesmenu:IsSalesmenuOpen()) then
		cw.salesmenu.cash = cash
		cw.salesmenu.panel:Rebuild()
	end
end)

netstream.Hook("SalesmanPlaySound", function(data)
	if (data[2] and data[2]:IsValid()) then
		data[2]:EmitSound(data[1])
	end
end)

netstream.Hook("SalesmanAdd", function(data)
	if (cw.salesman:IsSalesmanOpen()) then
		CloseDermaMenus()

		cw.salesman.panel:Close()
		cw.salesman.panel:Remove()
	end

	Derma_StringRequest("Имя", "Каким будет имя торговца?", "", function(text)
		cw.salesman.name = text

		gui.EnableScreenClicker(true)

		cw.salesman.showChatBubble = true
		cw.salesman.buyInShipments = true
		cw.salesman.priceScale = 1
		cw.salesman.physDesc = ""
		cw.salesman.flags = ""
		cw.salesman.factions = {}
		cw.salesman.buyRate = 100
		cw.salesman.classes = {}
		cw.salesman.stock = -1
		cw.salesman.sells = {}
		cw.salesman.model = "models/humans/group01/male_0"..math.random(1, 9)..".mdl"
		cw.salesman.items = {}
		cw.salesman.cash = -1
		cw.salesman.text = {
			doneBusiness = {},
			cannotAfford = {},
			needMore = {},
			noStock = {},
			noSale = {},
			start = {}
		}
		cw.salesman.buys = {}
		cw.salesman.name = cw.salesman.name

		for k, v in pairs(item.GetAll()) do
			if (!v.isBaseItem) then
				cw.salesman.items[k] = v
			end
		end

		cw.salesman.panel = vgui.Create("cwSalesman")
		cw.salesman.panel:Rebuild()
		cw.salesman.panel:MakePopup()
	end)
end)

netstream.Hook("SalesmanEdit", function(data)
	if (cw.salesman:IsSalesmanOpen()) then
		CloseDermaMenus()

		cw.salesman.panel:Close()
		cw.salesman.panel:Remove()
	end

	Derma_StringRequest("Имя", "Вы хотите изменить имя торговца?", data.name, function(text)
		cw.salesman.showChatBubble = data.showChatBubble
		cw.salesman.buyInShipments = data.buyInShipments
		cw.salesman.priceScale = data.priceScale
		cw.salesman.factions = data.factions
		cw.salesman.physDesc = data.physDesc
		cw.salesman.flags = data.flags
		cw.salesman.buyRate = data.buyRate
		cw.salesman.classes = data.classes
		cw.salesman.stock = -1
		cw.salesman.sells = data.sellTab
		cw.salesman.model = data.model
		cw.salesman.items = {}
		cw.salesman.cash = data.cash
		cw.salesman.text = data.textTab
		cw.salesman.buys = data.buyTab
		cw.salesman.name = text

		for k, v in pairs(item.GetAll()) do
			if (!v.isBaseItem) then
				cw.salesman.items[k] = v
			end
		end

		gui.EnableScreenClicker(true)

		local scrW = ScrW()
		local scrH = ScrH()

		cw.salesman.panel = vgui.Create("cwSalesman")
		cw.salesman.panel:SetSize(scrW * 0.5, scrH * 0.75)
		cw.salesman.panel:SetPos(
			(scrW / 2) - (cw.salesman.panel:GetWide() / 2),
			(scrH / 2) - (cw.salesman.panel:GetTall() / 2)
		)
		cw.salesman.panel:Rebuild()
		cw.salesman.panel:MakePopup()
	end)
end);
