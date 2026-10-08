--- Main file of the Nightvision plugin, which draws the green night vision screen effect for players whose
-- `nightvisionfx` networked boolean is set and defines who may use it.
--
-- The client renders the effect in a `RenderScreenspaceEffects` hook, and the server's `PlayerThink` hook switches it
-- off for players who lose the right. `Schema:PlayerCanUseNightvision` allows Civil Protection units of rank SpF, CmD,
-- CpT, MaJ or SeC and anyone with the `9` flag, which this file registers.

local PLUGIN = PLUGIN

if CLIENT then
  local render = render

  local fadeRate = 0.02
  local bloomMultiply = 0.5
  local bloomDarken = 0.5
  local bloomBlur = 0.1
  local bloomColorMul = 0.25
  local curScale = 0.5
  local bWasActive = false
  local matNightVision = CreateMaterial('NightVisionMaterial', 'UnlitTwoTexture', {
    ['$additive'] = '1',
    ['$basetexture'] = '_rt_FullFrameFB',
    ['$texture2'] = 'nightvision_noise',
    ['Proxies'] =
    {
      ['TextureScroll'] =
      {
        ['texturescrollvar'] = '$texture2transform',
        ['texturescrollrate'] = '10',
        ['texturescrollangle'] = '45'
      }
    }
  })
  matNightVision:SetFloat('$alpha', 1.5)

  local colorTable = {
    ['$pp_colour_addr'] = -1,
    ['$pp_colour_addg'] = -0.4,
    ['$pp_colour_addb'] = -1,
    ['$pp_colour_brightness'] = 0.8,
    ['$pp_colour_contrast'] = 2,
    ['$pp_colour_colour'] = 0,
    ['$pp_colour_mulr'] = 0,
    ['$pp_colour_mulg'] = 0.1,
    ['$pp_colour_mulb'] = 0
  }

  local function NightVisionFX()
    local bActive = LocalPlayer():GetNWBool('nightvisionfx')

    -- The effect brightens up from half strength every time it is switched on.
    if bWasActive != bActive then
      bWasActive = bActive
      curScale = 0.5
    end

    if !bActive then return end

    if curScale < 0.995 then
      curScale = curScale + fadeRate * (1 - curScale)
    end

    render.UpdateScreenEffectTexture()
    render.SetMaterial(matNightVision)
    render.DrawScreenQuad()

    colorTable['$pp_colour_brightness'] = curScale * 0.8
    colorTable['$pp_colour_contrast'] = curScale * 2
    DrawColorModify(colorTable)
    DrawBloom(bloomDarken, curScale * bloomMultiply, bloomBlur, bloomBlur, 1, curScale * bloomColorMul, 0, 1, 0)
  end

  hook.Add('RenderScreenspaceEffects', 'NightVisionFX', NightVisionFX)
else
  --- Called at an interval while a player is connected; turns night vision off for players no longer allowed to use it.
  -- @param player [Player The player being updated]
  -- @param curTime [Number The current `CurTime()`]
  -- @param infoTable [Map The player's info table for this think]
  -- @see Schema:PlayerCanUseNightvision
  function PLUGIN:PlayerThink(player, curTime, infoTable)
    if player:GetNWBool('nightvisionfx') then
      if !Schema:PlayerCanUseNightvision(player) then
        player:SetNWBool('nightvisionfx', false)
      end
    end
  end
end

--- Returns whether a player may use night vision.
--
-- MPF units of the SpF, CmD, CpT, MaJ or SeC rank may, as may anyone with the `9` flag.
-- @param player [Player The player to check]
-- @return [Boolean Whether the player can use night vision]
function Schema:PlayerCanUseNightvision(player)
  if player:GetFaction() == FACTION_MPF then
    if self:IsPlayerCombineRank(player, 'SpF') then
      return true
    elseif self:IsPlayerCombineRank(player, 'CmD') then
      return true
    elseif self:IsPlayerCombineRank(player, 'CpT') then
      return true
    elseif self:IsPlayerCombineRank(player, 'MaJ') then
      return true
    elseif self:IsPlayerCombineRank(player, 'SeC') then
      return true
    end
  end

  if cw.player:HasFlags(player, '9') then
    return true
  end

  return false
end

cw.flag:Add('9', 'Nightvision', 'Access to the nightvision ability.')
