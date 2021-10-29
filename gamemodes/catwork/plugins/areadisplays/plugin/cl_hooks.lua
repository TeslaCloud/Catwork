--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when the client initializes.
function cwAreaDisplays:Initialize()
	CW_CONVAR_SHOWAREAS = cw.core:CreateClientConVar("cwShowAreas", 1, true, true)
end

-- Called when the local player has entered an area.
function cwAreaDisplays:PlayerEnteredArea(name, minimum, maximum)
	netstream.Start("EnteredArea", {name, minimum, maximum})
end

-- Called when the local player has exited an area.
function cwAreaDisplays:PlayerExitedArea(name, minimum, maximum)
	self.currentAreaDisplay = nil
end

-- Called just after the translucent renderables have been drawn.
function cwAreaDisplays:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingSkybox or bDrawingDepth) then return end

	for k, v in pairs(self.activeDisplays) do
		if (v.class == "3D") then
			self:DrawDisplay3D(v)
			self:CalculateDisplayAlpha(v, k)
		end
	end
end

-- Called when the foreground HUD should be painted.
function cwAreaDisplays:HUDPaintForeground()
	local info = {x = ScrW() * 0.1, y = ScrH() * 0.6}

	for k, v in pairs(self.activeDisplays) do
		if (v.class == "Scrolling") then
			self:DrawDisplayScrolling(v, info)
			self:CalculateDisplayAlpha(v, k)
		end
	end
end

-- Called each tick.
function cwAreaDisplays:Tick()
	local lastAreaDisplay = self.currentAreaDisplay
	local bDidLeave = false
	local curTime = UnPredictedCurTime()

	if (!IsValid(cw.client) or !cw.client:HasInitialized()) then
		return
	end

	if (self.nextCheckAreaDisplays and curTime < self.nextCheckAreaDisplays) then
		return
	end

	self.nextCheckAreaDisplays = curTime + 1

	for k, v in pairs(self.storedList) do
		if (cw.entity:IsInBox(cw.client, v.minimum, v.maximum)) then

			if (self.currentAreaDisplay != v.name) then
				local bCalledHooks = self:HandleAreaTable(v, k)

				if (!bCalledHooks) then
					hook.Run(
						"PlayerExitedArea", lastAreaDisplay, v.name
					)
				end

				return
			end
		elseif (lastAreaDisplay == v.name) then
			bDidLeave = v.name
		end
	end

	if (bDidLeave) then
		hook.Run("PlayerExitedArea", bDidLeave)
	end
end
