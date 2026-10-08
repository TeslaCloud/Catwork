--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--[[ We need the plugin library to add this as a module! --]]
if !plugin then
  include('catwork/gamemode/core/libraries/sh_plugin.lua')
end

library.New('outline', cw)

--- Draws a glowing outline around one or more entities this frame.
--
-- Wraps `halo.Add`, so call it every frame from the `AddEntityOutlines` hook.
--
-- ```
-- function PLUGIN:AddEntityOutlines(outlines)
--   outlines:Add(self.target, Color(255, 200, 0), 2)
-- end
-- ```
--
-- @param entity [Entity The entity, or a `List` of entities]
-- @param glowColor [Color Color of the outline]
-- @param glowSize=2 [Number Blur size of the outline]
-- @param bIgnoreZ=nil [Boolean Whether the outline is drawn through walls]
-- @see cw.outline:Fader
function cw.outline:Add(entity, glowColor, glowSize, bIgnoreZ)
  if !glowSize then glowSize = 2 end

  if type(entity) != 'table' then
    entity = { entity }
  end

  halo.Add(
    entity, glowColor, glowSize, glowSize, 1, true, bIgnoreZ
  )
end

--- Draws an outline around an entity that fades with distance and when it is out of sight.
--
-- The alpha moves smoothly towards its target and is stored on the entity as
-- `cwLastOutlineAlpha`. Call it every frame from the `AddEntityOutlines` hook.
-- @param entity [Entity The entity to outline]
-- @param glowColor [Color Color of the outline; its alpha is the strongest alpha used]
-- @param iDrawDist=nil [Number Distance at which the outline has faded out; when `nil` it does not
-- fade with distance]
-- @param bShowAnyway=nil [Boolean Whether to keep the outline when the local player cannot see the entity]
-- @param tIgnoreEnts=nil [List<Entity> Entities ignored by the line of sight check]
-- @param glowSize=2 [Number Blur size of the outline]
-- @param bIgnoreZ=nil [Boolean Whether the outline is drawn through walls]
-- @see cw.outline:Add
function cw.outline:Fader(entity, glowColor, iDrawDist, bShowAnyway, tIgnoreEnts, glowSize, bIgnoreZ)
  local fOutlineAlpha = glowColor.a

  if iDrawDist then
    local distance = cw.client:GetPos():Distance(entity:GetPos())
    fOutlineAlpha = fOutlineAlpha - ((fOutlineAlpha / iDrawDist) * math.min(distance, iDrawDist))
  end

  if !cw.player:CanSeeEntity(cw.client, entity, 0.9, tIgnoreEnts)
  and !bShowAnyway then
    fOutlineAlpha = 0
  end

  if !entity.cwLastOutlineAlpha then
    entity.cwLastOutlineAlpha = 0
  end

  entity.cwLastOutlineAlpha = math.Approach(
    entity.cwLastOutlineAlpha, fOutlineAlpha, FrameTime() * 64
  )

  if entity.cwLastOutlineAlpha > 0 then
    self:Add(
      entity, Color(glowColor.r, glowColor.g, glowColor.b, entity.cwLastOutlineAlpha),
      glowSize, bIgnoreZ
    )
  end
end

--- Called when GMod halos should be added; runs the `AddEntityOutlines` hook with `cw.outline`.
--
-- The library is registered as the `Outline` plugin module so this runs before other hooks.
function cw.outline:PreDrawHalos()
  hook.Run('AddEntityOutlines', self)
end

--[[
  Register the library as a module. We're doing this because
  we want the PreDrawHalos function to be called
  before anything else.
--]]

plugin.Add('Outline', cw.outline)
