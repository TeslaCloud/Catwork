--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ACCESS_FLAG = "a"

if (CLIENT) then
	local SYSTEM = cw.system:New("Color Modify")
	SYSTEM.access = ACCESS_FLAG
	SYSTEM.toolTip = "Edit the schema's global color to suit your needs."
	SYSTEM.doesCreateForm = false
	cw.OverrideColorMod = cw.core:RestoreSchemaData("color", false)

	-- A function to get the modification values.
	function SYSTEM:GetModifyTable()
		return cw.OverrideColorMod
	end

	-- A function to get the key info.
	function SYSTEM:GetKeyInfo(key)
		if (key == "brightness") then
			return {name = "Brightness", minimum = -2, maximum = 2, decimals = 2}
		elseif (key == "contrast") then
			return {name = "Contrast", minimum = 0, maximum = 10, decimals = 2}
		elseif (key == "color") then
			return {name = "Color", minimum = 0, maximum = 5, decimals = 2}
		elseif (key == "addr") then
			return {name = "Add Red", minimum = 0, maximum = 255, decimals = 0}
		elseif (key == "addg") then
			return {name = "Add Green", minimum = 0, maximum = 255, decimals = 0}
		elseif (key == "addb") then
			return {name = "Add Blue", minimum = 0, maximum = 255, decimals = 0}
		elseif (key == "mulr") then
			return {name = "Multiply Red", minimum = 0, maximum = 255, decimals = 0}
		elseif (key == "mulg") then
			return {name = "Multiply Green", minimum = 0, maximum = 255, decimals = 0}
		elseif (key == "mulb") then
			return {name = "Multiply Blue", minimum = 0, maximum = 255, decimals = 0}
		end
	end

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		local infoText = vgui.Create("cwInfoText", systemPanel)
			infoText:SetText("Changing these values will affect the color for all players.")
			infoText:SetInfoColor("blue")
			infoText:DockMargin(0, 0, 0, 8)
		systemPanel.panelList:AddItem(infoText)

		local infoText = vgui.Create("cwInfoText", systemPanel)
			infoText:SetText("Please note that this is for advanced users only.")
			infoText:SetInfoColor("orange")
			infoText:DockMargin(0, 0, 0, 8)
		systemPanel.panelList:AddItem(infoText)

		self.colorModForm = vgui.Create("DForm", systemPanel)
			self.colorModForm:SetName("Color")
			self.colorModForm:SetPadding(4)
		systemPanel.panelList:AddItem(self.colorModForm)

		local checkBox = self.colorModForm:CheckBox("Enabled")
		checkBox.OnChange = function(checkBox, value)
			if (value != cw.OverrideColorMod.enabled) then
				netstream.Start("SystemColSet", {key = "enabled", value = value})
			end
		end
		checkBox:SetValue(cw.OverrideColorMod.enabled)

		for k, v in pairs(cw.OverrideColorMod) do
			if (k != "enabled") then
				local info = self:GetKeyInfo(k)
				local numSlider = self.colorModForm:NumSlider(info.name, nil, info.minimum, info.maximum, info.decimals)
				numSlider.OnValueChanged = function(numSlider, value)
					if (value != cw.OverrideColorMod[k]) then
						local timerName = "ColorModifySet: "..k
						timer.Create(timerName, 1, 0, function()
							if (!input.IsMouseDown(MOUSE_LEFT)) then
								netstream.Start("SystemColSet", {key = k, value = value})
								timer.Remove(timerName)
							end
						end)
					end
				end
				numSlider:SetValue(v)
			end
		end
	end

	SYSTEM:Register()

	netstream.Hook("SystemColSet", function(data)
		cw.OverrideColorMod[data.key] = data.value
			cw.core:SaveSchemaData("color", cw.OverrideColorMod)
		local systemTable = cw.system:FindByID("Color Modify")

		if (systemTable) then
			systemTable:Rebuild()
		end
	end)

	netstream.Hook("SystemColGet", function(data)
		cw.OverrideColorMod = data
		cw.core:SaveSchemaData("color", cw.OverrideColorMod)
	end)
else
	netstream.Hook("SystemColSet", function(player, data)
		if (cw.player:HasFlags(player, "a")) then
			cw.OverrideColorMod[data.key] = data.value
			cw.core:SaveSchemaData("color", cw.OverrideColorMod)
			netstream.Start(nil, "SystemColSet", data)
		end
	end)
end

if (!cw.OverrideColorMod) then
	cw.OverrideColorMod = {
		brightness = 0,
		contrast = 1,
		enabled = false,
		color = 1,
		mulr = 0,
		mulg = 0,
		mulb = 0,
		addr = 0,
		addg = 0,
		addb = 0,
	}
end
