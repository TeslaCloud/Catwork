--- Registers the `/AreaAdd` command, which defines a named area and its display in steps, using the point the player is
-- looking at for each corner and for the text.

local COMMAND = cw.command:New('AreaAdd')
COMMAND.tip = '#Command_Areaadd_Description'
COMMAND.text = '#Command_Areaadd_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.optionalArguments = 3

--- Adds an area in steps, using the point the player is looking at each time.
--
-- The first run with a name sets the box's minimum corner, the second its maximum, and for `3D`
-- displays a third run places the text. The area is then saved and sent to every client. Optional
-- arguments are the 3D text scale, whether the area expires after being shown once, and the display
-- class (`Scrolling`, `3D` or `Cinematic`).
function COMMAND:OnRun(player, arguments)
  local areaPointData = player.cwAreaData
  local trace = player:GetEyeTraceNoCursor()
  local name = arguments[1]

  if !areaPointData or areaPointData.name != name then
    player.cwAreaData = {
      name = name,
      class = (arguments[4] != '' and arguments[4] or 'Scrolling'),
      scale = tonumber(arguments[2]),
      minimum = trace.HitPos
    }

    if cw.core:ToBool(arguments[3]) then
      player.cwAreaData.doesExpire = true
    end

    cw.player:Notify(player, L('AreaDisplays_MinimumAdded'))
    return
  elseif !areaPointData.maximum then
    areaPointData.maximum = trace.HitPos

    if areaPointData.class == '3D' then
      cw.player:Notify(player, L('AreaDisplays_MaximumAdded'))
      return
    end
  end

  local data = {
    name = areaPointData.name,
    scale = areaPointData.scale,
    angles = trace.HitNormal:Angle(),
    expires = areaPointData.doesExpire,
    minimum = areaPointData.minimum,
    maximum = areaPointData.maximum,
    position = trace.HitPos + (trace.HitNormal * 1.25)
  }

  data.angles:RotateAroundAxis(data.angles:Forward(), 90)
  data.angles:RotateAroundAxis(data.angles:Right(), 270)

  netstream.Start(nil, 'AreaAdd', data)
    cwAreaDisplays.storedList[#cwAreaDisplays.storedList + 1] = data
    cwAreaDisplays:SaveAreaDisplays()
  cw.player:Notify(player, L('AreaDisplays_Added').." '"..data.name.."'.")

  player.cwAreaData = nil
end

COMMAND:Register()
