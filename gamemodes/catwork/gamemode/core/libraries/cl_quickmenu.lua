--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("quickmenu", cw)
cw.quickmenu.stored = cw.quickmenu.stored or {}
cw.quickmenu.categories = cw.quickmenu.categories or {}

-- A function to add a quick menu callback.
function cw.quickmenu:AddCallback(name, category, GetInfo, OnCreateMenu)
	if (category) then
		if (!self.categories[category]) then
			self.categories[category] = {}
		end

		self.categories[category][name] = {
			OnCreateMenu = OnCreateMenu,
			GetInfo = GetInfo,
			name = name
		}
	else
		self.stored[name] = {
			OnCreateMenu = OnCreateMenu,
			GetInfo = GetInfo,
			name = name
		}
	end

	return name
end

-- A function to add a command quick menu callback.
function cw.quickmenu:AddCommand(name, category, command, options)
	return self:AddCallback(name, category, function()
		local commandTable = cw.command:FindByID(command)

		if (commandTable) then
			return {
				toolTip = commandTable.tip,
				Callback = function(option)
					cw.core:RunCommand(command, option)
				end,
				options = options
			}
		else
			return false
		end
	end)
end

cw.quickmenu:AddCallback("#QuickMenu_FallOver", nil, function()
	local commandTable = cw.command:FindByID("CharFallOver")

	if (commandTable) then
		return {
			toolTip = commandTable.tip,
			Callback = function(option)
				cw.core:RunCommand("CharFallOver")
			end
		}
	else
		return false
	end
end)

cw.quickmenu:AddCallback("#QuickMenu_Description", nil, function()
	local commandTable = cw.command:FindByID("CharPhysDesc")

	if (commandTable) then
		return {
			toolTip = commandTable.tip,
			Callback = function(option)
				cw.core:RunCommand("CharPhysDesc")
			end
		}
	else
		return false
	end
end);
