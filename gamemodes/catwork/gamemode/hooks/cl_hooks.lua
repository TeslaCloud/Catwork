--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called to determine whether player has lenses or not.
function GM:PlayerHasLenses()
	local clientInventory = cw.inventory:GetClient()

	if (clientInventory) then
		return cw.inventory:HasItemByID(clientInventory, "lenses")
	end

	return false
end

-- Called when derma skin's name is needed.
function GM:ForceDermaSkin()
	return "Clockwork"
end

--[[
	@codebase Client
	@details Called to display a HUD notification when a weapon has been picked up. (Used to override GMOD function)
--]]
function GM:HUDWeaponPickedUp(...) end

--[[
	@codebase Client
	@details Called to display a HUD notification when an item has been picked up. (Used to override GMOD function)
--]]
function GM:HUDItemPickedUp(...) end

--[[
	@codebase Client
	@details Called to display a HUD notification when ammo has been picked up. (Used to override GMOD function)
--]]
function GM:HUDAmmoPickedUp(...) end

--[[
	@codebase Client
	@details Called when the context menu is opened.
--]]
function GM:OnContextMenuOpen()
	if (cw.core:IsUsingTool()) then
		return self.BaseClass:OnContextMenuOpen(self)
	else
		gui.EnableScreenClicker(true)
	end
end

--[[
	@codebase Client
	@details Called when the context menu is close.
--]]
function GM:OnContextMenuClose()
	if (cw.core:IsUsingTool()) then
		return self.BaseClass:OnContextMenuClose(self)
	else
		gui.EnableScreenClicker(false)
	end
end

--[[
	@codebase Client
	@details Called to determine if a player can use property.
	@param Player The player that is trying to use property.
	@param
	@param Entity The entity that is being used.
	@returns Bool Whether or not the player can use property.
--]]
function GM:CanProperty(player, property, entity)
	if (!IsValid(entity)) then
		return false
	end

	local bIsAdmin = cw.player:IsAdmin(player)

	if (!player:Alive() or player:IsRagdolled() or !bIsAdmin) then
		return false
	end

	return self.BaseClass:CanProperty(player, property, entity)
end

--[[
	@codebase Client
	@details Called to determine if a player can drive.
	@param Player The player trying to drive.
	@param Entity The entity that the player is trying to drive.
	@return Bool Whether or not the player can drive the entity.
--]]
function GM:CanDrive(player, entity)
	if (!IsValid(entity)) then
		return false
	end

	if (!player:Alive() or player:IsRagdolled() or !cw.player:IsAdmin(player)) then
		return false
	end

	return self.BaseClass:CanDrive(player, entity)
end

--[[
	@codebase Client
	@details Called when the directory is rebuilt.
	@param <DPanel> The directory panel.
--]]
function GM:ClockworkDirectoryRebuilt(panel)
	for k, v in pairs(cw.command.stored) do
		if (!cw.player:HasFlags(cw.client, v.access)) then
			cw.command:RemoveHelp(v)
		else
			cw.command:AddHelp(v)
		end
	end
end

--[[
	@codebase Client
	@details Called when the local player is given an item.
	@param Table The table of the item that was given.
--]]
function GM:PlayerItemGiven(itemTable)
	if (cw.storage:IsStorageOpen()) then
		cw.storage:GetPanel():Rebuild()
	end
end

--[[
	@codebase Client
	@details Called when the local player has an item taken from them.
	@param Table The table of the item that was taken.
--]]
function GM:PlayerItemTaken(itemTable)
	if (cw.storage:IsStorageOpen()) then
		cw.storage:GetPanel():Rebuild()
	end
end

--[[
	@codebase Client
	@details Called when clockwork's config is initialized.
	@param String The name of the config key.
	@param String The value relating to the key in the table.
--]]
function GM:ClockworkConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs(item.GetAll()) do
			v.cost = 0
		end
	end
end

local checkTable = {
	["cwTextColorR"] = true,
	["cwTextColorG"] = true,
	["cwTextColorB"] = true,
	["cwTextColorA"] = true
}

--[[
	@codebase Client
	@details Called when one of the client's console variables have been changed.
	@param String The name of the convar that was changed.
	@param String The previous value of the convar.
	@param String The new value of the convar.
--]]
function GM:ClockworkConVarChanged(name, previousValue, newValue)
	if (checkTable[name] and !cw.theme:IsFixed()) then
		cw.option:SetColor(
			"information",
			Color(
				GetConVarNumber("cwTextColorR"),
				GetConVarNumber("cwTextColorG"),
				GetConVarNumber("cwTextColorB"),
				GetConVarNumber("cwTextColorA")
			)
		)
	elseif (name == "cwActiveTheme") then
		if (config.Get("modify_themes"):GetBoolean()) then
			local newTheme = cw.theme:FindByID(newValue)

			if (newTheme) then
				cw.theme:SetActive(newTheme)
			end
		end
	end
end

--[[
	@codebase Client
	@details Called when an entity's menu options are needed.
	@param Entity The entity that is being checked for menu options.
	@param Table The table of options for the entity.
--]]
function GM:GetEntityMenuOptions(entity, options)
	local class = entity:GetClass()

	if (class == "cw_item") then
		local itemTable = nil

		if (entity.GetItemTable) then
			itemTable = entity:GetItemTable()
		else
			debug.Trace()
		end

		if (itemTable) then
			local useText = itemTable.useText or "#EntityMenuOptions_useText"

			if (itemTable.OnUse) then
				options[L(useText)] = "cw.itemUse"
			end

			if (itemTable.GetEntityMenuOptions) then
				itemTable:GetEntityMenuOptions(entity, options)
			end

			options["#EntityMenuOptions_Take"] = "cw.itemTake"
			options["#EntityMenuOptions_Examine"] = "cw.itemExamine"
		end
	elseif (class == "cw_belongings") then
		options["#EntityMenuOptions_Open"] = "cwBelongingsOpen"
	elseif (class == "cw_shipment") then
		options["#EntityMenuOptions_Open"] = "cwShipmentOpen"
	elseif (class == "cw_cash") then
		options["#EntityMenuOptions_Take"] = "cwCashTake"
	end
end

--[[
	@codebase Client
	@details Called when the GUI mouse has been released.
--]]
function GM:GUIMouseReleased(code)
	if (!config.Get("use_opens_entity_menus"):Get()
	and vgui.CursorVisible()) then
		local trace = cw.client:GetEyeTrace()

		if (IsValid(trace.Entity) and trace.HitPos:Distance(cw.client:GetShootPos()) <= 80) then
			cw.EntityMenu = cw.core:HandleEntityMenu(trace.Entity)

			if (IsValid(cw.EntityMenu)) then
				cw.EntityMenu:SetPos(gui.MouseX() - (cw.EntityMenu:GetWide() / 2), gui.MouseY() - (cw.EntityMenu:GetTall() / 2))
			end
		end
	end
end

--[[
	@codebase Client
	@details Called when a key has been released.
	@param Player The player releasing a key.
	@param Key The key that is being released.
--]]
function GM:KeyRelease(player, key)
	if (config.Get("use_opens_entity_menus"):Get()) then
		if (key == IN_USE) then
			local activeWeapon = player:GetActiveWeapon()
			local trace = cw.client:GetEyeTraceNoCursor()

			if (IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_physgun") then
				if (player:KeyDown(IN_ATTACK)) then
					return
				end
			end

			if (IsValid(trace.Entity) and trace.HitPos:Distance(cw.client:GetShootPos()) <= 80) then
				cw.EntityMenu = cw.core:HandleEntityMenu(trace.Entity)

				if (IsValid(cw.EntityMenu)) then
					cw.EntityMenu:SetPos(
						(ScrW() / 2) - (cw.EntityMenu:GetWide() / 2), (ScrH() / 2) - (cw.EntityMenu:GetTall() / 2)
					)
				end
			end
		end
	end
end

function GM:PreDrawHalos()
	if (IsValid(cw.client.openedEnt)) then
		if (IsValid(cw.EntityMenu)) then
			halo.Add({cw.client.openedEnt}, Color(255, 255, 255), 2, 2, 1, true, false)
		else
			cw.client.openedEnt = nil
		end
	end
end

--[[
	@codebase Client
	@details Called when the local player has been created.
--]]
function GM:LocalPlayerCreated()
	cw.core:RegisterNetworkProxy(cw.client, "Clothes", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			if (newValue != "") then
				local clothesData = string.Explode(" ", newValue)
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
		netstream.Start("LocalPlayerCreated", true)
	end)
end

--[[
	@codebase Client
	@details Called when the client initializes.
--]]
function GM:Initialize()
	CW_CONVAR_TWELVEHOURCLOCK = cw.core:CreateClientConVar("cwTwelveHourClock", 0, true, true)
	CW_CONVAR_HEADBOBSCALE = cw.core:CreateClientConVar("cwHeadbobScale", 1, true, true)
	CW_CONVAR_SHOWAURA = cw.core:CreateClientConVar("cwShowCW", 1, true, true)
	CW_CONVAR_SHOWLOG = cw.core:CreateClientConVar("cwShowLog", 1, true, true)
	CW_CONVAR_SHOWHINTS = cw.core:CreateClientConVar("cwShowHints", 1, true, true)
	CW_CONVAR_VIGNETTE = cw.core:CreateClientConVar("cwShowVignette", 1, true, true)

	CW_CONVAR_ESPTIME = cw.core:CreateClientConVar("cwESPTime", 1, true, true)
	CW_CONVAR_ADMINESP = cw.core:CreateClientConVar("cwAdminESP", 0, true, true)
	CW_CONVAR_ESPBARS = cw.core:CreateClientConVar("cwESPBars", 1, true, true)
	CW_CONVAR_ITEMESP = cw.core:CreateClientConVar("cwItemESP", 0, false, true)
	CW_CONVAR_PROPESP = cw.core:CreateClientConVar("cwPropESP", 0, false, true)
	CW_CONVAR_SPAWNESP = cw.core:CreateClientConVar("cwSpawnESP", 0, false, true)
	CW_CONVAR_SALEESP = cw.core:CreateClientConVar("cwSaleESP", 0, false, true)
	CW_CONVAR_NPCESP = cw.core:CreateClientConVar("cwNPCESP", 0, false, true)

	CW_CONVAR_ACTIVETHEME = cw.core:CreateClientConVar("cwActiveTheme", "", true, true)

	if (!chatbox.panel) then
		chatbox.CreateDerma()
		chatbox.Hide()
	end

	if (file.Exists("cwavatars.txt", "DATA")) then
		cw.AvatarsData = pon.decode(file.Read("cwavatars.txt", "DATA")) or {}
	else
		cw.AvatarsData = {}
	end

	item.Initialize()

	if (!cw.option:GetKey("top_bars")) then
		CW_CONVAR_TOPBARS = cw.core:CreateClientConVar("cwTopBars", 1, true, true)
	else
		cw.setting:RemoveByConVar("cwTopBars")
	end

	hook.Run("ClockworkInitialized")

	cw.theme:Initialize()
	cw.setting:AddSettings()
	cw.core:CacheLimbs()

	hook.Remove("PostDrawEffects", "RenderWidgets")
end

--[[
	@codebase Client
	@details Called when Clockwork has initialized.
--]]
function GM:ClockworkInitialized()
	local logoFile = "clockwork/logo/002.png"

	cw.SpawnIconMaterial = cw.core:GetMaterial("vgui/spawnmenu/hover")
	cw.DefaultGradient = surface.GetTextureID("gui/gradient_down")
	cw.GradientTexture = cw.core:GetMaterial(cw.option:GetKey("gradient")..".png")
	cw.ClockworkSplash = cw.core:GetMaterial(logoFile)
	cw.FishEyeTexture = cw.core:GetMaterial("models/props_c17/fisheyelens")
	cw.GradientCenter = surface.GetTextureID("gui/center_gradient")
	cw.GradientRight = surface.GetTextureID("gui/gradient")
	cw.GradientUp = surface.GetTextureID("gui/gradient_up")
	cw.ScreenBlur = cw.core:GetMaterial("pp/blurscreen")
	cw.Gradients = {
		[GRADIENT_CENTER] = cw.GradientCenter,
		[GRADIENT_RIGHT] = cw.GradientRight,
		[GRADIENT_DOWN] = cw.DefaultGradient,
		[GRADIENT_UP] = cw.GradientUp
	}

	cw.setting:AddSettings()

	cw.directory:AddCategoryMatch(cw.lang:TranslateText("#Directory_Commands"), "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKVSURBVDjLfVNLSFRRGP7umTs+xubpTJQO4bRxoUGRZS1CCCa0oghatkpo4aZN0LJttIhx1UZs0aZ0UxaKgSFC0KZxhnxRaGqjiU7eUZur93n6z5lR0Kxz+e93H+f/vu//zzkK5xz/G+l0+rlt23csy1IJQSjDNE2BL5V/EWSz2SAl9IRCoduVlT4YlATXhZxNOeFwCMPDQ1APS85kMu0iORqN1tfU1OD7/BKEuutyuNwlIg6HyAzDgDo9PW04jlNBISft2hSoadpBy1hf14jIRfJKh/ymiuR4/AQKhQ2pzsXFhUsuQ7yQJiLhIN4OvEFT8xmpLv5JB4JVJD/sSdM0BYpC99JNooitzU08uXdOKo6nP0G4PX7tZsmBsCpUxcRwpBaMMSgUrBziWRBwx0WD8xGJBEPeaQQv94AJB9QTImDweDz7gpVRjsUBtLREcDLZhWOBLJzVdMmBVV4ehSnwqOqeukRRAuGFQAZR308EG5MoLgwhGCAHc68R2vZCFSyiIaIEoZg46pP1l4aC5Q0bTZFlBE9dh6NPoioax46TQ92lJiQ3xkoErFyniNmvf++LhmgAljZPAnlyVERFIA/s6Ciu7JQIvF4VjztPy+WxLBu6bpArF9VWDuGtQXirXbj2JJhbAJgf3DIx0zeHd7k4VOrk09HRD227G4Uw4vf7E7XWFHyY4HUdtxRuvofibGFiUIfXKMJDJaqtD7CyOIJ9Z6G7u/s+kdw433rxcrzQi/qWNpj5Z1DVICZGdAxOxqCxGO0DG9s2xH6Y2TsLqVQqRkuWam+/iiN+P5heAcWzBE9lDFPDv35/GV/tetQ79uJgf/YIyPo6xef+/ldnRSmNVWto/rGAoqabudm1zru93/oOO3h/ANOqi32og/qlAAAAAElFTkSuQmCC")
	cw.directory:AddCategoryMatch("Plugins", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAHhSURBVDjLpZI9SJVxFMZ/r2YFflw/kcQsiJt5b1ije0tDtbQ3GtFQYwVNFbQ1ujRFa1MUJKQ4VhYqd7K4gopK3UIly+57nnMaXjHjqotnOfDnnOd/nt85SURwkDi02+ODqbsldxUlD0mvHw09ubSXQF1t8512nGJ/Uz/5lnxi0tB+E9QI3D//+EfVqhtppGxUNzCzmf0Ekojg4fS9cBeSoyzHQNuZxNyYXp5ZM5Mk1ZkZT688b6thIBenG/N4OB5B4InciYBCVyGnEBHO+/LH3SFKQuF4OEs/51ndXMXC8Ajqknrcg1O5PGa2h4CJUqVES0OO7sYevv2qoFBmJ/4gF4boaOrg6rPLYWaYiVfDo0my8w5uj12PQleB0vcp5I6HsHAUoqUhR29zH+5B4IxNTvDmxljy3x2YCYUwZVlbzXJh9UKeQY6t2m0Lt94Oh5loPdqK3EkjzZi4MM/Y9Db3MTv/mYWVxaqkw9IOATNR7B5ABHPrZQrtg9sb8XDKa1+QOwsri4zeHD9SAzE1wxBTXz9xtvMc5ZU5lirLSKIz18nJnhOZjb22YKkhd4odg5icpcoyL669TAAujlyIvmPHSWXY1ti1AmZ8mJ3ElP1ips1/YM3H300g+W+51nc95YPEX8fEbdA2ReVYAAAAAElFTkSuQmCC")
	cw.directory:AddCategoryMatch("Flags", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAH0SURBVDjLlZPLbxJRGMX5X/xbjBpjjCtXLl2L0YWkaZrhNQwdIA4FZxygC22wltYYSltG1HGGl8nopCMPX9AUKQjacdW4GNPTOywak7ZAF/eRe/M73/nOzXUAcEwaqVTKmUgkGqIoWoIgWP/fTYSTyaSTgAfdbhemaSIej+NcAgRudDod9Pt95PN5RKPR8wnwPG/Z1XVdB8dxin0WDofBsiyCwaA1UYBY/tdqtVAqlRCJRN6FQiE1k8mg2WyCpunxArFY7DKxfFir1VCtVlEoFCBJEhRFQbFYhM/na5wKzq/+4ALprzqxbFUqFWiaBnstl8tQVRWyLMPr9R643W7nCZhZ3uUS+T74jR7Y5c8wDAO5XA4MwxzalklVy+PxNCiKcp4IkbbhzR4K+h9IH02wax3MiAYCgcBfv99/4TS3xxtfepcTCPyKgGl5gCevfyJb/Q3q6Q5uMcb7s3IaTZ6lHY5f70H6YGLp7QDx9T0kSRtr5V9wLbZxw1N/fqbAHIEXsj1saQR+M8BCdg8icbJaHOJBqo3r1KfMuJdyuBZb2NT2R5a5l108JuFl1CHuJ9q4NjceHgncefSN9LoPcYskT9pYIfA9Al+Z3X4xzUdz3H74RbODWlGGeCYPcVf4jksz08HHId6k63USFK7ObuOia3rYHkdyavlR+267GwAAAABJRU5ErkJggg==")
	cw.directory:AddCategoryMatch("Voice Commands", "[icon]", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKVSURBVDjLfVNLSFRRGP7umTs+xubpTJQO4bRxoUGRZS1CCCa0oghatkpo4aZN0LJttIhx1UZs0aZ0UxaKgSFC0KZxhnxRaGqjiU7eUZur93n6z5lR0Kxz+e93H+f/vu//zzkK5xz/G+l0+rlt23csy1IJQSjDNE2BL5V/EWSz2SAl9IRCoduVlT4YlATXhZxNOeFwCMPDQ1APS85kMu0iORqN1tfU1OD7/BKEuutyuNwlIg6HyAzDgDo9PW04jlNBISft2hSoadpBy1hf14jIRfJKh/ymiuR4/AQKhQ2pzsXFhUsuQ7yQJiLhIN4OvEFT8xmpLv5JB4JVJD/sSdM0BYpC99JNooitzU08uXdOKo6nP0G4PX7tZsmBsCpUxcRwpBaMMSgUrBziWRBwx0WD8xGJBEPeaQQv94AJB9QTImDweDz7gpVRjsUBtLREcDLZhWOBLJzVdMmBVV4ehSnwqOqeukRRAuGFQAZR308EG5MoLgwhGCAHc68R2vZCFSyiIaIEoZg46pP1l4aC5Q0bTZFlBE9dh6NPoioax46TQ92lJiQ3xkoErFyniNmvf++LhmgAljZPAnlyVERFIA/s6Ciu7JQIvF4VjztPy+WxLBu6bpArF9VWDuGtQXirXbj2JJhbAJgf3DIx0zeHd7k4VOrk09HRD227G4Uw4vf7E7XWFHyY4HUdtxRuvofibGFiUIfXKMJDJaqtD7CyOIJ9Z6G7u/s+kdw433rxcrzQi/qWNpj5Z1DVICZGdAxOxqCxGO0DG9s2xH6Y2TsLqVQqRkuWam+/iiN+P5heAcWzBE9lDFPDv35/GV/tetQ79uJgf/YIyPo6xef+/ldnRSmNVWto/rGAoqabudm1zru93/oOO3h/ANOqi32og/qlAAAAAElFTkSuQmCC")

	cw.directory:SetCategoryTip("Clockwork", "Contains topics based on the Clockwork framework-.")
	cw.directory:SetCategoryTip("Chat Commands", "Contains a list of commands and their syntax.")

	cw.directory:AddCategory("Plugins", "Clockwork")
	cw.directory:AddCategory("Flags", "Clockwork")

	_G["ClockworkClientsideBooted"] = true
end

--[[
	@codebase Client
	@details Called when the tool menu needs to be populated.
--]]
function GM:PopulateToolMenu()
	local toolGun = weapons.GetStored("gmod_tool")

	for k, v in pairs(cw.tool:GetAll()) do
		toolGun.Tool[v.Mode] = v

		if (v.AddToMenu != false) then		
			spawnmenu.AddToolMenuOption(v.Tab or "Main",
				v.Category or "New Category",
				k,
				v.Name or "#"..k,
				v.Command or "gmod_tool "..k,
				v.ConfigName or k,
				v.BuildCPanel
			);			
		end

		language.Add("tool."..v.UniqueID..".name", v.Name)
		language.Add("tool."..v.UniqueID..".desc", v.Desc)
		language.Add("tool."..v.UniqueID..".0", v.HelpText)
	end
end

--[[
	@codebase Client
	@details Called when a player's door access name is needed.
--]]
function GM:GetPlayerDoorAccessName(player, door, owner)
	return player:Name()
end

--[[
	@codebase Client
	@details Called when a player should show on the door access list.
--]]
function GM:PlayerShouldShowOnDoorAccessList(player, door, owner)
	return true
end

--[[
	@codebase Client
	@details Called when a player should show on the scoreboard.
--]]
function GM:PlayerShouldShowOnScoreboard(player)
	return true
end

--[[
	@codebase Client
	@details Called when the local player attempts to zoom.
--]]
function GM:PlayerCanZoom()
	return true
end

-- Called when the local player attempts to see a business item.
function GM:PlayerCanSeeBusinessItem(itemTable) return true end

function GM:PlayerBindPress(player, bind, bPress, break_cycle)
	if (break_cycle) then return end -- break the cycle

	if (player:GetRagdollState() == RAGDOLL_FALLENOVER and string.find(bind, "+jump")) then
		cw.core:RunCommand("CharGetUp")
	elseif (string.find(bind, "toggle_zoom")) then
		return true
	elseif (string.find(bind, "+zoom")) then
		if (!hook.Run("PlayerCanZoom")) then
			return true
		end
	end

	if (!player:IsNoClipping() and !cw.player:HasFlags(player, "B") and bind:find("+jump")) then
		if (player:GetNetVar("Stamina", 100) < 2) then
			return true
		end
	end

	if (string.find(bind, "+attack") or string.find(bind, "+attack2")) then
		if (cw.storage:IsStorageOpen()) then
			return true
		end
	end

	local bindText = string.lower(bind)

	if (config.GetVal("block_inv_binds")) then
		if (bindText:find(config.Get("command_prefix"):Get().."invaction") or bindText:find("cwcmd invaction")) then
			return true
		end
	end

	if (config.GetVal("block_cash_binds")) then
		if (bindText:find("cash") or bindText:find("cwcmd cash") or
		bindText:find("tokens") or bindText:find("droptokens")) then
			return true
		end
	end

	if (config.GetVal("block_fallover_binds")) then
		if (bindText:find("fallover") or bindText:find("cwcmd fallover") or bindText:find("charfallover")) then
			return true
		end
	end

	local override = hook.Run("TopLevelPlayerBindPress", player, bind, bPress)

	if (!override) then
		-- Prevent weird stack overflow error.
		if (self.BaseClass.PlayerBindPress != self.PlayerBindPress) then
			return self.BaseClass.PlayerBindPress(self, player, bind, bPress, true)
		end
	end

	return override
end

-- Called when the local player attempts to see while unconscious.
function GM:PlayerCanSeeUnconscious()
	return false
end

-- Called when the local player's move data is created.
function GM:CreateMove(userCmd)
	local ragdollEyeAngles = cw.core:GetRagdollEyeAngles()

	if (ragdollEyeAngles and IsValid(cw.client)) then
		local defaultSensitivity = 0.05
		local sensitivity = defaultSensitivity * (hook.Run("AdjustMouseSensitivity", defaultSensitivity) or defaultSensitivity)

		if (sensitivity <= 0) then
			sensitivity = defaultSensitivity
		end

		if (cw.client:IsRagdolled()) then
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -48, 48)
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -48, 48)
		else
			ragdollEyeAngles.p = math.Clamp(ragdollEyeAngles.p + (userCmd:GetMouseY() * sensitivity), -90, 90)
			ragdollEyeAngles.y = math.Clamp(ragdollEyeAngles.y - (userCmd:GetMouseX() * sensitivity), -90, 90)
		end
	end
end

local LAST_RAISED_TARGET = 0

-- Called when the view should be calculated.
function GM:CalcView(player, origin, angles, fov)
	local scale

	if (CW_CONVAR_HEADBOBSCALE) then
		scale = math.Clamp(CW_CONVAR_HEADBOBSCALE:GetFloat(), 0, 1) or 1
	else
		scale = 1
	end

	if (cw.client:IsRagdolled()) then
		local ragdollEntity = cw.client:GetRagdollEntity()
		local ragdollState = cw.client:GetRagdollState()

		if (cw.BlackFadeIn == 255) then
			return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov}
		else
			local eyes = ragdollEntity:GetAttachment(ragdollEntity:LookupAttachment("eyes"))

			if (eyes) then
				local ragdollEyeAngles = eyes.Ang + cw.core:GetRagdollEyeAngles()
				local physicsObject = ragdollEntity:GetPhysicsObject()

				if (IsValid(physicsObject)) then
					local velocity = physicsObject:GetVelocity().z

					if (velocity <= -1000 and cw.client:GetMoveType() == MOVETYPE_WALK) then
						ragdollEyeAngles.p = ragdollEyeAngles.p + math.sin(UnPredictedCurTime()) * math.abs((velocity + 1000) - 16)
					end
				end

				return {origin = eyes.Pos, angles = ragdollEyeAngles, fov = fov}
			else
				return self.BaseClass:CalcView(player, origin, angles, fov)
			end
		end
	elseif (!cw.client:Alive()) then
		return {origin = Vector(20000, 0, 0), angles = Angle(0, 0, 0), fov = fov}
	elseif (config.Get("enable_headbob"):Get() and scale > 0) then
		if (player:IsOnGround()) then
			local frameTime = FrameTime()

			if (!cw.player:IsNoClipping(player)) then
				local approachTime = frameTime * 2
				local curTime = UnPredictedCurTime()
				local info = {speed = 1, yaw = 0.5, roll = 0.1}

				if (!cw.HeadbobAngle) then
					cw.HeadbobAngle = 0
				end

				if (!cw.HeadbobInfo) then
					cw.HeadbobInfo = info
				end

				hook.Run("PlayerAdjustHeadbobInfo", info)

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

				if (!cw.VelSmooth) then cw.VelSmooth = 0; end
				if (!cw.WalkTimer) then cw.WalkTimer = 0; end
				if (!cw.LastStrafeRoll) then cw.LastStrafeRoll = 0; end

				cw.VelSmooth = math.Clamp(cw.VelSmooth * 0.9 + velocity:Length() * 0.1, 0, 700)
				cw.WalkTimer = cw.WalkTimer + cw.VelSmooth * FrameTime() * 0.05

				cw.LastStrafeRoll = (cw.LastStrafeRoll * 3) + (eyeAngles:Right():DotProduct(velocity) * 0.0001 * cw.VelSmooth * 0.3)
				cw.LastStrafeRoll = cw.LastStrafeRoll * 0.25
				angles.r = angles.r + cw.LastStrafeRoll

				if (player:GetGroundEntity() != NULL) then
					angles.p = angles.p + math.cos(cw.WalkTimer * 0.5) * cw.VelSmooth * 0.000002 * cw.VelSmooth
					angles.r = angles.r + math.sin(cw.WalkTimer) * cw.VelSmooth * 0.000002 * cw.VelSmooth
					angles.y = angles.y + math.cos(cw.WalkTimer) * cw.VelSmooth * 0.000002 * cw.VelSmooth
				end

				velocity = cw.client:GetVelocity().z

				if (velocity <= -1000 and cw.client:GetMoveType() == MOVETYPE_WALK) then
					angles.p = angles.p + math.sin(UnPredictedCurTime()) * math.abs((velocity + 1000) - 16)
				end
			end
		end
	end

	local view = self.BaseClass:CalcView(player, origin, angles, fov)

	hook.Run("CalcViewAdjustTable", view)

	return view
end

local WEAPON_LOWERED_ANGLES = Angle(30, -30, -25)
local WEAPON_LOWERED_ORIGIN = Vector(0, 0, 0)

function GM:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
	if (!IsValid(weapon)) then return end

	local weaponRaised = cw.client:IsWeaponRaised()

	if (!cw.client:HasInitialized() or !config.HasInitialized()
	or cw.client:GetMoveType() == MOVETYPE_OBSERVER) then
		weaponRaised = nil
	end

	local targetValue = 100

	if (weaponRaised) then
		targetValue = 0
	end

	local fraction = (cw.client.cwRaisedFraction or 100) / 100
	local itemTable = item.GetByWeapon(weapon)
	local originMod = weapon.LoweredOrigin or WEAPON_LOWERED_ORIGIN
	local anglesMod = weapon.LoweredAngles or WEAPON_LOWERED_ANGLES

	if (itemTable and itemTable.loweredAngles) then
		anglesMod = itemTable.loweredAngles
	elseif (weapon.LoweredAngles) then
		anglesMod = weapon.LoweredAngles
	end

	if (itemTable and itemTable.loweredOrigin) then
		originMod = itemTable.loweredOrigin
	elseif (weapon.LoweredOrigin) then
		originMod = weapon.LoweredOrigin
	end

	local viewInfo = {
		origin = originMod,
		angles = anglesMod
	}

	hook.Run("GetWeaponLoweredViewInfo", itemTable, weapon, viewInfo)

	eyeAngles:RotateAroundAxis(eyeAngles:Up(), viewInfo.angles.p * fraction)
	eyeAngles:RotateAroundAxis(eyeAngles:Forward(), viewInfo.angles.y * fraction)
	eyeAngles:RotateAroundAxis(eyeAngles:Right(), viewInfo.angles.r * fraction)

	oldEyePos = oldEyePos + ((eyeAngles:Forward() * viewInfo.origin.y) + (eyeAngles:Right() * viewInfo.origin.x) + (eyeAngles:Up() * viewInfo.origin.z)) * fraction

	cw.client.cwRaisedFraction = Lerp(FrameTime() * 2, cw.client.cwRaisedFraction or 100, targetValue)

	--Return the edited angle and position.
	return oldEyePos, eyeAngles
end

-- Called when the local player's limb damage is received.
function GM:PlayerLimbDamageReceived() end

-- Called when the local player's limb damage is reset.
function GM:PlayerLimbDamageReset() end

-- Called when the local player's limb damage is bIsHealed.
function GM:PlayerLimbDamageHealed(hitGroup, amount) end

-- Called when the local player's limb takes damage.
function GM:PlayerLimbTakeDamage(hitGroup, damage) end

-- Called when a weapon's lowered view info is needed.
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

-- Called when a HUD element should be drawn.
function GM:HUDShouldDraw(name)
	if (!IsValid(cw.client) or !cw.client:HasInitialized() or cw.core:IsChoosingCharacter()) then
		if (name != "CHudGMod") then
			return false
		end
	elseif (blockedElements[name]) then
		return false
	end

	return self.BaseClass:HUDShouldDraw(name)
end

-- Called when the menu is opened.
function GM:MenuOpened()
	for k, v in pairs(cw.menu:GetItems()) do
		if (v.panel.OnMenuOpened) then
			v.panel:OnMenuOpened()
		end
	end
end

-- Called when the menu is closed.
function GM:MenuClosed()
	for k, v in pairs(cw.menu:GetItems()) do
		if (v.panel.OnMenuClosed) then
			v.panel:OnMenuClosed()
		end
	end

	cw.core:RemoveActiveToolTip()
	cw.core:CloseActiveDermaMenus()
end

-- Called when the character screen's faction characters should be sorted.
function GM:CharacterScreenSortFactionCharacters(faction, a, b)
	return a.name < b.name
end

-- Called when the scoreboard's class players should be sorted.
function GM:ScoreboardSortClassPlayers(class, a, b)
	local recogniseA = cw.player:DoesRecognise(a)
	local recogniseB = cw.player:DoesRecognise(b)

	if (recogniseA and recogniseB) then
		return a:Team() < b:Team()
	elseif (recogniseA) then
		return true
	else
		return false
	end
end

-- Called when the scoreboard's player info should be adjusted.
function GM:ScoreboardAdjustPlayerInfo(info) end

-- Called when the menu's items should be adjusted.
function GM:MenuItemsAdd(menuItems)
	local attributesName = cw.option:GetKey("name_attributes")
	local systemName = cw.option:GetKey("name_system")
	local scoreboardName = cw.option:GetKey("name_scoreboard")
	local directoryName = cw.option:GetKey("name_directory")
	local inventoryName = cw.option:GetKey("name_inventory")

	--menuItems:Add("#Classes", "cwClasses", "#ClassesDesc", cw.option:GetKey("icon_data_classes"))
	menuItems:Add("#Settings", "cwSettings", "#SettingsDesc", cw.option:GetKey("icon_data_settings"))
	menuItems:Add(systemName, "cwSystem", "Управление схемой и фреймворком.", cw.option:GetKey("icon_data_system"))
	menuItems:Add(scoreboardName, "cwScoreboard", "Список игроков на сервере.", cw.option:GetKey("icon_data_scoreboard"))
	menuItems:Add(inventoryName, "cwInventory", "Инвентарь Вашего персонажа.", cw.option:GetKey("icon_data_inventory"))
	menuItems:Add(directoryName, "cwDirectory", "Список команд и необходимая информация.", cw.option:GetKey("icon_data_directory"))
	menuItems:Add(attributesName, "cwAttributes", "Узнать навыки и характеристики Вашего персонажа.", cw.option:GetKey("icon_data_attributes"))

	if (config.Get("show_business"):GetBoolean() == true) then
		local businessName = cw.option:GetKey("name_business")
		--menuItems:Add(businessName, "cwBusiness", cw.option:GetKey("description_business"), cw.option:GetKey("icon_data_business"))
	end
end

-- Called when the menu's items should be destroyed.
function GM:MenuItemsDestroy(menuItems) end

function GM:HalfSecond()
	local realCurTime = CurTime()
	local curTime = UnPredictedCurTime()

	if (!cw.NextHandleAttributeBoosts or realCurTime >= cw.NextHandleAttributeBoosts) then
		cw.NextHandleAttributeBoosts = realCurTime + 3

		for k, v in pairs(cw.attributes.boosts) do
			for k2, v2 in pairs(v) do
				if (v2.duration and v2.endTime) then
					if (realCurTime > v2.endTime) then
						cw.attributes.boosts[k][k2] = nil
					else
						local timeLeft = v2.endTime - realCurTime

						if (timeLeft >= 0) then
							if (v2.default < 0) then
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

-- Called each tick.
function GM:Tick()
	local font = cw.option:GetFont("player_info_text")

	if (cw.character:IsPanelPolling()) then
		local panel = cw.character:GetPanel()

		if (!panel and hook.Run("ShouldCharacterMenuBeCreated")) then
			cw.character:SetPanelPolling(false)
			cw.character.isOpen = true
			cw.character.panel = vgui.Create("cw.characterMenu")
			cw.character.panel:MakePopup()
			cw.character.panel:ReturnToMainMenu()

			hook.Run("PlayerCharacterScreenCreated", cw.character.panel)
		end
	end

	if (IsValid(cw.client) and !cw.core:IsChoosingCharacter()) then
		cw.bars.stored = {}
		cw.PlayerInfoText.text = {}
		cw.PlayerInfoText.width = ScrW() * 0.15
		cw.PlayerInfoText.subText = {}

		cw.core:DrawHealthBar()
		cw.core:DrawArmorBar()

		hook.Run("GetBars", cw.bars)
		hook.Run("DestroyBars", cw.bars)
		hook.Run("GetPlayerInfoText", cw.PlayerInfoText)
		hook.Run("DestroyPlayerInfoText", cw.PlayerInfoText)

		table.sort(cw.bars.stored, function(a, b)
			if (a.text == "" and b.text == "") then
				return a.priority > b.priority
			elseif (a.text == "") then
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

		if (config.Get("fade_dead_npcs"):Get()) then
			for k, v in pairs(ents.FindByClass("class C_ClientRagdoll")) do
				if (!cw.entity:IsDecaying(v)) then
					cw.entity:Decay(v, 300)
				end
			end
		end

		local playedHeartbeatSound = false

		if (cw.client:Alive() and config.Get("enable_heartbeat"):Get()) then
			local maxHealth = cw.client:GetMaxHealth()
			local health = cw.client:Health()

			if (health < maxHealth) then
				if (!cw.HeartbeatSound) then
					cw.HeartbeatSound = CreateSound(cw.client, "player/heartbeat1.wav")
				end

				if (!cw.NextHeartbeat or CurTime() >= cw.NextHeartbeat) then
					cw.NextHeartbeat = CurTime() + (0.75 + ((1.25 / maxHealth) * health))
					cw.HeartbeatSound:PlayEx(0.75 - ((0.7 / maxHealth) * health), 100)
				end

				playedHeartbeatSound = true
			end
		end

		if (!playedHeartbeatSound and cw.HeartbeatSound) then
			cw.HeartbeatSound:Stop()
		end
	end

	if (cw.core:IsInfoMenuOpen() and !input.IsKeyDown(KEY_F1)) then
		cw.core:RemoveBackgroundBlur("InfoMenu")
		cw.core:CloseActiveDermaMenus()
		cw.InfoMenuOpen = false

		if (IsValid(cw.InfoMenuPanel)) then
			cw.InfoMenuPanel:SetVisible(false)
			cw.InfoMenuPanel:Remove()
		end

		timer.Simple(FrameTime() * 0.5, function()
			cw.core:RemoveActiveToolTip()
		end)
	end

	local menuMusic = cw.option:GetKey("menu_music")

	if (menuMusic != "") then
		if (IsValid(cw.client) and cw.character:IsPanelOpen()) then
			if (!cw.MusicSound) then
				cw.MusicSound = CreateSound(cw.client, menuMusic)
				cw.MusicSound:PlayEx(0.3, 100)
				cw.MusicFading = false
			end
		elseif (cw.MusicSound and !cw.MusicFading) then
			cw.MusicSound:FadeOut(8)
			cw.MusicFading = true

			timer.Simple(8, function()
				cw.MusicSound = nil
			end)
		end
	end

	local worldEntity = game.GetWorld()

	for k, v in pairs(cw.NetworkProxies) do
		if (IsValid(k) or k == worldEntity) then
			for k2, v2 in pairs(v) do
				local value = nil

				if (k == worldEntity) then
					value = netvars.GetNetVar(k2)
				else
					value = k:GetNetVar(k2)
				end

				if (value != v2.oldValue) then
					v2.Callback(k, k2, v2.oldValue, value)
					v2.oldValue = value
				end
			end
		else
			cw.NetworkProxies[k] = nil
		end
	end
end

function GM:InitPostEntity()
	cw.client = LocalPlayer()

	if (IsValid(cw.client)) then
		hook.Run("LocalPlayerCreated")
	end

	for k, v in ipairs(_player.GetAll()) do
		hook.Run("PlayerModelChanged", v, v:GetModel())
	end

	hook.Run("ClockworkInitPostEntity")
end

-- Called each frame.
function GM:Think()
	cw.core:CalculateHints()

	if (cw.core:IsCharacterScreenOpen()) then
		local panel = cw.character:GetPanel()

		if (panel) then
			panel:SetVisible(hook.Run("GetPlayerCharacterScreenVisible", panel))

			if (panel:IsVisible()) then
				cw.HasCharacterMenuBeenVisible = true
			end
		end
	end
end

local SCREEN_DAMAGE_OVERLAY = cw.core:GetMaterial("clockwork/screendamage.png")
local VIGNETTE_OVERLAY = cw.core:GetMaterial("clockwork/vignette.png")

-- Called when the local player's screen damage should be drawn.
function GM:DrawPlayerScreenDamage(damageFraction)
	surface.SetDrawColor(255, 255, 255, math.Clamp(255 * damageFraction, 0, 150))
	surface.SetMaterial(SCREEN_DAMAGE_OVERLAY)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end

--[[
	Called when the entity outlines should be added.
	The "outlines" parameter is a reference to cw.outline.
--]]
function GM:AddEntityOutlines(outlines)
	if (IsValid(cw.EntityMenu) and IsValid(cw.EntityMenu.entity)) then
		--[[ Maybe this isn't needed. --]]
		cw.EntityMenu.entity:DrawModel()

		outlines:Add(
			cw.EntityMenu.entity, Color(255, 255, 255, 255)
		)
	end
end

-- Called when the local player's vignette should be drawn.
function GM:DrawPlayerVignette()
	local curTime = CurTime()

	if (!cw.cwVignetteAlpha) then
		cw.cwVignetteAlpha = 100
		cw.cwVignetteDelta = cw.cwVignetteAlpha
		cw.cwVignetteRayTime = 0
	end

	if (curTime >= cw.cwVignetteRayTime) then
		local data = {}
			data.start = cw.client:GetShootPos()
			data.endpos = data.start + (cw.client:GetUp() * 512)
			data.filter = cw.client
		local trace = util.TraceLine(data)

		if (!trace.HitWorld and !trace.HitNonWorld) then
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

-- Called when the foreground HUD should be painted.
function GM:HUDPaintForeground()
	local backgroundColor = cw.option:GetColor("background")
	local colorWhite = cw.option:GetColor("white")
	local info = hook.Run("GetProgressBarInfo")
	local scrW, scrH = ScrW(), ScrH()
	local curTime = CurTime()

	if (LocalPlayer().ErrorBoxTime and LocalPlayer().ErrorBoxTime > (curTime)) then
		draw.RoundedBox(2, scrW - 300, 8, 292, 24, Color(math.Clamp(255 * (math.sin(curTime)), 150, 255), 90, 90))
		draw.SimpleText(L"#HookErrors", cw.fonts:GetSize(cw.option:GetFont("menu_text_small"), 18), scrW - 292, 10, Color(255, 255, 255))
	end

	if (cw.client:GetRagdollState() == RAGDOLL_FALLENOVER) then
		cdraw.DrawSimpleBlurBox(0, 0, scrW, scrH, Color(40, 40, 40, 45), 2)
	elseif (cw.client:WaterLevel() >= 3) then
		cdraw.DrawSimpleBlurBox(0, 0, scrW, scrH, Color(40, 40, 40, 45), 4)
	end

	if (info) then
		local height = 32
		local width = (scrW * 0.5)
		local x = scrW * 0.25
		local y = scrH * 0.3

		cw.core:DrawBar(
			x, y, width, height, info.color or cw.option:GetColor("information"),
			info.text or "Progress Bar", info.percentage or 100, 100, info.flash, {uniqueID = info.uniqueID}
		)
	else
		info = hook.Run("GetPostProgressBarInfo")

		if (info) then
			local height = 32
			local width = (scrW / 2) - 64
			local x = scrW * 0.25
			local y = scrH * 0.3

			cw.core:DrawBar(
				x, y, width, height, info.color or cw.option:GetColor("information"),
				info.text or "Progress Bar", info.percentage or 100, 100, info.flash, {uniqueID = info.uniqueID}
			)
		end
	end

	if (cw.player:IsAdmin(cw.client)) then
		if (hook.Run("PlayerCanSeeAdminESP")) then
			cw.core:DrawAdminESP()
		end
	end

	local screenTextInfo = hook.Run("GetScreenTextInfo")

	if (screenTextInfo) then
		local alpha = screenTextInfo.alpha or 255
		local y = (scrH / 2) - 128
		local x = scrW / 2

		if (screenTextInfo.title) then
			cw.core:OverrideMainFont(cw.option:GetFont("menu_text_small"))
				y = cw.core:DrawInfo(screenTextInfo.title, x, y, colorWhite, alpha)
			cw.core:OverrideMainFont(false)
		end

		if (screenTextInfo.text) then
			cw.core:OverrideMainFont(cw.option:GetFont("menu_text_tiny"))
				y = cw.core:DrawInfo(screenTextInfo.text, x, y, colorWhite, alpha)
			cw.core:OverrideMainFont(false)
		end
	end

	local info = {width = scrW * cw.option:GetKey("top_bar_width_scale"), x = 8, y = 8}
		cw.core:DrawBars(info, "top")

	local action, percentage = cw.player:GetAction(cw.client, true)
	local color_white = Color(255, 255, 255)

	if (!cw.client:Alive() and action == "spawn" and !cw.client:GetNetVar("permaKilled")) then
		local respawnRounded = math.ceil(percentage)
		local font = cw.option:GetFont("menu_text_big")

		if (!cw.client.respawnAlpha) then cw.client.respawnAlpha = 0 end

		cw.client.respawnAlpha = math.Clamp(cw.client.respawnAlpha + 1, 0, 200)

		draw.RoundedBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, cw.client.respawnAlpha))

		draw.SimpleText("#DeathScreen_YouDied", font, 16, 16, color_white)
		draw.SimpleText("#DeathScreen_SpawnPercentage:"..respawnRounded..";%", font, 16, 16 + draw.GetFontHeight(font), color_white)

		draw.RoundedBox(0, 0, 0, scrW / 100 * percentage, 2, color_white)

		if (percentage >= 92) then
			cw.client.whiteAlpha = math.Clamp((51 * (percentage - 95)), 0, 255)
		else
			cw.client.whiteAlpha = 0
		end
	else
		cw.client.respawnAlpha = 0

		if (isnumber(cw.client.whiteAlpha) and cw.client.whiteAlpha > 0.5) then
			cw.client.whiteAlpha = Lerp(0.04, cw.client.whiteAlpha, 0)
		end
	end

	draw.RoundedBox(0, 0, 0, scrW, scrH, ColorAlpha(color_white, cw.client.whiteAlpha or 0))

	hook.Run("HUDPaintTopScreen", info)
end

-- Called when an item's network data has been updated.
function GM:ItemNetworkDataUpdated(itemTable, newData)
	if (itemTable.OnNetworkDataUpdated) then
		itemTable:OnNetworkDataUpdated(newData)
	end
end

-- Called to get the screen text info.
function GM:GetScreenTextInfo()
	local blackFadeAlpha = cw.core:GetBlackFadeAlpha()

	if (cw.client:GetNetVar("CharBanned")) then
		return {
			alpha = blackFadeAlpha,
			title = "#ScreenTextInfo_CharBanned_title",
			text = "#ScreenTextInfo_CharBanned_text"
		}
	end
end

-- Called after the VGUI has been rendered.
function GM:PostRenderVGUI()
	local cinematic = cw.Cinematics[1]

	if (cinematic) then
		cw.core:DrawCinematic(cinematic, CurTime())
	end

	local activeMarkupToolTip = cw.core:GetActiveMarkupToolTip()

	if (activeMarkupToolTip and IsValid(activeMarkupToolTip) and activeMarkupToolTip:IsVisible()) then
		local markupToolTip = activeMarkupToolTip:GetMarkupToolTip()
		local alpha = activeMarkupToolTip:GetAlpha()
		local x, y = gui.MouseX(), gui.MouseY() + 24

		if (markupToolTip) then
			cw.core:DrawMarkupToolTip(markupToolTip.object, x, y, alpha)
		end
	end
end

-- Called to get whether the local player can see the admin ESP.
function GM:PlayerCanSeeAdminESP()
	return (CW_CONVAR_ADMINESP:GetInt() == 1)
end

-- Called when the local player attempts to get up.
function GM:PlayerCanGetUp()
	return true
end

-- Called when the local player attempts to see the top bars.
function GM:PlayerCanSeeBars(class)
	if (class == "tab") then
		if (CW_CONVAR_TOPBARS) then
			return (CW_CONVAR_TOPBARS:GetInt() == 0 and cw.core:IsInfoMenuOpen())
		else
			return cw.core:IsInfoMenuOpen()
		end
	elseif (class == "top") then
		if (!cw.client:Alive()) then return false end

		if (CW_CONVAR_TOPBARS) then
			return CW_CONVAR_TOPBARS:GetInt() == 1
		else
			return true
		end
	else
		return true
	end
end

-- Called when the local player attempts to see the top hints.
function GM:PlayerCanSeeHints()
	return true
end

-- Called when the local player attempts to see the center hints.
function GM:PlayerCanSeeCenterHints()
	return true
end

-- Called when the local player attempts to see their limb damage.
function GM:PlayerCanSeeLimbDamage()
	return (cw.core:IsInfoMenuOpen() and config.Get("limb_damage_system"):Get())
end

-- Called when the local player attempts to see the date and time.
function GM:PlayerCanSeeDateTime()
	return cw.core:IsInfoMenuOpen()
end

-- Called when the local player attempts to see a class.
function GM:PlayerCanSeeClass(class)
	return true
end

-- Called when the local player attempts to see the player info.
function GM:PlayerCanSeePlayerInfo()
	return cw.core:IsInfoMenuOpen()
end

--
function GM:AddHint(name, delay)
	if (IsValid(cw.client) and cw.client:HasInitialized()) then
		cw.core:AddTopHint(
			cw.core:ParseData("#Hint_"..name), delay
		)
	end
end

--
function GM:AddNotify(text, class, length)
	if (class != NOTIFY_HINT or string.utf8sub(text, 1, 6) != "#Hint_") then
		if (self.BaseClass.AddNotify) then
			self.BaseClass:AddNotify(text, class, length)
		end
	end
end

-- Called when the target ID HUD should be drawn.
function GM:HUDDrawTargetID()
	local targetIDTextFont = cw.option:GetFont("target_id_text")
	local traceEntity = NULL
	local colorWhite = cw.option:GetColor("white")

	cw.core:OverrideMainFont(targetIDTextFont)

	if (IsValid(cw.client) and cw.client:Alive() and !IsValid(cw.EntityMenu)) then
		if (!cw.client:IsRagdolled(RAGDOLL_FALLENOVER)) then
			local fadeDistance = 196
			local curTime = UnPredictedCurTime()
			local trace = cw.player:GetRealTrace(cw.client)
			local ent = trace.Entity

			if (IsValid(ent) and !ent:IsEffectActive(EF_NODRAW)) then
				if (!cw.TargetIDData or cw.TargetIDData.entity != ent) then
					cw.TargetIDData = {
						showTime = curTime + config.Get("target_id_delay"):Get(),
						entity = ent
					}
				end

				if (cw.TargetIDData) then
					cw.TargetIDData.trace = trace
				end

				if (!IsValid(traceEntity)) then
					traceEntity = ent
				end

				if (curTime >= cw.TargetIDData.showTime) then
					if (!cw.TargetIDData.fadeTime) then
						cw.TargetIDData.fadeTime = curTime + 1
					end

					local class = ent:GetClass()
					local entity = cw.entity:GetPlayer(ent)

					if (entity) then
						fadeDistance = hook.Run("GetTargetPlayerFadeDistance", entity)
					end

					local alpha = math.Clamp(cw.core:CalculateAlphaFromDistance(fadeDistance, cw.client, trace.HitPos) * 1.5, 0, 255)

					if (alpha > 0) then
						alpha = math.min(alpha, math.Clamp(1 - ((cw.TargetIDData.fadeTime - curTime) / 3), 0, 1) * 255)
					end

					cw.TargetIDData.fadeDistance = fadeDistance
					cw.TargetIDData.player = entity
					cw.TargetIDData.alpha = alpha
					cw.TargetIDData.class = class

					if (entity and cw.client != entity) then
						if (hook.Run("ShouldDrawPlayerTargetID", entity)) then
							if (!cw.player:IsNoClipping(entity)) then
								if (cw.client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
									local flashAlpha = nil
									local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
									local x, y = toScreen.x, toScreen.y

									if (!cw.player:DoesTargetRecognise()) then
										flashAlpha = math.Clamp(math.sin(curTime * 2) * alpha, 0, 255)
									end

									if (cw.player:DoesRecognise(entity, RECOGNISE_PARTIAL)) then
										local text = string.Explode("\n", hook.Run("GetTargetPlayerName", entity))
										local newY

										for k, v in pairs(text) do
											newY = cw.core:DrawInfo(v, x, y, _team.GetColor(entity:Team()), alpha)

											if (flashAlpha) then
												cw.core:DrawInfo(v, x, y, colorWhite, flashAlpha)
											end

											if (newY) then
												y = newY
											end
										end
									else
										local unrecognisedName, usedPhysDesc = cw.player:GetUnrecognisedName(entity)
										local wrappedTable = {unrecognisedName}
										local teamColor = _team.GetColor(entity:Team())
										local result = hook.Run("PlayerCanShowUnrecognised", entity, x, y, unrecognisedName, teamColor, alpha, flashAlpha)
										local newY

										if (isstring(result)) then
											wrappedTable = {}
											cw.core:WrapText(result, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable)
										elseif (usedPhysDesc) then
											wrappedTable = {}
											cw.core:WrapText(unrecognisedName, targetIDTextFont, math.max(ScrW() / 9, 384), wrappedTable)
										end

										if (result == true or isstring(result)) then
											for k, v in pairs(wrappedTable) do
												newY = cw.core:DrawInfo(v, x, y, teamColor, alpha)

												if (flashAlpha) then
													cw.core:DrawInfo(v, x, y, colorWhite, flashAlpha)
												end

												if (newY) then
													y = newY
												end
											end
										elseif (tonumber(result)) then
											y = result
										end
									end

									cw.TargetPlayerText.stored = {}

									hook.Run("GetTargetPlayerText", entity, cw.TargetPlayerText)
									hook.Run("DestroyTargetPlayerText", entity, cw.TargetPlayerText)

									y = hook.Run("DrawPlayerStatusExtra", entity, alpha, x, y) or y
									y = hook.Run("DrawTargetPlayerStatus", entity, alpha, x, y) or y

									for k, v in pairs(cw.TargetPlayerText.stored) do
										if (v.scale) then
											y = cw.core:DrawInfoScaled(v.scale, v.text, x, y, v.color or colorWhite, alpha)
										else
											y = cw.core:DrawInfo(v.text, x, y, v.color or colorWhite, alpha)
										end
									end

									if (!cw.nextCheckRecognises or curTime >= cw.nextCheckRecognises[1]
									or cw.nextCheckRecognises[2] != entity) then
										netstream.Start("GetTargetRecognises", entity)

										cw.nextCheckRecognises = {curTime + 2, entity}
									end
								end
							end
						end
					elseif (ent:IsWeapon()) then
						if (cw.client:GetShootPos():Distance(trace.HitPos) <= fadeDistance) then
							local active = nil

							for k, v in ipairs(_player.GetAll()) do
								if (v:GetActiveWeapon() == ent) then
									active = true
								end
							end

							if (!active) then
								local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
								local x, y = toScreen.x, toScreen.y

								y = cw.core:DrawInfo("#HUDTargetID_Weapon_DrawInfo1", x, y, Color(200, 100, 50, 255), alpha)
								y = cw.core:DrawInfo("#HUDTargetID_Weapon_DrawInfo2", x, y, colorWhite, alpha)
							end
						end
					elseif (ent.HUDPaintTargetID) then
						local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
						local x, y = toScreen.x, toScreen.y

						ent:HUDPaintTargetID(x, y, alpha)
					else
						local toScreen = (trace.HitPos + Vector(0, 0, 16)):ToScreen()
						local x, y = toScreen.x, toScreen.y

						hook.Run("HUDPaintEntityTargetID", ent, {
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

	if (!IsValid(traceEntity)) then
		if (cw.TargetIDData) then
			cw.TargetIDData = nil
		end
	end
end

-- Called when the target's status should be drawn.
function GM:DrawTargetPlayerStatus(target, alpha, x, y)
	local informationColor = cw.option:GetColor("information")
	local gender = "#TargetPlayerStatus_Male"

	if (target:GetGender() == GENDER_FEMALE) then
		gender = "#TargetPlayerStatus_Female"
	end

	if (!target:Alive()) then
		return cw.core:DrawInfo("#TargetPlayerStatus_deceased:"..gender..";", x, y, informationColor, alpha)
	else
		return y
	end
end

-- Called when the character panel tool tip is needed.
function GM:GetCharacterPanelToolTip(panel, character)
	if (table.Count(faction.GetAll()) > 1) then
		local numPlayers = #faction.GetPlayers(character.faction)
		local numLimit = faction.GetLimit(character.faction)
		return "#CharacterPanelToolTip_PlayersWithThisFaction:"..numPlayers..","..numLimit..";"
	end
end

-- Called when a player's status info is needed.
function GM:GetStatusInfo(player, text)
	local action = cw.player:GetAction(player, true)

	if (action) then
		if (!player:IsRagdolled()) then
			if (action == "lock") then
				table.insert(text, "#StatusInfo_lock")
			elseif (action == "unlock") then
				table.insert(text, "#StatusInfo_unlock")
			end
		elseif (action == "unragdoll") then
			if (player:GetRagdollState() == RAGDOLL_FALLENOVER) then
				table.insert(text, "#StatusInfo_unragdoll_fallenover")
			else
				table.insert(text, "#StatusInfo_unragdoll")
			end
		elseif (!player:Alive()) then
			table.insert(text, "#StatusInfo_Dead")
		else
			table.insert(text, "#StatusInfo_Performing:"..action..";")
		end
	end

	if (player:GetRagdollState() == RAGDOLL_FALLENOVER) then
		local fallenOver = player:GetDTBool(BOOL_FALLENOVER)

		if (fallenOver) then
			table.insert(text, "#StatusInfo_fallenover")
		end
	end
end

--[[
	@codebase Client
	@details This function is called to figure out the text, percentage and flash of the current progress bar.
	@class Clockwork
	@returns Table The text, flash, and percentage of the progress bar.
--]]
function GM:GetProgressBarInfo()
	local action, percentage = cw.player:GetAction(cw.client, true)

	if (!cw.client:Alive() and action == "spawn") then
		return
		--return {text = cw.lang:TranslateText("#ProgressBarInfo_spawn"), percentage = percentage, flash = percentage < 10, isBlocky = true, blocksAmt = 32}
	end

	if (!cw.client:IsRagdolled()) then
		if (action == "lock") then
			return {text = cw.lang:TranslateText("#ProgressBarInfo_lock"), percentage = percentage, flash = percentage < 10, isBlocky = true, blocksAmt = 32}
		elseif (action == "unlock") then
			return {text = cw.lang:TranslateText("#ProgressBarInfo_unlock"), percentage = percentage, flash = percentage < 10, isBlocky = true, blocksAmt = 32}
		end
	elseif (action == "unragdoll") then
		if (cw.client:GetRagdollState() == RAGDOLL_FALLENOVER) then
			return {text = cw.lang:TranslateText("#ProgressBarInfo_unragdoll_fallenover"), percentage = percentage, flash = percentage < 10, isBlocky = true, blocksAmt = 32}
		else
			return {text = cw.lang:TranslateText("#ProgressBarInfo_unragdoll"), percentage = percentage, flash = percentage < 10, isBlocky = true, blocksAmt = 32}
		end
	elseif (cw.client:GetRagdollState() == RAGDOLL_FALLENOVER) then
		local fallenOver = cw.client:GetDTBool(BOOL_FALLENOVER)

		if (fallenOver and hook.Run("PlayerCanGetUp")) then
			return {text = cw.lang:TranslateText("#ProgressBarInfo_PlayerCanGetUp"), percentage = 100, isBlocky = true, blocksAmt = 32}
		end
	end
end

-- Called just before the local player's information is drawn.
function GM:PreDrawPlayerInfo(boxInfo, information, subInformation) end

-- Called just after the local player's information is drawn.
function GM:PostDrawPlayerInfo(boxInfo, information, subInformation) end

-- Called just after the date time box is drawn.
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
--[[
	@codebase Client
	@details This function is called when local player info text is needed and adds onto it (F1 menu).
	@class Clockwork
	@param Table The current table of player info text to add onto.
--]]
function GM:GetPlayerInfoText(playerInfoText)
	local cash = cw.player:GetCash() or 0
	local wages = cw.player:GetWages() or 0

	if (config.Get("cash_enabled"):Get()) then
		if (cash > 0) then
			playerInfoText:Add("CASH", cw.lang:TranslateText(cw.option:GetKey("name_cash")..": "..cw.core:FormatCash(cash, true)))
		end

		if (wages > 0) then
			playerInfoText:Add("WAGES", cw.lang:TranslateText(cw.client:GetWagesName()..": "..cw.core:FormatCash(wages)))
		end
	end

	playerInfoText:AddSub("NAME", cw.client:Name(), 2)
	playerInfoText:AddSub("CLASS", _team.GetName(cw.client:Team()), 1)
end

--[[
	@codebase Client
	@details This function is called when the player's fade distance is needed for their target text (when you look at them).
	@class Clockwork
	@param Table The player we are finding the distance for.
	@returns Int The fade distance, defaulted at 4096.
--]]
function GM:GetTargetPlayerFadeDistance(player)
	return 4096
end

-- Called when the player info text should be destroyed.
function GM:DestroyPlayerInfoText(playerInfoText) end

--[[
	@codebase Client
	@details This function is called when the targeted player's target text is needed.
	@class Clockwork
	@param Table The player we are finding the distance for.
	@param Table The player's current target text.
--]]
function GM:GetTargetPlayerText(player, targetPlayerText)
	local targetIDTextFont = cw.option:GetFont("target_id_text")
	local physDescTable = {}
	local thirdPerson = "#Scoreboard_TargetPlayerText_him"

	if (player:GetGender() == GENDER_FEMALE) then
		thirdPerson = "#Scoreboard_TargetPlayerText_her"
	end

	if (cw.player:DoesRecognise(player, RECOGNISE_PARTIAL)) then
		cw.core:WrapText(cw.player:GetPhysDesc(player), targetIDTextFont, math.max(ScrW() / 9, 384), physDescTable)

		for k, v in pairs(physDescTable) do
			targetPlayerText:Add("PHYSDESC_"..k, v)
		end
	elseif (player:Alive()) then
		targetPlayerText:Add("PHYSDESC", "#Scoreboard_TargetPlayerText:"..cw.lang:TranslateText(thirdPerson)..";")
	end
end

-- Called when the target player's text should be destroyed.
function GM:DestroyTargetPlayerText(player, targetPlayerText) end

-- Called when a player's scoreboard text is needed.
function GM:GetPlayerScoreboardText(player)
	local thirdPerson = "#Scoreboard_ScoreboardText_him"

	if (player:GetGender() == GENDER_FEMALE) then
		thirdPerson = "#Scoreboard_ScoreboardText_her"
	end

	if (cw.player:DoesRecognise(player, RECOGNISE_PARTIAL)) then
		local physDesc = cw.player:GetPhysDesc(player)

		if (string.utf8len(physDesc) > 64) then
			return string.utf8sub(physDesc, 1, 61).."..."
		else
			return physDesc
		end
	else
		return "#Scoreboard_ScoreboardText:"..cw.lang:TranslateText(thirdPerson)..";"
	end
end

-- Called when the local player's character screen faction is needed.
function GM:GetPlayerCharacterScreenFaction(character)
	return character.faction
end

-- Called to get whether the local player's character screen is visible.
function GM:GetPlayerCharacterScreenVisible(panel)
	if (!cw.quiz:GetEnabled() or cw.quiz:GetCompleted()) then
		return true
	else
		return false
	end
end

-- Called to get whether the character menu should be created.
function GM:ShouldCharacterMenuBeCreated()
	if (cw.ClockworkIntroFadeOut) then
		return false
	end

	return true
end

-- Called when the local player's character screen is created.
function GM:PlayerCharacterScreenCreated(panel)
	if (cw.quiz:GetEnabled()) then
		netstream.Start("GetQuizStatus", true)
	end
end

-- Called when a player's scoreboard class is needed.
function GM:GetPlayerScoreboardClass(player)
	return _team.GetName(player:Team())
end

-- Called when a player's scoreboard options are needed.
function GM:GetPlayerScoreboardOptions(player, options, menu)
	local charTakeFlags = cw.command:FindByID("CharTakeFlags")
	local charGiveFlags = cw.command:FindByID("CharGiveFlags")
	local charGiveItem = cw.command:FindByID("CharGiveItem")
	local charSetName = cw.command:FindByID("CharSetName")
	local plySetGroup = cw.command:FindByID("PlySetGroup")
	local plyDemote = cw.command:FindByID("PlyDemote")
	local charBan = cw.command:FindByID("CharBan")
	local plyKick = cw.command:FindByID("PlyKick")
	local plyBan = cw.command:FindByID("PlyBan")

	if (charBan and cw.player:HasFlags(cw.client, charBan.access)) then
		options["#ScoreboardOptions_CharBan"] = function()
			RunConsoleCommand("cwCmd", "CharBan", player:Name())
		end
	end

	if (plyKick and cw.player:HasFlags(cw.client, plyKick.access)) then
		options["#ScoreboardOptions_PlyKick"] = function()
			Derma_StringRequest(player:Name(), "#ScoreboardOptions_PlyKick_StringRequest", nil, function(text)
				cw.core:RunCommand("PlyKick", player:Name(), text)
			end)
		end
	end

	if (plyBan and cw.player:HasFlags(cw.client, cw.command:FindByID("PlyBan").access)) then
		options["#ScoreboardOptions_PlyBan"] = function()
			Derma_StringRequest(player:Name(), "#ScoreboardOptions_PlyBan_StringRequest_Minutes", nil, function(minutes)
				Derma_StringRequest(player:Name(), "#ScoreboardOptions_PlyBan_StringRequest_Reason", nil, function(reason)
					cw.core:RunCommand("PlyBan", player:Name(), minutes, reason)
				end)
			end)
		end
	end

	if (charGiveFlags and cw.player:HasFlags(cw.client, charGiveFlags.access)) then
		options["#ScoreboardOptions_CharGiveFlags"] = function()
			Derma_StringRequest(player:Name(), "#ScoreboardOptions_CharGiveFlags_StringRequest", nil, function(text)
				cw.core:RunCommand("CharGiveFlags", player:Name(), text)
			end)
		end
	end

	if (charTakeFlags and cw.player:HasFlags(cw.client,charTakeFlags.access)) then
		options["#ScoreboardOptions_CharTakeFlags"] = function()
			Derma_StringRequest(player:Name(), "#ScoreboardOptions_CharTakeFlags_StringRequest", player:GetDTString(STRING_FLAGS), function(text)
				cw.core:RunCommand("CharTakeFlags", player:Name(), text)
			end)
		end
	end

	if (charSetName and cw.player:HasFlags(cw.client, charSetName.access)) then
		options["#ScoreboardOptions_CharSetName"] = function()
			Derma_StringRequest(player:Name(), "#ScoreboardOptions_CharSetName_StringRequest", player:Name(), function(text)
				cw.core:RunCommand("CharSetName", player:Name(), text)
			end)
		end
	end

	if (charGiveItem and cw.player:HasFlags(cw.client, charGiveItem.access)) then
		options["#ScoreboardOptions_CharGiveItem"] = function()
			Derma_StringRequest(player:Name(), "#ScoreboardOptions_CharGiveItem_StringRequest", nil, function(text)
				cw.core:RunCommand("CharGiveItem", player:Name(), text)
			end)
		end
	end

	if (plySetGroup and cw.player:HasFlags(cw.client, plySetGroup.access)) then
		options["#ScoreboardOptions_PlySetGroup"] = {}
		options["#ScoreboardOptions_PlySetGroup"]["#ScoreboardOptions_PlySetGroup_SuperAdmin"] = function()
			cw.core:RunCommand("PlySetGroup", player:Name(), "superadmin")
		end
		options["#ScoreboardOptions_PlySetGroup"]["#ScoreboardOptions_PlySetGroup_Admin"] = function()
			cw.core:RunCommand("PlySetGroup", player:Name(), "admin")
		end
		options["#ScoreboardOptions_PlySetGroup"]["#ScoreboardOptions_PlySetGroup_Operator"] = function()
			cw.core:RunCommand("PlySetGroup", player:Name(), "operator")
		end
	end

	if (plyDemote and cw.player:HasFlags(cw.client, plyDemote.access)) then
		options["#ScoreboardOptions_PlyDemote"] = function()
			cw.core:RunCommand("PlyDemote", player:Name())
		end
	end

	local canUwhitelist = false
	local canWhitelist = false
	local unwhitelist = cw.command:FindByID("PlyUnwhitelist")
	local whitelist = cw.command:FindByID("PlyWhitelist")

	if (whitelist and cw.player:HasFlags(cw.client, whitelist.access)) then
		canWhitelist = true
	end

	if (unwhitelist and cw.player:HasFlags(cw.client, unwhitelist.access)) then
		canUnwhitelist = true
	end

	if (canWhitelist or canUwhitelist) then
		local areWhitelistFactions = false

		for k, v in pairs(faction.GetAll()) do
			if (v.whitelist) then
				areWhitelistFactions = true
			end
		end

		if (areWhitelistFactions) then
			if (canWhitelist) then
				options["#ScoreboardOptions_PlyWhitelist"] = {}
			end

			if (canUwhitelist) then
				options["#ScoreboardOptions_PlyUnWhitelist"] = {}
			end

			for k, v in pairs(faction.GetAll()) do
				if (v.whitelist) then
					if (options["#ScoreboardOptions_PlyWhitelist"]) then
						options["#ScoreboardOptions_PlyWhitelist"][k] = function()
							cw.core:RunCommand("PlyWhitelist", player:Name(), k)
						end
					end

					if (options["#ScoreboardOptions_PlyUnWhitelist"]) then
						options["#ScoreboardOptions_PlyUnWhitelist"][k] = function()
							cw.core:RunCommand("PlyUnwhitelist", player:Name(), k)
						end
					end
				end
			end
		end
	end
end

-- Called when information about a door is needed.
function GM:GetDoorInfo(door, information)
	local doorCost = config.Get("door_cost"):Get()
	local owner = cw.entity:GetOwner(door)
	local text = cw.entity:GetDoorText(door)
	local name = cw.entity:GetDoorName(door)

	if (information == DOOR_INFO_NAME) then
		if (cw.entity:IsDoorHidden(door)
		or cw.entity:IsDoorFalse(door)) then
			return false
		elseif (name == "") then
			return "#Doors_Name"
		else
			return name
		end
	elseif (information == DOOR_INFO_TEXT) then
		if (cw.entity:IsDoorUnownable(door)) then
			if (!cw.entity:IsDoorHidden(door)
			and !cw.entity:IsDoorFalse(door)) then
				if (text == "") then
					return "#Doors_Unownable"
				else
					return text
				end
			else
				return false
			end
		elseif (text != "") then
			if (!IsValid(owner)) then
				if (doorCost > 0) then
					return "#Doors_CanBePurchased"
				else
					return "#Doors_CanBeOwned"
				end
			else
				return text
			end
		elseif (IsValid(owner)) then
			if (doorCost > 0) then
				return "#Doors_HasBeenPurchased"
			else
				return "#Doors_HasBeenOwned"
			end
		elseif (doorCost > 0) then
			return "#Doors_CanBePurchased"
		else
			return "#Doors_CanBeOwned"
		end
	end
end

-- Called to get whether or not a post process is permitted.
function GM:PostProcessPermitted(class)
	return false
end

-- Called just after the translucent renderables have been drawn.
function GM:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingSkybox or bDrawingDepth) then return end

	if (!cw.core:IsChoosingCharacter()) then
		local eyePos = EyePos()
		local entities = ents.FindInSphere(eyePos, 256)

		if (#entities > 0) then
			local colorWhite = cw.option:GetColor("white")
			local colorInfo = cw.option:GetColor("information")
			local doorFont = cw.option:GetFont("large_3d_2d")
			local eyeAngles = EyeAngles()

			for k, v in ipairs(entities) do
				if (cw.entity:IsDoor(v)) then
					cw.core:DrawDoorText(v, eyePos, eyeAngles, doorFont, colorInfo, colorWhite)
				end
			end
		end
	end
end

-- Called when screen space effects should be rendered.
function GM:RenderScreenspaceEffects()
	if (IsValid(cw.client)) then
		local frameTime = FrameTime()
		local motionBlurs = {
			enabled = true,
			blurTable = {}
		}
		local color = 1

		if (!cw.core:IsChoosingCharacter()) then
			if (cw.limb:IsActive() and cw.event:CanRun("blur", "limb_damage")) then
				local headDamage = cw.limb:GetDamage(HITGROUP_HEAD)
				motionBlurs.blurTable["health"] = math.Clamp(1 - (headDamage * 0.01), 0, 1)
			elseif (cw.client:Health() <= 75) then
				if (cw.event:CanRun("blur", "health")) then
					motionBlurs.blurTable["health"] = math.Clamp(
						1 - ((cw.client:GetMaxHealth() - cw.client:Health()) * 0.01), 0, 1
					)
				end
			end

			if (cw.client:Alive()) then
				color = math.Clamp(color - ((cw.client:GetMaxHealth() - cw.client:Health()) * 0.01), 0, color)
			else
				color = 0
			end
		end

		if (cw.FishEyeTexture and cw.client:WaterLevel() > 2) then
			render.UpdateScreenEffectTexture()
				cw.FishEyeTexture:SetFloat("$envmap", 0)
				cw.FishEyeTexture:SetFloat("$envmaptint",	0)
				cw.FishEyeTexture:SetFloat("$refractamount", 0.1)
				cw.FishEyeTexture:SetInt("$ignorez", 1)
			render.SetMaterial(cw.FishEyeTexture)
			render.DrawScreenQuad()
		end

		cw.ColorModify["$pp_colour_brightness"] = 0
		cw.ColorModify["$pp_colour_contrast"] = 1
		cw.ColorModify["$pp_colour_colour"] = color
		cw.ColorModify["$pp_colour_addr"] = 0
		cw.ColorModify["$pp_colour_addg"] = 0
		cw.ColorModify["$pp_colour_addb"] = 0
		cw.ColorModify["$pp_colour_mulr"] = 0
		cw.ColorModify["$pp_colour_mulg"] = 0
		cw.ColorModify["$pp_colour_mulb"] = 0

		local systemTable = cw.system:FindByID("Color Modify")
		local overrideColorMod

		if (systemTable) then
			overrideColorMod = systemTable:GetModifyTable()
		end

		if (overrideColorMod and overrideColorMod.enabled) then
			cw.ColorModify["$pp_colour_brightness"] = overrideColorMod.brightness
			cw.ColorModify["$pp_colour_contrast"] = overrideColorMod.contrast
			cw.ColorModify["$pp_colour_colour"] = overrideColorMod.color
			cw.ColorModify["$pp_colour_addr"] = overrideColorMod.addr * 0.025
			cw.ColorModify["$pp_colour_addg"] = overrideColorMod.addg * 0.025
			cw.ColorModify["$pp_colour_addb"] = overrideColorMod.addg * 0.025
			cw.ColorModify["$pp_colour_mulr"] = overrideColorMod.mulr * 0.1
			cw.ColorModify["$pp_colour_mulg"] = overrideColorMod.mulg * 0.1
			cw.ColorModify["$pp_colour_mulb"] = overrideColorMod.mulb * 0.1
		else
			hook.Run("PlayerSetDefaultColorModify", cw.ColorModify)
		end

		hook.Run("PlayerAdjustColorModify", cw.ColorModify)
		hook.Run("PlayerAdjustMotionBlurs", motionBlurs)

		if (motionBlurs.enabled) then
			local addAlpha = nil

			for k, v in pairs(motionBlurs.blurTable) do
				if (!addAlpha or v < addAlpha) then
					addAlpha = v
				end
			end

			if (addAlpha) then
				DrawMotionBlur(math.Clamp(addAlpha, 0.1, 1), 1, 0)
			end
		end

		--[[
			Hotfix for ColorModify issues on OS X.
		--]]
		if (system.IsOSX()) then
			cw.ColorModify["$pp_colour_brightness"] = 0
			cw.ColorModify["$pp_colour_contrast"] = 1
		end

		DrawColorModify(cw.ColorModify)
	end
end

-- Called when the chat box is opened.
function GM:ChatBoxOpened() end

-- Called when the chat box is closed.
function GM:ChatBoxClosed(textTyped) end

-- Called when the chat box text has been typed.
function GM:ChatBoxTextTyped(text)
	if (cw.LastChatBoxText) then
		if (#cw.LastChatBoxText >= 25) then
			table.remove(cw.LastChatBoxText, 25)
		end
	else
		cw.LastChatBoxText = {}
	end

	cw.LastChatBoxCheck = 0

	if (text != "") then
		table.insert(cw.LastChatBoxText, 1, text)
	end
end

-- Called when the calc view table should be adjusted.
function GM:CalcViewAdjustTable(view) end

-- Called when the chat box info should be adjusted.
function GM:ChatBoxAdjustInfo(info) end

-- Called when the chat box text has changed.
function GM:ChatBoxTextChanged(previousText, newText) end

-- Called when the chat box has had a key code typed in.
function GM:ChatBoxKeyCodeTyped(code, text)
	if (!cw.LastChatBoxCheck) then
		cw.LastChatBoxCheck = 1
	end

	if (code == KEY_UP) then
		if (cw.LastChatBoxText) then
			cw.LastChatBoxCheck = math.Clamp(cw.LastChatBoxCheck + 1, 0, 25)
			if (cw.LastChatBoxCheck > #cw.LastChatBoxText) then
				cw.LastChatBoxCheck = 0
			end
			return cw.LastChatBoxText[cw.LastChatBoxCheck]
		end
	elseif (code == KEY_DOWN) then
		if (cw.LastChatBoxText) then
			cw.LastChatBoxCheck = math.Clamp(cw.LastChatBoxCheck - 1, 0, 25)
			if (cw.LastChatBoxCheck <= 0) then
				cw.LastChatBoxCheck = #cw.LastChatBoxText + 1
			end
			return cw.LastChatBoxText[cw.LastChatBoxCheck]
		end
	end
end

-- Called when a notification should be adjusted.
function GM:NotificationAdjustInfo(info)
	return true
end

-- Called when the local player's business item should be adjusted.
function GM:PlayerAdjustBusinessItemTable(itemTable) end

-- Called when the local player's class model info should be adjusted.
function GM:PlayerAdjustClassModelInfo(class, info) end

-- Called when the local player's headbob info should be adjusted.
function GM:PlayerAdjustHeadbobInfo(info)
	local bisDrunk = cw.player:GetDrunk()
	local scale

	if (CW_CONVAR_HEADBOBSCALE) then
		scale = math.Clamp(CW_CONVAR_HEADBOBSCALE:GetFloat(),0,1) or 1
	else
		scale = 1
	end

	if (cw.client:IsRunning()) then
		info.speed = (info.speed * 4) * scale
		info.roll = (info.roll * 2) * scale
	elseif (cw.client:GetVelocity():Length() > 0) then
		info.speed = (info.speed * 3) * scale
		info.roll = (info.roll * 1) * scale
	else
		info.roll = info.roll * scale
	end

	if (isDrunk) then
		info.speed = info.speed * math.min(isDrunk * 0.25, 4)
		info.yaw = info.yaw * math.min(isDrunk, 4)
	end
end

-- Called when the local player's motion blurs should be adjusted.
function GM:PlayerAdjustMotionBlurs(motionBlurs) end

-- Called when the local player's item menu should be adjusted.
function GM:PlayerAdjustMenuFunctions(itemTable, menuPanel, itemFunctions) end

-- Called when the local player's item functions should be adjusted.
function GM:PlayerAdjustItemFunctions(itemTable, itemFunctions) end

-- Called when the local player's default colorify should be set.
function GM:PlayerSetDefaultColorModify(colorModify) end

-- Called when the local player's colorify should be adjusted.
function GM:PlayerAdjustColorModify(colorModify) end

-- Called to get whether a player's target ID should be drawn.
function GM:ShouldDrawPlayerTargetID(player)
	return true
end

-- Called to get whether the local player's screen should fade black.
function GM:ShouldPlayerScreenFadeBlack()
	if (!cw.client:Alive() or cw.client:IsRagdolled(RAGDOLL_FALLENOVER)) then
		if (!hook.Run("PlayerCanSeeUnconscious")) then
			return true
		end
	end

	return false
end

-- Called when the menu background blur should be drawn.
function GM:ShouldDrawMenuBackgroundBlur()
	return true
end

-- Called when the character background blur should be drawn.
function GM:ShouldDrawCharacterBackgroundBlur()
	return true
end

-- Called when the character background should be drawn.
function GM:ShouldDrawCharacterBackground()
	return true
end

-- Called when the character fault should be drawn.
function GM:ShouldDrawCharacterFault(fault)
	return true
end

-- Called when the score board should be drawn.
function GM:HUDDrawScoreBoard()
	self.BaseClass:HUDDrawScoreBoard(player)

	local drawPendingScreenBlack = nil
	local drawCharacterLoading = nil
	local hasClientInitialized = cw.client:HasInitialized()
	local introTextSmallFont = cw.option:GetFont("intro_text_small")
	local colorWhite = cw.option:GetColor("white")
	local curTime = UnPredictedCurTime()
	local scrH = ScrH()
	local scrW = ScrW()

	if (cw.core:IsChoosingCharacter()) then
		if (hook.Run("ShouldDrawCharacterBackground")) then
			cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255))
		end

		hook.Run("HUDPaintCharacterSelection")
	elseif (!hasClientInitialized) then
		if (!cw.HasCharacterMenuBeenVisible
		and hook.Run("ShouldDrawCharacterBackground")) then
			drawPendingScreenBlack = true
		end
	end

	if (hasClientInitialized) then
		if (!cw.LastChatBoxCheck) then
			local loadingTime = hook.Run("GetCharacterLoadingTime")
			cw.CharacterLoadingDelay = loadingTime
			cw.LastChatBoxCheck = curTime + loadingTime
		end

		if (!cw.core:IsChoosingCharacter()) then
			cw.core:CalculateScreenFading()

			if (!cw.core:IsUsingCamera()) then
				hook.Run("HUDPaintForeground")
			end

			hook.Run("HUDPaintImportant")
		end

		if (cw.LastChatBoxCheck > curTime) then
			drawCharacterLoading = true
		elseif (!cw.CinematicScreenDone) then
			cw.core:DrawCinematicIntro(curTime)
			cw.core:DrawCinematicIntroBars()
		end
	end

	if (hook.Run("ShouldDrawBackgroundBlurs")) then
		cw.core:DrawBackgroundBlurs()
	end

	if (!cw.player:HasDataStreamed()) then
		if (!cw.DataStreamedAlpha) then
			cw.DataStreamedAlpha = 255
		end
	elseif (cw.DataStreamedAlpha) then
		cw.DataStreamedAlpha = math.Approach(cw.DataStreamedAlpha, 0, FrameTime() * 100)

		if (cw.DataStreamedAlpha <= 0) then
			cw.DataStreamedAlpha = nil
		end
	end

	if (cw.ClockworkIntroFadeOut) then
		local duration = 8
		local introImage = cw.option:GetKey("intro_image")

		if (introImage != "") then
			duration = 16
		end

		local timeLeft = math.Clamp(cw.ClockworkIntroFadeOut - curTime, 0, duration)
		local material = cw.ClockworkIntroOverrideImage or cw.ClockworkSplash
		local sineWave = math.sin(curTime)
		local height = 256
		local width = 512; --Patched
		local alpha = 384

		if (!cw.ClockworkIntroOverrideImage) then
			if (introImage != "" and timeLeft <= 8) then
				cw.ClockworkIntroWhiteScreen = curTime + (FrameTime() * 8)
				cw.ClockworkIntroOverrideImage = cw.core:GetMaterial(introImage..".png")
				surface.PlaySound("buttons/combine_button5.wav")
			end
		end

		if (timeLeft <= 3) then
			alpha = (255 / 3) * timeLeft
		end

		if (timeLeft == 0) then
			cw.ClockworkIntroFadeOut = nil
			cw.ClockworkIntroOverrideImage = nil
		end

		if (sineWave > 0) then
			width = width - (sineWave * 16)
			height = height - (sineWave * 4)
		end

		if (curTime <= cw.ClockworkIntroWhiteScreen) then
			cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(255, 255, 255, alpha))
		else
			local x, y = (scrW / 2) - (width / 2), (scrH * 0.3) - (height / 2)

			cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha))
			cw.core:DrawGradient(
				GRADIENT_CENTER, 0, y - 8, scrW, height + 16, Color(100, 100, 100, math.min(alpha, 150))
			)

			material:SetFloat("$alpha", alpha / 255)

			surface.SetDrawColor(255, 255, 255, alpha)
				surface.SetMaterial(material)
			surface.DrawTexturedRect(x, y, width, height)
		end

		drawPendingScreenBlack = nil
	end

	if (netvars.GetNetVar("NoMySQL") and netvars.GetNetVar("NoMySQL") != "") then
		cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255))
		draw.SimpleText(netvars.GetNetVar("NoMySQL"), introTextSmallFont, scrW / 2, scrH / 2, Color(179, 46, 49, 255), 1, 1)
	elseif (cw.DataStreamedAlpha and cw.DataStreamedAlpha > 0) then
		local textString = "#MainMenu_Loading"

		if (_file.Exists("materials/clockwork/logo/002.png", "GAME")) then
			surface.SetDrawColor(255, 255, 255, cw.DataStreamedAlpha)
			surface.SetMaterial(cw.core:GetMaterial("materials/clockwork/logo/002.png"))
			surface.DrawTexturedRect(scrW / 2 - 32, scrH / 2 - 16, 64, 32)
		end

		cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, cw.DataStreamedAlpha))
		draw.SimpleText(textString, introTextSmallFont, scrW / 2, scrH * 0.75, Color(colorWhite.r, colorWhite.g, colorWhite.b, cw.DataStreamedAlpha), 1, 1)

		drawPendingScreenBlack = nil
	end

	if (drawCharacterLoading) then
		hook.Run("HUDPaintCharacterLoading", math.Clamp((255 / cw.CharacterLoadingDelay) * (cw.LastChatBoxCheck - curTime), 0, 255))
	elseif (drawPendingScreenBlack) then
		cw.core:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, 255))
	end

	if (cw.LastChatBoxCheck) then
		if (!cw.CinematicInfoDrawn) then
			cw.core:DrawCinematicInfo()
		end

		if (!cw.CinematicBarsDrawn) then
			cw.core:DrawCinematicIntroBars()
		end
	end

	hook.Run("PostDrawBackgroundBlurs")
end

-- Called when the background blurs should be drawn.
function GM:ShouldDrawBackgroundBlurs()
	return true
end

-- Called just after the background blurs have been drawn.
function GM:PostDrawBackgroundBlurs()
	local introTextSmallFont = cw.option:GetFont("intro_text_small");	
	local backgroundColor = cw.option:GetColor("background")
	local colorWhite = cw.option:GetColor("white")
	local panelInfo = cw.CurrentFactionSelected
	local menuPanel = cw.core:GetRecogniseMenu()

	if (panelInfo and IsValid(panelInfo[1]) and panelInfo[1]:IsVisible()) then
		local factionTable = faction.FindByID(panelInfo[2])

		if (factionTable and factionTable.material) then
			if (_file.Exists("materials/"..factionTable.material..".png", "GAME")) then
				if (!panelInfo[3]) then
					panelInfo[3] = cw.core:GetMaterial(factionTable.material..".png")
				end

				if (cw.core:IsCharacterScreenOpen(true)) then
					surface.SetDrawColor(255, 255, 255, panelInfo[1]:GetAlpha())
					surface.SetMaterial(panelInfo[3])
					surface.DrawTexturedRect(panelInfo[1].x, panelInfo[1].y + panelInfo[1]:GetTall() + 16, 512, 256)
				end
			end
		end
	end

	if (cw.TitledMenu and IsValid(cw.TitledMenu.menuPanel)) then
		local menuTextTiny = cw.option:GetFont("menu_text_tiny")
		local menuPanel = cw.TitledMenu.menuPanel
		local menuTitle = cw.TitledMenu.title or ""

		cw.core:DrawSimpleGradientBox(2, menuPanel.x - 4, menuPanel.y - 4, menuPanel:GetWide() + 8, menuPanel:GetTall() + 8, backgroundColor)
		cw.core:OverrideMainFont(menuTextTiny)
			cw.core:DrawInfo(menuTitle, menuPanel.x, menuPanel.y, colorWhite, 255, true, function(x, y, width, height)
				return x, y - height - 4
			end)
		cw.core:OverrideMainFont(false)
	end

	cw.core:DrawDateTime()
end

-- Called just before a bar is drawn.
function GM:PreDrawBar(barInfo) end

-- Called just after a bar is drawn.
function GM:PostDrawBar(barInfo) end

-- Called when the top bars are needed.
function GM:GetBars(bars) end

-- Called when the top bars should be destroyed.
function GM:DestroyBars(bars) end

-- Called when the cinematic intro info is needed.
function GM:GetCinematicIntroInfo()
	return {
		credits = "#Schema_Credits:"..Schema:GetAuthor()..";",
		title = Schema:GetName(),
		text = Schema:GetDescription()
	}
end

-- Called when the character loading time is needed.
function GM:GetCharacterLoadingTime() return 8; end

-- Called when a player's HUD should be painted.
function GM:HUDPaintPlayer(player) end

-- Called when the HUD should be painted.
function GM:HUDPaint()
	if (!cw.core:IsChoosingCharacter() and !cw.core:IsUsingCamera()) then
		if (cw.event:CanRun("view", "damage") and cw.client:Alive()) then
			local maxHealth = cw.client:GetMaxHealth()
			local health = cw.client:Health()

			if (health < maxHealth * 0.5) then
				--hook.Run("DrawPlayerScreenDamage", 1 - ((1 / maxHealth) * health))
			end
		end

		if (cw.event:CanRun("view", "vignette") and config.GetVal("enable_vignette") and CW_CONVAR_VIGNETTE:GetInt() == 1) then
			hook.Run("DrawPlayerVignette")
		end

		self.BaseClass:HUDPaint()

		if (!cw.core:IsUsingTool()) then
			cw.core:DrawHints()
		end

		local weapon = cw.client:GetActiveWeapon()

		if (hook.Run("CanDrawCrosshair", weapon)) then
			local info = {
				color = Color(255, 255, 255, 255),
				x = ScrW() / 2,
				y = ScrH() / 2
			}

			hook.Run("GetPlayerCrosshairInfo", info)

			cw.CustomCrosshair = hook.Run("DrawPlayerCrosshair", info.x, info.y, info.color)
		else
			cw.CustomCrosshair = false
		end
	end
end

function GM:CanDrawCrosshair(weapon)
	return false
end

-- Called when the local player's crosshair info is needed.
function GM:GetPlayerCrosshairInfo(info)
	if (config.GetVal("use_free_aiming")) then
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

-- Called when the local player's crosshair should be drawn.
function GM:DrawPlayerCrosshair(x, y, color)
	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	surface.DrawRect(x, y, 2, 2)
	surface.DrawRect(x, y + 9, 2, 2)
	surface.DrawRect(x, y - 9, 2, 2)
	surface.DrawRect(x + 9, y, 2, 2)
	surface.DrawRect(x - 9, y, 2, 2)

	return true
end

-- Called when a player starts using voice.
function GM:PlayerStartVoice(player)
	if (config.Get("local_voice"):Get()) then
		if (player:IsRagdolled(RAGDOLL_FALLENOVER) or !player:Alive() or !cw.player:HasFlags(player, "x")) then
			return
		end
	end

	if (self.BaseClass and self.BaseClass.PlayerStartVoice) then
		self.BaseClass:PlayerStartVoice(player)
	end
end

-- Called to check if a player does have an flag.
function GM:PlayerDoesHaveFlag(player, flag)
	if (string.find(config.GetVal("default_flags"), flag)) then
		return true
	end
end

-- Called to check if a player does recognise another player.
function GM:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
	return realValue
end

-- Called when a player's name should be shown as unrecognised.
function GM:PlayerCanShowUnrecognised(player, x, y, color, alpha, flashAlpha)
	return true
end

-- Called when the target player's name is needed.
function GM:GetTargetPlayerName(player)
	return player:Name()
end

-- Called when a player begins typing.
function GM:StartChat(team)
	return true
end

-- Called when a player says something.
function GM:OnPlayerChat(player, text, teamOnly, playerIsDead)
	if (!IsValid(player)) then
		chatbox.AddText(nil, "[color=red]#Console[/color]: "..text, {icon = "icon16/shield.png"})
	end

	return true
end

-- Called when chat text is received from the server
function GM:ChatText(index, name, text, class)
	return true
end

-- Called when the scoreboard should be created.
function GM:CreateScoreboard() end

-- Called when the scoreboard should be shown.
function GM:ScoreboardShow()
	if (cw.client:HasInitialized()) then
		if (hook.Run("CanShowTabMenu")) then
			cw.menu:Create()
			cw.menu:SetOpen(true)
			cw.menu.holdTime = UnPredictedCurTime() + 0.5
		end
	end
end

-- Called when the scoreboard should be hidden.
function GM:ScoreboardHide()
	if (cw.client:HasInitialized() and cw.menu.holdTime) then
		if (UnPredictedCurTime() >= cw.menu.holdTime) then
			if (hook.Run("CanShowTabMenu")) then
				cw.menu:SetOpen(false)
			end
		end
	end
end

-- Called before the tab menu is shown.
function GM:CanShowTabMenu() return true end

-- Overriding Garry's "grab ear" animation.
function GM:GrabEarAnimation(player) end

-- Called before the item entity's target ID is drawn. Return false to stop default draw.
function GM:PaintItemTargetID(x, y, alpha, itemTable) return true end

function GM:OnHookError(name, isGM, message)
	LocalPlayer().ErrorBoxTime = CurTime() + 3
end
