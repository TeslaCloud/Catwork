-- All credit for the emplacement gun entity goes to Zaubermuffin and his/her affiliates.
-- His/her steam profile: http://steamcommunity.com/id/zaubermuffin

-- ZAR3
-- Copyright (c) 2012 Zaubermuffin
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- Based on the original Bouncy Ball.

include('shared.lua')

-- Import the function(s) and remove their globals.
local FindAR3At = ZAR3_FindAR3At
ZAR3_FindAR3At, ZAR3_AR3Position = nil, nil

local AR3 = nil -- The AR3 we are currently using.
local Shooting = false -- If we are shooting or not

-- This message is used for both, getting in and out of AR3s.
local function ZAR3_S(msg)
	AR3 = msg:ReadEntity()

	local wep = LocalPlayer():GetActiveWeapon()
	local vm = LocalPlayer():GetViewModel()	

	-- We won't mess around with you.
	if not IsValid(wep) then
		-- Worst case: Make us visible again.
		if IsValid(vm) then
			vm:SetNoDraw(false)
		end
		return
	end

	if IsValid(AR3) then
		vm:SetNoDraw(true)
		-- "nicer", but way buggier and breaking quite a lot:
--~ 		-- Holster it
--~ 		wep:SendWeaponAnim(ACT_VM_HOLSTER)
--~ 		-- Do we need to multiply with the playback rate? I doubt it
--~ 		-- Hide the weapon as soon as it's gone.
--~ 		-- I'd like to keep it, but the repeat-this-sequence glitch is annoying.
--~ 		timer.Simple(vm:SequenceDuration(), function() local vm = LocalPlayer():GetViewModel() if IsValid(vm) then vm:SetNoDraw(true) end end)
	else
		-- Make the weapon visible again.
		if IsValid(vm) then
			vm:SetNoDraw(false)
		end

		-- Play the "draw" animation.
		wep:SendWeaponAnim(ACT_VM_DRAW)
		-- No stuff until this has been done.
		wep:SetNextPrimaryFire(math.max(CurTime() + wep:SequenceDuration(), wep:GetNextPrimaryFire()))
		wep:SetNextSecondaryFire(math.max(CurTime() + wep:SequenceDuration(), wep:GetNextSecondaryFire()))
		-- There seems to be a repeating-glitch, somehow, avoid that. Yes, if you start shooting it will break the animation, but it's better than having to re-draw all the time.
		timer.Simple(vm:SequenceDuration(), function() if IsValid(wep) and wep == LocalPlayer():GetActiveWeapon() then wep:SendWeaponAnim(ACT_VM_IDLE) end end)
	end
end
usermessage.Hook('ZAR3_S', ZAR3_S)

function ENT:Draw()
	self:DrawModel()
end

-- Override CreateMove - because there seems to be no way to intercept attacks on the server,
-- we have to "catch" them on the client and tell the entity that way.
local function CreateMove(cmd)
	if IsValid(AR3) then
		if cmd:KeyDown(IN_ATTACK) then
			cmd:SetButtons(cmd:GetButtons() - IN_ATTACK)
			if not Shooting then
				Shooting = true
				RunConsoleCommand('zar3_attack', '1')
			end
		elseif Shooting then
			Shooting = false
			RunConsoleCommand('zar3_attack', '0')
		end

		if cmd:KeyDown(IN_ATTACK2) then
			cmd:SetButtons(cmd:GetButtons() - IN_ATTACK2)
		end
	end
end
hook.Add('CreateMove', '_ZAR3CreateMove', CreateMove)

-- Hide the ammo while we're operating one of these.
local function HUDShouldDraw(name)
	if IsValid(AR3) and name == 'CHudAmmo' then
		return false
	end
end
hook.Add('HUDShouldDraw', '_ZAR3HUDShouldDraw', HUDShouldDraw)