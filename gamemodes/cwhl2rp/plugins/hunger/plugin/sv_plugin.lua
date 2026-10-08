--- Registers the server-side config keys of the Hunger plugin: `hunger_tick`, `thirst_tick`, `hunger_default_refill`
-- and `thirst_drain_scale`.

config.Add('hunger_tick', 15000, true)
config.Add('thirst_tick', 10000, true)
config.Add('hunger_default_refill', 25, true)
config.Add('thirst_drain_scale', 4, true)
