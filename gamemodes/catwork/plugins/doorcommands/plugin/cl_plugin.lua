--- Client-side part of the Door Commands plugin that outlines the parent door being edited and its children.
--
-- The doors arrive over the `doorParentESP` netstream and are drawn in `PreDrawHalos`, the parent in orange and the
-- children in cyan. Also adds the `default_doors_hidden` and `doors_save_state` config keys to the system config menu.

config.AddToSystem('#DoorsDefaultHidden', 'default_doors_hidden', '#DoorsDefaultHiddenDesc')
config.AddToSystem('#DoorsSaveState', 'doors_save_state', '#DoorsSaveStateDesc')

local colorChild = Color(0, 170, 170, 255)
local colorParent = Color(255, 100, 0, 255)

-- Called to sync the ESP data.
netstream.Hook('doorParentESP', function(data)
  cwDoorCmds.doorHalos = data
end)

--- Called before halos are drawn; outlines the door parent being edited in orange and its children in cyan.
--
-- The doors come from the `doorParentESP` netstream message sent by the door parenting commands.
function cwDoorCmds:PreDrawHalos()
  local doorHalos = self.doorHalos

  if !doorHalos or next(doorHalos) == nil then return end

  local children = {}

  for k, door in pairs(doorHalos) do
    if IsValid(door) then
      if k == 'Parent' then
        halo.Add({ door }, colorParent, 1, 1, 1, true, true)
      else
        children[#children + 1] = door
      end
    end
  end

  if #children > 0 then
    halo.Add(children, colorChild, 1, 1, 1, true, true)
  end
end
