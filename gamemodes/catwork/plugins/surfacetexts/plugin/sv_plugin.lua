--- Server-side functions of the Surface Texts plugin that add, remove, save and load the map's 3D texts.
--
-- `cwSurfaceTexts:AddText` stores a text and sends it to every client, and `cwSurfaceTexts:Remove` has an admin's
-- client pick the text under the crosshair, which the `cw3DText_Remove` netstream then deletes. The texts are saved
-- per map in the `plugins/3dtexts` schema data.
--
-- Backported from the [Flux](https://github.com/TeslaCloud/flux-ce) project.

--- Saves the surface texts and the ID counter to the schema data for the current map.
function cwSurfaceTexts:Save()
  cw.core:SaveSchemaData('plugins/3dtexts/'..game.GetMap(), { self.stored, self.count })
end

--- Loads the current map's surface texts and ID counter from the schema data.
function cwSurfaceTexts:Load()
  local loaded = cw.core:RestoreSchemaData('plugins/3dtexts/'..game.GetMap(), {})

  self.stored = loaded[1] or {}
  self.count = loaded[2] or 0
end

--- Adds a surface text under a new ID, saves the list and sends the text to every client.
--
-- Does nothing when any of `text`, `pos`, `angle`, `style` or `scale` is missing.
--
-- ```
-- cwSurfaceTexts:AddText({
--   text = 'Nexus',
--   style = 1,
--   color = Color('#FFFFFF'),
--   extraColor = Color('#FF0000'),
--   angle = angle,
--   pos = trace.HitPos,
--   normal = trace.HitNormal,
--   scale = 1
-- })
-- ```
--
-- @param data [Map The text: `text`, `pos` (Vector), `normal` (Vector), `angle` (Angle), `style` (1-6),
-- `scale`, `color`, `extraColor` (the box color) and an optional `fadeOffset`]
function cwSurfaceTexts:AddText(data)
  if !data or !data.text or !data.pos or !data.angle or !data.style or !data.scale then return end

  self.count = (self.count or 0) + 1

  self.stored[self.count] = data

  self:Save()

  netstream.Start(nil, 'cw3DText_Add', self.count, data)
end

--- Removes the surface text an admin is looking at.
--
-- Asks the player's client to find the text under their crosshair with `cwSurfaceTexts:RemoveAtTrace`,
-- which sends it back for removal. Does nothing for non-admins.
--
-- @param player [Player The admin removing the text]
function cwSurfaceTexts:Remove(player)
  if player:IsAdmin() then
    netstream.Start(player, 'cw3DText_Calculate', true)
  end
end

netstream.Hook('cw3DText_Remove', function(player, idx)
  if player:IsAdmin() then
    cwSurfaceTexts.stored[idx] = nil
    cwSurfaceTexts:Save()

    netstream.Start(nil, 'cw3DText_Remove', idx)

    cw.player:Notify(player, L('SurfaceTexts_Removed'))
  end
end)
