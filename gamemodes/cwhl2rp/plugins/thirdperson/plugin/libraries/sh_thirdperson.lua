-- All credit for third person script goes to cringerpants and his/her affiliates.
-- His/her email: cringerpants@phuce.com

library.New('thirdperson', cw)

-- Client
if CLIENT then
  local cvBob = CreateClientConVar('chasecam_bob', 1, true, false)
  local cvBobScale = CreateClientConVar('chasecam_bobscale', 0.5, true, false)
  local cvBack = CreateClientConVar('chasecam_back', 75, true, false)
  local cvRight = CreateClientConVar('chasecam_right', 20, true, false)
  local cvUp = CreateClientConVar('chasecam_up', 5, true, false)
  local cvSmooth = CreateClientConVar('chasecam_smooth', 1, true, false)
  local cvSmoothScale = CreateClientConVar('chasecam_smoothscale', 0.2, true, false)

  --- Computes the third person camera view; runs as a `CalcView` hook.
  --
  -- Only acts while the player's `thirdperson` networked int is 1. The camera sits behind and to
  -- the right of the player, offset by the `chasecam_back`, `chasecam_right` and `chasecam_up`
  -- convars (or close up while zoomed), is traced so it stays out of walls, and moves forward and
  -- bobs while sprinting. Position and field of view are eased when `chasecam_smooth` is on.
  -- Also turns the player to face the aim direction.
  -- @param player [Player The local player]
  -- @param pos [Vector The default view origin]
  -- @param angles [Angle The default view angles]
  -- @param fov [Number The default field of view]
  -- @return [Map The view table from `GAMEMODE:CalcView`, or `nil` when third person is off]
  function cw.thirdperson.CalcView(player, pos, angles, fov)
    local smooth = cvSmooth:GetFloat()
    local smoothscale = cvSmoothScale:GetFloat()

    if player:GetNWInt('thirdperson') == 1 then
      angles = player:GetAimVector():Angle()

      local targetpos = Vector(0, 0, 60)

      if player:KeyDown(IN_DUCK) then
        if player:GetVelocity():Length() > 0 then
          targetpos.z = 50
        else
          targetpos.z = 40
        end
      end

      player:SetAngles(angles)
      local targetfov = fov

      if player:GetVelocity():DotProduct(player:GetForward()) > 10 then
        if player:KeyDown(IN_SPEED) then
          targetpos = targetpos + player:GetForward() * -10

          if cvBob:GetFloat() != 0 and player:OnGround() then
            angles.pitch = angles.pitch + cvBobScale:GetFloat() * math.sin(CurTime() * 10)
            angles.roll = angles.roll + cvBobScale:GetFloat() * math.cos(CurTime() * 10)
            targetfov = targetfov + 3
          end
        else
          targetpos = targetpos + player:GetForward() * -5
        end
      end

      -- tween to the target position
      pos = player:GetVar('thirdperson_pos') or targetpos

      if smooth != 0 then
        pos.x = math.Approach(pos.x, targetpos.x, math.abs(targetpos.x - pos.x) * smoothscale)
        pos.y = math.Approach(pos.y, targetpos.y, math.abs(targetpos.y - pos.y) * smoothscale)
        pos.z = math.Approach(pos.z, targetpos.z, math.abs(targetpos.z - pos.z) * smoothscale)
      else
        pos = targetpos
      end

      player:SetVar('thirdperson_pos', pos)

      -- offset it by the stored amounts, but trace so it stays outside walls
      -- we don't tween this so the camera feels like its tightly following the mouse
      local offset = Vector(5, 5, 5)

      if player:GetVar('thirdperson_zoom') != 1 then
        offset.x = cvBack:GetFloat()
        offset.y = cvRight:GetFloat()
        offset.z = cvUp:GetFloat()
      end

      local t = {}
      t.start = player:GetPos() + pos
      t.endpos = t.start + angles:Forward() * -offset.x
      t.endpos = t.endpos + angles:Right() * offset.y
      t.endpos = t.endpos + angles:Up() * offset.z
      t.filter = player

        local tr = util.TraceLine(t)
        pos = tr.HitPos

        if tr.Fraction < 1.0 then
          pos = pos + tr.HitNormal * 5
        end

      player:SetVar('thirdperson_viewpos', pos)

      -- tween the fov
      fov = player:GetVar('thirdperson_fov') or targetfov

      if smooth != 0 then
        fov = math.Approach(fov, targetfov, math.abs(targetfov - fov) * smoothscale)
      else
        fov = targetfov
      end

      player:SetVar('thirdperson_fov', fov)

      return GAMEMODE:CalcView(player, pos, angles, fov)
    end
  end

  hook.Add('CalcView', 'cw.thirdperson.CalcView', cw.thirdperson.CalcView)

  -- thanks to termy58's crosshair example
  -- ... and thanks to termy58 for finding my stupid bug :P
  --- Draws the third person crosshair where the local player's aim hits; runs as a `HUDPaint` hook.
  --
  -- The crosshair grows as the target gets closer and turns red when the camera cannot see the
  -- hit position.
  function cw.thirdperson.HUDPaint()
    local player = LocalPlayer()

    if player:GetNWInt('thirdperson') == 0 then
      return
    end

    -- trace from muzzle to hit pos
    local t = {}
    t.start = player:GetShootPos()
    t.endpos = t.start + player:GetAimVector() * 9000
    t.filter = player
    local tr = util.TraceLine(t)
    local pos = tr.HitPos:ToScreen()
    local fraction = math.min((tr.HitPos - t.start):Length(), 1024) / 1024
    local size = 10 + 20 * (1.0 - fraction)
    local offset = size * 0.5
    local offset2 = offset - (size * 0.1)

    -- trace from camera to hit pos, if blocked, red cursor
    t = {}
    t.start = player:GetVar('thirdperson_viewpos') or player:GetPos()
    t.endpos = tr.HitPos + tr.HitNormal * 5
    t.filter = player
    local tr = util.TraceLine(t)

    if tr.Fraction != 1.0 then
      surface.SetDrawColor(255, 48, 0, 255)
    else
      surface.SetDrawColor(255, 208, 64, 255)
    end

    surface.DrawLine(pos.x - offset, pos.y, pos.x - offset2, pos.y)
    surface.DrawLine(pos.x + offset, pos.y, pos.x + offset2, pos.y)
    surface.DrawLine(pos.x, pos.y - offset, pos.x, pos.y - offset2)
    surface.DrawLine(pos.x, pos.y + offset, pos.x, pos.y + offset2)
    surface.DrawLine(pos.x - 1, pos.y, pos.x + 1, pos.y)
    surface.DrawLine(pos.x, pos.y - 1, pos.x, pos.y + 1)
  end

  hook.Add('HUDPaint', 'cw.thirdperson.HUDPaint', cw.thirdperson.HUDPaint)

  --- Hides the default crosshair while third person is on; runs as a `HUDShouldDraw` hook.
  -- @param name [String Name of the HUD element]
  -- @return [Boolean `false` for `CHudCrosshair` in third person, otherwise `nil`]
  function cw.thirdperson.HUDShouldDraw(name)
    if name == 'CHudCrosshair' and LocalPlayer():GetNWInt('thirdperson') == 1 then
      return false
    end
  end

  hook.Add('HUDShouldDraw', 'cw.thirdperson.HUDShouldDraw', cw.thirdperson.HUDShouldDraw)

  --- Toggles the close-up third person camera; bound to the `chasecam_zoom` console command.
  -- @param player [Player The local player]
  -- @param command [String The console command name]
  -- @param arguments [List<String> The command arguments; unused]
  function cw.thirdperson.Zoom(player, command, arguments)
    if player:GetVar('thirdperson_zoom') == 1 then
      player:SetVar('thirdperson_zoom', 0)
    else
      player:SetVar('thirdperson_zoom', 1)
    end
  end

  concommand.Add('chasecam_zoom', cw.thirdperson.Zoom)

  -- Server
else
  --- Handles the `chasecam` console command: `1` enables third person, `0` disables it and no argument toggles it.
  -- @param player [Player The player who ran the command]
  -- @param command [String The console command name]
  -- @param arguments [List<String> The command arguments]
  -- @see cw.thirdperson.Enable
  -- @see cw.thirdperson.Disable
  function cw.thirdperson.Command(player, command, arguments)
    if !arguments[1] then
      if player:GetNWInt('thirdperson') == 1 then
        cw.thirdperson.Disable(player)
      else
        cw.thirdperson.Enable(player)
      end
    elseif arguments[1] == '1' then
      cw.thirdperson.Enable(player)
    elseif arguments[1] == '0' then
      cw.thirdperson.Disable(player)
    end
  end

  concommand.Add('chasecam', cw.thirdperson.Command)

  --- Turns third person off for a player.
  --
  -- Resets the view entity to the player and removes the camera entity. Does nothing when third
  -- person is already off.
  -- @param player [Player The player to switch to first person]
  -- @see cw.thirdperson.Enable
  function cw.thirdperson.Disable(player)
    if player:GetNWInt('thirdperson') == 0 then
      return
    end

    local entity = player:GetViewEntity()
    player:SetNWInt('thirdperson', 0)
    player:SetViewEntity(player)

    -- The view entity can already be the player again (respawn, another view override); never remove the player.
    if IsValid(entity) and entity != player then
      entity:Remove()
    end
  end

  --- Turns third person on for a player.
  --
  -- Creates an invisible `prop_dynamic` parented to the player, makes it the player's view entity
  -- and sets the `thirdperson` networked int to 1. Does nothing when third person is already on.
  -- @param player [Player The player to switch to third person]
  -- @see cw.thirdperson.Disable
  function cw.thirdperson.Enable(player)
    if player:GetNWInt('thirdperson') == 1 then
      return
    end

    local entity = ents.Create('prop_dynamic')
    entity:SetModel('models/error.mdl')
    entity:SetColor(Color(0, 0, 0, 0))
    entity:DrawShadow(false)
    entity:Spawn()
    entity:SetAngles(player:GetAngles())
    entity:SetMoveType(MOVETYPE_NONE)
    entity:SetParent(player)
    entity:SetPos(player:GetPos() + Vector(0, 0, 60))
    entity:SetRenderMode(RENDERMODE_NONE)
    entity:SetSolid(SOLID_NONE)
    player:SetViewEntity(entity)
    player:SetNWInt('thirdperson', 1)
  end
end

-- Shared
--- Speeds up the player's animation playback while sprinting; runs as an `UpdateAnimation` hook.
-- @param player [Player The player being animated]
function cw.thirdperson.UpdateAnimation(player)
  if player:KeyDown(IN_SPEED) then
    player:SetPlaybackRate(1.5)
  end
end

hook.Add('UpdateAnimation', 'cw.thirdperson.UpdateAnimation', cw.thirdperson.UpdateAnimation)
