--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

PLUGIN.name = "Weapon Selector"
PLUGIN.description = "Provides a weapon selector replacement."
PLUGIN.author = "Mr. Meow"
PLUGIN.compatibility = "1.2"
PLUGIN:SetGlobalAlias("cwWeaponSelect")

local function fixTable(tab)
	local newTable = {}

	for k, v in pairs(tab) do
		table.insert(newTable, v)
	end

	return newTable
end

if (SERVER) then
	concommand.Add("selectweapon", function(player, command, arguments)
		local weapon = fixTable(player:GetWeapons())[tonumber(arguments[1]) or 1]

		if (IsValid(weapon)) then
			player:SelectWeapon(weapon:GetClass())
		end
	end)

	return
end

PLUGIN.WeaponIndex = PLUGIN.WeaponIndex or 1
PLUGIN.IsOpen = PLUGIN.IsOpen or false
PLUGIN.OpenTime = PLUGIN.OpenTime or 0
PLUGIN.CurAlpha = PLUGIN.CurAlpha or 255
PLUGIN.Display = PLUGIN.Display or {}
PLUGIN.IndexOffset = PLUGIN.IndexOffset or nil
PLUGIN.ForcedDir = nil
PLUGIN.ForcedIndex = nil

local function relativeClamp(n, min, max)
	if (n > max) then
		return relativeClamp(n - max, min, max)
	elseif (n < min) then
		return relativeClamp(max - n, min, max)
	end

	return n
end

local function safeIndex(tab, idx)
	return tab[relativeClamp(idx, 1, #tab)]
end

-- A function to draw a weapon's information.
function PLUGIN:DrawWeaponInformation(itemTable, weapon, x, y, alpha)
	if (!itemTable or !IsValid(weapon)) then return end

	local informationColor = cw.option:GetColor("information")
	local clipTwoAmount = cw.client:GetAmmoCount(weapon:GetSecondaryAmmoType())
	local clipOneAmount = cw.client:GetAmmoCount(weapon:GetPrimaryAmmoType())
	local mainTextFont = cw.option:GetFont("main_text")
	local secondaryAmmo = nil
	local primaryAmmo = nil
	local clipTwo = weapon:Clip2()
	local clipOne = weapon:Clip1()

	if (!weapon.Primary or !weapon.Primary.ClipSize or weapon.Primary.ClipSize > 0) then
		if (clipOne >= 0) then
			primaryAmmo = "Primary: "..clipOne.."/"..clipOneAmount.."."
		end
	end

	if (!weapon.Secondary or !weapon.Secondary.ClipSize or weapon.Secondary.ClipSize > 0) then
		if (clipTwo >= 0) then
			secondaryAmmo = "Secondary: "..clipTwo.."/"..clipTwoAmount.."."
		end
	end

	if (!weapon.Instructions) then weapon.Instructions = ""; end
	if (!weapon.Purpose) then weapon.Purpose = ""; end
	if (!weapon.Contact) then weapon.Contact = ""; end
	if (!weapon.Author) then weapon.Author = ""; end

	if (itemTable or primaryAmmo or secondaryAmmo or (weapon.DrawWeaponInfoBox
	and (weapon.Author != "" or weapon.Contact != "" or weapon.Purpose != ""
	or weapon.Instructions != ""))) then
		local text = "<font="..mainTextFont..">"
		local textColor = "<color=255,255,255,255>"
		local titleColor = "<color=230,230,230,255>"

		if (informationColor) then
			titleColor = "<color="..informationColor.r..","..informationColor.g..","..informationColor.b..",255>"
		end

		if (itemTable and itemTable.description != "") then
			text = text..titleColor..cw.lang:TranslateText("#SWEPS_Description"):utf8upper().."</color>\n"..textColor..config.Parse(itemTable.description).."</color>\n"
		end

		if (primaryAmmo or secondaryAmmo) then
			text = text..titleColor..cw.lang:TranslateText("#SWEPS_Ammunition"):utf8upper().."</color>\n"

			if (secondaryAmmo) then
				text = text..textColor..secondaryAmmo.."</color>\n"
			end

			if (primaryAmmo) then
				text = text..textColor..primaryAmmo.."</color>\n"
			end
		end

		if (weapon.Instructions != "") then
			text = text..titleColor..cw.lang:TranslateText("#SWEPS_Instructions"):utf8upper().."</color>\n"..textColor..weapon.Instructions.."</color>\n"
		end

		if (weapon.Purpose != "") then
			text = text..titleColor..cw.lang:TranslateText("#SWEPS_Purpose"):utf8upper().."</color>\n"..textColor..weapon.Purpose.."</color>\n"
		end

		if (weapon.Contact != "") then
			text = text..titleColor..cw.lang:TranslateText("#SWEPS_Contact"):utf8upper().."</color>\n"..textColor..weapon.Contact.."</color>\n"
		end

		if (weapon.Author != "") then
			text = text..titleColor..cw.lang:TranslateText("#SWEPS_Author"):utf8upper().."</color>\n"..textColor..weapon.Author.."</color>\n"
		end

		weapon.InfoMarkup = markup.Parse(text.."</font>", 248)
		cw.core:OverrideMarkupDraw(weapon.InfoMarkup)

		local weaponMarkupHeight = weapon.InfoMarkup:GetHeight()
		local realY = y - (weaponMarkupHeight / 2)
		local info = {
			drawBackground = true,
			weapon = weapon,
			height = weaponMarkupHeight + 8,
			width = 260,
			alpha = alpha,
			x = x - 4,
			y = realY
		}

		hook.Run("PreDrawWeaponSelectionInfo", info)

		if (info.drawBackground) then
			SLICED_LARGE_DEFAULT:Draw(x - 8, realY, info.width + 16, info.height + 16, 8, Color(255, 255, 255, alpha))
		end

		if (weapon.InfoMarkup) then
			weapon.InfoMarkup:Draw(x + 4, realY + 4, nil, nil, alpha)
		end
	end
end

function PLUGIN:HUDShouldDraw(element)
	if (element == "CHudWeaponSelection") then
		return false
	end
end

function PLUGIN:HUDPaint()
	if (self.IsOpen) then
		local x, y = ScrW() - 306, ScrH() / 2 - 84, 200
		local w, h = 200, 186

		if (istable(self.Display) and istable(self.Display[3])) then
			local curWeapon = self.Display[3].weapon

			self:DrawWeaponInformation(item.GetByWeapon(curWeapon), curWeapon, x - 300, y + 85, self.CurAlpha)
		end

		if (self.IndexOffset and self.IndexOffset != 0) then
			local dir -- true = down, false = up

			if (self.ForcedDir != nil) then
				dir = self.ForcedDir
			else
				dir = (self.IndexOffset == math.abs(self.IndexOffset))
			end

			local frameTime = FrameTime() * 24
			local targets = {}

			if (!self.Display[1].target) then
				local idx

				if (self.ForcedIndex != nil) then
					idx = self.ForcedIndex
				else
					idx = self.WeaponIndex - ((dir and self.IndexOffset - 1) or self.IndexOffset + 1)
				end

				targets = self:MakeDisplay(idx, true)
			end

			for k, v in ipairs(self.Display) do
				if (!v.target) then
					local next = safeIndex(targets, (dir and k - 1) or k + 1)

					-- Make first and last weapons look nicer when scrolling.
					if (dir and k == 1) then
						v.y = targets[5].y + 50
						v.scale = v.scale / 2
					elseif (!dir and k == 5) then
						v.y = targets[1].y - 50
						v.scale = v.scale / 2
					end

					v.target = next.y
					v.scaleTarget = next.scale
					v.weapon = next.weapon
				end

				if (math.abs(v.y - v.target) < 1) then
					self.IndexOffset = (dir and self.IndexOffset - 1) or self.IndexOffset + 1
					self:MakeDisplay(self.WeaponIndex - self.IndexOffset)

					self.ForcedDir = nil
					self.ForcedIndex = nil

					break
				end

				local absOffset = math.Clamp(math.abs(self.IndexOffset), 1, 100)

				self.Display[k].y = Lerp(frameTime * absOffset, v.y, v.target)
				self.Display[k].scale = Lerp(frameTime * absOffset, v.scale, v.scaleTarget)
			end
		end

		render.SetScissorRect(x, y, x + w, y + h, true)

		draw.RoundedBox(0, x, y, w, h, Color(40, 40, 40, 100 * (self.CurAlpha / 255)))

		for k, v in ipairs(self.Display) do
			local textColor = Color(255, 255, 255, self.CurAlpha * v.scale)

			if (v.scale == 1 or v.scaleTarget == 1) then
				textColor = cw.option:GetColor("information")
			end

			surface.DrawScaledText((IsValid(v.weapon) and v.weapon:GetPrintName():utf8upper()) or "Unknown Weapon", cw.option:GetFont("menu_text_tiny"), v.x, v.y, v.scale, textColor)
		end

		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function PLUGIN:Think()
	if (self.IsOpen) then
		if (CurTime() - self.OpenTime > 5) then
			self.CurAlpha = math.Clamp(self.CurAlpha - 2, 0, 255)

			if (self.CurAlpha == 0) then
				self.IsOpen = false
			end
		else
			self.CurAlpha = Lerp(FrameTime() * 16, self.CurAlpha, 255)
		end
	end
end

function PLUGIN:MakeDisplay(index, tab)
	local clientWeapons = fixTable(cw.client:GetWeapons())
	local count = table.Count(clientWeapons)
	local offsetY = 32
	local result = {}

	for i = -2, 2 do
		local scale = 1 - math.abs(i * 0.25)

		table.insert(result, {
			weapon = safeIndex(clientWeapons, index + i),
			scale = scale,
			x = ScrW() - 300,
			y = ScrH() / 2 - 90 + offsetY - 36 * scale / 2
		})

		offsetY = offsetY + 32
	end

	if (tab) then
		return result
	else
		self.Display = result
	end
end

function PLUGIN:OnWeaponIndexChange(oldIndex, index)
	self.IsOpen = true
	self.OpenTime = CurTime()

	if (#self.Display == 0) then
		self:MakeDisplay(index)
	else
		self.IndexOffset = index - oldIndex

		local weaponCount = table.Count(cw.client:GetWeapons())

		if ((self.WeaponIndex == 1 and oldIndex == weaponCount) or (self.WeaponIndex == weaponCount and oldIndex == 1)) then
			self.ForcedDir = !(self.IndexOffset == math.abs(self.IndexOffset))
			self.ForcedIndex = self.WeaponIndex
			self.IndexOffset = (self.ForcedDir and 1) or -1
		end
	end
end

function PLUGIN:ShouldWeaponMenuOpen(player, oldIndex, newIndex)
	if (player:KeyDown(IN_ATTACK)) then
		return false
	end
end

function PLUGIN:OnWeaponSelected(index)
	self.IsOpen = false
	self.CurAlpha = 0
end

do
	local prevIndex = 0

	function PLUGIN:PlayerBindPress(player, bind, bIsPressed)
		local weapon = player:GetActiveWeapon()

		if (!player:InVehicle() and IsValid(weapon)) then
			local weaponClass = weapon:GetClass()
			local weaponCount = table.Count(player:GetWeapons())
			local oldIndex = self.WeaponIndex
			bind = bind:lower()

			if (bind:find("invprev") and hook.Run("ShouldWeaponMenuOpen", player, oldIndex, self.WeaponIndex) != false and bIsPressed) then
				if (self.IsOpen) then
					self.WeaponIndex = relativeClamp(self.WeaponIndex - 1, 1, weaponCount)

					hook.Run("OnWeaponIndexChange", oldIndex, self.WeaponIndex)
				else
					self.IsOpen = true
					self.OpenTime = CurTime()

					hook.Run("OnWeaponIndexChange", self.WeaponIndex, self.WeaponIndex)
				end

				return true
			elseif (bind:find("invnext") and hook.Run("ShouldWeaponMenuOpen", player, oldIndex, self.WeaponIndex) != false and bIsPressed) then
				if (self.IsOpen) then
					self.WeaponIndex = relativeClamp(self.WeaponIndex + 1, 1, weaponCount)

					hook.Run("OnWeaponIndexChange", oldIndex, self.WeaponIndex)
				else
					self.IsOpen = true
					self.OpenTime = CurTime()

					hook.Run("OnWeaponIndexChange", self.WeaponIndex, self.WeaponIndex)
				end

				return true
			elseif (bind:find("slot") and hook.Run("ShouldWeaponMenuOpen", player, oldIndex, self.WeaponIndex) != false and bIsPressed) then
				local slot = tonumber(string.match(bind, "slot(%d)")) or 1

				if (IsValid(cpgui_radiomenu)) then
					cpgui_radiomenu:CallMenu(slot)

					return
				end

				if (self.IsOpen) then
					local index = tonumber(bind:sub(5, bind:len())) or 1
					local classicScroll = false

					if (index == prevIndex or (index == 2 and prevIndex == 1) or (index == 1 and prevIndex == 2)) then
						if (index == 1) then
							self.WeaponIndex = self.WeaponIndex - 1
						else
							self.WeaponIndex = self.WeaponIndex + 1
						end

						self.WeaponIndex = relativeClamp(self.WeaponIndex, 1, weaponCount)

						classicScroll = true
					end

					prevIndex = index

					if (!classicScroll) then
						index = relativeClamp(index, 1, weaponCount)

						self.WeaponIndex = index
					else
						index = self.WeaponIndex
					end

					hook.Run("OnWeaponIndexChange", oldIndex, index)
				else
					self.IsOpen = true
					self.OpenTime = CurTime()

					hook.Run("OnWeaponIndexChange", self.WeaponIndex, self.WeaponIndex)
				end

				return true
			elseif (bind:find("attack") and self.IsOpen and bIsPressed) then
				RunConsoleCommand("selectweapon", self.WeaponIndex)

				hook.Run("OnWeaponSelected", self.WeaponIndex)

				return true
			end
		end
	end
end
