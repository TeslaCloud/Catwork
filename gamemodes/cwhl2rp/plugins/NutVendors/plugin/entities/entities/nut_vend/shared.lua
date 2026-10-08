--- Defines the `nut_vend` entity of the Nutscript Vending Machines plugin, an admin-spawnable vending machine with four
-- buttons that sell drinks and supplements for tokens.
--
-- The file holds both realms. On the server `ENT:Use` finds the button the player aims at with `ENT:GetNearestButton`
-- and sells `breens_water`, `smooth_breens_water`, `special_breens_water` or `citizen_supplements` from that button's
-- stock, while Combine players switch the machine on and off or, holding sprint, refill an empty button for 25 tokens.
-- On the client `ENT:Draw` draws the product labels and a glowing sprite per button, green with stock, red when empty
-- and orange when the machine is off. The active state is kept in DT bool 0 and the four stocks in DT floats 1 to 4.

AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'Vending Machine'
ENT.Author = 'Chessnut'
ENT.Category = 'HL2RP'
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.PhysgunAllowAdmin = true

local machineModel = 'models/props_interiors/vendingmachinesoda01a.mdl'

-- How far up from the machine's origin each of the four buttons sits.
local buttonHeights = { 5.3, 3.35, 1.35, -0.7 }

-- A button is aimed at when a 96 unit trace from the eyes ends within 2 units of it, and every button is within 31
-- units of the machine's origin, so nobody further away than this can be aiming at one.
local maxAimDistanceSqr = 130 * 130

--- Recomputes the world positions of the four buttons from the machine's current position and angles.
-- @param entity [Entity The vending machine]
local function UpdateButtons(entity)
  local buttons = entity.buttons or {}
  local base = entity:GetPos() + entity:GetForward() * 18 + entity:GetRight() * -24.4
  local up = entity:GetUp()

  for k, v in ipairs(buttonHeights) do
    buttons[k] = base + up * v
  end

  entity.buttons = buttons
end

--- Spawns a vending machine at the trace hit position, facing the spawning player.
--
-- The yaw is snapped to 45 degrees. If a soda machine prop already sits in the new machine's
-- bounds, `ENT:Initialize` makes the machine take over that prop's position and angles.
-- @param client [Player The player spawning the machine]
-- @param trace [Map Trace result whose `HitPos` is the spawn position]
-- @return [Entity The new vending machine]
function ENT:SpawnFunction(client, trace)
  local entity = ents.Create('nut_vend')
  entity:SetPos(trace.HitPos + Vector(0, 0, 48))

  local angles = (entity:GetPos() - client:GetPos()):Angle()
  angles.p = 0
  angles.y = math.Round(angles.y / 45) * 45 + 180
  angles.r = 0

  entity:SetAngles(angles)
  entity:Spawn()
  entity:Activate()

  return entity
end

--- Returns the index of the button the player is aiming at.
--
-- Traces 96 units from the player's eyes and picks the button within 2 units of the hit position.
-- On the server the button positions are recomputed from the entity's current position first.
-- @param client=nil [Player The player whose aim is checked; defaults to the local player on the client]
-- @return [Number Button index from 1 to 4, or `nil` when no button is aimed at]
function ENT:GetNearestButton(client)
  client = client or (CLIENT and LocalPlayer())

  if !self.buttons or !IsValid(client) then return end

  local start = client:GetShootPos()

  if start:DistToSqr(self:GetPos()) > maxAimDistanceSqr then return end

  if SERVER then
    UpdateButtons(self)
  end

  local trace = util.TraceLine({
    start = start,
    endpos = start + client:GetAimVector() * 96,
    filter = client
  })
  local hitPos = trace.HitPos

  for k, v in ipairs(self.buttons) do
    if v:DistToSqr(hitPos) <= 4 then
      return k
    end
  end
end

if SERVER then
  --- Sets up the machine's model, frozen physics, button positions, full stock and active state.
  --
  -- A soda machine prop found inside its bounds is removed, and the machine takes over its position and angles.
  function ENT:Initialize()
    self.buttons = {}

    self:SetModel(machineModel)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self:SetDTFloat(1, 10)
    self:SetDTFloat(2, 5)
    self:SetDTFloat(3, 5)
    self:SetDTFloat(4, 5)
    self:SetDTBool(0, true)

    local physObj = self:GetPhysicsObject()

    if IsValid(physObj) then
      physObj:EnableMotion(false)
      physObj:Sleep()
    end

    local mins, maxs = self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs())

    -- ents.FindInBox needs ordered corners, which a rotated machine does not have.
    OrderVectors(mins, maxs)

    for k, v in ipairs(ents.FindInBox(mins, maxs)) do
      if string.find(v:GetClass(), 'prop') and v:GetModel() == machineModel then
        self:SetPos(v:GetPos())
        self:SetAngles(v:GetAngles())
        SafeRemoveEntity(v)

        break
      end
    end

    UpdateButtons(self)
  end

  --- Handles a player pressing a button on the machine.
  --
  -- Combine toggle the machine on or off, or refill an empty button for 25 tokens while holding
  -- sprint. Other players buy the button's item (water, sparkling water, lemonade or supplements)
  -- if the machine is active, the button has stock and they can afford the price.
  function ENT:Use(activator)
    if !IsValid(activator) or !activator:IsPlayer() then return end

    activator:EmitSound('buttons/lightswitch2.wav', 55, 125)

    if (self.nextUse or 0) < CurTime() then
      self.nextUse = CurTime() + 2
    else
      return
    end

    local button = self:GetNearestButton(activator)

    if Schema:PlayerIsCombine(activator) then
      if activator:KeyDown(IN_SPEED) and button then
        if self:GetDTFloat(button) > 0 then
          cw.player:Notify(activator, L('NutVend_Full'))
          return
        end

        self:EmitSound('buttons/button5.wav')

        if !cw.player:CanAfford(activator, 25) then
          return cw.player:Notify(activator, L('NutVend_NeedTokensToRefill', 25))
        else
          cw.player:GiveCash(activator, -25, L('NutVend_CashReason_Refill'))
        end

        timer.Simple(1, function()
          if !IsValid(self) then return end

          self:SetDTFloat(button, (button == 1 and 10 or 5))
        end)

        return
      else
        self:SetDTBool(0, !self:GetDTBool(0))
        self:EmitSound('buttons/combine_button1.wav')

        return
      end
    end

    if self:GetDTBool(0) == false then
      return
    end

    if button and self:GetDTFloat(button) > 0 then
      local itemName = 'breens_water'
      local price = 5

      if button == 2 then
        itemName = 'smooth_breens_water'
        price = price + 10
      elseif button == 3 then
        itemName = 'special_breens_water'
        price = price + 15
      elseif button == 4 then
        itemName = 'citizen_supplements'
        price = price + 25
      end

      if !cw.player:CanAfford(activator, price) then
        self:EmitSound('buttons/button2.wav')
        return cw.player:Notify(activator, L('NutVend_NeedTokensToBuy', tostring(price)))
      end

      local position = self:GetPos()
      local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()
      local itemPosition = position + f * 19 + r * 4 + u * -26
      local entity = cw.entity:CreateItem(activator, item.CreateInstance(itemName), itemPosition, self:GetAngles())

      if IsValid(entity) then
        self:SetDTFloat(button, self:GetDTFloat(button) - 1)

        if self:GetDTFloat(button) < 1 then
          self:EmitSound('buttons/button6.wav')
        end

        self:EmitSound('buttons/button4.wav')

        cw.player:GiveCash(activator, -price, L('NutVend_CashReason_Purchase'))
      end
    end
  end
else
  local draw_SimpleText = draw.SimpleText
  local glowMaterial = Material('sprites/glow04_noz')

  local color_green = Color(0, 255, 0, 255)
  local color_red = Color(255, 0, 0, 255)
  local color_orange = Color(255, 125, 0, 255)
  local color_pressed = Color(255, 255, 255, 255)

  --- Computes the button positions used for drawing the button sprites.
  function ENT:Initialize()
    UpdateButtons(self)
  end

  --- Draws the machine with its product labels and a glowing sprite per button.
  --
  -- Sprites are green with stock, red when empty, orange when the machine is off, and the
  -- aimed-at button pulses.
  function ENT:Draw()
    self:DrawModel()

    local position = self:GetPos()
    local angles = self:GetAngles()
    angles:RotateAroundAxis(angles:Up(), 90)
    angles:RotateAroundAxis(angles:Forward(), 90)

    local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

    cam.Start3D2D(position + f * 17.33 + r * -19.5 + u * 5.75, angles, 0.06)
      draw_SimpleText('#NutVend_Label_Regular', 'hl2_MainText', 0, 0, color_white, 0, 0)
      draw_SimpleText('#NutVend_Label_Sparkling', 'hl2_MainText', 0, 36, color_white, 0, 0)
      draw_SimpleText('#NutVend_Label_Lemonade', 'hl2_MainText', 0, 72, color_white, 0, 0)
      draw_SimpleText('#NutVend_Label_Supplements', 'hl2_MainText', 0, 108, color_white, 0, 0)
    cam.End3D2D()

    render.SetMaterial(glowMaterial)

    -- Initialize does not always run on the client, and admins can move the machine, so recompute every frame.
    UpdateButtons(self)

    local closest = self:GetNearestButton()
    local bActive = self:GetDTBool(0) != false
    local bUsing = closest and LocalPlayer():KeyDown(IN_USE)

    for k, v in ipairs(self.buttons) do
      local color = color_green

      if bActive then
        if self:GetDTFloat(k) < 1 then
          color = color_red
        end

        if closest != k then
          color.a = color == color_red and 100 or 75
        else
          color.a = 230 + (math.sin(RealTime() * 7.5) * 25)

          if bUsing then
            color_pressed.r = math.min(color.r + 100, 255)
            color_pressed.g = math.min(color.g + 100, 255)
            color_pressed.b = math.min(color.b + 100, 255)
            color_pressed.a = color.a

            color = color_pressed
          end
        end
      else
        color = color_orange
      end

      render.DrawSprite(v, 4, 4, color)
    end
  end
end
