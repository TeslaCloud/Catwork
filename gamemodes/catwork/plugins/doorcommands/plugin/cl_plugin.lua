--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

config.AddToSystem("Doors Default Hidden", "default_doors_hidden", "Set whether doors are hidden and unownable by default.")
config.AddToSystem("Doors Save State", "doors_save_state", "Set whether or not doors will save being open or closed and locked.")

-- Called to sync the ESP data.
netstream.Hook("doorParentESP", function(data)
	cwDoorCmds.doorHalos = data
end)

-- Called before halos need to be rendered.
function cwDoorCmds:PreDrawHalos()
	self.doorHalos = self.doorHalos or {}

	for k, door in pairs(self.doorHalos) do
		if (IsValid(door)) then
			local color = Color(0, 170, 170, 255)

			if (k == "Parent") then
				color = Color(255, 100, 0, 255)
			end

			halo.Add({door}, color, 1, 1, 1, true, true)
		end
	end
end
