

if (CLIENT) then

	netstream.Hook("PlayLocalSound", function(sound, speaker)
		_sound.Play(sound, LocalPlayer():GetPos() + (speaker:GetPos() - LocalPlayer():GetPos()) * 0.1, 75, 100, 1)
	end)

end