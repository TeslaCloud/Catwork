--- Client side of the `cw_combineaccessmonitor` entity of the Combine Devices plugin, which draws the access monitor's
-- screen.
--
-- The screen is rendered to a per-entity render target with a scrolling scanline material and shows the three text
-- lines and the access level, or a flashing `ERROR` screen with random binary in the error status; a destroyed monitor
-- shows no screen. Also creates the `_CMB_FONT_1` to `_CMB_FONT_5` fonts.

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
include('shared.lua')

local screenMaterial = Material('props/combine_monitor_access')
local gradientMaterial = Material('gui/gradient_up')
local errorc = CreateMaterial('_CMB_ERROR', 'Modulate', {
  ['$basetexture'] = 'props/combine_monitor_access_off',
  ['$ignorez'] = '1',
  ['$vertexcolor'] = '1',
  ['$vertexalpha'] = '1',
  ['$translucent'] = '1'
})

surface.CreateFont('_CMB_FONT_1', {
  font = 'Myriad Pro',
  extended = true,
  size = 42,
  weight = 1000,
  antialias = true,
  underline = false
})
surface.CreateFont('_CMB_FONT_2', {
  font = 'Myriad Pro',
  size = 36,
  weight = 1000,
  antialias = true,
  underline = false
})
surface.CreateFont('_CMB_FONT_3', {
  font = 'HalfLife2',
  size = 60,
  weight = 1000,
  antialias = true,
  underline = false
})
surface.CreateFont('_CMB_FONT_4', {
  font = 'System',
  size = 72,
  weight = 1000,
  antialias = true,
  underline = false
})
surface.CreateFont('_CMB_FONT_5', {
  font = 'System',
  size = 9,
  weight = 500,
  antialias = false,
  underline = false
})

--- Creates the render target and scanline material the monitor's screen is drawn with.
function ENT:Initialize()
  -- Render targets are never freed, so an entity that is created again has to get the one it had before.
  self.RT = GetRenderTarget('_CMB_ACCESSMONITOR_ENT'..self:EntIndex(), 256, 256, false)
  self.RTMat = CreateMaterial('_CMB_ACCESSMONITOR_ENT_RTMAT'..self:EntIndex(), 'UnlitTwoTexture', {
    ['$selfilium'] = '1',
    ['$texture2'] = 'dev/dev_scanline',
    ['Proxies'] =
    {
      ['TextureScroll'] =
      {
        ['texturescrollvar'] = '$texture2transform',
        ['texturescrollrate'] = '3',
        ['texturescrollangle'] = '90'
      }
    }
  })
  self.error = true
  self.errorFlash = CurTime()
end

local function bitkek(int)
  local str = ''

  for i = 0, int do
    str = str..math.random(0, 1)
  end

  return str
end

--- Draws the monitor and its screen: the three text lines and access level, or a flashing error.
--
-- Nearby players also see random binary on the error screen. Destroyed monitors show no
-- screen.
function ENT:DrawTranslucent()
  self:DrawModel()

  local status = self:GetDTInt(5)

  if status == 1 then return end

  local pos = self:GetPos()
  local ang = self:GetAngles()

  ang:RotateAroundAxis(ang:Forward(), 90)
  ang:RotateAroundAxis(ang:Right(), -90)

  pos = pos + self:GetForward() * 13 + self:GetUp() * 19 + self:GetRight() * 6.8

  render.PushRenderTarget(self.RT)
    render.Clear(0, 0, 0, 255)
    cam.Start2D()
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(screenMaterial)
    surface.DrawTexturedRect(0, 0, 256, 256)

    if status == 2 then
      if self.error then
        surface.SetTextColor(255, 0, 0)
        surface.SetFont('_CMB_FONT_4')
        surface.SetTextPos(30, 50)
        surface.DrawText('ERROR')
      end

      if CurTime() >= self.errorFlash then
        self.error = !self.error
        self.errorFlash = CurTime() + 0.4
      end

      if LocalPlayer():GetPos():Distance(self:GetPos()) < 300 then
        surface.SetTextColor(255, 255, 255)
        surface.SetFont('_CMB_FONT_5')
        surface.SetTextPos(20, 140)
        surface.DrawText('1E'..bitkek(13))
        surface.SetTextPos(20, 155)
        surface.DrawText(bitkek(6)..'cmb_ACCESS')
        surface.SetTextPos(20, 180)
        surface.DrawText(bitkek(2)..util.CRC(self:EntIndex())..bitkek(2)..'CP_cmb'..bitkek(4))
      end

      surface.SetDrawColor(255, 0, 0, 255)
      surface.SetMaterial(errorc)
      surface.DrawTexturedRect(0, 0, 256, 256)
    else
      surface.SetTextColor(0, 0, 114)
      surface.SetFont('_CMB_FONT_1')
      surface.SetTextPos(24, 33)
      surface.DrawText(self:GetDTString(0))
      surface.SetTextPos(24, 33 + 25)
      surface.DrawText(self:GetDTString(1))
      surface.SetTextPos(24, 33 + 25 + 25)
      surface.DrawText(self:GetDTString(2))

      surface.SetFont('_CMB_FONT_2')
      surface.SetTextPos(24, 256 - 128 + 8)
      surface.DrawText('ACCESS')
      surface.SetTextPos(24, 256 - 128 + 38 + 8)
      surface.DrawText('LEVEL:')
      surface.SetDrawColor(255, 0, 0, 128)
      surface.SetMaterial(gradientMaterial)
      surface.DrawTexturedRect(256 - 256 / 3.5 - 56 / 2, 256 - 256 / 3.5 - 56 / 2, 56, 56)

      surface.SetTextColor(255, 0, 0)
      surface.SetFont('_CMB_FONT_3')
      surface.SetTextPos(256 - 256 / 4 - 24, 256 - 128 + 21)
      surface.DrawText(self:GetDTString(3) == '' and '0' or self:GetDTString(3))
    end

    cam.End2D()
  render.PopRenderTarget()

  self.RTMat:SetTexture('$basetexture', self.RT)

  cam.Start3D2D(pos, ang, 0.064)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(self.RTMat)
    surface.DrawTexturedRect(0, 0, 256, 256)
  cam.End3D2D()
end
