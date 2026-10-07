
if CLIENT then
  netstream.Hook('PlayLocalSound', function(sound, speaker)
    local origin = LocalPlayer():GetPos()

    -- The speaker is a NULL entity for everyone outside of their PVS.
    if IsValid(speaker) then
      origin = origin + (speaker:GetPos() - origin) * 0.1
    end

    _sound.Play(sound, origin, 75, 100, 1)
  end)
end
