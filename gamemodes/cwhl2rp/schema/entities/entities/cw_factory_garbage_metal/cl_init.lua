--- Client side of the `cw_factory_garbage_metal` entity: creates the `_GR_CMB_FONT_1` to `_GR_CMB_FONT_4` fonts and
-- draws the metal recycler's indicator screen.
--
-- The screen is painted to a per-entity render target and shows the status, the garbage count and the cycle progress
-- as bars. While the local player holds the toolgun, lines also mark the product position.

include('shared.lua')

surface.CreateFont('_GR_CMB_FONT_1', {
  font = 'Default',
  size = 13,
  weight = 1000,
  antialias = false,
  underline = false,
  extended = true
})
surface.CreateFont('_GR_CMB_FONT_2', {
  font = 'Default',
  size = 11,
  weight = 1000,
  antialias = false,
  underline = false,
  extended = true
})
surface.CreateFont('_GR_CMB_FONT_3', {
  font = 'Verdana',
  size = 10,
  weight = 800,
  antialias = false,
  underline = false,
  extended = true
})
surface.CreateFont('_GR_CMB_FONT_4', {
  font = 'System',
  size = 40,
  weight = 1000,
  antialias = false,
  underline = false,
  extended = true
})

--- Creates the render target and material for the indicator screen.
function ENT:Initialize()
  self.RT = GetRenderTargetEx(
    '_cmb_FIndicatorRT'..self:EntIndex(),
    128,
    85,
    RT_SIZE_DEFAULT,
    MATERIAL_RT_DEPTH_SHARED,
    0x0001,
    CREATERENDERTARGETFLAGS_UNFILTERABLE_OK,
    IMAGE_FORMAT_DEFAULT
  )
  self.RTMat = CreateMaterial('_cmb_FIndicatorRTMAT'..self:EntIndex(), 'UnlitTwoTexture', {
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
end

--- Draws the recycler and its indicator screen with the status, garbage count and progress bars.
--
-- While the local player holds the toolgun, a marker also shows the product position.
function ENT:Draw()
  self:DrawModel()

  if IsValid(LocalPlayer():GetActiveWeapon()) then
    if LocalPlayer():GetActiveWeapon():GetClass() == 'gmod_tool' then
      render.DrawLine(
        self:GetProductPos() - self:GetForward() * 12,
        self:GetProductPos() + self:GetForward() * 12,
        color_white,
        true
      )
      render.DrawLine(
        self:GetProductPos() - self:GetRight() * 12,
        self:GetProductPos() + self:GetRight() * 12,
        color_white,
        true
      )
      render.DrawLine(
        self:GetProductPos() - self:GetUp() * 12,
        self:GetProductPos() + self:GetUp() * 12,
        color_white,
        true
      )
      render.DrawLine(self:GetProductPos(), self:GetPos(), color_white, true)
    end
  end

  -- The client does not always run Initialize for entities it receives while still loading.
  if !self.RT then self:Initialize() end

  local pos = self:GetPos()
  local ang = self:GetAngles()

  ang:RotateAroundAxis(ang:Forward(), 90)
  ang:RotateAroundAxis(ang:Right(), -90)

  pos = pos + self:GetForward() * 10.2 + self:GetUp() * 18.85 + self:GetRight() * 17

  render.PushRenderTarget(self.RT)
    render.Clear(0, 0, 0, 255)
    cam.Start2D()
    surface.SetDrawColor(50, 50, 50, 255)
    surface.DrawRect(0, 0, 385, 256)
    surface.SetTextColor(255, 255, 255)
    surface.SetFont('_GR_CMB_FONT_1')
    surface.SetTextPos(8, 5)
    surface.DrawText('#GarbageRecycler_Title')
    surface.SetFont('_GR_CMB_FONT_2')
    surface.SetTextPos(8, 20)
    surface.DrawText('#GarbageRecycler_Metal')

    local isWorking = self:GetIsWorking()
    local stopped = self:GetStopWorkTime() > 0
    local notEnough = self:GetGarbageCount() < self.METAL_GARBAGE_COUNT_START

    local text = isWorking and '#GarbageRecycler_Status_Recycling'
      or (stopped and '#GarbageRecycler_Status_Stopped'
      or (notEnough and '#GarbageRecycler_Status_NotEnough' or '#GarbageRecycler_Status_Ready'))
    local red = isWorking and 0 or (stopped and 255 or (notEnough and 255 or 0))
    local green = isWorking and 255 or (stopped and 0 or (notEnough and 0 or 255))
    surface.SetTextColor(red, green, 0, math.abs(math.cos(RealTime() * 2) * 255))
    surface.SetFont('_GR_CMB_FONT_3')
    surface.SetTextPos(6, 31)
    surface.DrawText(text)

    local var = self:GetGarbageCount() / self.METAL_GARBAGE_COUNT_START
    local _cur = CurTime() - self:GetStartWorkTime()
    local _end = self:GetNextWorkTime() - self:GetStartWorkTime()
    local var2 = math.Clamp((_cur / _end), 0, 1)

    if !self:GetIsWorking() then
      if self:GetStopWorkTime() > 0 then
        local i = self.WORK_TIME - self:GetStopWorkTime()
        _cur = 0 - (0 - i)
        _end = ((0 + self.WORK_TIME) - i) - (0 - i)
        var2 = math.Clamp((_cur / _end), 0, 1)
      else
        var2 = 0
      end
    end

    surface.SetDrawColor(65, 65, 65, 255)
    surface.DrawRect(128 / 2 - 114 / 2, 100 / 2 - 16 / 2, 114, 16)
    surface.SetDrawColor(50, 120, 230, 255)
    local bar = math.Clamp((var * 114) - 2, 0, 114)
    surface.DrawRect(128 / 2 - 114 / 2 + 1, 100 / 2 - 16 / 2 + 1, bar, 16 - 2)

    local text = math.Round(self:GetGarbageCount(), 2)..'/'..self.METAL_GARBAGE_COUNT_START
    surface.SetTextColor(255, 255, 255, 150)
    surface.SetFont('_GR_CMB_FONT_1')
    local w, h = surface.GetTextSize(text)
    surface.SetTextPos(128 / 2 - w / 2, 100 / 2 - h / 2)
    surface.DrawText(text)

    surface.SetDrawColor(65, 65, 65, 255)
    surface.DrawRect(128 / 2 - 114 / 2, 100 / 2 - 16 / 2 + 20, 114, 16)
    surface.SetDrawColor(50, 240, 50, 255)
    local bar = math.Clamp((var2 * 114) - 2, 0, 114)
    surface.DrawRect(128 / 2 - 114 / 2 + 1, 100 / 2 - 16 / 2 + 1 + 20, bar, 16 - 2)

    local text = math.Round((var2 * 100))..'%'
    surface.SetTextColor(255, 255, 255, 150)
    surface.SetFont('_GR_CMB_FONT_1')
    local w, h = surface.GetTextSize(text)
    surface.SetTextPos(128 / 2 - w / 2, 100 / 2 - h / 2 + 20)
    surface.DrawText(text)
    cam.End2D()
  render.PopRenderTarget()

  self.RTMat:SetTexture('$basetexture', self.RT)

  cam.Start3D2D(pos, ang, 0.064)
    render.PushFilterMin(TEXFILTER.NONE)
    render.PushFilterMag(TEXFILTER.NONE)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(self.RTMat)
    surface.DrawTexturedRect(0, 0, 385, 269)

    render.PopFilterMin()
    render.PopFilterMag()
  cam.End3D2D()
end
