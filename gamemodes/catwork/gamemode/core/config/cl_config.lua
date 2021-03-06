--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

config.AddToSystem("#AttributeProgressionScale", "scale_attribute_progress", "#AttributeProgressionScaleDesc")
config.AddToSystem("#MessagesMustSeePlayer", "messages_must_see_player", "#MessagesMustSeePlayerDesc")
config.AddToSystem("#StartingAttributePoints", "default_attribute_points", "#StartingAttributePointsDesc")
config.AddToSystem("#ClockworkIntroEnabled", "clockwork_intro_enabled", "#ClockworkIntroEnabledDesc")
config.AddToSystem("#HealthRegenerationEnabled", "health_regeneration_enabled", "#HealthRegenerationEnabledDesc")
config.AddToSystem("#PropProtectionEnabled", "enable_prop_protection", "#PropProtectionEnabledDesc")
config.AddToSystem("#UseLocalMachineDate", "use_local_machine_date", "#UseLocalMachineDateDesc")
config.AddToSystem("#UseLocalMachineTime", "use_local_machine_time", "#UseLocalMachineTimeDesc")
config.AddToSystem("#UseKeyOpensEntityMenus", "use_opens_entity_menus", "#UseKeyOpensEntityMenusDesc")
config.AddToSystem("#ShootAfterRaiseDelay", "shoot_after_raise_time", "#ShootAfterRaiseDelayDesc")
config.AddToSystem("#UseClockworkAdminSystem", "use_own_group_system", "#UseClockworkAdminSystemDesc")
config.AddToSystem("#SavedRecognisedNames", "save_recognised_names", "#SavedRecognisedNamesDesc")
config.AddToSystem("#SaveAttributeBoosts", "save_attribute_boosts", "#SaveAttributeBoostsDesc")
config.AddToSystem("#RagdollDamageImmunityTime", "ragdoll_immunity_time", "#RagdollDamageImmunityTimeDesc")
config.AddToSystem("#AdditionalCharacterCount", "additional_characters", "#AdditionalCharacterCountDesc")
config.AddToSystem("#ClassChangingInterval", "change_class_interval", "#ClassChangingIntervalDesc", 0, 7200)
config.AddToSystem("#SprintingLowersWeapon", "sprint_lowers_weapon", "#SprintingLowersWeaponDesc")
config.AddToSystem("#WeaponRaisingSystem", "raised_weapon_system", "#WeaponRaisingSystemDesc")
config.AddToSystem("#PropKillProtection", "prop_kill_protection", "#PropKillProtectionDesc")
config.AddToSystem("#GravityGunPunt", "enable_gravgun_punt", "#GravityGunPuntDesc")
config.AddToSystem("#DefaultInventoryWeight", "default_inv_weight", "#DefaultInventoryWeightDesc")
config.AddToSystem("#DefaultInventorySpace", "default_inv_space", "#DefaultInventorySpaceDesc")
config.AddToSystem("#DataSaveInterval", "save_data_interval", "#DataSaveIntervalDesc", 0, 7200)
config.AddToSystem("#ViewPunchOnDamage", "damage_view_punch", "#ViewPunchOnDamageDesc")
config.AddToSystem("#UnrecognisedName", "unrecognised_name", "#UnrecognisedNameDesc")
config.AddToSystem("#LimbDamageSystem", "limb_damage_system", "#LimbDamageSystemDesc")
config.AddToSystem("#FallDamageScale", "scale_fall_damage", "#FallDamageScaleDesc")
config.AddToSystem("#StartingCurrency", "default_cash", "#StartingCurrencyDesc", 0, 10000)
config.AddToSystem("#ArmorAffectsChest", "armor_chest_only", "#ArmorAffectsChestDesc")
config.AddToSystem("#MinimumPhysicalDescription", "minimum_physdesc", "#MinimumPhysicalDescriptionDesc", 0, 128)
config.AddToSystem("#WoodBreaksFall", "wood_breaks_fall", "#WoodBreaksFallDesc")
config.AddToSystem("#VignetteEnabled", "enable_vignette", "#VignetteEnabledDesc")
config.AddToSystem("#HeartbeatSounds", "enable_heartbeat", "#HeartbeatSoundsDesc")
config.AddToSystem("#CrosshairEnabled", "enable_crosshair", "#CrosshairEnabledDesc")
config.AddToSystem("#FreeAiming", "use_free_aiming", "#FreeAimingDesc")
config.AddToSystem("#RecogniseSystem", "recognise_system", "#RecogniseSystemDesc")
config.AddToSystem("#CurrencyEnabled", "cash_enabled", "#CurrencyEnabledDesc")
config.AddToSystem("#DefaultPhysicalDescription", "default_physdesc", "#DefaultPhysicalDescriptionDesc")
config.AddToSystem("#ChestDamageScale", "scale_chest_dmg", "#ChestDamageScaleDesc")
config.AddToSystem("#CorpseDecayTime", "body_decay_time", "#CorpseDecayTimeDesc", 0, 7200)
config.AddToSystem("#BannedDisconnectMessage", "banned_message", "#BannedDisconnectMessageDesc")
config.AddToSystem("#WagesInterval", "wages_interval", "#WagesIntervalDesc", 0, 7200)
config.AddToSystem("#PropCostScale", "scale_prop_cost", "#PropCostScaleDesc")
config.AddToSystem("#FadeNPCCorpses", "fade_dead_npcs", "#FadeNPCCorpsesDesc")
config.AddToSystem("#CashWeight", "cash_weight", "#CashWeightDesc", 0, 100, 3)
config.AddToSystem("#CashSpace", "cash_space", "#CashSpaceDesc", 0, 100, 3)
config.AddToSystem("#HeadDamageScale", "scale_head_dmg", "#HeadDamageScaleDesc")
config.AddToSystem("#BlockInventoryBinds", "block_inv_binds", "#BlockInventoryBindsDesc")
config.AddToSystem("#LimbDamageScale", "scale_limb_dmg", "#LimbDamageScaleDesc")
config.AddToSystem("#TargetIDDelay", "target_id_delay", "#TargetIDDelayDesc")
config.AddToSystem("#HeadbobEnabled", "enable_headbob", "#HeadbobEnabledDesc")
config.AddToSystem("#ChatCommandPrefix", "command_prefix", "#ChatCommandPrefixDesc")
config.AddToSystem("#CrouchWalkSpeed", "crouched_speed", "#CrouchWalkSpeedDesc", 0, 1024)
config.AddToSystem("#MaximumChatLength", "max_chat_length", "#MaximumChatLengthDesc", 0, 1024)
config.AddToSystem("#StartingFlags", "default_flags", "#StartingFlagsDesc")
config.AddToSystem("#PlayerSpray", "disable_sprays", "#PlayerSprayDesc")
config.AddToSystem("#HintInterval", "hint_interval", "#HintIntervalDesc", 0, 7200)
config.AddToSystem("#OOCChatInterval", "ooc_interval", "#OOCChatIntervalDesc", 0, 7200)
config.AddToSystem("#LOOCChatInterval", "looc_interval", "#LOOCChatIntervalDesc", 0, 7200)
config.AddToSystem("#MinuteTime", "minute_time", "#MinuteTimeDesc", 0, 7200)
config.AddToSystem("#DoorUnlockInterval", "unlock_time", "#DoorUnlockIntervalDesc", 0, 7200)
config.AddToSystem("#VoiceChatEnabled", "voice_enabled", "#VoiceChatEnabledDesc")
config.AddToSystem("#LocalVoiceChat", "local_voice", "#LocalVoiceChatDesc")
config.AddToSystem("#TalkRadius", "talk_radius", "#TalkRadiusDesc", 0, 4096)
config.AddToSystem("#GiveHands", "give_hands", "#GiveHandsDesc")
config.AddToSystem("#CustomWeaponColor", "custom_weapon_color", "#CustomWeaponColorDesc")
config.AddToSystem("#GiveKeys", "give_keys", "#GiveKeysDesc")
config.AddToSystem("#WagesName", "wages_name", "#WagesNameDesc")
config.AddToSystem("#JumpPower", "jump_power", "#JumpPowerDesc", 0, 1024)
config.AddToSystem("#RespawnDelay", "spawn_time", "#RespawnDelayDesc", 0, 7200)
config.AddToSystem("#MaximumWalkSpeed", "walk_speed", "#MaximumWalkSpeedDesc", 0, 1024)
config.AddToSystem("#MaximumRunSpeed", "run_speed", "#MaximumRunSpeedDesc", 0, 1024)
config.AddToSystem("#DoorPrice", "door_cost", "#DoorPriceDesc")
config.AddToSystem("#DoorLockInterval", "lock_time", "#DoorLockIntervalDesc", 0, 7200)
config.AddToSystem("#MaximumOwnableDoors", "max_doors", "#MaximumOwnableDoorsDesc")
config.AddToSystem("#EnableSpaceSystem", "enable_space_system", "#EnableSpaceSystemDesc")
config.AddToSystem("#DrawIntroBars", "draw_intro_bars", "#DrawIntroBarsDesc")
config.AddToSystem("#EnableLOOCIcons", "enable_looc_icons", "#EnableLOOCIconsDesc")
config.AddToSystem("#ShowBusinessMenu", "show_business", "#ShowBusinessMenuDesc")
config.AddToSystem("#EnableChatMultiplier", "chat_multiplier", "#EnableChatMultiplierDesc")
config.AddToSystem("#SteamAPIKey", "steam_api_key", "#SteamAPIKeyDesc")
config.AddToSystem("#MapPropsPhysgrab", "enable_map_props_physgrab", "#MapPropsPhysgrabDesc")
config.AddToSystem("#EntityUseCooldown", "entity_handle_time", "#EntityUseCooldownDesc", 0, 1, 3)
config.AddToSystem("#EnableQuickRaise", "quick_raise_enabled", "#EnableQuickRaiseDesc")
config.AddToSystem("#PlayersChangeThemes", "modify_themes", "#PlayersChangeThemesDesc")
config.AddToSystem("#DefaultTheme", "default_theme", "#DefaultThemeDesc")
config.AddToSystem("Enable Mouth Move Animation", "enable_mouth_move", "Whether or not to enable mouth move animation. Set to true if your server allows voice communication, false otherwise.")
config.AddToSystem("Block Cash Commands Binds", "block_cash_binds", "Whether or not to block any cash command binds.")
config.AddToSystem("Block Fallover Binds", "block_fallover_binds", "Whether or not to block charfallover binds.");
