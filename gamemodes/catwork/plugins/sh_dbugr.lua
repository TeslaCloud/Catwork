--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

PLUGIN.name = "DBugR Support"
PLUGIN.author = "Mr. Meow and NightAngel"
PLUGIN.description = "Provides plugin hook detours for DBugR."
PLUGIN.compatibility = "1.2"

if (DBugR) then
	local hooksDetoured = false

	function PLUGIN:ClockworkLoaded()
		if (hooksDetoured) then return end

		for hookName, hooks in pairs(plugin.GetCache()) do
			for k, v in ipairs(hooks) do
				local name = "N/A"
				local func = v[1]

				if (v[2] and v[2].GetName) then
					name = v[2]:GetName()
				elseif (v.id) then
					name = v.id
				end

				hooks[k][1] = DBugR.Util.Func.AttachProfiler(func, function(time)
					DBugR.Profilers.Hook:AddPerformanceData(name..":"..hookName, time, func)
				end)
			end
		end

		DBugR.Print("Catwork plugin hooks detoured!")

		hooksDetoured = true
	end
end
