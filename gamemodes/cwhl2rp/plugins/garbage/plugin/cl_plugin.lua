--- Adds the Garbage plugin's `garbage_respawn_delay`, `garbage_pickup_time` and `garbage_item_percentage` config keys
-- to the client's system config menu.

config.AddToSystem('#Garbage_RespawnDelay', 'garbage_respawn_delay', '#Garbage_RespawnDelayDesc', 0, 3600)
config.AddToSystem('#Garbage_PickupTime', 'garbage_pickup_time', '#Garbage_PickupTimeDesc', 0, 120)
config.AddToSystem('#Garbage_ItemPercentage', 'garbage_item_percentage', '#Garbage_ItemPercentageDesc', 0, 100)
