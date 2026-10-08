--- Registers the `/ContainmentSpherePlace` superadmin command of the Radiation plugin, which adds a sphere containment
-- zone with the given radius and radiation level where the player is looking.

local COMMAND = cw.command:New('ContainmentSpherePlace')
COMMAND.tip = ''
COMMAND.text = '#Command_Containmentsphereplace_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 2

--- Adds a sphere containment zone at the position the player is looking at.
--
-- The arguments are the sphere's radius, which has to be above zero, and its radiation level, which cannot be
-- negative.
function COMMAND:OnRun(player, arguments)
  local radius = tonumber(arguments[1])
  local rad = tonumber(arguments[2])

  -- A NaN fails every comparison, so it is refused here as well.
  if !radius or !rad or !(radius > 0 and radius < math.huge) or !(rad >= 0 and rad < math.huge) then
    cw.player:Notify(player, L('Containment_InvalidNumber'))

    return
  end

  local trace = player:GetEyeTraceNoCursor()

  cwRadSystem.stored[#cwRadSystem.stored + 1] = {
    pos = trace.HitPos,
    radius = radius,
    rad = rad
  }

  cw.player:Notify(player, L('Containment_SphereAdded', radius, rad))
end

COMMAND:Register()
