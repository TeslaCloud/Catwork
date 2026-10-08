--- Registers the `/TextAdd` admin command, which places a 3D text on the surface the player is looking at, with an
-- optional scale, style, color and second color.

local COMMAND = cw.command:New('TextAdd')
COMMAND.tip = '#Command_Textadd_Description'
COMMAND.text = '#Command_Textadd_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1
COMMAND.optionalArguments = 4

--- Adds a surface text where the player is looking, with optional scale, style, color and box color.
function COMMAND:OnRun(player, arguments)
  local text = arguments[1]
  local scale = tonumber(arguments[2])
  local style = tonumber((arguments[3] or 1))
  local color = arguments[4] or '#FF0000'
  local extraColor = arguments[5]

  if !text or text == '' then
    cw.player:Notify(player, L('NotEnoughText'))

    return
  end

  local trace = player:GetEyeTraceNoCursor()
  local angle = trace.HitNormal:Angle()
  angle:RotateAroundAxis(angle:Forward(), 90)
  angle:RotateAroundAxis(angle:Right(), 270)

  local data = {
    text = text,
    style = style or 0,
    color = (color and Color(color)) or Color('#FFFFFF'),
    extraColor = (extraColor and Color(extraColor)) or Color('#FF0000'),
    angle = angle,
    pos = trace.HitPos,
    normal = trace.HitNormal,
    scale = scale or 1
  }

  cwSurfaceTexts:AddText(data)

  cw.player:Notify(player, L('SurfaceTexts_Added'))
end

COMMAND:Register()
