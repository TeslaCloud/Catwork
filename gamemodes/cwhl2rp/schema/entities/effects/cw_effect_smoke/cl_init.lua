--- Defines the `cw_effect_smoke` effect, a burst of large, long-lived smoke particles used as the cloud of the
-- `cw_smokegrenade` weapon.

--- Emits a burst of `32 * scale` long-lived smoke grenade particles at the effect origin.
-- @param data [CEffectData Effect data; the origin and scale (default 2) are used]
function EFFECT:Init(data)
  local particleEmitter = ParticleEmitter(data:GetOrigin())
  local scale = data:GetScale() or 2

  for i = 1, (32 * scale) do
    local startSize = math.Rand(128 * scale, 256 * scale)
    local position = Vector(math.Rand(-16, 16), math.Rand(-16, 16), math.Rand(-16, 16) + 30)
    local particle = particleEmitter:Add('particle/particle_smokegrenade', data:GetOrigin() + position)

    if particle then
      particle:SetAirResistance(math.Rand(500, 600))
      particle:SetStartAlpha(math.Rand(250, 255))
      particle:SetStartSize(startSize)
      particle:SetRollDelta(math.Rand(-0.2, 0.2))
      particle:SetEndAlpha(math.Rand(0, 64))
      particle:SetVelocity(VectorRand() * math.Rand(2000, 2200))
      particle:SetLifeTime(0)
      particle:SetLighting(0)
      particle:SetGravity(Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(16, -16)))
      particle:SetCollide(true)
      particle:SetEndSize(startSize * 2)
      particle:SetDieTime(math.random(16, 24))
      particle:SetBounce(0.5)
      particle:SetColor(math.random(220, 240), math.random(220, 240), math.random(220, 240))
      particle:SetRoll(math.Rand(-180, 180))
    end
  end

  particleEmitter:Finish()
end

--- Draws nothing; the particles render themselves.
function EFFECT:Render() end

--- Ends the effect straight away, leaving the emitted particles to live out their die time.
-- @return [Boolean Always `false`]
function EFFECT:Think()
  return false
end
