--- Client-side gamemode hooks of the Catwork framework, defined on `GM`.
--
-- Covers the HUD (`HUDPaint`, `HUDPaintForeground`, `HUDDrawTargetID`, `HUDDrawScoreBoard`, the bars, crosshair and
-- vignette), the view and input (`CalcView`, `CreateMove`, `PlayerBindPress`), screen effects, the menu, the
-- scoreboard and the chat box. Much of the file is the default implementation of the framework's own hooks, such as
-- `PlayerCanSeeBars`, `GetPlayerScoreboardOptions`, `GetEntityMenuOptions`, `GetDoorInfo` and `GetProgressBarInfo`,
-- which schemas and plugins override or extend.

--- Called to check whether the local player has lenses, an item with the unique ID `lenses` in their inventory.
-- @return [Boolean Whether the player has lenses]
function GM:PlayerHasLenses()
  local clientInventory = cw.inventory:GetClient()

  if clientInventory then
    return cw.inventory:HasItemByID(clientInventory, 'lenses')
  end

  return false
end

--- Called when the Derma skin's name is needed; forces the `Clockwork` skin.
-- @return [String The skin name]
function GM:ForceDermaSkin()
  return 'Clockwork'
end

--- Called to display a HUD notification when a weapon has been picked up; overridden to show nothing.
-- @param ... [Any The engine's arguments, ignored]
function GM:HUDWeaponPickedUp(...) end

--- Called to display a HUD notification when an item has been picked up; overridden to show nothing.
-- @param ... [Any The engine's arguments, ignored]
function GM:HUDItemPickedUp(...) end

--- Called to display a HUD notification when ammo has been picked up; overridden to show nothing.
-- @param ... [Any The engine's arguments, ignored]
function GM:HUDAmmoPickedUp(...) end

--- Called when the context menu is opened.
--
-- Opens the normal context menu while a tool is in use, otherwise only shows the cursor.
function GM:OnContextMenuOpen()
  if cw.core:IsUsingTool() then
    return self.BaseClass:OnContextMenuOpen(self)
  else
    gui.EnableScreenClicker(true)
  end
end

--- Called when the context menu is closed.
--
-- Closes the normal context menu while a tool is in use, otherwise only hides the cursor.
function GM:OnContextMenuClose()
  if cw.core:IsUsingTool() then
    return self.BaseClass:OnContextMenuClose(self)
  else
    gui.EnableScreenClicker(false)
  end
end

--- Called to check whether a player can use a property on an entity; only living, standing admins can.
-- @param player [Player The player trying to use the property]
-- @param property [String The property name]
-- @param entity [Entity The entity the property is used on]
-- @return [Boolean Whether the player can use the property]
function GM:CanProperty(player, property, entity)
  if !IsValid(entity) then
    return false
  end

  local bIsAdmin = cw.player:IsAdmin(player)

  if !player:Alive() or player:IsRagdolled() or !bIsAdmin then
    return false
  end

  return self.BaseClass:CanProperty(player, property, entity)
end

--- Called to check whether a player can drive an entity; only living, standing admins can.
-- @param player [Player The player trying to drive]
-- @param entity [Entity The entity the player is trying to drive]
-- @return [Boolean Whether the player can drive the entity]
function GM:CanDrive(player, entity)
  if !IsValid(entity) then
    return false
  end

  if !player:Alive() or player:IsRagdolled() or !cw.player:IsAdmin(player) then
    return false
  end

  return self.BaseClass:CanDrive(player, entity)
end

--- Called when the directory is rebuilt; lists help only for the commands the local player has the flags for.
-- @param panel [Panel The directory panel]
function GM:ClockworkDirectoryRebuilt(panel)
  for k, v in pairs(cw.command.stored) do
    if !cw.player:HasFlags(cw.client, v.access) then
      cw.command:RemoveHelp(v)
    else
      cw.command:AddHelp(v)
    end
  end
end

--- Called when the local player is given an item; rebuilds the open storage panel.
-- @param itemTable [Item The item that was given]
function GM:PlayerItemGiven(itemTable)
  if cw.storage:IsStorageOpen() then
    cw.storage:GetPanel():Rebuild()
  end
end

--- Called when the local player has an item taken from them; rebuilds the open storage panel.
-- @param itemTable [Item The item that was taken]
function GM:PlayerItemTaken(itemTable)
  if cw.storage:IsStorageOpen() then
    cw.storage:GetPanel():Rebuild()
  end
end

--- Called for each config key once the config has been received; zeroes every item's cost when `cash_enabled` is off.
-- @param key [String The config key]
-- @param value [Any The config value]
function GM:ClockworkConfigInitialized(key, value)
  if key == 'cash_enabled' and !value then
    for k, v in pairs(item.GetAll()) do
      v.cost = 0
    end
  end
end

local checkTable = {
  ['cwTextColorR'] = true,
  ['cwTextColorG'] = true,
  ['cwTextColorB'] = true,
  ['cwTextColorA'] = true
}

--- Called when one of the client's Catwork ConVars has changed.
--
-- The `cwTextColor` ConVars update the `information` colour unless the theme is fixed, and
-- `cwActiveTheme` switches the theme when `modify_themes` is enabled.
-- @param name [String The ConVar name]
-- @param previousValue [String The previous value]
-- @param newValue [String The new value]
function GM:ClockworkConVarChanged(name, previousValue, newValue)
  if checkTable[name] and !cw.theme:IsFixed() then
    cw.option:SetColor(
      'information',
      Color(
        cvars.Number('cwTextColorR', 255),
        cvars.Number('cwTextColorG', 255),
        cvars.Number('cwTextColorB', 255),
        cvars.Number('cwTextColorA', 255)
      )
    )
  elseif name == 'cwActiveTheme' then
    if config.Get('modify_themes'):GetBoolean() then
      local newTheme = cw.theme:FindByID(newValue)

      if newTheme then
        cw.theme:SetActive(newTheme)
      end
    end
  end
end

--- Called when an entity's menu options are needed.
--
-- Adds use (when the item has `OnUse`), take and examine options for `cw_item` entities plus the
-- item's own `GetEntityMenuOptions`, open for `cw_belongings` and `cw_shipment`, and take for
-- `cw_cash`. The values are sent to the server's `GM:EntityHandleMenuOption`.
-- @param entity [Entity The entity]
-- @param options [Map Option names mapped to their argument strings, modified in place]
function GM:GetEntityMenuOptions(entity, options)
  local class = entity:GetClass()

  if class == 'cw_item' then
    local itemTable = nil

    if entity.GetItemTable then
      itemTable = entity:GetItemTable()
    else
      debug.Trace()
    end

    if itemTable then
      local useText = itemTable.useText or '#EntityMenuOptions_useText'

      if itemTable.OnUse then
        options[L(useText)] = 'cw.itemUse'
      end

      if itemTable.GetEntityMenuOptions then
        itemTable:GetEntityMenuOptions(entity, options)
      end

      options['#EntityMenuOptions_Take'] = 'cw.itemTake'
      options['#EntityMenuOptions_Examine'] = 'cw.itemExamine'
    end
  elseif class == 'cw_belongings' then
    options['#EntityMenuOptions_Open'] = 'cwBelongingsOpen'
  elseif class == 'cw_shipment' then
    options['#EntityMenuOptions_Open'] = 'cwShipmentOpen'
  elseif class == 'cw_cash' then
    options['#EntityMenuOptions_Take'] = 'cwCashTake'
  end
end

--- Called when the GUI mouse has been released.
--
-- Unless `use_opens_entity_menus` is set, clicking an entity within 80 units while the cursor is
-- visible opens its entity menu at the cursor.
-- @param code [Number The mouse button (`MOUSE_*`)]
function GM:GUIMouseReleased(code)
  if !config.Get('use_opens_entity_menus'):Get()
  and vgui.CursorVisible() then
    local trace = cw.client:GetEyeTrace()

    if IsValid(trace.Entity) and trace.HitPos:Distance(cw.client:GetShootPos()) <= 80 then
      cw.EntityMenu = cw.core:HandleEntityMenu(trace.Entity)

      if IsValid(cw.EntityMenu) then
        cw.EntityMenu:SetPos(gui.MouseX() - (cw.EntityMenu:GetWide() / 2), gui.MouseY() - (cw.EntityMenu:GetTall() / 2))
      end
    end
  end
end

--- Called when a key has been released.
--
-- With `use_opens_entity_menus` set, releasing use on an entity within 80 units opens its entity
-- menu, unless the player is holding an object with the physics gun.
-- @param player [Player The player releasing the key]
-- @param key [Number The key released (`IN_*`)]
function GM:KeyRelease(player, key)
  if config.Get('use_opens_entity_menus'):Get() then
    if key == IN_USE then
      local activeWeapon = player:GetActiveWeapon()
      local trace = cw.client:GetEyeTraceNoCursor()

      if IsValid(activeWeapon) and activeWeapon:GetClass() == 'weapon_physgun' then
        if player:KeyDown(IN_ATTACK) then
          return
        end
      end

      if IsValid(trace.Entity) and trace.HitPos:Distance(cw.client:GetShootPos()) <= 80 then
        cw.EntityMenu = cw.core:HandleEntityMenu(trace.Entity)

        if IsValid(cw.EntityMenu) then
          cw.EntityMenu:SetPos(
            (ScrW() / 2) - (cw.EntityMenu:GetWide() / 2), (ScrH() / 2) - (cw.EntityMenu:GetTall() / 2)
          )
        end
      end
    end
  end
end

--- Called before halos are drawn; outlines the entity whose entity menu is open.
function GM:PreDrawHalos()
  if IsValid(cw.client.openedEnt) then
    if IsValid(cw.EntityMenu) then
      halo.Add({ cw.client.openedEnt }, Color(255, 255, 255), 2, 2, 1, true, false)
    else
      cw.client.openedEnt = nil
    end
  end
end

--- Called when the local player entity has been created.
--
-- Watches the `Clothes` network variable to keep `cw.ClothesData` and the inventory up to date,
-- and tells the server a second later with the `LocalPlayerCreated` message.
function GM:LocalPlayerCreated()
  cw.core:RegisterNetworkProxy(cw.client, 'Clothes', function(entity, name, oldValue, newValue)
    if oldValue != newValue then
      if newValue != '' then
        local clothesData = string.Explode(' ', newValue)
        cw.ClothesData.uniqueID = clothesData[1]
        cw.ClothesData.itemID = tonumber(clothesData[2])
      else
        cw.ClothesData.uniqueID = nil
        cw.ClothesData.itemID = nil
      end

      cw.inventory:Rebuild()
    end
  end)

  timer.Simple(1, function()
    netstream.Start('LocalPlayerCreated', true)
  end)
end

--- Called when the client initializes.
--
-- Creates the client ConVars (clock, headbob, HUD, ESP and theme options), creates the chatbox,
-- initializes items, runs `ClockworkInitialized`, then initializes the theme, settings and limb
-- textures.
function GM:Initialize()
  CW_CONVAR_TWELVEHOURCLOCK = cw.core:CreateClientConVar('cwTwelveHourClock', 0, true, true)
  CW_CONVAR_HEADBOBSCALE = cw.core:CreateClientConVar('cwHeadbobScale', 1, true, true)
  CW_CONVAR_SHOWAURA = cw.core:CreateClientConVar('cwShowCW', 1, true, true)
  CW_CONVAR_SHOWLOG = cw.core:CreateClientConVar('cwShowLog', 1, true, true)
  CW_CONVAR_SHOWHINTS = cw.core:CreateClientConVar('cwShowHints', 1, true, true)
  CW_CONVAR_VIGNETTE = cw.core:CreateClientConVar('cwShowVignette', 1, true, true)

  CW_CONVAR_ESPTIME = cw.core:CreateClientConVar('cwESPTime', 1, true, true)
  CW_CONVAR_ADMINESP = cw.core:CreateClientConVar('cwAdminESP', 0, true, true)
  CW_CONVAR_ESPBARS = cw.core:CreateClientConVar('cwESPBars', 1, true, true)
  CW_CONVAR_ITEMESP = cw.core:CreateClientConVar('cwItemESP', 0, false, true)
  CW_CONVAR_PROPESP = cw.core:CreateClientConVar('cwPropESP', 0, false, true)
  CW_CONVAR_SPAWNESP = cw.core:CreateClientConVar('cwSpawnESP', 0, false, true)
  CW_CONVAR_SALEESP = cw.core:CreateClientConVar('cwSaleESP', 0, false, true)
  CW_CONVAR_NPCESP = cw.core:CreateClientConVar('cwNPCESP', 0, false, true)

  CW_CONVAR_ACTIVETHEME = cw.core:CreateClientConVar('cwActiveTheme', '', true, true)

  if !chatbox.panel then
    chatbox.CreateDerma()
    chatbox.Hide()
  end

  item.Initialize()

  if !cw.option:GetKey('top_bars') then
    CW_CONVAR_TOPBARS = cw.core:CreateClientConVar('cwTopBars', 1, true, true)
  else
    cw.setting:RemoveByConVar('cwTopBars')
  end

  hook.Run('ClockworkInitialized')

  cw.theme:Initialize()
  cw.setting:AddSettings()
  cw.core:CacheLimbs()

  hook.Remove('PostDrawEffects', 'RenderWidgets')
end

--- Called when Catwork has initialized on the client.
--
-- Loads the shared materials and gradient textures, adds the settings and sets up the
-- directory's categories, icons and tips.
function GM:ClockworkInitialized()
  local logoFile = 'clockwork/logo/002.png'

  cw.SpawnIconMaterial = cw.core:GetMaterial('vgui/spawnmenu/hover')
  cw.DefaultGradient = surface.GetTextureID('gui/gradient_down')
  cw.GradientTexture = cw.core:GetMaterial(cw.option:GetKey('gradient')..'.png')
  cw.ClockworkSplash = cw.core:GetMaterial(logoFile)
  cw.FishEyeTexture = cw.core:GetMaterial('models/props_c17/fisheyelens')
  cw.GradientCenter = surface.GetTextureID('gui/center_gradient')
  cw.GradientRight = surface.GetTextureID('gui/gradient')
  cw.GradientUp = surface.GetTextureID('gui/gradient_up')
  cw.ScreenBlur = cw.core:GetMaterial('pp/blurscreen')
  cw.Gradients = {
    [GRADIENT_CENTER] = cw.GradientCenter,
    [GRADIENT_RIGHT] = cw.GradientRight,
    [GRADIENT_DOWN] = cw.DefaultGradient,
    [GRADIENT_UP] = cw.GradientUp
  }

  cw.setting:AddSettings()

  -- proofreader-disable Layout/LineLength -- embedded base64 icons
  cw.directory:AddCategoryMatch(cw.lang:TranslateText('#Directory_Commands'), '[icon]', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKVSURBVDjLfVNLSFRRGP7umTs+xubpTJQO4bRxoUGRZS1CCCa0oghatkpo4aZN0LJttIhx1UZs0aZ0UxaKgSFC0KZxhnxRaGqjiU7eUZur93n6z5lR0Kxz+e93H+f/vu//zzkK5xz/G+l0+rlt23csy1IJQSjDNE2BL5V/EWSz2SAl9IRCoduVlT4YlATXhZxNOeFwCMPDQ1APS85kMu0iORqN1tfU1OD7/BKEuutyuNwlIg6HyAzDgDo9PW04jlNBISft2hSoadpBy1hf14jIRfJKh/ymiuR4/AQKhQ2pzsXFhUsuQ7yQJiLhIN4OvEFT8xmpLv5JB4JVJD/sSdM0BYpC99JNooitzU08uXdOKo6nP0G4PX7tZsmBsCpUxcRwpBaMMSgUrBziWRBwx0WD8xGJBEPeaQQv94AJB9QTImDweDz7gpVRjsUBtLREcDLZhWOBLJzVdMmBVV4ehSnwqOqeukRRAuGFQAZR308EG5MoLgwhGCAHc68R2vZCFSyiIaIEoZg46pP1l4aC5Q0bTZFlBE9dh6NPoioax46TQ92lJiQ3xkoErFyniNmvf++LhmgAljZPAnlyVERFIA/s6Ciu7JQIvF4VjztPy+WxLBu6bpArF9VWDuGtQXirXbj2JJhbAJgf3DIx0zeHd7k4VOrk09HRD227G4Uw4vf7E7XWFHyY4HUdtxRuvofibGFiUIfXKMJDJaqtD7CyOIJ9Z6G7u/s+kdw433rxcrzQi/qWNpj5Z1DVICZGdAxOxqCxGO0DG9s2xH6Y2TsLqVQqRkuWam+/iiN+P5heAcWzBE9lDFPDv35/GV/tetQ79uJgf/YIyPo6xef+/ldnRSmNVWto/rGAoqabudm1zru93/oOO3h/ANOqi32og/qlAAAAAElFTkSuQmCC')
  cw.directory:AddCategoryMatch('Plugins', '[icon]', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAHhSURBVDjLpZI9SJVxFMZ/r2YFflw/kcQsiJt5b1ije0tDtbQ3GtFQYwVNFbQ1ujRFa1MUJKQ4VhYqd7K4gopK3UIly+57nnMaXjHjqotnOfDnnOd/nt85SURwkDi02+ODqbsldxUlD0mvHw09ubSXQF1t8512nGJ/Uz/5lnxi0tB+E9QI3D//+EfVqhtppGxUNzCzmf0Ekojg4fS9cBeSoyzHQNuZxNyYXp5ZM5Mk1ZkZT688b6thIBenG/N4OB5B4InciYBCVyGnEBHO+/LH3SFKQuF4OEs/51ndXMXC8Ajqknrcg1O5PGa2h4CJUqVES0OO7sYevv2qoFBmJ/4gF4boaOrg6rPLYWaYiVfDo0my8w5uj12PQleB0vcp5I6HsHAUoqUhR29zH+5B4IxNTvDmxljy3x2YCYUwZVlbzXJh9UKeQY6t2m0Lt94Oh5loPdqK3EkjzZi4MM/Y9Db3MTv/mYWVxaqkw9IOATNR7B5ABHPrZQrtg9sb8XDKa1+QOwsri4zeHD9SAzE1wxBTXz9xtvMc5ZU5lirLSKIz18nJnhOZjb22YKkhd4odg5icpcoyL669TAAujlyIvmPHSWXY1ti1AmZ8mJ3ElP1ips1/YM3H300g+W+51nc95YPEX8fEbdA2ReVYAAAAAElFTkSuQmCC')
  cw.directory:AddCategoryMatch('Flags', '[icon]', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAH0SURBVDjLlZPLbxJRGMX5X/xbjBpjjCtXLl2L0YWkaZrhNQwdIA4FZxygC22wltYYSltG1HGGl8nopCMPX9AUKQjacdW4GNPTOywak7ZAF/eRe/M73/nOzXUAcEwaqVTKmUgkGqIoWoIgWP/fTYSTyaSTgAfdbhemaSIej+NcAgRudDod9Pt95PN5RKPR8wnwPG/Z1XVdB8dxin0WDofBsiyCwaA1UYBY/tdqtVAqlRCJRN6FQiE1k8mg2WyCpunxArFY7DKxfFir1VCtVlEoFCBJEhRFQbFYhM/na5wKzq/+4ALprzqxbFUqFWiaBnstl8tQVRWyLMPr9R643W7nCZhZ3uUS+T74jR7Y5c8wDAO5XA4MwxzalklVy+PxNCiKcp4IkbbhzR4K+h9IH02wax3MiAYCgcBfv99/4TS3xxtfepcTCPyKgGl5gCevfyJb/Q3q6Q5uMcb7s3IaTZ6lHY5f70H6YGLp7QDx9T0kSRtr5V9wLbZxw1N/fqbAHIEXsj1saQR+M8BCdg8icbJaHOJBqo3r1KfMuJdyuBZb2NT2R5a5l108JuFl1CHuJ9q4NjceHgncefSN9LoPcYskT9pYIfA9Al+Z3X4xzUdz3H74RbODWlGGeCYPcVf4jksz08HHId6k63USFK7ObuOia3rYHkdyavlR+267GwAAAABJRU5ErkJggg==')
  cw.directory:AddCategoryMatch('Voice Commands', '[icon]', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKVSURBVDjLfVNLSFRRGP7umTs+xubpTJQO4bRxoUGRZS1CCCa0oghatkpo4aZN0LJttIhx1UZs0aZ0UxaKgSFC0KZxhnxRaGqjiU7eUZur93n6z5lR0Kxz+e93H+f/vu//zzkK5xz/G+l0+rlt23csy1IJQSjDNE2BL5V/EWSz2SAl9IRCoduVlT4YlATXhZxNOeFwCMPDQ1APS85kMu0iORqN1tfU1OD7/BKEuutyuNwlIg6HyAzDgDo9PW04jlNBISft2hSoadpBy1hf14jIRfJKh/ymiuR4/AQKhQ2pzsXFhUsuQ7yQJiLhIN4OvEFT8xmpLv5JB4JVJD/sSdM0BYpC99JNooitzU08uXdOKo6nP0G4PX7tZsmBsCpUxcRwpBaMMSgUrBziWRBwx0WD8xGJBEPeaQQv94AJB9QTImDweDz7gpVRjsUBtLREcDLZhWOBLJzVdMmBVV4ehSnwqOqeukRRAuGFQAZR308EG5MoLgwhGCAHc68R2vZCFSyiIaIEoZg46pP1l4aC5Q0bTZFlBE9dh6NPoioax46TQ92lJiQ3xkoErFyniNmvf++LhmgAljZPAnlyVERFIA/s6Ciu7JQIvF4VjztPy+WxLBu6bpArF9VWDuGtQXirXbj2JJhbAJgf3DIx0zeHd7k4VOrk09HRD227G4Uw4vf7E7XWFHyY4HUdtxRuvofibGFiUIfXKMJDJaqtD7CyOIJ9Z6G7u/s+kdw433rxcrzQi/qWNpj5Z1DVICZGdAxOxqCxGO0DG9s2xH6Y2TsLqVQqRkuWam+/iiN+P5heAcWzBE9lDFPDv35/GV/tetQ79uJgf/YIyPo6xef+/ldnRSmNVWto/rGAoqabudm1zru93/oOO3h/ANOqi32og/qlAAAAAElFTkSuQmCC')
  -- proofreader-enable Layout/LineLength

  cw.directory:SetCategoryTip('Clockwork', L('#Directory_ClockworkTip'))
  cw.directory:SetCategoryTip('Chat Commands', L('#Directory_CommandsTip'))

  cw.directory:AddCategory('Plugins', 'Clockwork')
  cw.directory:AddCategory('Flags', 'Clockwork')

  _G['ClockworkClientsideBooted'] = true
end

--- Called when the tool menu needs to be populated; registers Catwork tools with `gmod_tool` and the spawn menu.
function GM:PopulateToolMenu()
  local toolGun = weapons.GetStored('gmod_tool')

  for k, v in pairs(cw.tool:GetAll()) do
    toolGun.Tool[v.Mode] = v

    if v.AddToMenu != false then
      spawnmenu.AddToolMenuOption(v.Tab or 'Main',
        v.Category or 'New Category',
        k,
        v.Name or '#'..k,
        v.Command or 'gmod_tool '..k,
        v.ConfigName or k,
        v.BuildCPanel
      )
    end

    language.Add('tool.'..v.UniqueID..'.name', v.Name)
    language.Add('tool.'..v.UniqueID..'.desc', v.Desc)
    language.Add('tool.'..v.UniqueID..'.0', v.HelpText)
  end
end

--- Called to get the name a player is listed under in the door access menu; uses their name.
-- @param player [Player The player listed]
-- @param door [Entity The door]
-- @param owner [Player The door's owner]
-- @return [String The name shown]
function GM:GetPlayerDoorAccessName(player, door, owner)
  return player:Name()
end

--- Called to check whether a player appears in the door access menu; always shows them.
-- @param player [Player The player]
-- @param door [Entity The door]
-- @param owner [Player The door's owner]
-- @return [Boolean Whether the player is listed]
function GM:PlayerShouldShowOnDoorAccessList(player, door, owner)
  return true
end

--- Called to check whether a player appears on the scoreboard; always shows them.
-- @param player [Player The player]
-- @return [Boolean Whether the player is listed]
function GM:PlayerShouldShowOnScoreboard(player)
  return true
end

--- Called when the local player attempts to zoom with `+zoom`; always allows it.
-- @return [Boolean Whether the zoom bind runs]
function GM:PlayerCanZoom()
  return true
end

--- Called to check whether an item is listed in the business menu; always lists it.
-- @param itemTable [Item The item]
-- @return [Boolean Whether the item is listed]
function GM:PlayerCanSeeBusinessItem(itemTable) return true end

--- Called when the local player presses a bind.
--
-- Jumping while fallen over runs `/CharGetUp`. Blocks `toggle_zoom`, `+zoom` when
-- `PlayerCanZoom` refuses, jumping without stamina (unless noclipping or with the `B` flag),
-- attacking while storage is open, and inventory, cash and fall over binds when the matching
-- `block_*_binds` config is set. Then runs `TopLevelPlayerBindPress` and falls back to the base
-- gamemode.
-- @param player [Player The local player]
-- @param bind [String The bind]
-- @param bPress [Boolean Whether the bind is pressed rather than released]
-- @param break_cycle [Any `true` when called back from the base gamemode, to stop recursion; the
-- engine passes the button code here]
-- @return [Boolean `true` to block the bind]
function GM:PlayerBindPress(player, bind, bPress, break_cycle)
  -- The engine passes the button code as the fourth argument, only an explicit `true` breaks the cycle.
  if break_cycle == true then return end

  if player:GetRagdollState() == RAGDOLL_FALLENOVER and string.find(bind, '+jump') then
    cw.core:RunCommand('CharGetUp')
  elseif string.find(bind, 'toggle_zoom') then
    return true
  elseif string.find(bind, '+zoom') then
    if !hook.Run('PlayerCanZoom') then
      return true
    end
  end

  if !player:IsNoClipping() and !cw.player:HasFlags(player, 'B') and bind:find('+jump') then
    if player:GetNetVar('Stamina', 100) < 2 then
      return true
    end
  end

  if string.find(bind, '+attack') or string.find(bind, '+attack2') then
    if cw.storage:IsStorageOpen() then
      return true
    end
  end

  local bindText = string.lower(bind)

  if config.GetVal('block_inv_binds') then
    if bindText:find(config.Get('command_prefix'):Get()..'invaction') or bindText:find('cwcmd invaction') then
      return true
    end
  end

  if config.GetVal('block_cash_binds') then
    if bindText:find('cash') or bindText:find('cwcmd cash') or
    bindText:find('tokens') or bindText:find('droptokens') then
      return true
    end
  end

  if config.GetVal('block_fallover_binds') then
    if bindText:find('fallover') or bindText:find('cwcmd fallover') or bindText:find('charfallover') then
      return true
    end
  end

  local override = hook.Run('TopLevelPlayerBindPress', player, bind, bPress)

  if !override then
    -- Prevent weird stack overflow error.
    if self.BaseClass.PlayerBindPress != self.PlayerBindPress then
      return self.BaseClass.PlayerBindPress(self, player, bind, bPress, true)
    end
  end

  return override
end

--- Called to check whether the local player can see while unconscious; never by default, so the screen goes black.
-- @return [Boolean Whether the player can see]
function GM:PlayerCanSeeUnconscious()
  return false
end

--- Called when the local player's move data is created; turns mouse movement into ragdoll eye angles while ragdolled.
--
-- Sensitivity follows `AdjustMouseSensitivity`, and the look range is clamped to 48 degrees while
-- ragdolled and 90 otherwise.
-- @param userCmd [CUserCmd The user command]
function GM:CreateMove(userCmd)
  local ragdollEyeAngles = cw.core:GetRagdollEyeAngles()

  if ragdollEyeAngles and IsValid(cw.client) then
    local defaultSensitivity = 0.05
    local sensitivity =
      defaultSensitivity * (hook.Run('AdjustMouseSensitivity', defaultSensitivity) or defaultSensitivity)

    if sensitivity <= 0 then
      sensitivity = defaultSensitivity
    end

    if cw.client:IsRagdolled() then
      ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -48, 48)
      ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -48, 48)
    else
      ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -90, 90)
      ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -90, 90)
    end
  end
end

local LAST_RAISED_TARGET = 0

--- Called when the view should be calculated.
--
-- While ragdolled the view is from the ragdoll's eyes (or blacked out at full fade), dead players
-- see nothing, and with `enable_headbob` the view sways while walking, scaled by
-- `cwHeadbobScale` and adjustable through `PlayerAdjustHeadbobInfo`. The final view table is
-- passed to `CalcViewAdjustTable`.
-- @param player [Player The local player]
-- @param origin [Vector The view origin]
-- @param angles [Angle The view angles]
-- @param fov [Number The field of view]
-- @return [Map The view table]
function GM:CalcView(player, origin, angles, fov)
  local scale

  if CW_CONVAR_HEADBOBSCALE then
    scale = math.Clamp(CW_CONVAR_HEADBOBSCALE:GetFloat(), 0, 1) or 1
  else
    scale = 1
  end

  if cw.client:IsRagdolled() then
    local ragdollEntity = cw.client:GetRagdollEntity()
    local ragdollState = cw.client:GetRagdollState()

    if cw.BlackFadeIn == 255 then
      return { origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov }
    else
      local eyes = ragdollEntity:GetAttachment(ragdollEntity:LookupAttachment('eyes'))

      if eyes then
        local ragdollEyeAngles = eyes.Ang + cw.core:GetRagdollEyeAngles()
        local physicsObject = ragdollEntity:GetPhysicsObject()

        if IsValid(physicsObject) then
          local velocity = physicsObject:GetVelocity().z

          if velocity <= -1000 and cw.client:GetMoveType() == MOVETYPE_WALK then
            ragdollEyeAngles.p = ragdollEyeAngles.p + math.sin(UnPredictedCurTime()) * math.abs((velocity + 1000) - 16)
          end
        end

        return { origin = eyes.Pos, angles = ragdollEyeAngles, fov = fov }
      else
        return self.BaseClass:CalcView(player, origin, angles, fov)
      end
    end
  elseif !cw.client:Alive() then
    return { origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov }
  elseif config.Get('enable_headbob'):Get() and scale > 0 then
    if player:IsOnGround() then
      local frameTime = FrameTime()

      if !cw.player:IsNoClipping(player) then
        local approachTime = frameTime * 2
        local curTime = UnPredictedCurTime()
        local info = { speed = 1, yaw = 0.5, roll = 0.1 }

        if !cw.HeadbobAngle then
          cw.HeadbobAngle = 0
        end

        if !cw.HeadbobInfo then
          cw.HeadbobInfo = info
        end

        hook.Run('PlayerAdjustHeadbobInfo', info)

        cw.HeadbobInfo.yaw = math.Approach(cw.HeadbobInfo.yaw, info.yaw, approachTime)
        cw.HeadbobInfo.roll = math.Approach(cw.HeadbobInfo.roll, info.roll, approachTime)
        cw.HeadbobInfo.speed = math.Approach(cw.HeadbobInfo.speed, info.speed, approachTime)
        cw.HeadbobAngle = cw.HeadbobAngle + (cw.HeadbobInfo.speed * frameTime)

        local yawAngle = math.sin(cw.HeadbobAngle)
        local rollAngle = math.cos(cw.HeadbobAngle)

        angles.y = angles.y + (yawAngle * cw.HeadbobInfo.yaw)
        angles.r = angles.r + (rollAngle * cw.HeadbobInfo.roll)

        local velocity = player:GetVelocity()
        local eyeAngles = player:EyeAngles()

        if !cw.VelSmooth then cw.VelSmooth = 0 end
        if !cw.WalkTimer then cw.WalkTimer = 0 end
        if !cw.LastStrafeRoll then cw.LastStrafeRoll = 0 end

        cw.VelSmooth = math.Clamp(cw.VelSmooth * 0.9 + velocity:Length() * 0.1, 0, 700)
        cw.WalkTimer = cw.WalkTimer + cw.VelSmooth * FrameTime() * 0.05

        cw.LastStrafeRoll =
          (cw.LastStrafeRoll * 3) + (eyeAngles:Right():DotProduct(velocity) * 0.0001 * cw.VelSmooth * 0.3)
        cw.LastStrafeRoll = cw.LastStrafeRoll * 0.25
        angles.r = angles.r + cw.LastStrafeRoll

        if player:GetGroundEntity() != NULL then
          angles.p = angles.p + math.cos(cw.WalkTimer * 0.5) * cw.VelSmooth * 0.000002 * cw.VelSmooth
          angles.r = angles.r + math.sin(cw.WalkTimer) * cw.VelSmooth * 0.000002 * cw.VelSmooth
          angles.y = angles.y + math.cos(cw.WalkTimer) * cw.VelSmooth * 0.000002 * cw.VelSmooth
        end

        velocity = cw.client:GetVelocity().z

        if velocity <= -1000 and cw.client:GetMoveType() == MOVETYPE_WALK then
          angles.p = angles.p + math.sin(UnPredictedCurTime()) * math.abs((velocity + 1000) - 16)
        end
      end
    end
  end

  local view = self.BaseClass:CalcView(player, origin, angles, fov)

  hook.Run('CalcViewAdjustTable', view)

  return view
end

local WEAPON_LOWERED_ANGLES = Angle(30, -30, -25)
local WEAPON_LOWERED_ORIGIN = Vector(0, 0, 0)

--- Called to position the view model; tilts it into the lowered pose while the weapon is lowered.
--
-- The lowered offset comes from the item's `loweredAngles`/`loweredOrigin`, then the weapon's
-- `LoweredAngles`/`LoweredOrigin`, and can be changed through `GetWeaponLoweredViewInfo`.
-- @param weapon [Weapon The active weapon]
-- @param viewModel [Entity The view model]
-- @param oldEyePos [Vector The original eye position]
-- @param oldEyeAngles [Angle The original eye angles]
-- @param eyePos [Vector The eye position]
-- @param eyeAngles [Angle The eye angles]
-- @return [Vector The view model position, Angle The view model angles]
function GM:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
  if !IsValid(weapon) then return end

  local weaponRaised = cw.client:IsWeaponRaised()

  if !cw.client:HasInitialized() or !config.HasInitialized()
  or cw.client:GetMoveType() == MOVETYPE_OBSERVER then
    weaponRaised = nil
  end

  local targetValue = 100

  if weaponRaised then
    targetValue = 0
  end

  local fraction = (cw.client.cwRaisedFraction or 100) / 100
  local itemTable = item.GetByWeapon(weapon)
  local originMod = weapon.LoweredOrigin or WEAPON_LOWERED_ORIGIN
  local anglesMod = weapon.LoweredAngles or WEAPON_LOWERED_ANGLES

  if itemTable and itemTable.loweredAngles then
    anglesMod = itemTable.loweredAngles
  elseif weapon.LoweredAngles then
    anglesMod = weapon.LoweredAngles
  end

  if itemTable and itemTable.loweredOrigin then
    originMod = itemTable.loweredOrigin
  elseif weapon.LoweredOrigin then
    originMod = weapon.LoweredOrigin
  end

  local viewInfo = {
    origin = originMod,
    angles = anglesMod
  }

  hook.Run('GetWeaponLoweredViewInfo', itemTable, weapon, viewInfo)

  eyeAngles:RotateAroundAxis(eyeAngles:Up(), viewInfo.angles.p * fraction)
  eyeAngles:RotateAroundAxis(eyeAngles:Forward(), viewInfo.angles.y * fraction)
  eyeAngles:RotateAroundAxis(eyeAngles:Right(), viewInfo.angles.r * fraction)

  oldEyePos = oldEyePos + (
    (eyeAngles:Forward() * viewInfo.origin.y)
    + (eyeAngles:Right() * viewInfo.origin.x)
    + (eyeAngles:Up() * viewInfo.origin.z)
  ) * fraction

  cw.client.cwRaisedFraction = Lerp(FrameTime() * 2, cw.client.cwRaisedFraction or 100, targetValue)

  -- Return the edited angle and position.
  return oldEyePos, eyeAngles
end

--- Called when the local player's limb damage is received from the server; does nothing by default.
function GM:PlayerLimbDamageReceived() end

--- Called when the local player's limb damage is reset; does nothing by default.
function GM:PlayerLimbDamageReset() end

--- Called when the local player's limb damage is healed; does nothing by default.
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param amount [Number The amount healed]
function GM:PlayerLimbDamageHealed(hitGroup, amount) end

--- Called when the local player's limb takes damage; does nothing by default.
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param damage [Number The damage taken]
function GM:PlayerLimbTakeDamage(hitGroup, damage) end

--- Called to adjust a weapon's lowered view model pose; does nothing by default.
-- @param itemTable [Item The weapon's item, or `nil`]
-- @param weapon [Weapon The weapon]
-- @param viewInfo [Map `origin` (Vector) and `angles` (Angle) of the lowered pose, which can be changed]
function GM:GetWeaponLoweredViewInfo(itemTable, weapon, viewInfo) end

local blockedElements = {
  CHudSecondaryAmmo = true,
  CHudVoiceStatus = true,
  CHudSuitPower = true,
  CHudCrosshair = true,
  CHudBattery = true,
  CHudHealth = true,
  CHudAmmo = true,
  CHudChat = true
}

--- Called to check whether a HUD element should be drawn.
--
-- Only `CHudGMod` is drawn before a character is loaded or while choosing one, and the default
-- health, armor, ammo, crosshair, chat and voice elements are always hidden.
-- @param name [String The HUD element name]
-- @return [Boolean Whether the element is drawn]
function GM:HUDShouldDraw(name)
  if !IsValid(cw.client) or !cw.client:HasInitialized() or cw.core:IsChoosingCharacter() then
    if name != 'CHudGMod' then
      return false
    end
  elseif blockedElements[name] then
    return false
  end

  return self.BaseClass:HUDShouldDraw(name)
end

--- Called when the main menu is opened; runs `OnMenuOpened` on each menu panel that has it.
function GM:MenuOpened()
  for k, v in pairs(cw.menu:GetItems()) do
    if v.panel.OnMenuOpened then
      v.panel:OnMenuOpened()
    end
  end
end

--- Called when the main menu is closed; runs `OnMenuClosed` on each menu panel and closes tooltips and Derma menus.
function GM:MenuClosed()
  for k, v in pairs(cw.menu:GetItems()) do
    if v.panel.OnMenuClosed then
      v.panel:OnMenuClosed()
    end
  end

  cw.core:RemoveActiveToolTip()
  cw.core:CloseActiveDermaMenus()
end

--- Called to sort the characters within a faction on the character screen; sorts them by name.
-- @param faction [String The faction name]
-- @param a [Map The first character's screen info]
-- @param b [Map The second character's screen info]
-- @return [Boolean Whether `a` comes before `b`]
function GM:CharacterScreenSortFactionCharacters(faction, a, b)
  return a.name < b.name
end

--- Called to sort the players within a class on the scoreboard.
--
-- Players the local player recognises come first, and recognised players are sorted by team.
-- @param class [String The class name]
-- @param a [Player The first player]
-- @param b [Player The second player]
-- @return [Boolean Whether `a` comes before `b`]
function GM:ScoreboardSortClassPlayers(class, a, b)
  local recogniseA = cw.player:DoesRecognise(a)
  local recogniseB = cw.player:DoesRecognise(b)

  if recogniseA and recogniseB then
    return a:Team() < b:Team()
  elseif recogniseA then
    return true
  else
    return false
  end
end

--- Called to adjust a player's scoreboard entry; does nothing by default.
-- @param info [Map The entry, with `player`, `text` and the other fields the scoreboard shows]
function GM:ScoreboardAdjustPlayerInfo(info) end

--- Called when the main menu's items should be added.
--
-- Adds the settings, system, scoreboard, inventory, directory and attributes tabs, named by the
-- schema's `name_*` options.
-- @param menuItems [Map The `cw.menuitems` library; call its `Add(name, panel, tip, icon)`]
function GM:MenuItemsAdd(menuItems)
  local attributesName = cw.option:GetKey('name_attributes')
  local systemName = cw.option:GetKey('name_system')
  local scoreboardName = cw.option:GetKey('name_scoreboard')
  local directoryName = cw.option:GetKey('name_directory')
  local inventoryName = cw.option:GetKey('name_inventory')

  -- menuItems:Add("#Classes", "cwClasses", "#ClassesDesc", cw.option:GetKey("icon_data_classes"))
  menuItems:Add('#Settings', 'cwSettings', '#SettingsDesc', cw.option:GetKey('icon_data_settings'))
  menuItems:Add(systemName, 'cwSystem', '#SystemDesc', cw.option:GetKey('icon_data_system'))
  menuItems:Add(scoreboardName, 'cwScoreboard', '#ScoreboardDesc', cw.option:GetKey('icon_data_scoreboard'))
  menuItems:Add(inventoryName, 'cwInventory', '#InventoryDesc', cw.option:GetKey('icon_data_inventory'))
  menuItems:Add(directoryName, 'cwDirectory', '#DirectoryDesc', cw.option:GetKey('icon_data_directory'))
  menuItems:Add(attributesName, 'cwAttributes', '#AttributesDesc', cw.option:GetKey('icon_data_attributes'))

  if config.Get('show_business'):GetBoolean() == true then
    local businessName = cw.option:GetKey('name_business')
    -- menuItems:Add(businessName, "cwBusiness", cw.option:GetKey("description_business"),
    -- cw.option:GetKey("icon_data_business"))
  end
end

--- Called after the main menu's items are added, so they can be removed; does nothing by default.
-- @param menuItems [Map The `cw.menuitems` library]
function GM:MenuItemsDestroy(menuItems) end

--- Called every half second; every 3 seconds it fades timed attribute boosts and removes expired ones.
function GM:HalfSecond()
  local realCurTime = CurTime()
  local curTime = UnPredictedCurTime()

  if !cw.NextHandleAttributeBoosts or realCurTime >= cw.NextHandleAttributeBoosts then
    cw.NextHandleAttributeBoosts = realCurTime + 3

    for k, v in pairs(cw.attributes.boosts) do
      for k2, v2 in pairs(v) do
        if v2.duration and v2.endTime then
          if realCurTime > v2.endTime then
            cw.attributes.boosts[k][k2] = nil
          else
            local timeLeft = v2.endTime - realCurTime

            if timeLeft >= 0 then
              if v2.default < 0 then
                v2.amount = math.min((v2.default / v2.duration) * timeLeft, 0)
              else
                v2.amount = math.max((v2.default / v2.duration) * timeLeft, 0)
              end
            end
          end
        end
      end
    end
  end
end

--- Called each tick on the client.
--
-- Creates the character menu when polling and `ShouldCharacterMenuBeCreated` allows, rebuilds the
-- HUD bars and player info text through `GetBars`, `DestroyBars`, `GetPlayerInfoText` and
-- `DestroyPlayerInfoText`, fades dead NPCs, plays the low health heartbeat, closes the info menu
-- once F1 is released, plays or fades the menu music and runs network proxy callbacks.
function GM:Tick()
  local font = cw.option:GetFont('player_info_text')

  if cw.character:IsPanelPolling() then
    local panel = cw.character:GetPanel()

    if !panel and hook.Run('ShouldCharacterMenuBeCreated') then
      cw.character:SetPanelPolling(false)
      cw.character.isOpen = true
      cw.character.panel = vgui.Create('cw.characterMenu')
      cw.character.panel:MakePopup()
      cw.character.panel:ReturnToMainMenu()

      hook.Run('PlayerCharacterScreenCreated', cw.character.panel)
    end
  end

  if IsValid(cw.client) and !cw.core:IsChoosingCharacter() then
    cw.bars.stored = {}
    cw.PlayerInfoText.text = {}
    cw.PlayerInfoText.width = ScrW() * 0.15
    cw.PlayerInfoText.subText = {}

    cw.core:DrawHealthBar()
    cw.core:DrawArmorBar()

    hook.Run('GetBars', cw.bars)
    hook.Run('DestroyBars', cw.bars)
    hook.Run('GetPlayerInfoText', cw.PlayerInfoText)
    hook.Run('DestroyPlayerInfoText', cw.PlayerInfoText)

    table.sort(cw.bars.stored, function(a, b)
      if a.text == '' and b.text == '' then
        return a.priority > b.priority
      elseif a.text == '' then
        return true
      else
        return a.priority > b.priority
      end
    end)

    table.sort(cw.PlayerInfoText.subText, function(a, b)
      return a.priority > b.priority
    end)

    for k, v in pairs(cw.PlayerInfoText.text) do
      cw.PlayerInfoText.width = cw.core:AdjustMaximumWidth(font, v.text, cw.PlayerInfoText.width)
    end

    for k, v in pairs(cw.PlayerInfoText.subText) do
      cw.PlayerInfoText.width = cw.core:AdjustMaximumWidth(font, v.text, cw.PlayerInfoText.width)
    end

    cw.PlayerInfoText.width = cw.PlayerInfoText.width + 16

    if config.Get('fade_dead_npcs'):Get() then
      for k, v in pairs(ents.FindByClass('class C_ClientRagdoll')) do
        if !cw.entity:IsDecaying(v) then
          cw.entity:Decay(v, 300)
        end
      end
    end

    local playedHeartbeatSound = false

    if cw.client:Alive() and config.Get('enable_heartbeat'):Get() then
      local maxHealth = cw.client:GetMaxHealth()
      local health = cw.client:Health()

      if health < maxHealth then
        if !cw.HeartbeatSound then
          cw.HeartbeatSound = CreateSound(cw.client, 'player/heartbeat1.wav')
        end

        if !cw.NextHeartbeat or CurTime() >= cw.NextHeartbeat then
          cw.NextHeartbeat = CurTime() + (0.75 + ((1.25 / maxHealth) * health))
          cw.HeartbeatSound:PlayEx(0.75 - ((0.7 / maxHealth) * health), 100)
        end

        playedHeartbeatSound = true
      end
    end

    if !playedHeartbeatSound and cw.HeartbeatSound then
      cw.HeartbeatSound:Stop()
    end
  end

  if cw.core:IsInfoMenuOpen() and !input.IsKeyDown(KEY_F1) then
    cw.core:RemoveBackgroundBlur('InfoMenu')
    cw.core:CloseActiveDermaMenus()
    cw.InfoMenuOpen = false

    if IsValid(cw.InfoMenuPanel) then
      cw.InfoMenuPanel:SetVisible(false)
      cw.InfoMenuPanel:Remove()
    end

    timer.Simple(FrameTime() * 0.5, function()
      cw.core:RemoveActiveToolTip()
    end)
  end

  local menuMusic = cw.option:GetKey('menu_music')

  if menuMusic != '' then
    if IsValid(cw.client) and cw.character:IsPanelOpen() then
      if !cw.MusicSound then
        cw.MusicSound = CreateSound(cw.client, menuMusic)
        cw.MusicSound:PlayEx(0.3, 100)
        cw.MusicFading = false
      end
    elseif cw.MusicSound and !cw.MusicFading then
      cw.MusicSound:FadeOut(8)
      cw.MusicFading = true

      timer.Simple(8, function()
        cw.MusicSound = nil
      end)
    end
  end

  local worldEntity = game.GetWorld()

  for k, v in pairs(cw.NetworkProxies) do
    if IsValid(k) or k == worldEntity then
      for k2, v2 in pairs(v) do
        local value = nil

        if k == worldEntity then
          value = netvars.GetNetVar(k2)
        else
          value = k:GetNetVar(k2)
        end

        if value != v2.oldValue then
          v2.Callback(k, k2, v2.oldValue, value)
          v2.oldValue = value
        end
      end
    else
      cw.NetworkProxies[k] = nil
    end
  end
end

--- Called when the map entities are initialized on the client.
--
-- Sets `cw.client`, runs `LocalPlayerCreated`, runs `PlayerModelChanged` for every player and
-- then `ClockworkInitPostEntity`.
function GM:InitPostEntity()
  cw.client = LocalPlayer()

  if IsValid(cw.client) then
    hook.Run('LocalPlayerCreated')
  end

  for k, v in ipairs(_player.GetAll()) do
    hook.Run('PlayerModelChanged', v, v:GetModel())
  end

  hook.Run('ClockworkInitPostEntity')
end

--- Called each frame; calculates hints and shows or hides the character screen.
--
-- The character screen's visibility comes from `GetPlayerCharacterScreenVisible`.
function GM:Think()
  cw.core:CalculateHints()

  if cw.core:IsCharacterScreenOpen() then
    local panel = cw.character:GetPanel()

    if panel then
      panel:SetVisible(hook.Run('GetPlayerCharacterScreenVisible', panel))

      if panel:IsVisible() then
        cw.HasCharacterMenuBeenVisible = true
      end
    end
  end
end

local SCREEN_DAMAGE_OVERLAY = cw.core:GetMaterial('clockwork/screendamage.png')
local VIGNETTE_OVERLAY = cw.core:GetMaterial('clockwork/vignette.png')

--- Called when the local player's screen damage should be drawn; draws the damage overlay.
-- @param damageFraction [Number How damaged the player is, from 0 to 1]
function GM:DrawPlayerScreenDamage(damageFraction)
  surface.SetDrawColor(255, 255, 255, math.Clamp(255 * damageFraction, 0, 150))
  surface.SetMaterial(SCREEN_DAMAGE_OVERLAY)
  surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end

--- Called when entity outlines should be added; outlines the entity whose entity menu is open.
-- @param outlines [Map The `cw.outline` library; call `outlines:Add(entity, color)`]
function GM:AddEntityOutlines(outlines)
  if IsValid(cw.EntityMenu) and IsValid(cw.EntityMenu.entity) then
    --[[ Maybe this isn't needed. --]]
    cw.EntityMenu.entity:DrawModel()

    outlines:Add(
      cw.EntityMenu.entity, Color(255, 255, 255, 255)
    )
  end
end

--- Called when the local player's vignette should be drawn.
--
-- The vignette darkens when something is above the player, checked once a second.
function GM:DrawPlayerVignette()
  local curTime = CurTime()

  if !cw.cwVignetteAlpha then
    cw.cwVignetteAlpha = 100
    cw.cwVignetteDelta = cw.cwVignetteAlpha
    cw.cwVignetteRayTime = 0
  end

  if curTime >= cw.cwVignetteRayTime then
    local data = {}
      data.start = cw.client:GetShootPos()
      data.endpos = data.start + (cw.client:GetUp() * 512)
      data.filter = cw.client
    local trace = util.TraceLine(data)

    if !trace.HitWorld and !trace.HitNonWorld then
      cw.cwVignetteAlpha = 100
    else
      cw.cwVignetteAlpha = 255
    end

    cw.cwVignetteRayTime = curTime + 1
  end

  cw.cwVignetteDelta = math.Approach(
    cw.cwVignetteDelta, cw.cwVignetteAlpha, FrameTime() * 70
  )

  surface.SetDrawColor(0, 0, 0, cw.cwVignetteDelta)
  surface.SetMaterial(VIGNETTE_OVERLAY)
  surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end

--- Called when the foreground HUD should be painted.
--
-- Draws the hook error notice, the fallen over and underwater blur, the progress bar from
-- `GetProgressBarInfo` (or `GetPostProgressBarInfo`), the admin ESP when `PlayerCanSeeAdminESP`
-- allows, the `GetScreenTextInfo` text, the top bars and the death screen with the respawn
-- countdown, then runs `HUDPaintTopScreen`.
function GM:HUDPaintForeground()
  local backgroundColor = cw.option:GetColor('background')
  local colorWhite = cw.option:GetColor('white')
  local info = hook.Run('GetProgressBarInfo')
  local scrW, scrH = ScrW(), ScrH()
  local curTime = CurTime()

  if LocalPlayer().ErrorBoxTime and LocalPlayer().ErrorBoxTime > (curTime) then
    draw.RoundedBox(2, scrW - 300, 8, 292, 24, Color(math.Clamp(255 * (math.sin(curTime)), 150, 255), 90, 90))
    draw.SimpleText(
      L'#HookErrors',
      cw.fonts:GetSize(cw.option:GetFont('menu_text_small'), 18),
      scrW - 292,
      10,
      Color(255, 255, 255)
    )
  end

  if cw.client:GetRagdollState() == RAGDOLL_FALLENOVER then
    cdraw.DrawSimpleBlurBox(0, 0, scrW, scrH, Color(40, 40, 40, 45), 2)
  elseif cw.client:WaterLevel() >= 3 then
    cdraw.DrawSimpleBlurBox(0, 0, scrW, scrH, Color(40, 40, 40, 45), 4)
  end

  if info then
    local height = 32
    local width = (scrW * 0.5)
    local x = scrW * 0.25
    local y = scrH * 0.3

    cw.core:DrawBar(
      x, y, width, height, info.color or cw.option:GetColor('information'),
      info.text or L('#ProgressBarInfo_Default'), info.percentage or 100, 100, info.flash, { uniqueID = info.uniqueID }
    )
  else
    info = hook.Run('GetPostProgressBarInfo')

    if info then
      local height = 32
      local width = (scrW / 2) - 64
      local x = scrW * 0.25
      local y = scrH * 0.3

      cw.core:DrawBar(
        x, y, width, height, info.color or cw.option:GetColor('information'),
        info.text or L('#ProgressBarInfo_Default'), info.percentage or 100, 100, info.flash, {
          uniqueID = info.uniqueID
        }
      )
    end
  end

  if cw.player:IsAdmin(cw.client) then
    if hook.Run('PlayerCanSeeAdminESP') then
      cw.core:DrawAdminESP()
    end
  end

  local screenTextInfo = hook.Run('GetScreenTextInfo')

  if screenTextInfo then
    local alpha = screenTextInfo.alpha or 255
    local y = (scrH / 2) - 128
    local x = scrW / 2

    if screenTextInfo.title then
      cw.core:OverrideMainFont(cw.option:GetFont('menu_text_small'))
        y = cw.core:DrawInfo(screenTextInfo.title, x, y, colorWhite, alpha)
      cw.core:OverrideMainFont(false)
    end

    if screenTextInfo.text then
      cw.core:OverrideMainFont(cw.option:GetFont('menu_text_tiny'))
        y = cw.core:DrawInfo(screenTextInfo.text, x, y, colorWhite, alpha)
      cw.core:OverrideMainFont(false)
    end
  end

  local info = { width = scrW * cw.option:GetKey('top_bar_width_scale'), x = 8, y = 8 }
    cw.core:DrawBars(info, 'top')

  local action, percentage = cw.player:GetAction(cw.client, true)
  local color_white = Color(255, 255, 255)

  if !cw.client:Alive() and action == 'spawn' and !cw.client:GetNetVar('permaKilled') then
    local respawnRounded = math.ceil(percentage)
    local font = cw.option:GetFont('menu_text_big')

    if !cw.client.respawnAlpha then cw.client.respawnAlpha = 0 end

    cw.client.respawnAlpha = math.Clamp(cw.client.respawnAlpha + 1, 0, 200)

    draw.RoundedBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, cw.client.respawnAlpha))

    draw.SimpleText('#DeathScreen_YouDied', font, 16, 16, color_white)
    draw.SimpleText(
      '#DeathScreen_SpawnPercentage:'..respawnRounded..';%',
      font,
      16,
      16 + draw.GetFontHeight(font),
      color_white
    )

    draw.RoundedBox(0, 0, 0, scrW / 100 * percentage, 2, color_white)

    if percentage >= 92 then
      cw.client.whiteAlpha = math.Clamp((51 * (percentage - 95)), 0, 255)
    else
      cw.client.whiteAlpha = 0
    end
  else
    cw.client.respawnAlpha = 0

    if isnumber(cw.client.whiteAlpha) and cw.client.whiteAlpha > 0.5 then
      cw.client.whiteAlpha = Lerp(0.04, cw.client.whiteAlpha, 0)
    end
  end

  draw.RoundedBox(0, 0, 0, scrW, scrH, ColorAlpha(color_white, cw.client.whiteAlpha or 0))

  hook.Run('HUDPaintTopScreen', info)
end

--- Called when an item's network data has been updated; runs the item's `OnNetworkDataUpdated`.
-- @param itemTable [Item The item]
-- @param newData [Map The updated data fields]
function GM:ItemNetworkDataUpdated(itemTable, newData)
  if itemTable.OnNetworkDataUpdated then
    itemTable:OnNetworkDataUpdated(newData)
  end
end

--- Called to get the text shown in the middle of the screen; shows a notice while the character is banned.
-- @return [Map `title`, `text` and `alpha` of the text, or `nil` to show nothing]
function GM:GetScreenTextInfo()
  local blackFadeAlpha = cw.core:GetBlackFadeAlpha()

  if cw.client:GetNetVar('CharBanned') then
    return {
      alpha = blackFadeAlpha,
      title = '#ScreenTextInfo_CharBanned_title',
      text = '#ScreenTextInfo_CharBanned_text'
    }
  end
end

--- Called after the VGUI has been rendered; draws the current cinematic and the active markup tooltip.
function GM:PostRenderVGUI()
  local cinematic = cw.Cinematics[1]

  if cinematic then
    cw.core:DrawCinematic(cinematic, CurTime())
  end

  local activeMarkupToolTip = cw.core:GetActiveMarkupToolTip()

  if activeMarkupToolTip and IsValid(activeMarkupToolTip) and activeMarkupToolTip:IsVisible() then
    local markupToolTip = activeMarkupToolTip:GetMarkupToolTip()
    local alpha = activeMarkupToolTip:GetAlpha()
    local x, y = gui.MouseX(), gui.MouseY() + 24

    if markupToolTip then
      cw.core:DrawMarkupToolTip(markupToolTip.object, x, y, alpha)
    end
  end
end

--- Called to check whether an admin local player sees the admin ESP; follows the `cwAdminESP` ConVar.
-- @return [Boolean Whether the ESP is drawn]
function GM:PlayerCanSeeAdminESP()
  return (CW_CONVAR_ADMINESP:GetInt() == 1)
end

--- Called to check whether the local player can get up while fallen over, to show the get up hint; always allows it.
-- @return [Boolean Whether the hint is shown]
function GM:PlayerCanGetUp()
  return true
end

--- Called to check whether the local player sees a group of HUD bars.
--
-- `tab` bars show in the info menu (when `cwTopBars` is off), `top` bars show while alive (when
-- `cwTopBars` is on), and other groups always show.
-- @param class [String The bar group, such as `top` or `tab`]
-- @return [Boolean Whether the bars are drawn]
function GM:PlayerCanSeeBars(class)
  if class == 'tab' then
    if CW_CONVAR_TOPBARS then
      return (CW_CONVAR_TOPBARS:GetInt() == 0 and cw.core:IsInfoMenuOpen())
    else
      return cw.core:IsInfoMenuOpen()
    end
  elseif class == 'top' then
    if !cw.client:Alive() then return false end

    if CW_CONVAR_TOPBARS then
      return CW_CONVAR_TOPBARS:GetInt() == 1
    else
      return true
    end
  else
    return true
  end
end

--- Called to check whether the local player sees the top hints; always shows them.
-- @return [Boolean Whether the hints are drawn]
function GM:PlayerCanSeeHints()
  return true
end

--- Called to check whether the local player sees the center hints; always shows them.
-- @return [Boolean Whether the hints are drawn]
function GM:PlayerCanSeeCenterHints()
  return true
end

--- Called to check whether the local player sees their limb damage.
--
-- It is shown in the info menu when `limb_damage_system` is enabled.
-- @return [Boolean Whether the limb damage is drawn]
function GM:PlayerCanSeeLimbDamage()
  return (cw.core:IsInfoMenuOpen() and config.Get('limb_damage_system'):Get())
end

--- Called to check whether the local player sees the date and time; shown in the info menu.
-- @return [Boolean Whether the date and time are drawn]
function GM:PlayerCanSeeDateTime()
  return cw.core:IsInfoMenuOpen()
end

--- Called to check whether a class is listed in the classes menu; always lists it.
-- @param class [Class The class]
-- @return [Boolean Whether the class is listed]
function GM:PlayerCanSeeClass(class)
  return true
end

--- Called to check whether the local player sees their player info text; shown in the info menu.
-- @return [Boolean Whether the player info is drawn]
function GM:PlayerCanSeePlayerInfo()
  return cw.core:IsInfoMenuOpen()
end

--- Called when GMod shows a hint; shows it as a Catwork top hint once a character is loaded.
-- @param name [String The hint name, looked up as the `#Hint_<name>` phrase]
-- @param delay [Number How long the hint stays]
function GM:AddHint(name, delay)
  if IsValid(cw.client) and cw.client:HasInitialized() then
    cw.core:AddTopHint(
      cw.core:ParseData(cw.lang:TranslateText('#Hint_'..name)), delay
    )
  end
end

--- Called when GMod shows a notification; passes it to the base gamemode unless it is a `#Hint_` hint.
-- @param text [String The notification text]
-- @param class [Number The notification type (`NOTIFY_*`)]
-- @param length [Number How long it stays]
function GM:AddNotify(text, class, length)
  if class != NOTIFY_HINT or string.utf8sub(text, 1, 6) != '#Hint_' then
    if self.BaseClass.AddNotify then
      self.BaseClass:AddNotify(text, class, length)
    end
  end
end

--- Called when the target ID HUD should be drawn.
--
-- For a player within `GetTargetPlayerFadeDistance` (and allowed by `ShouldDrawPlayerTargetID`)
-- it draws their name from `GetTargetPlayerName` if recognised, or their unrecognised name and
-- `PlayerCanShowUnrecognised` otherwise, then `GetTargetPlayerText`, `DrawPlayerStatusExtra` and
-- `DrawTargetPlayerStatus`, and asks the server whether the target recognises the local player.
-- Dropped weapons get a pickup hint, entities with `HUDPaintTargetID` draw themselves and other
-- entities go through `HUDPaintEntityTargetID`. The text fades in after `target_id_delay`.
function GM:HUDDrawTargetID()
  local targetIDTextFont = cw.option:GetFont('target_id_text')
  local traceEntity = NULL
  local colorWhite = cw.option:GetColor('white')

  cw.core:OverrideMainFont(targetIDTextFont)

  if IsValid(cw.client) and cw.client:Alive() and !IsValid(cw.EntityMenu) then
    if !cw.client:IsRagdolled(RAGDOLL_FALLENOVER) then
      local fadeDistance = 196
      local curTime = UnPredictedCurTime()
      local trace = cw.player:GetRealTrace(cw.client)
      local ent = trace.Entity

      if IsValid(ent) and !ent:IsEffectActive(EF_NODRAW) then
        if !cw.TargetIDData or cw.TargetIDData.entity != ent then
          cw.TargetIDData = {
            showTime = curTime + config.Get('target_id_delay'):Get(),
            entity = ent
          }
        end

        if cw.TargetIDData then
          cw.TargetIDData.trace = trace
        end

        if !IsValid(traceEntity) then
          traceEntity = ent
        end

        if curTime >= cw.TargetIDData.showTime then
          if !cw.TargetIDData.fadeTime then
            cw.TargetIDData.fadeTime = curTime + 1
          end

          local class = ent:GetClass()
          local entity = cw.entity:GetPlayer(ent)

          if entity then
            fadeDistance = hook.Run('GetTargetPlayerFadeDistance', entity)
          end

          local alpha =
            math.Clamp(cw.core:CalculateAlphaFromDistance(fadeDistance, cw.client, trace.HitPos) * 1.5, 0, 255)

          if alpha > 0 then
            alpha = math.min(alpha, math.Clamp(1 - ((cw.TargetIDData.fadeTime - curTime) / 3), 0, 1) * 255)
          end

          cw.TargetIDData.fadeDistance = fadeDistance
          cw.TargetIDData.player = entity
          cw.TargetIDData.alpha = alpha
          cw.TargetIDData.class = class

          if entity and cw.client != entity then
            if hook.Run('ShouldDrawPlayerTargetID', entity) then
              if !cw.player:IsNoClipping(entity) then
                if cw.client:GetShootPos():Distance(trace.HitPos) <= fadeDistance then
                  local flashAlpha = nil
                  local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
                  local x, y = toScreen.x, toScreen.y

                  if !cw.player:DoesTargetRecognise() then
                    flashAlpha = math.Clamp(math.sin(curTime * 2) * alpha, 0, 255)
                  end

                  if cw.player:DoesRecognise(entity, RECOGNISE_PARTIAL) then
                    local text = string.Explode('\n', hook.Run('GetTargetPlayerName', entity))
                    local newY

                    for k, v in pairs(text) do
                      newY = cw.core:DrawInfo(v, x, y, _team.GetColor(entity:Team()), alpha)

                      if flashAlpha then
                        cw.core:DrawInfo(v, x, y, colorWhite, flashAlpha)
                      end

                      if newY then
                        y = newY
                      end
                    end
                  else
                    local unrecognisedName, usedPhysDesc = cw.player:GetUnrecognisedName(entity)
                    local wrappedTable = { unrecognisedName }
                    local teamColor = _team.GetColor(entity:Team())
                    local result =
                      hook.Run(
                        'PlayerCanShowUnrecognised',
                        entity,
                        x,
                        y,
                        unrecognisedName,
                        teamColor,
                        alpha,
                        flashAlpha
                      )
                    local newY

                    if isstring(result) then
                      wrappedTable = {}
                      cw.core:WrapText(result, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable)
                    elseif usedPhysDesc then
                      wrappedTable = {}
                      cw.core:WrapText(unrecognisedName, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable)
                    end

                    if result == true or isstring(result) then
                      for k, v in pairs(wrappedTable) do
                        newY = cw.core:DrawInfo(v, x, y, teamColor, alpha)

                        if flashAlpha then
                          cw.core:DrawInfo(v, x, y, colorWhite, flashAlpha)
                        end

                        if newY then
                          y = newY
                        end
                      end
                    elseif tonumber(result) then
                      y = result
                    end
                  end

                  cw.TargetPlayerText.stored = {}

                  hook.Run('GetTargetPlayerText', entity, cw.TargetPlayerText)
                  hook.Run('DestroyTargetPlayerText', entity, cw.TargetPlayerText)

                  y = hook.Run('DrawPlayerStatusExtra', entity, alpha, x, y) or y
                  y = hook.Run('DrawTargetPlayerStatus', entity, alpha, x, y) or y

                  for k, v in pairs(cw.TargetPlayerText.stored) do
                    if v.scale then
                      y = cw.core:DrawInfoScaled(v.scale, v.text, x, y, v.color or colorWhite, alpha)
                    else
                      y = cw.core:DrawInfo(v.text, x, y, v.color or colorWhite, alpha)
                    end
                  end

                  if !cw.nextCheckRecognises or curTime >= cw.nextCheckRecognises[1]
                  or cw.nextCheckRecognises[2] != entity then
                    netstream.Start('GetTargetRecognises', entity)

                    cw.nextCheckRecognises = { curTime + 2, entity }
                  end
                end
              end
            end
          elseif ent:IsWeapon() then
            if cw.client:GetShootPos():Distance(trace.HitPos) <= fadeDistance then
              local active = nil

              for k, v in ipairs(_player.GetAll()) do
                if v:GetActiveWeapon() == ent then
                  active = true
                end
              end

              if !active then
                local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
                local x, y = toScreen.x, toScreen.y

                y = cw.core:DrawInfo('#HUDTargetID_Weapon_DrawInfo1', x, y, Color(200, 100, 50, 255), alpha)
                y = cw.core:DrawInfo('#HUDTargetID_Weapon_DrawInfo2', x, y, colorWhite, alpha)
              end
            end
          elseif ent.HUDPaintTargetID then
            local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
            local x, y = toScreen.x, toScreen.y

            ent:HUDPaintTargetID(x, y, alpha)
          else
            local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
            local x, y = toScreen.x, toScreen.y

            hook.Run('HUDPaintEntityTargetID', ent, {
              alpha = alpha,
              x = x,
              y = y
            })
          end
        end
      end
    end
  end

  cw.core:OverrideMainFont(false)

  if !IsValid(traceEntity) then
    if cw.TargetIDData then
      cw.TargetIDData = nil
    end
  end
end

--- Called to draw a looked at player's status below their target ID; shows that they are deceased.
-- @param target [Player The player looked at]
-- @param alpha [Number The text alpha]
-- @param x [Number The text x position]
-- @param y [Number The text y position]
-- @return [Number The y position below what was drawn]
function GM:DrawTargetPlayerStatus(target, alpha, x, y)
  local informationColor = cw.option:GetColor('information')
  local gender = '#TargetPlayerStatus_Male'

  if target:GetGender() == GENDER_FEMALE then
    gender = '#TargetPlayerStatus_Female'
  end

  if !target:Alive() then
    return cw.core:DrawInfo('#TargetPlayerStatus_deceased:'..gender..';', x, y, informationColor, alpha)
  else
    return y
  end
end

--- Called to get the tooltip of a character in the character menu.
--
-- When there is more than one faction it shows how many players are in the character's faction
-- and the faction's limit.
-- @param panel [Panel The character panel]
-- @param character [Map The character's screen info]
-- @return [String The tooltip, or `nil` for none]
function GM:GetCharacterPanelToolTip(panel, character)
  if table.Count(faction.GetAll()) > 1 then
    local numPlayers = #faction.GetPlayers(character.faction)
    local numLimit = faction.GetLimit(character.faction)
    return '#CharacterPanelToolTip_PlayersWithThisFaction:'..numPlayers..','..numLimit..';'
  end
end

--- Called to get a player's status lines for the admin ESP.
--
-- Adds the player's current action (locking, unlocking, getting up, dead or another action) and
-- whether they have fallen over.
-- @param player [Player The player]
-- @param text [List<String> The status lines, added to in place]
function GM:GetStatusInfo(player, text)
  local action = cw.player:GetAction(player, true)

  if action then
    if !player:IsRagdolled() then
      if action == 'lock' then
        table.insert(text, '#StatusInfo_lock')
      elseif action == 'unlock' then
        table.insert(text, '#StatusInfo_unlock')
      end
    elseif action == 'unragdoll' then
      if player:GetRagdollState() == RAGDOLL_FALLENOVER then
        table.insert(text, '#StatusInfo_unragdoll_fallenover')
      else
        table.insert(text, '#StatusInfo_unragdoll')
      end
    elseif !player:Alive() then
      table.insert(text, '#StatusInfo_Dead')
    else
      table.insert(text, '#StatusInfo_Performing:'..action..';')
    end
  end

  if player:GetRagdollState() == RAGDOLL_FALLENOVER then
    local fallenOver = player:GetDTBool(BOOL_FALLENOVER)

    if fallenOver then
      table.insert(text, '#StatusInfo_fallenover')
    end
  end
end

--- Called to get the progress bar shown in the middle of the screen.
--
-- Shows locking and unlocking progress, getting up progress while ragdolled, and the get up
-- prompt while fallen over when `PlayerCanGetUp` allows. Nothing is shown while waiting to
-- respawn.
-- @return [Map `text`, `percentage`, `flash`, `isBlocky` and `blocksAmt` of the bar, or `nil` for no bar]
function GM:GetProgressBarInfo()
  local action, percentage = cw.player:GetAction(cw.client, true)

  if !cw.client:Alive() and action == 'spawn' then
    return
    -- return {text = cw.lang:TranslateText("#ProgressBarInfo_spawn"), percentage = percentage, flash = percentage < 10,
    -- isBlocky = true, blocksAmt = 32}
  end

  if !cw.client:IsRagdolled() then
    if action == 'lock' then
      return {
        text = cw.lang:TranslateText('#ProgressBarInfo_lock'),
        percentage = percentage,
        flash = percentage < 10,
        isBlocky = true,
        blocksAmt = 32
      }
    elseif action == 'unlock' then
      return {
        text = cw.lang:TranslateText('#ProgressBarInfo_unlock'),
        percentage = percentage,
        flash = percentage < 10,
        isBlocky = true,
        blocksAmt = 32
      }
    end
  elseif action == 'unragdoll' then
    if cw.client:GetRagdollState() == RAGDOLL_FALLENOVER then
      return {
        text = cw.lang:TranslateText('#ProgressBarInfo_unragdoll_fallenover'),
        percentage = percentage,
        flash = percentage < 10,
        isBlocky = true,
        blocksAmt = 32
      }
    else
      return {
        text = cw.lang:TranslateText('#ProgressBarInfo_unragdoll'),
        percentage = percentage,
        flash = percentage < 10,
        isBlocky = true,
        blocksAmt = 32
      }
    end
  elseif cw.client:GetRagdollState() == RAGDOLL_FALLENOVER then
    local fallenOver = cw.client:GetDTBool(BOOL_FALLENOVER)

    if fallenOver and hook.Run('PlayerCanGetUp') then
      return {
        text = cw.lang:TranslateText('#ProgressBarInfo_PlayerCanGetUp'),
        percentage = 100,
        isBlocky = true,
        blocksAmt = 32
      }
    end
  end
end

--- Called just before the local player's information box is drawn in the info menu; does nothing by default.
-- @param boxInfo [Map The box position and size]
-- @param information [Map The player info text lines]
-- @param subInformation [Map The player info sub text lines]
-- @return [Boolean `true` to skip drawing the box]
function GM:PreDrawPlayerInfo(boxInfo, information, subInformation) end

--- Called just after the local player's information box is drawn; does nothing by default.
-- @param boxInfo [Map The box position and size]
-- @param information [Map The player info text lines]
-- @param subInformation [Map The player info sub text lines]
function GM:PostDrawPlayerInfo(boxInfo, information, subInformation) end

--- Called just after the date and time box is drawn in the info menu; does nothing by default.
-- @param info [Map The box's `x`, `y` and `width`]
function GM:PostDrawDateTimeBox(info) end

--[[
  @codebase Client
  @details Called after the view model is drawn.
  @param Entity The viewmodel being drawn.
  @param Player The player drawing the viewmodel.
  @param Weapon The weapon table for the viewmodel.

function GM:PostDrawViewModel(viewModel, player, weapon)
     if ((weapon.UseHands or !weapon:IsScripted()) and !weapon.IsSXBASEWeapon) then
    local hands = cw.client:GetHands()

      if IsValid(hands) then
        hands:DrawModel()
      end
     end
end
--]]

--- Called when the local player's info text (shown in the F1 menu) is needed.
--
-- Adds cash and wages when cash is enabled, and the player's name and class as sub text.
-- @param playerInfoText [Map `cw.PlayerInfoText`; call its `Add(id, text)` and `AddSub(id, text, priority)`]
function GM:GetPlayerInfoText(playerInfoText)
  local cash = cw.player:GetCash() or 0
  local wages = cw.player:GetWages() or 0

  if config.Get('cash_enabled'):Get() then
    if cash > 0 then
      playerInfoText:Add(
        'CASH',
        cw.lang:TranslateText(cw.option:GetKey('name_cash')..': '..cw.core:FormatCash(cash, true))
      )
    end

    if wages > 0 then
      playerInfoText:Add('WAGES', cw.lang:TranslateText(cw.client:GetWagesName()..': '..cw.core:FormatCash(wages)))
    end
  end

  playerInfoText:AddSub('NAME', cw.client:Name(), 2)
  playerInfoText:AddSub('CLASS', _team.GetName(cw.client:Team()), 1)
end

--- Called to get how far away a player's target ID text stays visible; 4096 units by default.
-- @param player [Player The player looked at]
-- @return [Number The fade distance]
function GM:GetTargetPlayerFadeDistance(player)
  return 4096
end

--- Called after the player info text is collected, so lines can be removed; does nothing by default.
-- @param playerInfoText [Map `cw.PlayerInfoText`]
function GM:DestroyPlayerInfoText(playerInfoText) end

--- Called when the text below a looked at player's name is needed.
--
-- Adds the wrapped physical description of recognised players, or a prompt to look at them for
-- unrecognised living players.
-- @param player [Player The player looked at]
-- @param targetPlayerText [Map `cw.TargetPlayerText`; call its `Add(id, text)`]
function GM:GetTargetPlayerText(player, targetPlayerText)
  local targetIDTextFont = cw.option:GetFont('target_id_text')
  local physDescTable = {}
  local thirdPerson = '#Scoreboard_TargetPlayerText_him'

  if player:GetGender() == GENDER_FEMALE then
    thirdPerson = '#Scoreboard_TargetPlayerText_her'
  end

  if cw.player:DoesRecognise(player, RECOGNISE_PARTIAL) then
    cw.core:WrapText(cw.player:GetPhysDesc(player), targetIDTextFont, math.max(ScrW() / 9, 384), physDescTable)

    for k, v in pairs(physDescTable) do
      targetPlayerText:Add('PHYSDESC_'..k, v)
    end
  elseif player:Alive() then
    targetPlayerText:Add('PHYSDESC', '#Scoreboard_TargetPlayerText:'..cw.lang:TranslateText(thirdPerson)..';')
  end
end

--- Called after the target player text is collected, so lines can be removed; does nothing by default.
-- @param player [Player The player looked at]
-- @param targetPlayerText [Map `cw.TargetPlayerText`]
function GM:DestroyTargetPlayerText(player, targetPlayerText) end

--- Called to get the text under a player's name on the scoreboard.
--
-- Shows the physical description (cut to 64 characters) of recognised players and a generic line
-- for others.
-- @param player [Player The player]
-- @return [String The text]
function GM:GetPlayerScoreboardText(player)
  local thirdPerson = '#Scoreboard_ScoreboardText_him'

  if player:GetGender() == GENDER_FEMALE then
    thirdPerson = '#Scoreboard_ScoreboardText_her'
  end

  if cw.player:DoesRecognise(player, RECOGNISE_PARTIAL) then
    local physDesc = cw.player:GetPhysDesc(player)

    if string.utf8len(physDesc) > 64 then
      return string.utf8sub(physDesc, 1, 61)..'...'
    else
      return physDesc
    end
  else
    return '#Scoreboard_ScoreboardText:'..cw.lang:TranslateText(thirdPerson)..';'
  end
end

--- Called to get which faction group a character is shown under on the character screen; uses its faction.
-- @param character [Map The character's screen info]
-- @return [String The faction name]
function GM:GetPlayerCharacterScreenFaction(character)
  return character.faction
end

--- Called each frame to check whether the character screen is visible.
--
-- When the quiz is enabled, it stays hidden until the quiz is completed.
-- @param panel [Panel The character menu]
-- @return [Boolean Whether the character screen is visible]
function GM:GetPlayerCharacterScreenVisible(panel)
  if !cw.quiz:GetEnabled() or cw.quiz:GetCompleted() then
    return true
  else
    return false
  end
end

--- Called to check whether the character menu can be created yet; waits while the intro is fading out.
-- @return [Boolean Whether the character menu is created]
function GM:ShouldCharacterMenuBeCreated()
  if cw.ClockworkIntroFadeOut then
    return false
  end

  return true
end

--- Called when the local player's character screen is created; asks the server for the quiz status.
--
-- The status is only requested when the quiz is enabled.
-- @param panel [Panel The character menu]
function GM:PlayerCharacterScreenCreated(panel)
  if cw.quiz:GetEnabled() then
    netstream.Start('GetQuizStatus', true)
  end
end

--- Called to get the scoreboard group a player is listed under; uses their team name.
-- @param player [Player The player]
-- @return [String The group name]
function GM:GetPlayerScoreboardClass(player)
  return _team.GetName(player:Team())
end

--- Called when the admin options for a player on the scoreboard are needed.
--
-- Adds ban, kick, flag, name, item, user group, demote and whitelist options for the commands the
-- local player has access to. Each option runs the matching command, asking for text first where
-- the command needs it.
-- @param player [Player The player the options act on]
-- @param options [Map Option names mapped to callbacks, or to nested option maps for submenus]
-- @param menu [Panel Unused; the callers do not pass it]
function GM:GetPlayerScoreboardOptions(player, options, menu)
  local charTakeFlags = cw.command:FindByID('CharTakeFlags')
  local charGiveFlags = cw.command:FindByID('CharGiveFlags')
  local charGiveItem = cw.command:FindByID('CharGiveItem')
  local charSetName = cw.command:FindByID('CharSetName')
  local plySetGroup = cw.command:FindByID('PlySetGroup')
  local plyDemote = cw.command:FindByID('PlyDemote')
  local charBan = cw.command:FindByID('CharBan')
  local plyKick = cw.command:FindByID('PlyKick')
  local plyBan = cw.command:FindByID('PlyBan')

  if charBan and cw.player:HasFlags(cw.client, charBan.access) then
    options['#ScoreboardOptions_CharBan'] = function()
      RunConsoleCommand('cwCmd', 'CharBan', player:Name())
    end
  end

  if plyKick and cw.player:HasFlags(cw.client, plyKick.access) then
    options['#ScoreboardOptions_PlyKick'] = function()
      Derma_StringRequest(player:Name(), '#ScoreboardOptions_PlyKick_StringRequest', nil, function(text)
        cw.core:RunCommand('PlyKick', player:Name(), text)
      end)
    end
  end

  if plyBan and cw.player:HasFlags(cw.client, cw.command:FindByID('PlyBan').access) then
    options['#ScoreboardOptions_PlyBan'] = function()
      Derma_StringRequest(player:Name(), '#ScoreboardOptions_PlyBan_StringRequest_Minutes', nil, function(minutes)
        Derma_StringRequest(player:Name(), '#ScoreboardOptions_PlyBan_StringRequest_Reason', nil, function(reason)
          cw.core:RunCommand('PlyBan', player:Name(), minutes, reason)
        end)
      end)
    end
  end

  if charGiveFlags and cw.player:HasFlags(cw.client, charGiveFlags.access) then
    options['#ScoreboardOptions_CharGiveFlags'] = function()
      Derma_StringRequest(player:Name(), '#ScoreboardOptions_CharGiveFlags_StringRequest', nil, function(text)
        cw.core:RunCommand('CharGiveFlags', player:Name(), text)
      end)
    end
  end

  if charTakeFlags and cw.player:HasFlags(cw.client, charTakeFlags.access) then
    options['#ScoreboardOptions_CharTakeFlags'] = function()
      Derma_StringRequest(
        player:Name(),
        '#ScoreboardOptions_CharTakeFlags_StringRequest',
        player:GetDTString(STRING_FLAGS),
        function(text)
          cw.core:RunCommand('CharTakeFlags', player:Name(), text)
        end
      )
    end
  end

  if charSetName and cw.player:HasFlags(cw.client, charSetName.access) then
    options['#ScoreboardOptions_CharSetName'] = function()
      Derma_StringRequest(player:Name(), '#ScoreboardOptions_CharSetName_StringRequest', player:Name(), function(text)
        cw.core:RunCommand('CharSetName', player:Name(), text)
      end)
    end
  end

  if charGiveItem and cw.player:HasFlags(cw.client, charGiveItem.access) then
    options['#ScoreboardOptions_CharGiveItem'] = function()
      Derma_StringRequest(player:Name(), '#ScoreboardOptions_CharGiveItem_StringRequest', nil, function(text)
        cw.core:RunCommand('CharGiveItem', player:Name(), text)
      end)
    end
  end

  if plySetGroup and cw.player:HasFlags(cw.client, plySetGroup.access) then
    options['#ScoreboardOptions_PlySetGroup'] = {}
    options['#ScoreboardOptions_PlySetGroup']['#ScoreboardOptions_PlySetGroup_SuperAdmin'] = function()
      cw.core:RunCommand('PlySetGroup', player:Name(), 'superadmin')
    end

    options['#ScoreboardOptions_PlySetGroup']['#ScoreboardOptions_PlySetGroup_Admin'] = function()
      cw.core:RunCommand('PlySetGroup', player:Name(), 'admin')
    end

    options['#ScoreboardOptions_PlySetGroup']['#ScoreboardOptions_PlySetGroup_Operator'] = function()
      cw.core:RunCommand('PlySetGroup', player:Name(), 'operator')
    end
  end

  if plyDemote and cw.player:HasFlags(cw.client, plyDemote.access) then
    options['#ScoreboardOptions_PlyDemote'] = function()
      cw.core:RunCommand('PlyDemote', player:Name())
    end
  end

  local canUwhitelist = false
  local canWhitelist = false
  local unwhitelist = cw.command:FindByID('PlyUnwhitelist')
  local whitelist = cw.command:FindByID('PlyWhitelist')

  if whitelist and cw.player:HasFlags(cw.client, whitelist.access) then
    canWhitelist = true
  end

  if unwhitelist and cw.player:HasFlags(cw.client, unwhitelist.access) then
    canUwhitelist = true
  end

  if canWhitelist or canUwhitelist then
    local areWhitelistFactions = false

    for k, v in pairs(faction.GetAll()) do
      if v.whitelist then
        areWhitelistFactions = true
      end
    end

    if areWhitelistFactions then
      if canWhitelist then
        options['#ScoreboardOptions_PlyWhitelist'] = {}
      end

      if canUwhitelist then
        options['#ScoreboardOptions_PlyUnWhitelist'] = {}
      end

      for k, v in pairs(faction.GetAll()) do
        if v.whitelist then
          if options['#ScoreboardOptions_PlyWhitelist'] then
            options['#ScoreboardOptions_PlyWhitelist'][k] = function()
              cw.core:RunCommand('PlyWhitelist', player:Name(), k)
            end
          end

          if options['#ScoreboardOptions_PlyUnWhitelist'] then
            options['#ScoreboardOptions_PlyUnWhitelist'][k] = function()
              cw.core:RunCommand('PlyUnwhitelist', player:Name(), k)
            end
          end
        end
      end
    end
  end
end

--- Called when a piece of information about a door is needed for its 3D2D text.
--
-- For `DOOR_INFO_NAME` it returns the door's name or a default; for `DOOR_INFO_TEXT` its text,
-- or whether it is unownable, can be bought or owned, or has been bought or owned (depending on
-- `door_cost`). Hidden and false doors show nothing.
-- @param door [Entity The door]
-- @param information [Number What is needed, `DOOR_INFO_NAME` or `DOOR_INFO_TEXT`]
-- @return [String The text, or `false` to show nothing]
function GM:GetDoorInfo(door, information)
  local doorCost = config.Get('door_cost'):Get()
  local owner = cw.entity:GetOwner(door)
  local text = cw.entity:GetDoorText(door)
  local name = cw.entity:GetDoorName(door)

  if information == DOOR_INFO_NAME then
    if cw.entity:IsDoorHidden(door)
    or cw.entity:IsDoorFalse(door) then
      return false
    elseif name == '' then
      return '#Doors_Name'
    else
      return name
    end
  elseif information == DOOR_INFO_TEXT then
    if cw.entity:IsDoorUnownable(door) then
      if !cw.entity:IsDoorHidden(door)
      and !cw.entity:IsDoorFalse(door) then
        if text == '' then
          return '#Doors_Unownable'
        else
          return text
        end
      else
        return false
      end
    elseif text != '' then
      if !IsValid(owner) then
        if doorCost > 0 then
          return '#Doors_CanBePurchased'
        else
          return '#Doors_CanBeOwned'
        end
      else
        return text
      end
    elseif IsValid(owner) then
      if doorCost > 0 then
        return '#Doors_HasBeenPurchased'
      else
        return '#Doors_HasBeenOwned'
      end
    elseif doorCost > 0 then
      return '#Doors_CanBePurchased'
    else
      return '#Doors_CanBeOwned'
    end
  end
end

--- Called to check whether a sandbox post process is permitted; never.
-- @param class [String The post process name]
-- @return [Boolean Always `false`]
function GM:PostProcessPermitted(class)
  return false
end

--- Called after translucent renderables are drawn; draws the 3D2D text of doors within 256 units.
-- @param bDrawingDepth [Boolean Whether this is a depth pass, skipped]
-- @param bDrawingSkybox [Boolean Whether the skybox is being drawn]
-- @param bDrawing3DSkybox [Boolean Whether the 3D skybox is being drawn, skipped]
function GM:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox, bDrawing3DSkybox)
  -- bDrawingSkybox is also true for the main view on maps with a 2D skybox, so only skip the 3D skybox pass.
  if bDrawingDepth or bDrawing3DSkybox then return end

  if !cw.core:IsChoosingCharacter() then
    local eyePos = EyePos()
    local entities = ents.FindInSphere(eyePos, 256)

    if #entities > 0 then
      local colorWhite = cw.option:GetColor('white')
      local colorInfo = cw.option:GetColor('information')
      local doorFont = cw.option:GetFont('large_3d_2d')
      local eyeAngles = EyeAngles()

      for k, v in ipairs(entities) do
        if cw.entity:IsDoor(v) then
          cw.core:DrawDoorText(v, eyePos, eyeAngles, doorFont, colorInfo, colorWhite)
        end
      end
    end
  end
end

--- Called when screen space effects should be rendered.
--
-- Blurs the screen for head damage or low health, drains colour with lost health, draws the
-- underwater fish eye effect and applies colour modification: the `Color Modify` system's override
-- when enabled, otherwise `PlayerSetDefaultColorModify`. `PlayerAdjustColorModify` and
-- `PlayerAdjustMotionBlurs` can adjust the result.
function GM:RenderScreenspaceEffects()
  if IsValid(cw.client) then
    local frameTime = FrameTime()
    local motionBlurs = {
      enabled = true,
      blurTable = {}
    }
    local color = 1

    if !cw.core:IsChoosingCharacter() then
      if cw.limb:IsActive() and cw.event:CanRun('blur', 'limb_damage') then
        local headDamage = cw.limb:GetDamage(HITGROUP_HEAD)
        motionBlurs.blurTable['health'] = math.Clamp(1 - (headDamage * 0.01), 0, 1)
      elseif cw.client:Health() <= 75 then
        if cw.event:CanRun('blur', 'health') then
          motionBlurs.blurTable['health'] = math.Clamp(
            1 - ((cw.client:GetMaxHealth() - cw.client:Health()) * 0.01), 0, 1
          )
        end
      end

      if cw.client:Alive() then
        color = math.Clamp(color - ((cw.client:GetMaxHealth() - cw.client:Health()) * 0.01), 0, color)
      else
        color = 0
      end
    end

    if cw.FishEyeTexture and cw.client:WaterLevel() > 2 then
      render.UpdateScreenEffectTexture()
        cw.FishEyeTexture:SetFloat('$envmap', 0)
        cw.FishEyeTexture:SetFloat('$envmaptint', 0)
        cw.FishEyeTexture:SetFloat('$refractamount', 0.1)
        cw.FishEyeTexture:SetInt('$ignorez', 1)
      render.SetMaterial(cw.FishEyeTexture)
      render.DrawScreenQuad()
    end

    cw.ColorModify['$pp_colour_brightness'] = 0
    cw.ColorModify['$pp_colour_contrast'] = 1
    cw.ColorModify['$pp_colour_colour'] = color
    cw.ColorModify['$pp_colour_addr'] = 0
    cw.ColorModify['$pp_colour_addg'] = 0
    cw.ColorModify['$pp_colour_addb'] = 0
    cw.ColorModify['$pp_colour_mulr'] = 0
    cw.ColorModify['$pp_colour_mulg'] = 0
    cw.ColorModify['$pp_colour_mulb'] = 0

    local systemTable = cw.system:FindByID('Color Modify')
    local overrideColorMod

    if systemTable then
      overrideColorMod = systemTable:GetModifyTable()
    end

    if overrideColorMod and overrideColorMod.enabled then
      cw.ColorModify['$pp_colour_brightness'] = overrideColorMod.brightness
      cw.ColorModify['$pp_colour_contrast'] = overrideColorMod.contrast
      cw.ColorModify['$pp_colour_colour'] = overrideColorMod.color
      cw.ColorModify['$pp_colour_addr'] = overrideColorMod.addr * 0.025
      cw.ColorModify['$pp_colour_addg'] = overrideColorMod.addg * 0.025
      cw.ColorModify['$pp_colour_addb'] = overrideColorMod.addg * 0.025
      cw.ColorModify['$pp_colour_mulr'] = overrideColorMod.mulr * 0.1
      cw.ColorModify['$pp_colour_mulg'] = overrideColorMod.mulg * 0.1
      cw.ColorModify['$pp_colour_mulb'] = overrideColorMod.mulb * 0.1
    else
      hook.Run('PlayerSetDefaultColorModify', cw.ColorModify)
    end

    hook.Run('PlayerAdjustColorModify', cw.ColorModify)
    hook.Run('PlayerAdjustMotionBlurs', motionBlurs)

    if motionBlurs.enabled then
      local addAlpha = nil

      for k, v in pairs(motionBlurs.blurTable) do
        if !addAlpha or v < addAlpha then
          addAlpha = v
        end
      end

      if addAlpha then
        DrawMotionBlur(math.Clamp(addAlpha, 0.1, 1), 1, 0)
      end
    end

    --[[
      Hotfix for ColorModify issues on OS X.
    --]]

    if system.IsOSX() then
      cw.ColorModify['$pp_colour_brightness'] = 0
      cw.ColorModify['$pp_colour_contrast'] = 1
    end

    DrawColorModify(cw.ColorModify)
  end
end

--- Called when the chat box is opened; does nothing by default.
function GM:ChatBoxOpened() end

--- Called when the chat box is closed; does nothing by default.
-- @param textTyped [String The text left in the chat box]
function GM:ChatBoxClosed(textTyped) end

--- Called when chat box text has been sent; remembers the last 25 messages for the up and down keys.
-- @param text [String The text sent]
function GM:ChatBoxTextTyped(text)
  if cw.LastChatBoxText then
    if #cw.LastChatBoxText >= 25 then
      table.remove(cw.LastChatBoxText, 25)
    end
  else
    cw.LastChatBoxText = {}
  end

  cw.LastChatBoxCheck = 0

  if text != '' then
    table.insert(cw.LastChatBoxText, 1, text)
  end
end

--- Called to adjust the final view table from `GM:CalcView`; does nothing by default.
-- @param view [Map The view table, with `origin`, `angles` and `fov`, modified in place]
function GM:CalcViewAdjustTable(view) end

--- Called when chat box info should be adjusted; does nothing by default.
-- @param info [Map The message info]
function GM:ChatBoxAdjustInfo(info) end

--- Called when the chat box text has changed; does nothing by default.
-- @param previousText [String The previous text]
-- @param newText [String The new text]
function GM:ChatBoxTextChanged(previousText, newText) end

--- Called when a key is typed in the chat box; up and down cycle through the remembered messages.
-- @param code [Number The key code (`KEY_*`)]
-- @param text [String The current chat box text]
-- @return [String Text to replace the chat box contents with, or `nil`]
function GM:ChatBoxKeyCodeTyped(code, text)
  if !cw.LastChatBoxCheck then
    cw.LastChatBoxCheck = 1
  end

  if code == KEY_UP then
    if cw.LastChatBoxText then
      cw.LastChatBoxCheck = math.Clamp(cw.LastChatBoxCheck + 1, 0, 25)

      if cw.LastChatBoxCheck > #cw.LastChatBoxText then
        cw.LastChatBoxCheck = 0
      end

      return cw.LastChatBoxText[cw.LastChatBoxCheck]
    end
  elseif code == KEY_DOWN then
    if cw.LastChatBoxText then
      cw.LastChatBoxCheck = math.Clamp(cw.LastChatBoxCheck - 1, 0, 25)

      if cw.LastChatBoxCheck <= 0 then
        cw.LastChatBoxCheck = #cw.LastChatBoxText + 1
      end

      return cw.LastChatBoxText[cw.LastChatBoxCheck]
    end
  end
end

--- Called before a notification from the server is shown, to adjust it; shows every notification.
-- @param info [Map `text`, `class` and `sound` of the notification, which can be changed]
-- @return [Boolean Whether the notification is shown]
function GM:NotificationAdjustInfo(info)
  return true
end

--- Called to adjust an item shown in the business menu; does nothing by default.
-- @param itemTable [Item The item, which can be changed]
function GM:PlayerAdjustBusinessItemTable(itemTable) end

--- Called to adjust the model shown for a class in the classes menu; does nothing by default.
-- @param class [Number The class index]
-- @param info [Map `model` and `skin`, which can be changed]
function GM:PlayerAdjustClassModelInfo(class, info) end

--- Called to adjust the local player's headbob.
--
-- Speeds up and strengthens the bob while walking and running, scaled by `cwHeadbobScale`, and is
-- meant to exaggerate it while drunk.
-- @param info [Map `speed`, `yaw` and `roll` of the headbob, modified in place]
function GM:PlayerAdjustHeadbobInfo(info)
  local bisDrunk = cw.player:GetDrunk()
  local scale

  if CW_CONVAR_HEADBOBSCALE then
    scale = math.Clamp(CW_CONVAR_HEADBOBSCALE:GetFloat(), 0, 1) or 1
  else
    scale = 1
  end

  if cw.client:IsRunning() then
    info.speed = (info.speed * 4) * scale
    info.roll = (info.roll * 2) * scale
  elseif cw.client:GetVelocity():Length() > 0 then
    info.speed = (info.speed * 3) * scale
    info.roll = (info.roll * 1) * scale
  else
    info.roll = info.roll * scale
  end

  if isDrunk then
    info.speed = info.speed * math.min(isDrunk * 0.25, 4)
    info.yaw = info.yaw * math.min(isDrunk, 4)
  end
end

--- Called to adjust the local player's motion blur; does nothing by default.
-- @param motionBlurs [Map `enabled` and `blurTable` (blur amounts by name, the lowest is used), modified in place]
function GM:PlayerAdjustMotionBlurs(motionBlurs) end

--- Called when the local player's item menu should be adjusted; does nothing by default.
-- @param itemTable [Item The item]
-- @param menuPanel [Panel The menu]
-- @param itemFunctions [List The item's functions]
function GM:PlayerAdjustMenuFunctions(itemTable, menuPanel, itemFunctions) end

--- Called to adjust the functions offered for an item in the inventory; does nothing by default.
-- @param itemTable [Item The item]
-- @param itemFunctions [List<Map> The functions, as `{ title = ..., name = ... }` entries, modified in place]
function GM:PlayerAdjustItemFunctions(itemTable, itemFunctions) end

--- Called to set the local player's default colour modification when no override is active; does nothing by default.
-- @param colorModify [Map The `$pp_colour_*` values, modified in place]
function GM:PlayerSetDefaultColorModify(colorModify) end

--- Called to adjust the local player's colour modification; does nothing by default.
-- @param colorModify [Map The `$pp_colour_*` values, modified in place]
function GM:PlayerAdjustColorModify(colorModify) end

--- Called to check whether a looked at player's target ID is drawn; always draws it.
-- @param player [Player The player looked at]
-- @return [Boolean Whether the target ID is drawn]
function GM:ShouldDrawPlayerTargetID(player)
  return true
end

--- Called to check whether the local player's screen fades to black.
--
-- Fades while dead or fallen over, unless `PlayerCanSeeUnconscious` allows seeing.
-- @return [Boolean Whether the screen fades to black]
function GM:ShouldPlayerScreenFadeBlack()
  if !cw.client:Alive() or cw.client:IsRagdolled(RAGDOLL_FALLENOVER) then
    if !hook.Run('PlayerCanSeeUnconscious') then
      return true
    end
  end

  return false
end

--- Called to check whether the menu background blur is drawn; always draws it.
-- @return [Boolean Whether the blur is drawn]
function GM:ShouldDrawMenuBackgroundBlur()
  return true
end

--- Called to check whether the character menu background blur is drawn; always draws it.
-- @return [Boolean Whether the blur is drawn]
function GM:ShouldDrawCharacterBackgroundBlur()
  return true
end

--- Called to check whether the black character menu background is drawn; always draws it.
-- @return [Boolean Whether the background is drawn]
function GM:ShouldDrawCharacterBackground()
  return true
end

--- Called to check whether a character creation fault is drawn; always draws it.
-- @param fault [String The fault]
-- @return [Boolean Whether the fault is drawn]
function GM:ShouldDrawCharacterFault(fault)
  return true
end

--- Called every frame to draw the full screen layers above the HUD.
--
-- Draws the character selection background and `HUDPaintCharacterSelection`, then for a loaded
-- character runs `HUDPaintForeground` and `HUDPaintImportant`, the cinematic intro, background
-- blurs (when `ShouldDrawBackgroundBlurs` allows), the Catwork intro splash, the loading and
-- no-database screens and `HUDPaintCharacterLoading`, then `PostDrawBackgroundBlurs`.
function GM:HUDDrawScoreBoard()
  self.BaseClass:HUDDrawScoreBoard(player)

  local drawPendingScreenBlack = nil
  local drawCharacterLoading = nil
  local hasClientInitialized = cw.client:HasInitialized()
  local introTextSmallFont = cw.option:GetFont('intro_text_small')
  local colorWhite = cw.option:GetColor('white')
  local curTime = UnPredictedCurTime()
  local scrH = ScrH()
  local scrW = ScrW()

  if cw.core:IsChoosingCharacter() then
    if hook.Run('ShouldDrawCharacterBackground') then
      cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255))
    end

    hook.Run('HUDPaintCharacterSelection')
  elseif !hasClientInitialized then
    if !cw.HasCharacterMenuBeenVisible
    and hook.Run('ShouldDrawCharacterBackground') then
      drawPendingScreenBlack = true
    end
  end

  if hasClientInitialized then
    if !cw.LastChatBoxCheck then
      local loadingTime = hook.Run('GetCharacterLoadingTime')
      cw.CharacterLoadingDelay = loadingTime
      cw.LastChatBoxCheck = curTime + loadingTime
    end

    if !cw.core:IsChoosingCharacter() then
      cw.core:CalculateScreenFading()

      if !cw.core:IsUsingCamera() then
        hook.Run('HUDPaintForeground')
      end

      hook.Run('HUDPaintImportant')
    end

    if cw.LastChatBoxCheck > curTime then
      drawCharacterLoading = true
    elseif !cw.CinematicScreenDone then
      cw.core:DrawCinematicIntro(curTime)
      cw.core:DrawCinematicIntroBars()
    end
  end

  if hook.Run('ShouldDrawBackgroundBlurs') then
    cw.core:DrawBackgroundBlurs()
  end

  if !cw.player:HasDataStreamed() then
    if !cw.DataStreamedAlpha then
      cw.DataStreamedAlpha = 255
    end
  elseif cw.DataStreamedAlpha then
    cw.DataStreamedAlpha = math.Approach(cw.DataStreamedAlpha, 0, FrameTime() * 100)

    if cw.DataStreamedAlpha <= 0 then
      cw.DataStreamedAlpha = nil
    end
  end

  if cw.ClockworkIntroFadeOut then
    local duration = 8
    local introImage = cw.option:GetKey('intro_image')

    if introImage != '' then
      duration = 16
    end

    local timeLeft = math.Clamp(cw.ClockworkIntroFadeOut - curTime, 0, duration)
    local material = cw.ClockworkIntroOverrideImage or cw.ClockworkSplash
    local sineWave = math.sin(curTime)
    local height = 256
    local width = 512 -- Patched
    local alpha = 384

    if !cw.ClockworkIntroOverrideImage then
      if introImage != '' and timeLeft <= 8 then
        cw.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8)
        cw.ClockworkIntroOverrideImage = cw.core:GetMaterial(introImage..'.png')
        surface.PlaySound('buttons/combine_button5.wav')
      end
    end

    if timeLeft <= 3 then
      alpha = (255 / 3) * timeLeft
    end

    if timeLeft == 0 then
      cw.ClockworkIntroFadeOut = nil
      cw.ClockworkIntroOverrideImage = nil
    end

    if sineWave > 0 then
      width = width - (sineWave * 16)
      height = height - (sineWave * 4)
    end

    if curTime <= cw.ClockworkIntroWhiteScreen then
      cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(255, 255, 255, alpha))
    else
      local x, y = (scrW / 2) - (width / 2), (scrH * 0.3) - (height / 2)

      cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha))
      cw.core:DrawGradient(
        GRADIENT_CENTER, 0, y - 8, scrW, height + 16, Color(100, 100, 100, math.min(alpha, 150))
      )

      material:SetFloat('$alpha', alpha / 255)

      surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(material)
      surface.DrawTexturedRect(x, y, width, height)
    end

    drawPendingScreenBlack = nil
  end

  if netvars.GetNetVar('NoMySQL') and netvars.GetNetVar('NoMySQL') != '' then
    cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255))
    draw.SimpleText(netvars.GetNetVar('NoMySQL'), introTextSmallFont, scrW / 2, scrH / 2, Color(179, 46, 49, 255), 1, 1)
  elseif cw.DataStreamedAlpha and cw.DataStreamedAlpha > 0 then
    local textString = '#MainMenu_Loading'

    if _file.Exists('materials/clockwork/logo/002.png', 'GAME') then
      surface.SetDrawColor(255, 255, 255, cw.DataStreamedAlpha)
      surface.SetMaterial(cw.core:GetMaterial('materials/clockwork/logo/002.png'))
      surface.DrawTexturedRect(scrW / 2 - 32, scrH / 2 - 16, 64, 32)
    end

    cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, cw.DataStreamedAlpha))
    draw.SimpleText(
      textString,
      introTextSmallFont,
      scrW / 2,
      scrH * 0.75,
      Color(colorWhite.r, colorWhite.g, colorWhite.b, cw.DataStreamedAlpha),
      1,
      1
    )

    drawPendingScreenBlack = nil
  end

  if drawCharacterLoading then
    hook.Run(
      'HUDPaintCharacterLoading',
      math.Clamp((255 / cw.CharacterLoadingDelay) * (cw.LastChatBoxCheck - curTime), 0, 255)
    )
  elseif drawPendingScreenBlack then
    cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255))
  end

  if cw.LastChatBoxCheck then
    if !cw.CinematicInfoDrawn then
      cw.core:DrawCinematicInfo()
    end

    if !cw.CinematicBarsDrawn then
      cw.core:DrawCinematicIntroBars()
    end
  end

  hook.Run('PostDrawBackgroundBlurs')
end

--- Called to check whether the background blurs are drawn; always draws them.
-- @return [Boolean Whether the blurs are drawn]
function GM:ShouldDrawBackgroundBlurs()
  return true
end

--- Called just after the background blurs have been drawn.
--
-- Draws the selected faction's image on the character screen, the title box of a titled menu and
-- the date and time.
function GM:PostDrawBackgroundBlurs()
  local introTextSmallFont = cw.option:GetFont('intro_text_small')
  local backgroundColor = cw.option:GetColor('background')
  local colorWhite = cw.option:GetColor('white')
  local panelInfo = cw.CurrentFactionSelected
  local menuPanel = cw.core:GetRecogniseMenu()

  if panelInfo and IsValid(panelInfo[1]) and panelInfo[1]:IsVisible() then
    local factionTable = faction.FindByID(panelInfo[2])

    if factionTable and factionTable.material then
      if _file.Exists('materials/'..factionTable.material..'.png', 'GAME') then
        if !panelInfo[3] then
          panelInfo[3] = cw.core:GetMaterial(factionTable.material..'.png')
        end

        if cw.core:IsCharacterScreenOpen(true) then
          surface.SetDrawColor(255, 255, 255, panelInfo[1]:GetAlpha())
          surface.SetMaterial(panelInfo[3])
          surface.DrawTexturedRect(panelInfo[1].x, panelInfo[1].y + panelInfo[1]:GetTall() + 16, 512, 256)
        end
      end
    end
  end

  if cw.TitledMenu and IsValid(cw.TitledMenu.menuPanel) then
    local menuTextTiny = cw.option:GetFont('menu_text_tiny')
    local menuPanel = cw.TitledMenu.menuPanel
    local menuTitle = cw.TitledMenu.title or ''

    cw.core:DrawSimpleGradientBox(
      2,
      menuPanel.x - 4,
      menuPanel.y - 4,
      menuPanel:GetWide() + 8,
      menuPanel:GetTall() + 8,
      backgroundColor
    )
    cw.core:OverrideMainFont(menuTextTiny)
      cw.core:DrawInfo(menuTitle, menuPanel.x, menuPanel.y, colorWhite, 255, true, function(x, y, width, height)
        return x, y - height - 4
      end)

    cw.core:OverrideMainFont(false)
  end

  cw.core:DrawDateTime()
end

--- Called just before a HUD bar is drawn; does nothing by default.
-- @param barInfo [Map The bar's position, size, colour, text and progress]
-- @return [Boolean `true` to skip drawing the bar's background and fill]
function GM:PreDrawBar(barInfo) end

--- Called just after a HUD bar is drawn; does nothing by default.
-- @param barInfo [Map The bar's position, size, colour, text and progress]
-- @return [Boolean `true` to skip drawing the bar's text]
function GM:PostDrawBar(barInfo) end

--- Called each tick when the HUD bars are collected; does nothing by default.
-- @param bars [Map The `cw.bars` library; add bars with its functions]
function GM:GetBars(bars) end

--- Called after the HUD bars are collected, so bars can be removed; does nothing by default.
-- @param bars [Map The `cw.bars` library]
function GM:DestroyBars(bars) end

--- Called when the cinematic intro info is needed; uses the schema's author, name and description.
-- @return [Map `credits`, `title` and `text` of the intro]
function GM:GetCinematicIntroInfo()
  return {
    credits = '#Schema_Credits:'..Schema:GetAuthor()..';',
    title = Schema:GetName(),
    text = Schema:GetDescription()
  }
end

--- Called to get how long the character loading screen lasts; 8 seconds.
-- @return [Number The loading time in seconds]
function GM:GetCharacterLoadingTime() return 8 end

--- Called when a player's HUD should be painted; does nothing by default.
-- @param player [Player The player]
function GM:HUDPaintPlayer(player) end

--- Called when the HUD should be painted.
--
-- Outside character selection and cameras it draws the vignette (when enabled by the event,
-- `enable_vignette` and `cwShowVignette`), the base HUD and the hints, and a crosshair when
-- `CanDrawCrosshair` allows, positioned by `GetPlayerCrosshairInfo` and drawn by
-- `DrawPlayerCrosshair`.
function GM:HUDPaint()
  if !cw.core:IsChoosingCharacter() and !cw.core:IsUsingCamera() then
    if cw.event:CanRun('view', 'damage') and cw.client:Alive() then
      local maxHealth = cw.client:GetMaxHealth()
      local health = cw.client:Health()

      if health < maxHealth * 0.5 then
        -- hook.Run("DrawPlayerScreenDamage", 1 - ((1 / maxHealth) * health))
      end
    end

    if cw.event:CanRun('view', 'vignette') and config.GetVal('enable_vignette')
    and CW_CONVAR_VIGNETTE:GetInt() == 1 then
      hook.Run('DrawPlayerVignette')
    end

    self.BaseClass:HUDPaint()

    if !cw.core:IsUsingTool() then
      cw.core:DrawHints()
    end

    local weapon = cw.client:GetActiveWeapon()

    if hook.Run('CanDrawCrosshair', weapon) then
      local info = {
        color = Color(255, 255, 255, 255),
        x = ScrW() / 2,
        y = ScrH() / 2
      }

      hook.Run('GetPlayerCrosshairInfo', info)

      cw.CustomCrosshair = hook.Run('DrawPlayerCrosshair', info.x, info.y, info.color)
    else
      cw.CustomCrosshair = false
    end
  end
end

--- Called to check whether the Catwork crosshair is drawn; never by default.
-- @param weapon [Weapon The local player's active weapon]
-- @return [Boolean Whether the crosshair is drawn]
function GM:CanDrawCrosshair(weapon)
  return false
end

--- Called to position the local player's crosshair; with `use_free_aiming` it follows where the weapon actually aims.
-- @param info [Map `color`, `x` and `y` of the crosshair, modified in place]
function GM:GetPlayerCrosshairInfo(info)
  if config.GetVal('use_free_aiming') then
    -- Thanks to BlackOps7799 for this open source example.

    local traceLine = util.TraceLine({
      start = cw.client:EyePos(),
      endpos = cw.client:EyePos() + (cw.client:GetAimVector() * 1024 * 1024),
      filter = cw.client
    })

    local screenPos = traceLine.HitPos:ToScreen()

    info.x = screenPos.x
    info.y = screenPos.y
  end
end

--- Called when the local player's crosshair should be drawn; draws five small dots.
-- @param x [Number The crosshair x position]
-- @param y [Number The crosshair y position]
-- @param color [Color The crosshair colour]
-- @return [Boolean Stored in `cw.CustomCrosshair`; `true` when a custom crosshair was drawn]
function GM:DrawPlayerCrosshair(x, y, color)
  surface.SetDrawColor(color.r, color.g, color.b, color.a)
  surface.DrawRect(x, y, 2, 2)
  surface.DrawRect(x, y + 9, 2, 2)
  surface.DrawRect(x, y - 9, 2, 2)
  surface.DrawRect(x + 9, y, 2, 2)
  surface.DrawRect(x - 9, y, 2, 2)

  return true
end

--- Called when a player starts using voice.
--
-- With `local_voice`, no voice indicator is shown for players who have fallen over, are dead or
-- lack the `x` flag.
-- @param player [Player The talking player]
function GM:PlayerStartVoice(player)
  if config.Get('local_voice'):Get() then
    if player:IsRagdolled(RAGDOLL_FALLENOVER) or !player:Alive() or !cw.player:HasFlags(player, 'x') then
      return
    end
  end

  if self.BaseClass and self.BaseClass.PlayerStartVoice then
    self.BaseClass:PlayerStartVoice(player)
  end
end

--- Called to check whether a player has a flag they do not hold themselves; grants the `default_flags` config flags.
-- @param player [Player The player]
-- @param flag [String A single flag]
-- @return [Boolean `true` to grant the flag, `false` to deny it, `nil` to fall through]
function GM:PlayerDoesHaveFlag(player, flag)
  if string.find(config.GetVal('default_flags'), flag) then
    return true
  end
end

--- Called after recognition is worked out, to override whether the local player recognises another.
--
-- Catwork returns the computed value unchanged.
-- @param player [Player The player who may be recognised]
-- @param status [Number The recognition level asked about (`RECOGNISE_*`)]
-- @param isAccurate [Boolean Whether the level must match exactly]
-- @param realValue [Boolean Whether the local player recognises the player according to their recognised names]
-- @return [Boolean Whether the local player recognises the player]
function GM:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
  return realValue
end

--- Called when the target ID of an unrecognised player is drawn; draws the unrecognised name.
--
-- `GM:HUDDrawTargetID` passes the arguments as `(player, x, y, unrecognisedName, teamColor,
-- alpha, flashAlpha)`, so from `color` onwards they are shifted by one compared to these names.
-- @param player [Player The player looked at]
-- @param x [Number The text x position]
-- @param y [Number The text y position]
-- @param color [String The unrecognised name (see above)]
-- @param alpha [Color The team colour (see above)]
-- @param flashAlpha [Number The text alpha (see above)]
-- @return [Any `true` to draw the unrecognised name, a string to draw that text instead, a number to
-- draw nothing and continue at that y position]
function GM:PlayerCanShowUnrecognised(player, x, y, color, alpha, flashAlpha)
  return true
end

--- Called to get the name drawn on a recognised player's target ID; uses their name.
-- @param player [Player The player looked at]
-- @return [String The name, which may contain newlines]
function GM:GetTargetPlayerName(player)
  return player:Name()
end

--- Called when the local player begins typing; returns `true` to hide the default chat box.
-- @param team [Boolean Whether team chat is being opened]
-- @return [Boolean Always `true`]
function GM:StartChat(team)
  return true
end

--- Called when a player says something; suppresses the default chat.
--
-- Console messages are added to the Catwork chatbox.
-- @param player [Player The player, or an invalid entity for the console]
-- @param text [String The message]
-- @param teamOnly [Boolean Whether it was team only]
-- @param playerIsDead [Boolean Whether the player is dead]
-- @return [Boolean Always `true`]
function GM:OnPlayerChat(player, text, teamOnly, playerIsDead)
  if !IsValid(player) then
    chatbox.AddText(nil, '[color=red]#Console[/color]: '..text, { icon = 'icon16/shield.png' })
  end

  return true
end

--- Called when engine chat text is received from the server; returns `true` to suppress it.
-- @param index [Number The player index]
-- @param name [String The player name]
-- @param text [String The text]
-- @param class [String The message type]
-- @return [Boolean Always `true`]
function GM:ChatText(index, name, text, class)
  return true
end

--- Called when the scoreboard should be created; overridden to do nothing, the scoreboard is part of the main menu.
function GM:CreateScoreboard() end

--- Called when the scoreboard key is pressed; opens the main menu when `CanShowTabMenu` allows.
function GM:ScoreboardShow()
  if cw.client:HasInitialized() then
    if hook.Run('CanShowTabMenu') then
      cw.menu:Create()
      cw.menu:SetOpen(true)
      cw.menu.holdTime = UnPredictedCurTime() + 0.5
    end
  end
end

--- Called when the scoreboard key is released; closes the main menu if it was held for at least half a second.
function GM:ScoreboardHide()
  if cw.client:HasInitialized() and cw.menu.holdTime then
    if UnPredictedCurTime() >= cw.menu.holdTime then
      if hook.Run('CanShowTabMenu') then
        cw.menu:SetOpen(false)
      end
    end
  end
end

--- Called before the main menu is opened or closed with the scoreboard key; always allows it.
-- @return [Boolean Whether the menu opens or closes]
function GM:CanShowTabMenu() return true end

--- Called to play GMod's "grab ear" animation while typing; overridden to do nothing.
-- @param player [Player The player]
function GM:GrabEarAnimation(player) end

--- Called before an item entity's target ID is drawn; return `false` to stop the default draw.
-- @param x [Number The text x position]
-- @param y [Number The text y position]
-- @param alpha [Number The text alpha]
-- @param itemTable [Item The item]
-- @return [Boolean Whether the default target ID is drawn]
function GM:PaintItemTargetID(x, y, alpha, itemTable) return true end

--- Called when a hook errors; shows the hook error notice on the HUD for 3 seconds.
-- @param name [String The hook name]
-- @param isGM [Boolean Whether the error was in a gamemode hook]
-- @param message [String The error message]
function GM:OnHookError(name, isGM, message)
  LocalPlayer().ErrorBoxTime = CurTime() + 3
end
