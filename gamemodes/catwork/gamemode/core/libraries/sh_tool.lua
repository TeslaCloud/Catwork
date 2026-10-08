--- Defines the `cw.tool` library, which lets the framework and plugins define tools for the tool gun.
--
-- A tool made with `cw.tool:New` has the interface of a sandbox `TOOL` (console variables, selected objects, ghost
-- entities, stages) and is registered under its `UniqueID`. Setting `leftClickCMD`, `rightClickCMD` or `reloadCMD`
-- makes that action run a Catwork command.

library.New('tool', cw)

local stored = cw.tool.stored or {}
cw.tool.stored = stored

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {}
CLASS_TABLE.__index = CLASS_TABLE

--- Creates the tool's console variables.
--
-- On the client, creates a saved, user-info console variable `<mode>_<name>` for every entry of
-- `ClientConVar`. On the server, creates the `toolmode_allow_<mode>` variable checked by
-- `CLASS_TABLE:Allowed`.
function CLASS_TABLE:CreateConVars()
  local mode = self:GetMode()

  if CLIENT then
    for cvar, default in pairs(self.ClientConVar) do
      CreateClientConVar(mode..'_'..cvar, default, true, true)
    end

    return
  end

  if SERVER then
    self.AllowedCVar = CreateConVar('toolmode_allow_'..mode, 1, FCVAR_NOTIFY)
  end
end

--- Returns the value of one of the tool's console variables in this realm.
-- @param property [String Name of the variable, without the `<mode>_` prefix]
-- @return [String The value, or `''` when it does not exist]
function CLASS_TABLE:GetServerInfo(property)
  local mode = self:GetMode()

  return cvars.String(mode..'_'..property, '')
end

--- Returns the tool's client console variables with their full names, for presets in the control panel.
-- @return [Map Default values indexed by `<mode>_<name>`]
function CLASS_TABLE:BuildConVarList()
  local mode = self:GetMode()
  local convars = {}

  for k, v in pairs(self.ClientConVar) do convars[mode..'_'..k] = v end

  return convars
end

--- Returns the value of one of the owner's client console variables for this tool.
-- @param property [String Name of the variable, as a key of `ClientConVar`]
-- @return [String The value]
function CLASS_TABLE:GetClientInfo(property)
  local mode = self:GetMode()
  return self:GetOwner():GetInfo(mode..'_'..property)
end

--- Returns the value of one of the owner's client console variables for this tool as a number.
-- @param property [String Name of the variable, as a key of `ClientConVar`]
-- @param default=0 [Number Value returned when the variable is not a number]
-- @return [Number The value]
function CLASS_TABLE:GetClientNumber(property, default)
  default = default or 0
  local mode = self:GetMode()
  return self:GetOwner():GetInfoNum(mode..'_'..property, default)
end

--- Returns whether the tool may be used.
-- @return [Boolean Always `true` on the client; the `toolmode_allow_<mode>` variable on the server]
function CLASS_TABLE:Allowed()
  if CLIENT then return true end

  return self.AllowedCVar:GetBool()
end

--- Called when the tool is initialized; does nothing by default.
function CLASS_TABLE:Init()	end

--- Returns the tool's mode, its unique ID.
-- @return [String The mode]
function CLASS_TABLE:GetMode() 			return self.Mode end
--- Returns the tool gun weapon table using this tool.
-- @return [Weapon The tool gun]
function CLASS_TABLE:GetSWEP() 			return self.SWEP end
--- Returns the player using the tool.
-- @return [Player The owner of the tool gun]
function CLASS_TABLE:GetOwner() return self:GetSWEP().Owner or self.Owner end
--- Returns the tool gun weapon entity.
-- @return [Weapon The tool gun entity]
function CLASS_TABLE:GetWeapon() return self:GetSWEP().Weapon or self.Weapon end

--- Called when the owner left clicks with the tool; does nothing by default.
--
-- Return `true` to fire the tool gun effect. Tools with `leftClickCMD` set get a replacement that
-- runs that command.
-- @return [Boolean Whether the click did something]
function CLASS_TABLE:LeftClick() return false end
--- Called when the owner right clicks with the tool; does nothing by default.
--
-- Return `true` to fire the tool gun effect. Tools with `rightClickCMD` set get a replacement that
-- runs that command.
-- @return [Boolean Whether the click did something]
function CLASS_TABLE:RightClick()			return false end
--- Called when the owner reloads with the tool; clears the selected objects by default.
function CLASS_TABLE:Reload()			self:ClearObjects() end
--- Called when the tool is selected; removes the ghost entity.
function CLASS_TABLE:Deploy()			self:ReleaseGhostEntity() return end
--- Called when the tool is put away; removes the ghost entity.
function CLASS_TABLE:Holster() self:ReleaseGhostEntity() return end
--- Called every frame while the tool is held; removes the ghost entity by default.
function CLASS_TABLE:Think() self:ReleaseGhostEntity() end

--- Clears the selected objects when any of them has been removed.
function CLASS_TABLE:CheckObjects()
  for k, v in pairs(self.Objects) do
    if !v.Ent:IsWorld() and !v.Ent:IsValid() then
      self:ClearObjects()
    end
  end
end

--- Sets the tool's stage to the number of selected objects.
function CLASS_TABLE:UpdateData()
  self:SetStage(self:NumObjects())
end

--- Sets the tool's stage, networked through the tool gun.
--
-- Does nothing on the client.
--
-- @param i [Number The stage]
function CLASS_TABLE:SetStage(i)
  if SERVER then
    self:GetWeapon():SetNWInt('Stage', i, true)
  end
end

--- Returns the tool's stage.
-- @return [Number The stage; `0` when not set]
function CLASS_TABLE:GetStage()
  return self:GetWeapon():GetNWInt('Stage', 0)
end

--- Returns the tool's current operation.
-- @return [Number The operation; `0` when not set]
function CLASS_TABLE:GetOperation()
  return self:GetWeapon():GetNWInt('Op', 0)
end

--- Sets the tool's current operation, networked through the tool gun.
--
-- Does nothing on the client.
--
-- @param i [Number The operation]
function CLASS_TABLE:SetOperation(i)
  if SERVER then
    self:GetWeapon():SetNWInt('Op', i, true)
  end
end

--- Clears the selected objects, removes the ghost entity and resets the stage and operation.
function CLASS_TABLE:ClearObjects()
  self:ReleaseGhostEntity()
  self.Objects = {}
  self:SetStage(0)
  self:SetOperation(0)
end

--- Returns the entity of a selected object.
-- @param i [Number Index of the object]
-- @return [Entity The entity, or `NULL` when no object has that index]
function CLASS_TABLE:GetEnt(i)
  if !self.Objects[i] then return NULL end

  return self.Objects[i].Ent
end

--- Returns the world position of a selected object.
--
-- The position is stored relative to the object's entity or physics object, so it follows the
-- entity as it moves.
-- @param i [Number Index of the object]
-- @return [Vector The world position]
function CLASS_TABLE:GetPos(i)
  if self.Objects[i].Ent:EntIndex() == 0 then
    return self.Objects[i].Pos
  else
    if self.Objects[i].Phys != nil and self.Objects[i].Phys:IsValid() then
      return self.Objects[i].Phys:LocalToWorld(self.Objects[i].Pos)
    else
      return self.Objects[i].Ent:LocalToWorld(self.Objects[i].Pos)
    end
  end
end

--- Returns the position of a selected object as stored, local to its entity unless it is the world.
-- @param i [Number Index of the object]
-- @return [Vector The stored position]
function CLASS_TABLE:GetLocalPos(i)
  return self.Objects[i].Pos
end

--- Returns the physics bone of a selected object.
-- @param i [Number Index of the object]
-- @return [Number The bone index]
function CLASS_TABLE:GetBone(i)
  return self.Objects[i].Bone
end

--- Returns the world-space hit normal of a selected object.
-- @param i [Number Index of the object]
-- @return [Vector The normal]
function CLASS_TABLE:GetNormal(i)
  if self.Objects[i].Ent:EntIndex() == 0 then
    return self.Objects[i].Normal
  else
    local norm

    if self.Objects[i].Phys != nil and self.Objects[i].Phys:IsValid() then
      norm = self.Objects[i].Phys:LocalToWorld(self.Objects[i].Normal)
    else
      norm = self.Objects[i].Ent:LocalToWorld(self.Objects[i].Normal)
    end

    return norm - self:GetPos(i)
  end
end

--- Returns the physics object of a selected object.
-- @param i [Number Index of the object]
-- @return [PhysObj The stored physics object, or the entity's own when none was stored]
function CLASS_TABLE:GetPhys(i)
  if self.Objects[i].Phys == nil then
    return self:GetEnt(i):GetPhysicsObject()
  end

  return self.Objects[i].Phys
end

--- Selects an object for the tool, storing its position and normal relative to the entity.
--
-- Usually called from `LeftClick` with the values of the trace.
--
-- ```
-- self:SetObject(self:NumObjects() + 1, trace.Entity, trace.HitPos,
--   trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone), trace.PhysicsBone, trace.HitNormal)
-- ```
--
-- @param i [Number Index of the object]
-- @param ent [Entity The entity, or the world]
-- @param pos [Vector The world position]
-- @param phys [PhysObj The physics object]
-- @param bone [Number The physics bone]
-- @param norm [Vector The hit normal]
function CLASS_TABLE:SetObject(i, ent, pos, phys, bone, norm)
  self.Objects[i] = {}
  self.Objects[i].Ent = ent
  self.Objects[i].Phys = phys
  self.Objects[i].Bone = bone
  self.Objects[i].Normal = norm

  if ent:EntIndex() == 0 then
    self.Objects[i].Phys = nil
    self.Objects[i].Pos = pos
  else
    norm = norm + pos

    if IsValid(phys) then
      self.Objects[i].Normal = self.Objects[i].Phys:WorldToLocal(norm)
      self.Objects[i].Pos = self.Objects[i].Phys:WorldToLocal(pos)
    else
      self.Objects[i].Normal = self.Objects[i].Ent:WorldToLocal(norm)
      self.Objects[i].Pos = self.Objects[i].Ent:WorldToLocal(pos)
    end
  end
end

--- Returns how many objects are selected.
-- @return [Number The number of objects; the stage on the client]
function CLASS_TABLE:NumObjects()
  if CLIENT then
    return self:GetStage()
  end

  return #self.Objects
end

--- Returns the help text shown on the tool gun HUD.
-- @return [String The tool's `HelpText`, or the `#tool.<mode>.<stage>` language phrase]
function CLASS_TABLE:GetHelpText()
  return self.HelpText or '#tool.'..cvars.String('gmod_toolmode', '')..'.'..self:GetStage()
end

--- Creates a translucent ghost entity to preview a placement.
--
-- The ghost is a client prop in multiplayer and a server prop in singleplayer; the call does
-- nothing in the other realm.
-- @param model [String Model of the ghost]
-- @param pos [Vector Position of the ghost]
-- @param angle [Angle Angles of the ghost]
function CLASS_TABLE:MakeGhostEntity(model, pos, angle)
  util.PrecacheModel(model)

  if SERVER and !game.SinglePlayer() then return end
  if CLIENT and game.SinglePlayer() then return end

  self:ReleaseGhostEntity()

  if !util.IsValidProp(model) then return end

  if CLIENT then
    self.GhostEntity = ents.CreateClientProp(model)
  else
    self.GhostEntity = ents.Create('prop_physics')
  end

  if !self.GhostEntity:IsValid() then
    self.GhostEntity = nil
    return
  end

  self.GhostEntity:SetModel(model)
  self.GhostEntity:SetPos(pos)
  self.GhostEntity:SetAngles(angle)
  self.GhostEntity:Spawn()
  self.GhostEntity:SetSolid(SOLID_VPHYSICS)
  self.GhostEntity:SetMoveType(MOVETYPE_NONE)
  self.GhostEntity:SetNotSolid(true)
  self.GhostEntity:SetRenderMode(RENDERMODE_TRANSALPHA)
  self.GhostEntity:SetColor(Color(255, 255, 255, 150))
end

--- Creates a ghost entity with the model, position and angles of an entity.
-- @param ent [Entity The entity to copy]
function CLASS_TABLE:StartGhostEntity(ent)
  if SERVER and !game.SinglePlayer() then return end
  if CLIENT and game.SinglePlayer() then return end

  self:MakeGhostEntity(ent:GetModel(), ent:GetPos(), ent:GetAngles())
end

--- Removes the tool's ghost entities.
function CLASS_TABLE:ReleaseGhostEntity()
  if self.GhostEntity then
    if !self.GhostEntity:IsValid() then self.GhostEntity = nil return end
    self.GhostEntity:Remove()
    self.GhostEntity = nil
  end

  if self.GhostEntities then
    for k, v in pairs(self.GhostEntities) do
      if v:IsValid() then v:Remove() end
      self.GhostEntities[k] = nil
    end

    self.GhostEntities = nil
  end

  if self.GhostOffset then
    for k, v in pairs(self.GhostOffset) do
      self.GhostOffset[k] = nil
    end
  end
end

--- Moves the ghost entity to where the first selected object would be placed on the owner's aim.
function CLASS_TABLE:UpdateGhostEntity()
  if self.GhostEntity == nil then return end

  if !self.GhostEntity:IsValid() then self.GhostEntity = nil return end

  local tr = util.GetPlayerTrace(self:GetOwner())
  local trace = util.TraceLine(tr)
  if !trace.Hit then return end

  local Ang1, Ang2 = self:GetNormal(1):Angle(), (trace.HitNormal * -1):Angle()
  local TargetAngle = self:GetEnt(1):AlignAngles(Ang1, Ang2)

  self.GhostEntity:SetPos(self:GetEnt(1):GetPos())
  self.GhostEntity:SetAngles(TargetAngle)

  local TranslatedPos = self.GhostEntity:LocalToWorld(self:GetLocalPos(1))
  local TargetPos = trace.HitPos + (self:GetEnt(1):GetPos() - TranslatedPos) + (trace.HitNormal)

  self.GhostEntity:SetPos(TargetPos)
end

if CLIENT then
  --- Returns whether the owner's view should be frozen while using the tool.
  -- @return [Boolean `false` by default]
  function CLASS_TABLE:FreezeMovement()
    return false
  end

  --- Called to draw the tool's HUD; does nothing by default.
  function CLASS_TABLE:DrawHUD()
  end
end

--- Registers the tool.
-- @see cw.tool:Register
function CLASS_TABLE:Register()
  return cw.tool:Register(self)
end

--- Creates a new tool object with the default fields.
--
-- Use `cw.tool:New` instead.
-- @return [Tool The new tool]
function CLASS_TABLE:Create()
  local tool = cw.core:NewMetaTable(CLASS_TABLE)

  tool.Mode				= nil
  tool.SWEP				= nil
  tool.Owner = nil
  tool.Category = 'Clockwork'
  tool.ClientConVar		= {}
  tool.ServerConVar		= {}
  tool.Objects = {}
  tool.Stage = 0
  tool.Message = 'start'
  tool.LastMessage		= 0
  tool.AllowedCVar		= 0

  return tool
end

--- Creates a new tool for the tool gun.
--
-- Set `UniqueID`, `Name`, `Category` and `ClientConVar` on it, define its callbacks and register
-- it with `CLASS_TABLE:Register`. Setting `leftClickCMD`, `rightClickCMD` or `reloadCMD` makes the
-- action run that Catwork command instead of a callback.
--
-- ```
-- local TOOL = cw.tool:New()
--
-- TOOL.UniqueID = 'static'
-- TOOL.Name = '#tool.static.name'
--
-- function TOOL:LeftClick(trace)
--   if CLIENT then return true end
--
--   plugin.Call('PlayerMakeStatic', self:GetOwner(), true)
--
--   return true
-- end
--
-- TOOL:Register()
-- ```
--
-- @return [Tool The new tool]
function cw.tool:New()
  return CLASS_TABLE:Create()
end

--- Returns every registered tool, indexed by unique ID.
--
-- The gamemode adds them to the tool gun and the spawn menu.
-- @return [Map<Tool> The tools indexed by unique ID]
function cw.tool:GetAll()
  return stored
end

--- Registers a tool so it is added to the tool gun.
--
-- Sets the tool's mode to its `UniqueID` and creates its console variables. For each of
-- `leftClickCMD`, `rightClickCMD` and `reloadCMD` that is set, replaces the matching callback with
-- one that runs the command for the owner; `leftClickFire`, `rightClickFire` and `reloadFire`
-- (default `true`) are returned on the client. Tools without a `UniqueID` are not registered and
-- an error is printed.
-- @param tool [Tool The tool]
function cw.tool:Register(tool)
  if tool.UniqueID then
    tool.Mode = tool.UniqueID
    tool:CreateConVars()

    if tool.leftClickCMD then
      if tool.leftClickFire == nil then tool.leftClickFire = true end

      function tool:LeftClick(tr)
        if CLIENT then return tool.leftClickFire end

        self:GetOwner():RunClockworkCmd(tool.leftClickCMD)
      end
    end

    if tool.rightClickCMD then
      if tool.rightClickFire == nil then tool.rightClickFire = true end

      function tool:RightClick(tr)
        if CLIENT then return tool.rightClickFire end

        self:GetOwner():RunClockworkCmd(tool.rightClickCMD)
      end
    end

    if tool.reloadCMD then
      if tool.reloadFire == nil then tool.reloadFire = true end

      function tool:Reload(tr)
        if CLIENT then return tool.reloadFire end

        self:GetOwner():RunClockworkCmd(tool.reloadCMD)
      end
    end

    stored[tool.UniqueID] = tool
  else
    MsgC(
      Color(255, 100, 0, 255),
      '[CW:Tool] The '..tostring(tool.Name)..' tool does not have a UniqueID, it will not function without one!\n'
    )
  end
end
