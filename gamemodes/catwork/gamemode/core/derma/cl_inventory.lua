--- Defines the `cwInventory` menu tab with its Inventory and Equipment sheets, and the panels it is built from.
--
-- `cwInventoryItem` is an item icon, `cwInventoryCustom` a custom entry, and `cwInventoryWeight` and
-- `cwInventorySpace` are the weight and space bars. The tab rebuilds from the local player's inventory and equipped
-- weapons when opened, and `HandleUnequip` asks the server to unequip an item.

local PANEL = {}

--- Creates the inventory menu tab with Inventory and Equipment sheets, registers itself as
-- `cw.inventory.panel` and builds it.
function PANEL:Init()
  self:SetSize(cw.menu:GetWidth(), cw.menu:GetHeight())

  self.inventoryList = vgui.Create('cwPanelList', self)
  self.inventoryList:SetPadding(8)
  self.inventoryList:SetSpacing(8)

  self.equipmentList = vgui.Create('cwPanelList', self)
  self.equipmentList:SetPadding(8)
  self.equipmentList:SetSpacing(8)

  self.columnSheet = vgui.Create('cwColumnSheet', self)
  self.columnSheet.Navigation:SetWidth(150)
  self.columnSheet:AddSheet('#Inventory', self.inventoryList, 'icon16/box.png')
  self.columnSheet:AddSheet('#Equipment', self.equipmentList, 'icon16/shield.png')

  cw.inventory.panel = self
  cw.inventory.panel:Rebuild()
end

--- Returns the width the menu should give the inventory tab.
-- @return [Number Half of the screen width]
function PANEL:GetMenuWidth()
  return ScrW() * 0.5
end

--- Asks the server to unequip an item, letting the item pick extra arguments first.
--
-- When the item has an `OnHandleUnequip` method, it is called with a function that sends the request,
-- optionally with arguments; otherwise the request is sent at once with the `UnequipItem` netstream.
--
-- @param itemTable [Item The equipped item to unequip]
function PANEL:HandleUnequip(itemTable)
  if itemTable.OnHandleUnequip then
    itemTable:OnHandleUnequip(
      function(arguments)
        if arguments then
          netstream.Start(
            'UnequipItem', { itemTable.uniqueID, itemTable.itemID, arguments }
          )
        else
          netstream.Start(
            'UnequipItem', { itemTable.uniqueID, itemTable.itemID }
          )
        end
      end)
  else
    netstream.Start(
      'UnequipItem', { itemTable.uniqueID, itemTable.itemID }
    )
  end
end

--- Rebuilds both sheets from the local player's inventory and equipped weapons.
--
-- The Inventory sheet starts with the weight bar, and the space bar when the space system is used.
-- Equipped items go to the Equipment sheet, under their `equippedCategory` when they have one, and
-- unequip when clicked. Categories are sorted by name and items by ID. Runs the `PlayerInventoryRebuilt`
-- hook with the panel and the `inventory` and `equipment` category lists before adding them.
function PANEL:Rebuild()
  self.equipmentList:Clear()
  self.inventoryList:Clear()

  --[[
  local label = vgui.Create("cwInfoText", self)
    label:SetText("To view an item's options, click on its spawn icon.")
    label:SetInfoColor("blue")
  self.inventoryList:AddItem(label)
  --]]

  self.weightForm = vgui.Create('cwBasicForm', self)
  self.weightForm:SetPadding(8)
  self.weightForm:SetSpacing(8)
  self.weightForm:SetAutoSize(true)
  self.weightForm:SetText('#Weight', nil, 'basic_form_highlight')
  self.weightForm:AddItem(vgui.Create('cwInventoryWeight', self))

  if cw.inventory:UseSpaceSystem() then
    self.spaceForm = vgui.Create('cwBasicForm', self)
    self.spaceForm:SetPadding(8)
    self.spaceForm:SetSpacing(8)
    self.spaceForm:SetAutoSize(true)
    self.spaceForm:SetText('#Space', nil, 'basic_form_highlight')
    self.spaceForm:AddItem(vgui.Create('cwInventorySpace', self))
  end

  local itemsList = { inventory = {}, equipment = {} }
  local categories = { inventory = {}, equipment = {} }

  for k, v in pairs(cw.client:GetWeapons()) do
    local itemTable = item.GetByWeapon(v)

    if itemTable and itemTable.HasPlayerEquipped
    and itemTable:HasPlayerEquipped(cw.client, true) then
      local itemCategory = itemTable.equippedCategory or itemTable.category

      itemsList.equipment[itemCategory] = itemsList.equipment[itemCategory] or {}
      itemsList.equipment[itemCategory][#itemsList.equipment[itemCategory] + 1] = itemTable
    end
  end

  for k, v in pairs(cw.inventory:GetClient()) do
    for k2, v2 in pairs(v) do
      local itemCategory = v2.category

      if v2.HasPlayerEquipped and v2:HasPlayerEquipped(cw.client, false) then
        itemCategory = v2.equippedCategory or itemCategory

        itemsList.equipment[itemCategory] = itemsList.equipment[itemCategory] or {}
        itemsList.equipment[itemCategory][#itemsList.equipment[itemCategory] + 1] = v2
      else
        itemsList.inventory[itemCategory] = itemsList.inventory[itemCategory] or {}
        itemsList.inventory[itemCategory][#itemsList.inventory[itemCategory] + 1] = v2
      end
    end
  end

  for k, v in pairs(itemsList.equipment) do
    categories.equipment[#categories.equipment + 1] = {
      itemsList = v,
      category = k
    }
  end

  table.sort(categories.equipment, function(a, b)
    return a.category < b.category
  end)

  for k, v in pairs(itemsList.inventory) do
    categories.inventory[#categories.inventory + 1] = {
      itemsList = v,
      category = k
    }
  end

  table.sort(categories.inventory, function(a, b)
    return a.category < b.category
  end)

  hook.Run('PlayerInventoryRebuilt', self, categories)

  if self.weightForm then
    self.inventoryList:AddItem(self.weightForm)
  end

  if cw.inventory:UseSpaceSystem() and self.spaceForm then
    self.inventoryList:AddItem(self.spaceForm)
  end

  if #categories.equipment > 0 then
    for k, v in pairs(categories.equipment) do
      --[[
      local collapsibleCategory = cw.core:CreateCustomCategoryPanel(v.category, self.equipmentList)
        collapsibleCategory:SetCookieName("Equipment"..v.category)
      self.equipmentList:AddItem(collapsibleCategory)
      --]]

      local categoryForm = vgui.Create('DCollapsibleCategory', self)
      categoryForm:SetLabel(L(v.category))

      local categoryList = vgui.Create('DPanelList', categoryForm)
        categoryList:EnableHorizontal(true)
        categoryList:SetAutoSize(true)
        categoryList:SetPadding(4)
        categoryList:SetSpacing(4)
      categoryForm:SetContents(categoryList)

      -- collapsibleCategory:SetContents(categoryList)

      table.sort(v.itemsList, function(a, b)
        return a.itemID < b.itemID
      end)

      for k2, v2 in pairs(v.itemsList) do
        local itemData = {
          itemTable = v2, OnPress = function()
            self:HandleUnequip(v2)
          end
        }

        self.itemData = itemData

        categoryList:AddItem(
          vgui.Create('cwInventoryItem', self)
        )
      end

      self.equipmentList:AddItem(categoryForm)
    end
  end

  if #categories.inventory > 0 then
    for k, v in pairs(categories.inventory) do
      --[[
      local collapsibleCategory = cw.core:CreateCustomCategoryPanel(v.category, self.inventoryList)
        collapsibleCategory:SetCookieName("Inventory"..v.category)
      self.inventoryList:AddItem(collapsibleCategory)
      --]]

      local categoryForm = vgui.Create('DCollapsibleCategory', self)
      categoryForm:SetLabel(L(v.category))

      local categoryList = vgui.Create('DPanelList', categoryForm)
        categoryList:EnableHorizontal(true)
        categoryList:SetAutoSize(true)
        categoryList:SetPadding(4)
        categoryList:SetSpacing(4)
      categoryForm:SetContents(categoryList)

      table.sort(v.itemsList, function(a, b)
        return a.itemID < b.itemID
      end)

      for k2, v2 in pairs(v.itemsList) do
        local itemData = {
          itemTable = v2
        }

        self.itemData = itemData
        categoryList:AddItem(
          vgui.Create('cwInventoryItem', self)
        )
      end

      self.inventoryList:AddItem(categoryForm)
    end
  end

  self.inventoryList:InvalidateLayout(true)
  self.equipmentList:InvalidateLayout(true)
  self:InvalidateLayout(true)
end

--- Rebuilds the sheets when the menu is opened while this tab is active.
function PANEL:OnMenuOpened()
  if cw.menu:IsPanelActive(self) then
    self:Rebuild()
  end
end

--- Rebuilds the sheets when the tab is selected in the menu.
function PANEL:OnSelected() self:Rebuild() end

--- Sizes the tab to 75% of the screen height and stretches the sheets to fill it.
function PANEL:PerformLayout(w, h)
  self:SetSize(w, ScrH() * 0.75)
  self.columnSheet:StretchToParent(4, 4, 4, 4)
  self.inventoryList:StretchToParent(4, 4, 4, 4)
  self.equipmentList:StretchToParent(4, 4, 4, 4)
end

--- Draws nothing.
function PANEL:Paint(w, h)
  return true
end

--- Rebuilds the inventory when the player gets a weapon that belongs to an item.
function PANEL:Think()
  for k, v in pairs(cw.client:GetWeapons()) do
    local weaponItem = item.GetByWeapon(v)

    if weaponItem and !v.cwIsWeaponItem then
      cw.inventory:Rebuild()
      v.cwIsWeaponItem = true
    end
  end
end

vgui.Register('cwInventory', PANEL, 'EditablePanel')

local PANEL = {}

--- Builds a custom inventory entry (`cwInventoryCustom`) from the parent's `customData` table.
--
-- `customData` may hold `PrintName` or `name`, `information` (a number is shown in kilograms),
-- `description` (the tooltip), `model`, `skin`, `spawnIconColor` and `Callback`, which runs when the
-- icon is clicked.
function PANEL:Init()
  self:SetSize(self:GetParent():GetWide(), 32)

  local customData = self:GetParent().customData or {}
  local toolTip = ''

  if customData.information then
    if isnumber(customData.information) then
      customData.information = customData.information..L('#Unit_Kilograms')
    end
  end

  if customData.description then
    toolTip = config.Parse(customData.description)
  end

  if toolTip == '' then
    toolTip = nil
  end

  self.nameLabel = vgui.Create('DLabel', self)
  self.nameLabel:SetPos(36, 2)
  self.nameLabel:SetText(cw.lang:TranslateText(customData.PrintName) or customData.name)
  self.nameLabel:SizeToContents()

  self.infoLabel = vgui.Create('DLabel', self)
  self.infoLabel:SetPos(36, 2)
  self.infoLabel:SetText(cw.lang:TranslateText('#ItemContextMenu_Information'))
  self.infoLabel:SizeToContents()

  self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create('cwSpawnIcon', self))
  self.spawnIcon:SetColor(customData.spawnIconColor)

  -- Called when the spawn icon is clicked.
  function self.spawnIcon.DoClick(spawnIcon)
    if customData.Callback then
      customData.Callback()
    end
  end

  self.spawnIcon:SetModel(customData.model, customData.skin)
  self.spawnIcon:SetTooltip(toolTip)
  self.spawnIcon:SetSize(32, 32)
end

--- Keeps the custom entry's information label at the bottom of the entry.
function PANEL:Think()
  self.infoLabel:SetPos(self.infoLabel.x, 30 - self.infoLabel:GetTall())
end

vgui.Register('cwInventoryCustom', PANEL, 'DPanel')

local PANEL = {}

--- Builds an item icon (`cwInventoryItem`) for the parent's `itemData`.
--
-- `itemData.itemTable` is the item shown. When `itemData.OnPress` is set it runs on click instead of the
-- usual item menu, and the right click menu is disabled.
function PANEL:Init()
  local itemData = self:GetParent().itemData
  self:SetSize(48, 48)
  self.itemTable = itemData.itemTable
  self.spawnIcon = cw.core:CreateMarkupToolTip(vgui.Create('cwSpawnIcon', self))

  if !itemData.OnPress then
    self.spawnIcon.OpenMenu = function(spawnIcon)
      cw.core:HandleItemSpawnIconRightClick(self.itemTable, spawnIcon)
    end
  end

  -- Called when the spawn icon is clicked.
  function self.spawnIcon.DoClick(spawnIcon)
    if itemData.OnPress then
      itemData.OnPress()
      return
    end

    cw.core:HandleItemSpawnIconClick(self.itemTable, spawnIcon)
  end

  local model, skin = item.GetIconInfo(self.itemTable)
    self.spawnIcon:SetModel(model, skin)
    self.spawnIcon:SetSize(48, 48)
  self.cachedInfo = { model = model, skin = skin }
end

--- Refreshes the item icon's tooltip and color, and its model when the item's icon changes.
function PANEL:Think()
  self.spawnIcon:SetMarkupToolTip(item.GetMarkupToolTip(self.itemTable))
  self.spawnIcon:SetColor(self.itemTable.color)

  --[[ Check if the model or skin has changed and update the spawn icon. --]]
  local model, skin = item.GetIconInfo(self.itemTable)

  if model != self.cachedInfo.model or skin != self.cachedInfo.skin then
    self.spawnIcon:SetModel(model, skin)
    self.cachedInfo.model = model
    self.cachedInfo.skin = skin
  end
end

--- Draws the item icon's background.
function PANEL:Paint(w, h)
  draw.RoundedBox(0, 0, 0, w, h, cw.option:GetColor('panel_background'))
end

vgui.Register('cwInventoryItem', PANEL, 'DPanel')

local PANEL = {}

PANEL.invWeight = 0

--- Creates the inventory weight bar (`cwInventoryWeight`) and its label.
function PANEL:Init()
  local maximumWeight = cw.player:GetMaxWeight()
  local colorWhite = cw.option:GetColor('white')

  self.spaceUsed = vgui.Create('DPanel', self)
  self.spaceUsed:SetPos(1, 1)

  self.weight = vgui.Create('DLabel', self)
  self.weight:SetText('N/A')
  self.weight:SetTextColor(colorWhite)
  self.weight:SizeToContents()

  -- Called when the panel should be painted.
  function self.spaceUsed.Paint(spaceUsed)
    local inventoryWeight = self.invWeight
    local maximumWeight = cw.player:GetMaxWeight()

    local width = math.Clamp((spaceUsed:GetWide() / maximumWeight) * inventoryWeight, 0, spaceUsed:GetWide())
    local red = math.Clamp((255 / maximumWeight) * inventoryWeight, 0, 255)

    draw.RoundedBox(2, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), cw.option:GetColor('panel_background'))
    cw.core:DrawSimpleGradientBox(0, 0, 0, width, spaceUsed:GetTall(), Color(115, 195, 100, 255))
  end
end

--- Updates the weight bar's carried and maximum weight.
function PANEL:Think()
  self.invWeight = cw.inventory:CalculateWeight(
    cw.inventory:GetClient()
  )

  self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2)
  self.weight:SetText(self.invWeight..'/'..cw.player:GetMaxWeight()..L('#Unit_Kilograms'))
  self.weight:SetPos(self:GetWide() / 2 - self.weight:GetWide() / 2, self:GetTall() / 2 - self.weight:GetTall() / 2)
  self.weight:SizeToContents()
end

vgui.Register('cwInventoryWeight', PANEL, 'DPanel')

local PANEL = {}

--- Creates the inventory space bar (`cwInventorySpace`) and its label.
function PANEL:Init()
  local maximumSpace = cw.player:GetMaxSpace()
  local colorWhite = cw.option:GetColor('white')

  self.spaceUsed = vgui.Create('DPanel', self)
  self.spaceUsed:SetPos(1, 1)

  self.space = vgui.Create('DLabel', self)
  self.space:SetText('N/A')
  self.space:SetTextColor(colorWhite)
  self.space:SizeToContents()
  self.space:SetExpensiveShadow(1, Color(0, 0, 0, 150))

  -- Called when the panel should be painted.
  function self.spaceUsed.Paint(spaceUsed)
    local inventorySpace = cw.inventory:CalculateSpace(
      cw.inventory:GetClient()
    )
    local maximumSpace = cw.player:GetMaxSpace()

    local color = Color(100, 100, 100, 255)
    local width = math.Clamp((spaceUsed:GetWide() / maximumSpace) * inventorySpace, 0, spaceUsed:GetWide())
    local red = math.Clamp((255 / maximumSpace) * inventorySpace, 0, 255)

    if color then
      color.r = math.min(color.r - 25, 255)
      color.g = math.min(color.g - 25, 255)
      color.b = math.min(color.b - 25, 255)
    end

    cw.core:DrawSimpleGradientBox(0, 0, 0, spaceUsed:GetWide(), spaceUsed:GetTall(), color)
    cw.core:DrawSimpleGradientBox(0, 0, 0, width, spaceUsed:GetTall(), Color(139, 215, 113, 255))
  end
end

--- Updates the space bar's used and maximum space every 0.1 seconds.
function PANEL:Think()
  if !self.nextUpdateContents then
    self.nextUpdateContents = CurTime() + 0.1
  end

  if CurTime() < self.nextUpdateContents then
    return
  end

  self.nextUpdateContents = nil

  local inventorySpace = cw.inventory:CalculateSpace(
    cw.inventory:GetClient()
  )

  self.spaceUsed:SetSize(self:GetWide() - 2, self:GetTall() - 2)
  self.space:SetText(inventorySpace..'/'..cw.player:GetMaxSpace()..L('#Unit_Litres'))
  self.space:SetPos(self:GetWide() / 2 - self.space:GetWide() / 2, self:GetTall() / 2 - self.space:GetTall() / 2)
  self.space:SizeToContents()
end

vgui.Register('cwInventorySpace', PANEL, 'DPanel')
