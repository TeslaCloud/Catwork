--- Client-side hook of the Diseases plugin that applies the screen effects of the disease in the local player's
-- `diseases` net var: motion blur for fever and the lethal injections, and a greyscale screen for colour blindness.

local PLUGIN = PLUGIN
local texturizeMaterial = Material('pp/texturize/plain.png')

--- Called when the local player's motion blurs should be adjusted; applies disease screen effects.
--
-- Fever and the death injections add motion blur, and colour blindness draws the screen in
-- greyscale.
--
-- @param motionBlurs [Map Motion blur state; entries of its `blurTable` are blur amounts by name]
function PLUGIN:PlayerAdjustMotionBlurs(motionBlurs)
  if cw.client:HasInitialized() then
    local disease = cw.client:GetNetVar('diseases')

    if disease == 'fever' then
      motionBlurs.blurTable['fever'] = 0.25
    end

    if disease == 'colorblindness' then
      DrawTexturize(1, texturizeMaterial)
    end

    if disease == 'slow_deathinjection' or disease == 'fast_deathinjection' then
      motionBlurs.blurTable['injection'] = 0.1
    end
  end
end
