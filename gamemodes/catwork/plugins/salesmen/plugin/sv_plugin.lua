--- Server-side part of the Salesmen plugin, which carries out trades, spawns salesmen from the editor's data and saves
-- the map's salesmen.
--
-- The `Salesmenu` netstream receiver performs a purchase or a sale, `SalesmanAdd` validates the editor's data and
-- spawns a `cw_salesman`, and `SalesmanDone` plays the farewell response. `cwSalesmen:LoadSalesmen` and
-- `cwSalesmen:SaveSalesmen` keep the salesmen in the schema data under `plugins/salesmen/<map>`.

local responseKeys = { 'doneBusiness', 'cannotAfford', 'needMore', 'noStock', 'noSale', 'start' }
local varTypes = {
  ['showChatBubble'] = 'boolean',
  ['buyInShipments'] = 'boolean',
  ['priceScale'] = 'number',
  ['factions'] = 'table',
  ['physDesc'] = 'string',
  ['buyRate'] = 'number',
  ['classes'] = 'table',
  ['model'] = 'string',
  ['sells'] = 'table',
  ['stock'] = 'number',
  ['text'] = 'table',
  ['cash'] = 'number',
  ['buys'] = 'table',
  ['name'] = 'string',
  ['flags'] = 'string'
}

local function IsSalesman(entity)
  return isentity(entity) and IsValid(entity) and entity:GetClass() == 'cw_salesman'
end

-- A price, scale or amount sent by a client is only usable when it is a real, non-negative number.
local function IsValidAmount(value)
  return value == value and value >= 0 and value != math.huge
end

local function CanTradeWith(player, entity)
  return IsSalesman(entity) and player:HasInitialized() and player:Alive() and !player:IsRagdolled()
    and player:GetPos():Distance(entity:GetPos()) < 196
end

local function SendRebuild(player, entity)
  netstream.Start(player, 'SalesmenuRebuild', entity.cwCash, entity.cwStock)
end

local function SellToPlayer(player, entity, uniqueID)
  local price = entity.cwSellTab[uniqueID]
  local itemTable = price and item.FindByID(uniqueID)

  if !itemTable or itemTable.isBaseItem or itemTable.uniqueID != uniqueID then return end

  local stock = entity.cwStock[uniqueID]

  if stock and stock <= 0 then
    entity:TalkToPlayer(player, entity.cwTextTab.noStock, L('Salesman_Default_NoStock'))

    return
  end

  local amount = 1
  local cost = isnumber(price) and price or itemTable.cost

  if entity.cwPriceScale then
    cost = cost * entity.cwPriceScale
  end

  if entity.cwBuyInShipments then
    amount = math.max(itemTable.batch or 1, 1)
  end

  local total = math.max(math.Round(cost * amount), 0)

  if !player:CanHoldWeight(itemTable.weight * amount) or !player:CanHoldSpace((itemTable.space or 0) * amount) then
    cw.player:Notify(player, L('Salesman_CannotCarry'))

    return
  end

  if !cw.player:CanAfford(player, total) then
    entity:TalkToPlayer(
      player,
      entity.cwTextTab.needMore,
      L('YouNeedAnother', cw.core:FormatCash(total - player:GetCash(), nil, true))
    )

    return
  end

  if itemTable.CanOrder and itemTable:CanOrder(player) == false then return end

  local given = 0

  for i = 1, amount do
    if player:GiveItem(item.CreateInstance(uniqueID)) then
      given = given + 1
    end
  end

  if given == 0 then return end

  -- Only charge for what the player actually received.
  if given != amount then
    total = math.max(math.Round(cost * given), 0)
  end

  cw.player:GiveCash(player, -total, given..' '..itemTable.PrintName)
  cw.player:Notify(
    player,
    L('Salesman_YouReceived', given)..' '..itemTable.PrintName..' '..L('Salesman_From')..' '..
      entity:GetNWString('Name')..'.'
  )

  -- A cash of -1 means the salesman's cash is unlimited.
  if entity.cwCash != -1 then
    entity.cwCash = entity.cwCash + total
  end

  if stock then
    entity.cwStock[uniqueID] = stock - 1
  end

  SendRebuild(player, entity)
end

local function BuyFromPlayer(player, entity, uniqueID, itemID)
  local price = entity.cwBuyTab[uniqueID]
  local itemTable = price and player:FindItemByID(uniqueID, itemID)

  if !itemTable or itemTable.isBaseItem or itemTable.uniqueID != uniqueID then return end

  local cost = isnumber(price) and price or itemTable.cost

  if entity.cwBuyRate then
    cost = cost * (entity.cwBuyRate / 100)
  end

  cost = math.max(math.Round(cost), 0)

  if entity.cwCash != -1 and entity.cwCash < cost then
    entity:TalkToPlayer(player, entity.cwTextTab.cannotAfford, L('Salesman_Default_CannotAfford'))
  elseif player:TakeItem(itemTable) then
    if entity.cwCash != -1 then
      entity.cwCash = entity.cwCash - cost
    end

    cw.player:GiveCash(player, cost, '1 '..itemTable.PrintName)
    cw.player:Notify(
      player,
      L('Salesman_YouSold')..' '..itemTable.PrintName..' '..L('Salesman_To')..' '..entity:GetNWString('Name')..'.'
    )
  end

  SendRebuild(player, entity)
end

netstream.Hook('SalesmanDone', function(player, data)
  if IsSalesman(data) then
    data:TalkToPlayer(player, data.cwTextTab.doneBusiness, L('Salesman_Default_DoneBusiness'))
  end
end)

netstream.Hook('Salesmenu', function(player, data)
  if !istable(data) or !isstring(data.uniqueID) then return end

  local entity = data.entity

  -- The menu stays open on the client, so everything `ENT:Use` checked has to be checked again for each trade.
  if !CanTradeWith(player, entity) or hook.Run('PlayerCanUseSalesman', player, entity) == false then return end

  if data.tradeType == 'Sells' then
    SellToPlayer(player, entity, data.uniqueID)
  elseif data.tradeType == 'Buys' then
    BuyFromPlayer(player, entity, data.uniqueID, data.itemID)
  end
end)

-- Keeps the entries of an editor's sells or buys list that name a real item, with a usable price override or `true`.
local function SanitizeItemList(list)
  local stored = item.GetStored()
  local result = {}

  for k, v in pairs(list) do
    local itemTable = isstring(k) and stored[k]

    if itemTable and !itemTable.isBaseItem then
      result[k] = (isnumber(v) and IsValidAmount(v)) and v or true
    end
  end

  return result
end

local function SanitizeResponses(text)
  local result = {}

  for k, v in ipairs(responseKeys) do
    local response = text[v]

    result[v] = {}

    if istable(response) then
      result[v].text = isstring(response.text) and response.text or nil
      result[v].sound = isstring(response.sound) and response.sound or nil
      result[v].bHideName = (response.bHideName == true)
    end
  end

  return result
end

local function IsValidSalesmanData(data)
  if !istable(data) then return false end

  for k, v in pairs(varTypes) do
    if type(data[k]) != v then
      return false
    end
  end

  return IsValidAmount(data.priceScale) and IsValidAmount(data.buyRate)
    and (data.stock == -1 or IsValidAmount(data.stock)) and (data.cash == -1 or IsValidAmount(data.cash))
end

netstream.Hook('SalesmanAdd', function(player, data)
  local bSetup = player.cwSalesmanSetup
  local position = player.cwSalesmanPos or player.cwSalesmanHitPos
  local angles = player.cwSalesmanAng
  local animation = player.cwSalesmanAnim
  local oldSalesman = player.cwSalesmanEdit

  player.cwSalesmanAnim = nil
  player.cwSalesmanSetup = nil
  player.cwSalesmanPos = nil
  player.cwSalesmanAng = nil
  player.cwSalesmanHitPos = nil
  player.cwSalesmanEdit = nil

  if !bSetup or !position or !IsValidSalesmanData(data) then return end

  local salesman = ents.Create('cw_salesman')

  if !IsValid(salesman) then return end

  -- The salesman being edited is only replaced now that its new settings are known to be usable.
  if IsSalesman(oldSalesman) then
    cwSalesmen:RemoveSalesman(oldSalesman)
  end

  if !angles then
    angles = player:GetAngles()
    angles.pitch = 0 angles.roll = 0
    angles.yaw = angles.yaw + 180
  end

  local sells = SanitizeItemList(data.sells)

  salesman:SetPos(position)
  salesman:SetAngles(angles)
  salesman:SetModel(data.model)
  salesman:Spawn()
  salesman.cwStock = {}

  if data.stock != -1 then
    for k, v in pairs(sells) do
      salesman.cwStock[k] = data.stock
    end
  end

  salesman.cwCash = data.cash
  salesman.cwBuyTab = SanitizeItemList(data.buys)
  salesman.cwSellTab = sells
  salesman.cwTextTab = SanitizeResponses(data.text)
  salesman.cwClasses = data.classes
  salesman.cwBuyRate = data.buyRate
  salesman.cwFactions = data.factions
  salesman.cwPriceScale = data.priceScale
  salesman.cwBuyInShipments = data.buyInShipments
  salesman.cwAnimation = animation
  salesman.cwFlags = data.flags

  salesman:SetupSalesman(data.name, data.physDesc, animation, data.showChatBubble)

  cw.entity:MakeSafe(salesman, true, true)
  cwSalesmen.salesmen[#cwSalesmen.salesmen + 1] = salesman
  cwSalesmen:SaveSalesmen()
end)

--- Removes a salesman entity from the map and from `cwSalesmen.salesmen`.
--
-- Does not save; call `cwSalesmen:SaveSalesmen` afterwards.
-- @param entity [Entity The `cw_salesman` entity]
function cwSalesmen:RemoveSalesman(entity)
  for k, v in pairs(self.salesmen) do
    if v == entity then
      self.salesmen[k] = nil
    end
  end

  -- Without its cash the removed salesman has nothing for the Storage plugin to drop on the ground.
  entity.cwCash = nil
  entity:Remove()
end

--- Spawns every salesman saved for the current map.
--
-- Reads `plugins/salesmen/<map>` from the schema data, creates a `cw_salesman` entity for each entry,
-- restores its trade settings and makes it safe from removal. Replaces `cwSalesmen.salesmen` with the
-- spawned entities; entries without a position, angles or model are skipped.
-- @see cwSalesmen:SaveSalesmen
function cwSalesmen:LoadSalesmen()
  local salesmen = cw.core:RestoreSchemaData('plugins/salesmen/'..game.GetMap())

  self.salesmen = {}

  for k, v in pairs(salesmen) do
    local salesman = istable(v) and isvector(v.position) and isangle(v.angles) and isstring(v.model)
      and ents.Create('cw_salesman')

    if IsValid(salesman) then
      salesman:SetPos(v.position)
      salesman:SetModel(v.model)
      salesman:SetAngles(v.angles)
      salesman:Spawn()

      salesman.cwCash = tonumber(v.cash) or -1
      salesman.cwStock = istable(v.stock) and v.stock or {}
      salesman.cwClasses = istable(v.classes) and v.classes or {}
      salesman.cwBuyRate = v.buyRate
      salesman.cwFactions = istable(v.factions) and v.factions or {}
      salesman.cwBuyTab = istable(v.buyTab) and v.buyTab or {}
      salesman.cwSellTab = istable(v.sellTab) and v.sellTab or {}
      salesman.cwTextTab = SanitizeResponses(istable(v.textTab) and v.textTab or {})
      salesman.cwPriceScale = v.priceScale
      salesman.cwBuyInShipments = v.buyInShipments
      salesman.cwAnimation = v.animation
      salesman.cwFlags = v.flags

      salesman:SetupSalesman(v.name or '', v.physDesc or '', v.animation, v.showChatBubble)

      cw.entity:MakeSafe(salesman, true, true)
      self.salesmen[#self.salesmen + 1] = salesman
    end
  end
end

--- Builds the saveable settings table of a salesman entity.
--
-- The keys are `name`, `cash`, `stock`, `model`, `angles`, `buyRate`, `factions`, `buyTab`, `sellTab`,
-- `textTab`, `classes`, `position`, `physDesc`, `animation`, `priceScale`, `buyInShipments`,
-- `showChatBubble` and `flags`. `cwSalesmen:LoadSalesmen` and the `SalesmanEdit` command read this format.
-- @param entity [Entity The `cw_salesman` entity]
-- @return [Map The salesman's settings]
function cwSalesmen:GetTableFromEntity(entity)
  return {
    name = entity:GetNWString('Name'),
    cash = entity.cwCash,
    stock = entity.cwStock,
    model = entity:GetModel(),
    angles = entity:GetAngles(),
    buyRate = entity.cwBuyRate,
    factions = entity.cwFactions,
    buyTab = entity.cwBuyTab,
    sellTab = entity.cwSellTab,
    textTab = entity.cwTextTab,
    classes = entity.cwClasses,
    position = entity:GetPos(),
    physDesc = entity:GetNWString('PhysDesc'),
    animation = entity.cwAnimation,
    priceScale = entity.cwPriceScale,
    buyInShipments = entity.cwBuyInShipments,
    showChatBubble = IsValid(entity:GetChatBubble()),
    flags = entity.cwFlags
  }
end

--- Saves every valid salesman on the map to the schema data file `plugins/salesmen/<map>`.
-- @see cwSalesmen:GetTableFromEntity
function cwSalesmen:SaveSalesmen()
  local salesmen = {}

  for k, v in pairs(self.salesmen) do
    if IsValid(v) then
      salesmen[#salesmen + 1] = self:GetTableFromEntity(v)
    end
  end

  cw.core:SaveSchemaData('plugins/salesmen/'..game.GetMap(), salesmen)
end
