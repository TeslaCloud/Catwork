--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

cw = cw or {}

do
	cw.startTime = os.clock()
	local startTime = cw.startTime

	local function SafeRequire(mod)
		local success, value = pcall(require, mod)

		if (!success) then
			ErrorNoHalt("[Catwork] Critical Error - Failed to open '"..mod.."' module!\n")

			return false
		end

		return true
	end

	if (cw and cw.core) then
		MsgC(Color(0, 255, 100, 255), "[Catwork] Change detected! Refreshing...\n")
	else
		MsgC(Color(0, 255, 100, 255), "[Catwork] Framework is initializing...\n")
	end

	if (!SafeRequire("catio")) then
		ErrorNoHalt("[Catwork] catio module has failed to load!\nAborting startup...\n")

		return
	else
		fileio = catio
	end

	if (!cw.WatchDogAvailable and system.IsWindows()) then
		if (file.Exists("lua/bin/gmsv_watchdog_win32.dll", "GAME")) then
			print("[Catwork] Loading Watch Dog file monitoring tools...")

			local success = SafeRequire("watchdog")

			if (success) then
				timer.Create("WatchDogUpdater", (1 / 16), 0, function()
					WatchdogUpdate()
				end)

				hook.Add("WatchDogFileChanged", "Printer", function(fileName)
					-- fileName is relative to garrysmod/gamemodes/
					print("[Watchdog] "..fileName)
				end)

				-- lmao
				cw.WatchDogAvailable = true
			else
				ErrorNoHalt("[Catwork] Failed to load Watchdog!\nYou do not appear to have MS Visual C++ 2015 installed!\n")
			end
		end
	end

	function GetTimeSinceBoot()
		return math.Round(os.clock() - startTime, 3)
	end

	function IsWatchdogAvailable()
		return cw.WatchDogAvailable
	end

	-- No need to re-include the stuff that doesn't change.
	if (!string.utf8len or !pon or !netstream) then
		AddCSLuaFile("thirdparty/utf8.lua")
		AddCSLuaFile("thirdparty/pon.lua")
		AddCSLuaFile("thirdparty/netstream.lua")
		AddCSLuaFile("thirdparty/md5.lua")
	end

	AddCSLuaFile("cl_init.lua")

	--[[
		Include pON and UTF-8 library.
	--]]
	if (!string.utf8len or !pon or !netstream or !vnet) then
		include("thirdparty/utf8.lua")
		include("thirdparty/pon.lua")
		include("thirdparty/netstream.lua")
		include("thirdparty/md5.lua")
	end

	include("shared.lua")

	if (cw and cwBootComplete) then
		MsgC(Color(0, 255, 100, 255), "[Catwork] AutoRefresh handled serverside in "..GetTimeSinceBoot().. " second(s)\n")
	else
		local version = cw.core:GetVersionBuild()

		MsgC(Color(0, 255, 100, 255), "[Catwork] Framework version ["..version.."] loading took "..GetTimeSinceBoot().. " second(s)\n")

		-- For benchmarking.
		cw.LastBootTime = startTime
	end
end

_G["cwBootComplete"] = true
