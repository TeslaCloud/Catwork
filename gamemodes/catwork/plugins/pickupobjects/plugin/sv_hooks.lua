--- Server-side hooks of the Pickup Objects plugin that handle picking up, throwing and dropping entities with the
-- hands.
--
-- `KeyPress` maps secondary attack, primary attack and reload to pickup, throw and drop, and `CanHandsPickupEntity`
-- decides what can be carried from its mass and the player's strength. Other hooks protect dragged ragdolls, pause
-- their unragdoll timer and apply the `take_physcannon` config.

--- Called when a player's character has unloaded; drops whatever the player was holding.
-- @param player [Player The player whose character unloaded]
function cwPickupObjects:PlayerCharacterUnloaded(player)
  self:ForceDropEntity(player)
end

--- Called to get the entity a player is holding; returns the entity picked up with the hands.
-- @param player [Player The player to check]
-- @return [Entity The held entity, or `nil` when the player holds nothing]
function cwPickupObjects:PlayerGetHoldingEntity(player)
  if IsValid(player.cwHoldingEnt) then
    return player.cwHoldingEnt
  end
end

--- Called when a player attempts to punch; returns `false` while the player holds an entity or for a
-- second after they dropped one.
-- @param player [Player The punching player]
-- @return [Boolean `false` to block the punch]
function cwPickupObjects:PlayerCanThrowPunch(player)
  if IsValid(player.cwHoldingEnt) or (player.nextPunchTime
  and player.nextPunchTime >= CurTime()) then
    return false
  end
end

--- Called when a player's weapons are given; removes the gravity gun from the spawn weapons when the
-- `take_physcannon` config is on.
-- @param player [Player The player receiving weapons]
function cwPickupObjects:PlayerGiveWeapons(player)
  if config.Get('take_physcannon'):Get() then
    cw.player:TakeSpawnWeapon(player, 'weapon_physcannon')
  end
end

--- Called to get whether an entity is being held; returns `true` for a non-player entity held with the
-- hands.
-- @param entity [Entity The entity to check]
-- @return [Boolean `true` when the entity is held, otherwise `nil`]
function cwPickupObjects:GetEntityBeingHeld(entity)
  if IsValid(entity.cwHoldingGrab) and !entity:IsPlayer() then
    return true
  end
end

--- Called when a config value changes; takes the gravity gun from, or gives it back to, every player
-- when `take_physcannon` changes.
-- @param key [String The config key]
-- @param data [Map The config's data table]
-- @param previousValue [Any The old value]
-- @param newValue [Any The new value]
function cwPickupObjects:ClockworkConfigChanged(key, data, previousValue, newValue)
  if key == 'take_physcannon' then
    for k, v in ipairs(_player.GetAll()) do
      if newValue then
        cw.player:TakeSpawnWeapon(v, 'weapon_physcannon')
      else
        cw.player:GiveSpawnWeapon(v, 'weapon_physcannon')
      end
    end
  end
end

--- Called when a player's ragdoll is about to take damage; protects dragged ragdolls.
--
-- A ragdoll takes no damage for a second after it is dropped, and while held it only takes explosion,
-- bullet, club and slash damage.
-- @param player [Player The ragdolled player]
-- @param ragdoll [Entity The player's ragdoll]
-- @param inflictor [Entity The entity that dealt the damage]
-- @param attacker [Entity The entity responsible for the damage]
-- @param hitGroup [Number The hit group, one of the `HITGROUP_*` enums]
-- @param damageInfo [CTakeDamageInfo The damage]
-- @return [Boolean `false` to block the damage]
function cwPickupObjects:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
  if ragdoll.cwNextTakeDmg and CurTime() < ragdoll.cwNextTakeDmg then
    return false
  elseif IsValid(ragdoll.cwHoldingGrab) then
    if !damageInfo:IsExplosionDamage() and !damageInfo:IsBulletDamage() then
      if !damageInfo:IsDamageType(DMG_CLUB) and !damageInfo:IsDamageType(DMG_SLASH) then
        return false
      end
    end
  end
end

--- Called when a player enters a vehicle; drops the vehicle if the player was holding it.
-- @param player [Player The player entering]
-- @param vehicle [Vehicle The vehicle]
-- @param class [Number The seat role]
function cwPickupObjects:PlayerEnteredVehicle(player, vehicle, class)
  if IsValid(player.cwHoldingEnt) and player.cwHoldingEnt == vehicle then
    self:ForceDropEntity(player)
  end
end

--- Called when a player attempts to get up; returns `false` while their ragdoll is dragged.
-- @param player [Player The ragdolled player]
-- @return [Boolean `false` to stop the player getting up]
function cwPickupObjects:PlayerCanGetUp(player)
  if player:GetNetVar('IsDragged') then
    return false
  end
end

--- Called every second for each player; pauses the unragdoll timer of a ragdoll that is being held and
-- keeps the `IsDragged` net var up to date.
-- @param player [Player The player being processed]
-- @param curTime [Number The current time]
function cwPickupObjects:OnePlayerSecond(player, curTime)
  if player:IsRagdolled() and cw.player:GetUnragdollTime(player) then
    local entity = player:GetRagdollEntity()

    if IsValid(entity) then
      if IsValid(entity.cwHoldingGrab) or entity:IsBeingHeld() then
        cw.player:PauseUnragdollTime(player)

        player:SetNetVar('IsDragged', true)
      elseif player:GetNetVar('IsDragged') then
        cw.player:StartUnragdollTime(player)

        player:SetNetVar('IsDragged', false)
      end
    else
      player:SetNetVar('IsDragged', false)
    end
  else
    player:SetNetVar('IsDragged', false)
  end
end

--- Called when a player presses a key; handles picking up, throwing and dropping with the hands.
--
-- With nothing held, secondary attack picks up the entity looked at within 96 units if the
-- `CanHandsPickupEntity` hook allows it, or knocks on a door. While holding, primary attack throws and
-- reload drops the entity.
-- @param player [Player The player pressing the key]
-- @param key [Number The key, one of the `IN_*` enums]
function cwPickupObjects:KeyPress(player, key)
  if player:IsUsingHands() then
    if !IsValid(player.cwHoldingEnt) then
      if key == IN_ATTACK2 then
        local trace = player:GetEyeTraceNoCursor()
        local entity = trace.Entity
        local bCanPickup = nil

        if IsValid(entity) and trace.HitPos:Distance(player:GetShootPos()) <= 96
        and !entity:IsPlayer() and !entity:IsNPC() then
          if hook.Run('CanHandsPickupEntity', player, entity, trace) then
            bCanPickup = true
          end

          local bIsDoor = cw.entity:IsDoor(entity)

          if bCanPickup and !bIsDoor and !player:InVehicle() then
            self:ForcePickup(player, entity, trace)
          elseif bIsDoor then
            local hands = player:GetActiveWeapon()

            hands:SecondaryAttack()
          end
        end
      end
    elseif key == IN_ATTACK then
      self:ForceThrowEntity(player)
    elseif key == IN_RELOAD then
      self:ForceDropEntity(player)
    end
  end
end

--- Called when a player attempts to pick up an entity with the hands.
--
-- Allows movable physics props that nobody else holds and that do not set `noHandsPickup`, up to a
-- mass of 100 plus a strength bonus of up to 100; ragdolls are allowed at any mass. Plants and garbage
-- are never allowed.
-- @param player [Player The player picking up]
-- @param entity [Entity The entity to pick up]
-- @param trace [Map The player's eye trace]
-- @return [Boolean `true` to allow the pickup, `false` to forbid it]
function cwPickupObjects:CanHandsPickupEntity(player, entity, trace)
  if entity:GetClass() == 'cw_plant' or entity:GetClass() == 'cw_garbage' then
    return false
  end

  if IsValid(entity:GetPhysicsObject()) and entity:GetSolid() == SOLID_VPHYSICS then
    if entity:GetClass() == 'prop_ragdoll'
    or entity:GetPhysicsObject():GetMass() <= 100 + cw.attributes:Fraction(player, ATB_STRENGTH, 100) then
      if entity:GetPhysicsObject():IsMoveable() and !IsValid(entity.cwHoldingGrab) then
        if !entity.noHandsPickup then
          return true
        end
      end
    end
  end
end
