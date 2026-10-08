--- Client-side netstream receivers of the Salesmen plugin that open the trade menu and the salesman editor.
--
-- `Salesmenu` and `SalesmenuRebuild` fill `cw.salesmenu` and show the `cwSalesmenu` panel, `SalesmanAdd` and
-- `SalesmanEdit` ask for a name, fill `cw.salesman` and show the `cwSalesman` editor, and `SalesmanPlaySound` plays a
-- response sound on the salesman.

--- Called when a salesman's target ID is painted; does nothing here.
--
-- The salesman draws its name and physical description only when a hook returns a true value.
-- @param entity [Entity The `cw_salesman` entity]
-- @param x [Number Horizontal position of the target ID]
-- @param y [Number Vertical position of the target ID]
-- @param alpha [Number Opacity of the target ID, from 0 to 255]
-- @return [Boolean Return `true` to draw the salesman's name and description]
function cwSalesmen:SalesmanTargetID(entity, x, y, alpha) end

netstream.Hook('Salesmenu', function(data)
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

  cw.salesmenu.panel = vgui.Create('cwSalesmenu')
  cw.salesmenu.panel:Rebuild()
  cw.salesmenu.panel:MakePopup()
end)

netstream.Hook('SalesmenuRebuild', function(cash, stock)
  if cw.salesmenu:IsSalesmenuOpen() then
    cw.salesmenu.cash = cash
    cw.salesmenu.stock = stock or cw.salesmenu.stock
    cw.salesmenu.panel:Rebuild()
  end
end)

netstream.Hook('SalesmanPlaySound', function(data)
  if IsValid(data[2]) then
    data[2]:EmitSound(data[1])
  end
end)

netstream.Hook('SalesmanAdd', function(data)
  if cw.salesman:IsSalesmanOpen() then
    CloseDermaMenus()

    cw.salesman.panel:Close()
    cw.salesman.panel:Remove()
  end

  Derma_StringRequest('#Salesman_Name', '#Salesman_NameRequest', '', function(text)
    cw.salesman.name = text

    gui.EnableScreenClicker(true)

    cw.salesman.showChatBubble = true
    cw.salesman.buyInShipments = true
    cw.salesman.priceScale = 1
    cw.salesman.physDesc = ''
    cw.salesman.flags = ''
    cw.salesman.factions = {}
    cw.salesman.buyRate = 100
    cw.salesman.classes = {}
    cw.salesman.stock = -1
    cw.salesman.sells = {}
    cw.salesman.model = 'models/humans/group01/male_0'..math.random(1, 9)..'.mdl'
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
      if !v.isBaseItem then
        cw.salesman.items[k] = v
      end
    end

    cw.salesman.panel = vgui.Create('cwSalesman')
    cw.salesman.panel:Rebuild()
    cw.salesman.panel:MakePopup()
  end)
end)

netstream.Hook('SalesmanEdit', function(data)
  if cw.salesman:IsSalesmanOpen() then
    CloseDermaMenus()

    cw.salesman.panel:Close()
    cw.salesman.panel:Remove()
  end

  Derma_StringRequest('#Salesman_Name', '#Salesman_NameEditRequest', data.name, function(text)
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
      if !v.isBaseItem then
        cw.salesman.items[k] = v
      end
    end

    gui.EnableScreenClicker(true)

    local scrW = ScrW()
    local scrH = ScrH()

    cw.salesman.panel = vgui.Create('cwSalesman')
    cw.salesman.panel:SetSize(scrW * 0.5, scrH * 0.75)
    cw.salesman.panel:SetPos(
      (scrW / 2) - (cw.salesman.panel:GetWide() / 2),
      (scrH / 2) - (cw.salesman.panel:GetTall() / 2)
    )
    cw.salesman.panel:Rebuild()
    cw.salesman.panel:MakePopup()
  end)
end)
