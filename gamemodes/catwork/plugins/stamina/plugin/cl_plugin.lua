--- Adds the `stam_regen_scale`, `stam_drain_scale` and `breathing_volume` configs of the Stamina plugin to the system
-- config menu.

config.AddToSystem('#StaminaRegenScale', 'stam_regen_scale', '#StaminaRegenScaleDesc', 0, 3, 3)
config.AddToSystem('#StaminaDrainScale', 'stam_drain_scale', '#StaminaDrainScaleDesc', 0, 1, 3)
config.AddToSystem('#BreathingVolume', 'breathing_volume', '#BreathingVolumeDesc', 0, 100)
