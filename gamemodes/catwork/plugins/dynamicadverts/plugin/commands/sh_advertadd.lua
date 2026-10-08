--- Registers the `/AdvertAdd` admin command, which places an image advert from a URL, with a given width, height and
-- optional scale, on the surface the player is looking at.

-- Called when the command has been run.
local COMMAND = cw.command:New('AdvertAdd')
COMMAND.tip = '#Command_Advertadd_Description'
COMMAND.text = '#Command_Advertadd_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 3
COMMAND.optionalArguments = 1

--- Adds an image advert from a URL where the player is looking, sends it to every client and saves it.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local url = arguments[1]
  local scale = tonumber(arguments[4])
  local width = tonumber(arguments[2]) or 256
  local height = tonumber(arguments[3]) or 256
  local fileName = string.match(url, '[^/]*$')
  local extension = (string.GetExtensionFromFilename(fileName) or ''):lower():match('^%a+')

  -- Every client downloads the image itself, so only take what `cwDynamicAdverts:CacheMaterial` is able to show.
  if extension != 'png' and extension != 'jpg' and extension != 'jpeg' then
    cw.player:Notify(player, L('DynamicAdverts_InvalidURL'))

    return
  end

  if scale then
    scale = scale * 0.25
  end

  local data = {
    url = url,
    scale = scale,
    width = width,
    height = height,
    angles = trace.HitNormal:Angle(),
    position = trace.HitPos + (trace.HitNormal * 1.25)
  }

  data.angles:RotateAroundAxis(data.angles:Forward(), 90)
  data.angles:RotateAroundAxis(data.angles:Right(), 270)

  netstream.Start(nil, 'DynamicAdvertAdd', data)

  cwDynamicAdverts.storedList[#cwDynamicAdverts.storedList + 1] = data
  cwDynamicAdverts:SaveDynamicAdverts()

  cw.player:Notify(player, L('DynamicAdverts_Added'))
end

COMMAND:Register()
