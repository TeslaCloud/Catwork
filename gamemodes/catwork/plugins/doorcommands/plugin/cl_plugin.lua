--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

config.AddToSystem("#DoorsDefaultHidden", "default_doors_hidden", "#DoorsDefaultHiddenDesc")
config.AddToSystem("#DoorsSaveState", "doors_save_state", "#DoorsSaveStateDesc")

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
