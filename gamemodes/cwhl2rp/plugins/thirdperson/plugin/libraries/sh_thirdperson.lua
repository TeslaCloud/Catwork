-- All credit for third person script goes to cringerpants and his/her affiliates.
-- His/her email: cringerpants@phuce.com

--- Defines the `cw.thirdperson` library, the chase camera behind the Third Person plugin.
--
-- On the server the `chasecam` console command switches a player's `thirdperson` networked int and view entity through
-- `cw.thirdperson.Enable` and `cw.thirdperson.Disable`. On the client its `CalcView` and `HUDPaint` hooks place the
-- camera behind the player and draw a crosshair at the aim point, tuned by the `chasecam_*` convars and the
-- `chasecam_zoom` command.

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

  -- Reused by the traces that run every frame.
  local traceData = {}

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
    if player:GetNWInt('thirdperson') == 1 then
      local smooth = cvSmooth:GetFloat()
      local smoothscale = cvSmoothScale:GetFloat()

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
      local back, right, up = 5, 5, 5

      if player:GetVar('thirdperson_zoom') != 1 then
        back, right, up = cvBack:GetFloat(), cvRight:GetFloat(), cvUp:GetFloat()
      end

      local start = player:GetPos() + pos

      traceData.start = start
      traceData.endpos = start + angles:Forward() * -back + angles:Right() * right + angles:Up() * up
      traceData.filter = player

      local tr = util.TraceLine(traceData)
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
    local start = player:GetShootPos()

    traceData.start = start
    traceData.endpos = start + player:GetAimVector() * 9000
    traceData.filter = player

    local tr = util.TraceLine(traceData)
    local hitPos = tr.HitPos
    local pos = hitPos:ToScreen()
    local fraction = math.min(hitPos:Distance(start), 1024) / 1024
    local size = 10 + 20 * (1.0 - fraction)
    local offset = size * 0.5
    local offset2 = offset - (size * 0.1)

    -- trace from camera to hit pos, if blocked, red cursor
    traceData.start = player:GetVar('thirdperson_viewpos') or player:GetPos()
    traceData.endpos = hitPos + tr.HitNormal * 5

    if util.TraceLine(traceData).Fraction != 1.0 then
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
  -- Seconds a player has to wait between two switches to third person through the console command.
  local enableCooldown = 0.5

  --- Handles the `chasecam` console command: `1` enables third person, `0` disables it and no argument toggles it.
  --
  -- Switching on is ignored within half a second of the previous switch on, since each one spawns a camera
  -- entity. Does nothing when run from the server console.
  -- @param player [Player The player who ran the command]
  -- @param command [String The console command name]
  -- @param arguments [List<String> The command arguments]
  -- @see cw.thirdperson.Enable
  -- @see cw.thirdperson.Disable
  function cw.thirdperson.Command(player, command, arguments)
    if !IsValid(player) then return end

    local bEnabled = player:GetNWInt('thirdperson') == 1
    local bEnable

    if !arguments[1] then
      bEnable = !bEnabled
    elseif arguments[1] == '1' then
      bEnable = true
    elseif arguments[1] == '0' then
      bEnable = false
    else
      return
    end

    if !bEnable then
      cw.thirdperson.Disable(player)
    elseif !bEnabled then
      local curTime = CurTime()

      if (player.cwNextChaseCam or 0) > curTime then return end

      player.cwNextChaseCam = curTime + enableCooldown

      cw.thirdperson.Enable(player)
    end
  end

  concommand.Add('chasecam', cw.thirdperson.Command)

  --- Turns third person off for a player.
  --
  -- Removes the camera entity and gives the view back to the player, unless something else has taken
  -- the view over since. Does nothing when third person is already off.
  -- @param player [Player The player to switch to first person]
  -- @see cw.thirdperson.Enable
  function cw.thirdperson.Disable(player)
    if player:GetNWInt('thirdperson') == 0 then
      return
    end

    local entity = player.cwChaseCam

    player.cwChaseCam = nil
    player:SetNWInt('thirdperson', 0)

    -- Only the camera made by Enable is ours to remove; the view entity may belong to something else by now.
    if !IsValid(entity) then
      player:SetViewEntity(player)

      return
    end

    if player:GetViewEntity() == entity then
      player:SetViewEntity(player)
    end

    entity:Remove()
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

    if !IsValid(entity) then return end

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

    player.cwChaseCam = entity
  end
end
