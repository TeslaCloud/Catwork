--- Client side of the `hl2_combinemonitor` entity of the Combine Civil Authority plugin, which draws the check
-- monitor's screen.
--
-- The screen is rendered to a per-entity render target with a scrolling scanline material, for players within 1000
-- units. It shows a waiting message while the monitor is off and the civil record from the `userData` net var while it
-- is on; an anti-citizen gets a flashing `ERROR` screen with random binary instead. Also creates the `_CMB_FONT_1`,
-- `_CMB_FONT_2`, `_CMB_FONT_4` and `_CMB_FONT_5` fonts.

include('shared.lua')

local glow = CreateMaterial('_CMB_SMALLMONITOR_GLOW4', 'UnlitGeneric', {
  ['$basetexture'] = 'sprites/glow06',
  ['$additive'] = '1',
  ['$selfilium'] = '1',
  ['$vertexcolor'] = '1',
  ['$vertexalpha'] = '1'
})

local errorc = CreateMaterial('_CMB_ERROR', 'Modulate', {
  ['$basetexture'] = 'props/combine_monitor_access_off',
  ['$ignorez'] = '1',
  ['$vertexcolor'] = '1',
  ['$vertexalpha'] = '1',
  ['$translucent'] = '1'
})

surface.CreateFont('_CMB_FONT_1', {
  font = 'Myriad Pro',
  size = 22,
  weight = 1000,
  antialias = true,
  underline = false,
  additive = true,
  extended = true
})

surface.CreateFont('_CMB_FONT_2', {
  font = 'Consolas',
  size = 20,
  weight = 1000,
  antialias = true,
  underline = false,
  additive = true,
  extended = true
})

surface.CreateFont('_CMB_FONT_4', {
  font = 'System',
  size = 72,
  weight = 1000,
  antialias = true,
  underline = false,
  extended = true
})

surface.CreateFont('_CMB_FONT_5', {
  font = 'System',
  size = 9,
  weight = 500,
  antialias = false,
  underline = false,
  extended = true
})

--- Creates the render target and scanline material the monitor's screen is drawn with.
function ENT:Initialize()
  self.RT = GetRenderTarget('_CMB_SMALLMONITOR_ENT'..self:EntIndex()..CurTime(), 256, 256, false)
  self.RTMat = CreateMaterial('_CMB_SMALLMONITOR_ENT_RTMAT'..self:EntIndex()..CurTime(), 'UnlitTwoTexture', {
    ['$selfilium'] = '1',
    ['$texture2'] = 'dev/dev_scanline',
    ['Proxies'] = {
      ['TextureScroll'] = {
        ['texturescrollvar'] = '$texture2transform',
        ['texturescrollrate'] = '3',
        ['texturescrollangle'] = '90'
      }
    }
  })

  self.error = true
  self.errorFlash = CurTime()
end

-- СУКА Я ОРУ С ЭТИХ НАЗВАНИЙ ФУНКЦИЙ
local function bitkek(int)
  local str = ''

  for i = 0, int do
    str = str..math.random(0, 1)
  end

  return str
end

--- Draws the monitor and its screen for players within 1000 units.
--
-- The screen shows a waiting message when off and the networked civil record when on. Anti-citizens get
-- a red error screen with scrolling noise, drawn only within 300 units.
function ENT:DrawTranslucent()
  local pos = self:GetPos()
  local clientPos = cw.client:GetPos()
  local dist = clientPos:Distance(pos)

  if dist < 1000 then
    self:DrawModel()

    local curTime = CurTime()
    local ang = self:GetAngles()

    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), -90)

    pos = pos + self:GetForward() * 13 + self:GetUp() * 19 + self:GetRight() * 6.8

    render.PushRenderTarget(self.RT)
      render.Clear(0, 50, 120, 255)
      cam.Start2D()
      local glow_text = math.abs(math.sin(curTime * 3) * 255)

      if !self:GetNetVar('monitor_activated') then
        surface.SetTextColor(100, 100, 255)
        surface.SetFont('_CMB_FONT_1')
        surface.SetTextPos(20, 15)
        surface.DrawText('#CombineMonitor_Title')
        surface.SetTextPos(90, 35)
        surface.DrawText(Schema.City)
        surface.SetTextColor(100, 100, 255, glow_text)
        surface.SetFont('_CMB_FONT_1')
        surface.SetTextPos(16, 256 - 128 - 4)
        surface.DrawText('#CombineMonitor_Waiting')
      else
        local data = self:GetNetVar('userData', {})

        if data.status == '#Status_AntiCitizen' then
          text = ''
          render.Clear(80, 0, 0, 255)
        end

        if string.utf8len(data.name) > 19 then
          data.name = string.utf8sub(data.name, 1, 19 - 3)..'...'
        end

        if data.status != '#Status_AntiCitizen' then
          local offset = 20

          surface.SetTextColor(100, 100, 255)
          surface.SetFont('_CMB_FONT_1')

          surface.SetTextPos(20, 15)
          surface.DrawText('#CombineMonitor_Title')

          surface.SetTextPos(90, 35)
          surface.DrawText(Schema.City)

          surface.SetTextColor(100, 100, 255)
          surface.SetFont('_CMB_FONT_2')

          surface.SetTextPos(18, 65)
          surface.DrawText(L('#CombineMonitor_Name')..': '..data.name)

          surface.SetTextPos(18, 85)
          surface.DrawText(L('#CombineMonitor_ID')..': #'..data.citizenID)

          surface.SetTextPos(18, 85 + offset)
          surface.DrawText(L('#CombineMonitor_Loyalty')..': '..data.lp)

          surface.SetTextPos(18, 85 + (offset * 2))
          surface.DrawText(L('#CombineMonitor_Violations')..': '..data.cp)

          surface.SetTextPos(18, 85 + (offset * 3))
          surface.DrawText(L('#CombineMonitor_Work:'..data.wp..','..data.workLevel..';'))

          surface.SetTextPos(18, 85 + (offset * 4))
          surface.DrawText(L('#CombineMonitor_Status')..': '..data.status)

          surface.SetTextPos(18, 85 + (offset * 5))
          surface.DrawText(L('#CombineMonitor_Residence')..':\n'..string.utf8upper(data.residence))

          surface.SetTextPos(18, 85 + (offset * 6))
          surface.DrawText(L('#CombineMonitor_Job')..': '..string.utf8upper(data.job))

          if data.status == '#Status_Unverified' then
            surface.SetTextPos(18, 85 + (offset * 7))
            surface.DrawText('#CombineMonitor_VerifyStatus')

            surface.SetTextPos(68, 76 + (offset * 8))
            surface.DrawText('#CombineMonitor_AtCWU')
          end

          surface.SetDrawColor(100, 100, 255)
          surface.DrawRect(0, 65, 256, 2)
          surface.DrawRect(0, 85 + (offset * 7), 256, 2)
        else
          surface.SetTextColor(255, 0, 0)
          surface.SetFont('_CMB_FONT_4')
          surface.SetTextPos(10, 50)
          surface.DrawText('ERROR')

          if curTime >= self.errorFlash then
            self.error = !self.error
            self.errorFlash = curTime + 0.4
          end

          if dist < 300 then
            surface.SetTextColor(255, 0, 0)
            surface.SetFont('_CMB_FONT_5')
            surface.SetTextPos(20, 140)
            surface.DrawText('1E'..string.upper(util.MD5('b'..math.random(0, 9))))
            surface.SetTextPos(20, 155)
            surface.DrawText(bitkek(6)..'cmb_ACCESS')
            surface.SetTextPos(20, 180)
            surface.DrawText(bitkek(2)..util.CRC(self:EntIndex())..bitkek(2)..'CP_cmb'..bitkek(4))
            surface.SetTextPos(20, 220)
            surface.DrawText(string.upper(util.MD5('b'..math.random(0, 9))))
            surface.SetTextPos(88, 50)
            surface.DrawText(bitkek(4)..'cmb_biba'..bitkek(1)..'systems'..bitkek(2)..'failure'..bitkek(3))
          end
        end
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
end
