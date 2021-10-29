--[[
	© 2016 TeslaCloud Studios.
	Please do not use anywhere else.
--]]

config.AddToSystem("Hunger Tick", "hunger_tick", "How quickly does hunger bar drain (higher = slower)", 0, 12800)
config.AddToSystem("Hunger Default Refill", "hunger_default_refill", "Default amount of hunger to be restored when player eats food (in percent).", 0, 100)
config.AddToSystem("Thirst Tick", "thirst_tick", "How quickly does thirst block the hunger bar? (higher = slower)", 0, 12800)
config.AddToSystem("Thirst Drain Scale", "thirst_drain_scale", "How quickly does thirst drain when player runs or jumps? (in percent)", 1, 200);