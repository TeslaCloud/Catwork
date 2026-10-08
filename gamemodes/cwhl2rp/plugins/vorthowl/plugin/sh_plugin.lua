--- Main file of the Vort Howl plugin, which lets vortigaunts howl messages to each other with `/VortHowl`; defines the
-- client-side `PlayLocalSound` Cable handler.
--
-- The handler plays the given sound next to the local player, shifted a tenth of the way towards the speaker when the
-- speaker is valid on the client.

if CLIENT then
  cable.receive('PlayLocalSound', function(sound, speaker)
    local origin = LocalPlayer():GetPos()

    -- The speaker is a NULL entity for everyone outside of their PVS.
    if IsValid(speaker) then
      origin = origin + (speaker:GetPos() - origin) * 0.1
    end

    _sound.Play(sound, origin, 75, 100, 1)
  end)
end
